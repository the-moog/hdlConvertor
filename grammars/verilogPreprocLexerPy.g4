lexer grammar verilogPreprocLexerPy;

// @note: comment channels are used only in macro definitions and calls and other places
//        where comments has to be removed
channels { CH_LINE_ESCAPE, CH_LINE_COMMENT, CH_COMMENT}

@lexer::header {

from autobuild.utils.unsigned import Unsigned
from typing import TypeVar, Union
text = TypeVar('text', str, bytes) 

class ExpressionParsingMetaInfo:
    parenthesis: int = 0
    braces: int = 0
    square_braces: int = 0
    reenter_expr_on_tailing_comma: bool = False
    exit_from_parent_mode_on_lp: bool = False
    next_mode_set: bool = False
    next_mode: Unsigned = 0

    def expression_parsing_meta_info(self) -> bool:
        self.reset()
        self.exit_from_parent_mode_on_lp = False

    def no_brace_active(self) -> bool:
        return self.parenthesis == 0 and self.braces == 0 and self.square_braces == 0

    def _reset(self):
        self.parenthesis = 0
        self.braces = 0
        self.square_braces = 0
        self.reenter_expr_on_tailing_comma = False
        self.exit_from_parent_mode_on_lp = False
        self.next_mode_set = False
        self.next_mode = 0
        
    
    def reset(self, _exit_from_parent_mode_on_lp:Union[None, bool] = None,
                    _reenter_expr_on_tailing_comma:Union[None, book] = None,
                    _next_mode:Union[None, Unsigned] = None):
        self._reset()
        if _exit_from_parent_mode_on_lp is not None and _reenter_expr_on_tailing_comma is not None:
            self.reenter_expr_on_tailing_comma = _reenter_expr_on_tailing_comma
            self.exit_from_parent_mode_on_lp = _exit_from_parent_mode_on_lp
            if _next_mode is not None:
                self.next_mode_set = True
                self.next_mode = _next_mode
            else:
                self.next_mode_set = False

}

@lexer::members {

define_in_def_val:bool = False
define_param_LP_seen:bool = False  ## 0 in original code???
macro_call_LP_seen:bool = False
expr_p_meta = ExpressionParsingMetaInfo()

@staticmethod
def cut_off_line_comment(s: text):
    if "//" in s:
        s = s.split("//",1)[0]
    return s
}

fragment CRLF : '\r'? '\n';
fragment LETTER: [a-zA-Z] ;
fragment ID_FIRST: LETTER | '_';
fragment F_DIGIT: [0-9] ;
fragment F_ID : ID_FIRST (ID_FIRST | F_DIGIT)*;
fragment ANY_WS: WS | CRLF;
fragment WS_ENDING_NEW_LINE: (WS* CRLF) | EOF;
fragment F_WS: [ \t];
fragment F_LINE_ESCAPE: '\\' CRLF;

// string with escaped newlines and '"'
STR: '"' ( ('\\' ('"' | CRLF)) | ~["\r\n] )* '"';
LINE_COMMENT : '//' ~[\r\n]* ( CRLF | EOF );
COMMENT: '/*' .*? '*/';
CODE: (~('`' | '/' | '"' | '\\')
        | ( '/' ~( '/' | '*' | '`' ) )
        | ('`' '\\' '`')+ '"' // the '\"' in macro escape
        | '`' '"'
        | '`' '`'
        // [todo] `"x\"`y\"`"' is interpreted as a CODE but there is `y
        | '\\' (~[ \t\r\n])* ([ \t\r\n] | EOF) // escaped id or \"
       )+ ( '/' '`' {
#// [TODO] /" is still causing an error
assert self.getText().back() == '`'
t = self.getText()
self.setText(t.substr(0, t.size()-1))
self.pushMode(self.DIRECTIVE_MODE)
})?;

MACRO_ENTER: '`' -> pushMode(DIRECTIVE_MODE),skip;

mode DIRECTIVE_MODE;
    D_STR: STR -> type(STR);
    D_LINE_COMMENT : LINE_COMMENT -> popMode,type(LINE_COMMENT),channel(CH_LINE_COMMENT);
    D_COMMENT : COMMENT -> type(COMMENT),channel(CH_COMMENT);
    INCLUDE: 'include' F_WS+ -> popMode,pushMode(INCLUDE_MODE);
    DEFINE:  'define'  F_WS+ F_LINE_ESCAPE*
            ( ( LINE_COMMENT | COMMENT ) F_WS* F_LINE_ESCAPE*)?
            (F_WS | F_LINE_ESCAPE)* {
self.define_in_def_val = False
self.define_param_LP_seen = False
} -> popMode,pushMode(DEFINE_MODE);
    IFNDEF: 'ifndef' F_WS+ -> popMode,pushMode(IFDEF_MODE);
    IFDEF:  'ifdef'  F_WS+ -> popMode,pushMode(IFDEF_MODE);
    ELSIF:  'elsif'  F_WS+ -> popMode,pushMode(IFDEF_MODE);
    ELSE:   'else'   ANY_WS -> popMode;
    ENDIF:  'endif'  (ANY_WS | EOF ) -> popMode;
    UNDEF:  'undef'  F_WS+ -> popMode,pushMode(UNDEF_MODE);

    BEGIN_KEYWORDS:  'begin_keywords'  F_WS -> popMode,pushMode(KEYWOORDS_MODE);
    END_KEYWORDS:    'end_keywords'    CRLF -> popMode;
    PRAGMA:          'pragma'          F_WS -> popMode,pushMode(PRAGMA_MODE);
    UNDEFINEALL:     'undefineall'     WS_ENDING_NEW_LINE -> popMode;
    RESETALL:        'resetall'        WS_ENDING_NEW_LINE -> popMode;
    CELLDEFINE:      'celldefine'      WS_ENDING_NEW_LINE -> popMode;
    ENDCELLDEFINE:   'endcelldefine'   WS_ENDING_NEW_LINE -> popMode;
    TIMESCALE:       'timescale'       F_WS+ -> popMode,pushMode(TIMING_SPEC_MODE);
    DEFAULT_NETTYPE: 'default_nettype' F_WS+ -> popMode,pushMode(DEFAULT_NETTYPE_MODE);
    LINE:            'line'            F_WS+ -> popMode,pushMode(LINE_MODE) ;
    UNCONNECTED_DRIVE: 'unconnected_drive' ANY_WS+ ('pull0' | 'pull1') WS_ENDING_NEW_LINE -> popMode;
    NOUNCONNECTED_DRIVE: 'nounconnected_drive' WS_ENDING_NEW_LINE -> popMode;
    PROTECTED: 'protected' ANY_WS -> popMode,pushMode(PROTECTED_MODE);
    OTHER_MACRO_CALL_WITH_ARGS:  F_ID F_WS* '(' {
self.macro_call_LP_seen = True
self.popMode()
self.pushMode(self.MACRO_ARG_LIST_MODE)
self.pushMode(self.EXPR_MODE)
self.expr_p_meta.reset(True, True) ## on ')' return to DEFAULT_MODE
};
    OTHER_MACRO_CALL_NO_ARGS: F_ID -> popMode;


// used when parsing the id, param list of define macro
mode DEFINE_MODE;
    DM_LINE_COMMENT: LINE_COMMENT {
if self.define_param_LP_seen:
    self.skip()
else:
    ## this define will not have any more parameter or body lines
    self.setType(self.LINE_COMMENT);
    self.popMode();
};
    DM_COMMENT: COMMENT {
if self.define_in_def_val:
    self.setType(self.CODE)
else:
    self.skip()
};
    LINE_ESCAPE: F_LINE_ESCAPE -> channel(CH_LINE_ESCAPE);
    LP: '(' {
assert not self.define_param_LP_seen
self.define_param_LP_seen = True
};
    RP: ')' WS* {
if self.define_param_LP_seen:
    ## is ')' in the param list
    self.popMode()
    self.pushMode(self.DEFINE_BODY_MODE)
else:
    self.setType(self.CODE)
    self.popMode()
    self.pushMode(self.DEFINE_BODY_MODE)
};
    COMMA: ',';
    EQUAL: '=' {
## if there is ')' jump directly to DEFINE_BODY_MODE
self.expr_p_meta.reset(True, False, self.DEFINE_BODY_MODE)
    } -> pushMode(EXPR_MODE);
    DM_NEW_LINE: CRLF {
if self.define_param_LP_seen:
    self.skip()
else:
    self.setType(self.NEW_LINE)
    self.popMode()
};
    WS: F_WS+ {
if self.define_param_LP_seen:
    self.skip()
else:
    ## inside of define body
    self.popMode()
    self.pushMode(self.DEFINE_BODY_MODE)
};
    ID: F_ID;
    DN_CODE: ( ( '`' '"' ) |  ~('\\'| '\n' | '"') | ( '\\'+ ~[\n]) )+? {
## inside of define body
self.popMode()
self.pushMode(self.DEFINE_BODY_MODE)
} -> type(CODE); // .* except newline or esacped newline



mode EXPR_MODE;
    EXPR_MODE_LINE_COMMENT: LINE_COMMENT -> type(LINE_COMMENT),channel(CH_LINE_COMMENT);
    EXPR_MODE_COMMENT: COMMENT -> type(CODE);
    // everything without strings, comments, all types of parenthesis and comma
    EXPR_CODE: (~('[' | ']' | '(' | ')' | '"' | '{' | '}' | ','))+ ->type(CODE);
    EXPR_MODE_LP: '(' { self.expr_p_meta.parenthesis += 1 } -> type(CODE);
    EXPR_MODE_RP: ')' {
if self.expr_p_meta.parenthesis > 0:
    self.expr_p_meta.parenthesis -= 1
    ## parenthesis in this expression
    self.setType(self.CODE)
else:
    ## parenthesis from outside
    self.setType(self.RP)
    ## exit from this mode
    self.popMode()
    if self.expr_p_meta.exit_from_parent_mode_on_lp:
        self.popMode()
    if self.expr_p_meta.next_mode_set:
        self.pushMode(self.expr_p_meta.next_mode)
};
    EXPR_MODE_LBR: '{' { self.expr_p_meta.braces += 1 } -> type(CODE);
    EXPR_MODE_RBR: '}' {
if self.expr_p_meta.braces > 0:
    self.expr_p_meta.braces -= 1
} -> type(CODE);
    EXPR_MODE_LSQR: '[' { self.expr_p_meta.square_braces += 1 } -> type(CODE);
    EXPR_MODE_RSQR: ']' {
if self.expr_p_meta.square_braces > 0:
    self.expr_p_meta.square_braces -= 1
} -> type(CODE);
    EXPR_MODE_COMMA: ',' {
if self.expr_p_meta.no_brace_active():
    ## comma from the outside (separating arguments or parameters)
    self.setType(self.COMMA)
    if not self.expr_p_meta.reenter_expr_on_tailing_comma:
        self.popMode()
else:
    ## comma inside of expression
    self.setType(self.CODE)
};
    EXPR_MODE_STR: STR -> type(CODE);


mode DEFINE_BODY_MODE;
    DB_LINE_ESCAPE:  F_LINE_ESCAPE -> channel(CH_LINE_ESCAPE);
    DB_STR: STR ->type(CODE);
    DB_LINE_COMMENT: LINE_COMMENT -> type(LINE_COMMENT),channel(CH_LINE_COMMENT);
    DB_CODE: (
    		( '\\'+ ~[\n] )
    		| ('`' '"')
        	| ('`' '\\' '`')+ '"' // the '\"' in macro escape
        	| ~('\\'| '\n' | '"')
        )+ {
self.setText(self.cut_off_line_comment(self.getText()))
} -> type(CODE); // .* except newline or esacped newline
    NEW_LINE: CRLF -> popMode;


// used when parsing the macro argument list
mode MACRO_ARG_LIST_MODE;
    // there has to be argument list or any non id/num value behind the macro call
    MA_COMMA: ',' {
if self.macro_call_LP_seen:
    ## this is a ',' in the arg list of macro
    self.setType(self.COMMA)
    self.pushMode(self.EXPR_MODE)
    self.expr_p_meta.reset(True, True)  ## on ')' return to DEFAULT_MODE on ')', reenter new EXPR_MODE on ','
else:
    ## [note] in normal case this should not happen as arguments should have be processed in EXPR_MODE and
    ##         ')' in text should cause exit also from this mode
    ## this macro has not a argument and this ',' is behind it
    self.setType(self.CODE)
    self.popMode()
};
    MA_RP: ')' {
if self.macro_call_LP_seen:
    ## this is a last ')' which is closing the argument list
    self.setType(self.RP)
    self.popMode()  ## back to default mode
    self.macro_call_LP_seen = False
else:
    assert False, "This ')' is a part of code and not preprocessor code and should not be processed in  MACRO_ARG_LIST_MODE"
};
    MA_CODE: (STR | ~[,()"] )+? {
## string or non parenthesis
## this code does not bellongs to a MACRO_ARG and it is part of code behind the macro call
self.popMode()
} -> type(CODE);

mode IFDEF_MODE;
    NUM: F_DIGIT+;
    IFDEF_MODE_ID : F_ID -> type(ID),popMode;

// `undef arguments processing
mode UNDEF_MODE;
    UNDEF_MODE_ID: F_ID -> type(ID);
    UNDEF_MODE_WS: F_WS -> type(WS),popMode;
    UNDEF_NEW_LINE : CRLF -> type(NEW_LINE),popMode;

mode DEFAULT_NETTYPE_MODE;
    WIRE : 'wire';
    TRI : 'tri';
    TRI0 : 'tri0';
    TRI1 : 'tri1';
    WAND : 'wand';
    TRIAND : 'triand';
    WOR : 'wor';
    TRIOR : 'trior';
    TRIREG : 'trireg';
    UWIRE : 'uwire';
    NONE : 'none';
    DEFAULT_NETTYPE_NEW_LINE : CRLF ->type(NEW_LINE),popMode;

// arguments of `line processing
mode LINE_MODE;
    LINE_MODE_NUM: F_DIGIT+ -> type(NUM);
    LINE_MODE_STR: STR ->type(STR);
    LINE_MODE_WS: F_WS ->skip;
    LINE_MODE_NEW_LINE: CRLF ->type(NEW_LINE),popMode;
    LINE_MODE_LINE_COMMENT: LINE_COMMENT -> type(LINE_COMMENT),channel(CH_LINE_COMMENT),popMode;
    LINE_MODE_COMMENT: COMMENT -> type(CODE);

mode TIMING_SPEC_MODE;
    Time_Identifier:
       F_DIGIT+ ' '* [munpf]? 's'
    ;
    TIMING_SPEC_MODE_SLASH : '/';
    TIMING_SPEC_MODE_WS : WS->skip;
    TIMING_SPEC_MODE_NEW_LINE : CRLF ->type(NEW_LINE),popMode;
    TIMING_SPEC_MODE_LINE_COMMENT: LINE_COMMENT -> type(LINE_COMMENT),channel(CH_LINE_COMMENT),popMode;
    TIMING_SPEC_MODE_COMMENT: COMMENT -> type(CODE);

mode KEYWOORDS_MODE;
    KEYWOORDS_MODE_STR: STR -> type(STR),popMode;
    //V18002017: '"1800-2017"' -> popMode;
    //V18002012: '"1800-2012"' -> popMode;
    //V18002009: '"1800-2009"' -> popMode;
    //V18002005: '"1800-2005"' -> popMode;
    //V13642005: '"1364-2005"' -> popMode;
    //V13642001: '"1364-2001"' -> popMode;
    //V13642001noconfig: '"1364-2001-noconfig"' -> popMode;
    //V13641995: '"1364-1995"' -> popMode;

// include argument processing
mode INCLUDE_MODE;
    INCLUDE_MODE_STR
        :  STR -> type(STR),popMode
        ;
    INCLUDE_MODE_STR_CHEVRONS
        :  '<' ( ~('\\'|'>') )* '>' -> type(STR),popMode
        ;
    INCLUDE_MODE_MACRO_ENTER: '`' -> popMode,pushMode(DIRECTIVE_MODE),skip;
    INCLUDE_MODE_WS : WS ->skip;

// pragma arguments processing
mode PRAGMA_MODE;
    PRAGMA_WS : WS+ -> skip;
    PRAGMA_NUM: F_DIGIT+ -> type(NUM);
    PRAGMA_ID : ID_FIRST (ID_FIRST | F_DIGIT)* ->type(ID);
    PRAGMA_STR: STR ->type(STR);
    PRAGMA_COMMA :  ',' ->type(COMMA);
    PRAGMA_EQUAL: '=' ->type(EQUAL);
    PRAGMA_LP: '(' -> type(LP);
    PRAGMA_RP: ')' -> type(RP);
    PRAGMA_NEW_LINE : CRLF -> type(NEW_LINE),popMode;

// protected edprotected block processing
mode PROTECTED_MODE;
    PROTECTED_WS : ANY_WS+ -> skip;
    ENDPROTECTED: '`endprotected' -> popMode;
    PROTECTED_LINE : (~[ \t\n\r])+;


