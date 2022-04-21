parser grammar verilogPreprocParserPy;

options { tokenVocab=verilogPreprocLexerPy;}

@parser::header {

from  hdl_language_enum import HDLLanguageEnum

class hdlConvertor:
    Language = HDLLanguageEnum()

}


file: text* EOF;

text:
   preprocess_directive
  | LINE_COMMENT
  | CODE
  | NEW_LINE
  | NUM
  | ID
  | STR
  | NEW_LINE
  | COMMENT
;

preprocess_directive:
    define
    | conditional
    | macro_call
    | resetall
    | undef
    | include
    | celldefine
    | endcelldefine
    | unconnected_drive
    | nounconnected_drive
    | default_nettype
    | line_directive
    | timing_spec
    | protected_block
    | {self.language_version >= hdlConvertor.Language.SV2009}? undefineall
    | {self.language_version >= hdlConvertor.Language.VERILOG2005}? (
		keywords_directive
        | endkeywords_directive
        | pragma
        )
    ;
define:
    DEFINE macro_id ( LP (define_args)? RP )? WS* replacement? (LINE_COMMENT | NEW_LINE | EOF)
;

define_args:
     { self.language_version >= hdlConvertor.Language.SV2009 }? define_args_with_def_val
 	| { self.language_version < hdlConvertor.Language.SV2009 }? define_args_basic
;

define_args_with_def_val:
	param_with_def_val ( COMMA param_with_def_val )*
;
param_with_def_val:
	var_id (EQUAL default_text?) ?
;
define_args_basic:
	var_id ( COMMA var_id )*
;

replacement: CODE+;
default_text: CODE+;


conditional:
    ifdef_directive
    | ifndef_directive
    ;

ifdef_directive:
      IFDEF cond_id group_of_lines
      ( ELSIF cond_id group_of_lines )*
      ( ELSE else_group_of_lines )?
      ENDIF
;


ifndef_directive:
      IFNDEF cond_id group_of_lines
      ( ELSIF cond_id group_of_lines )*
      ( ELSE else_group_of_lines )?
      ENDIF
;

else_group_of_lines: group_of_lines;
group_of_lines: text*;

macro_call:
	OTHER_MACRO_CALL_NO_ARGS
	| OTHER_MACRO_CALL_WITH_ARGS value? (COMMA value? )* RP
;

value: text+;

macro_id: ID;
var_id: COMMENT* ID COMMENT*;
cond_id: ID;
undef: UNDEF ID (WS | NEW_LINE | EOF);
celldefine: CELLDEFINE;
endcelldefine: ENDCELLDEFINE;
unconnected_drive: UNCONNECTED_DRIVE;
nounconnected_drive: NOUNCONNECTED_DRIVE;

default_nettype:
    DEFAULT_NETTYPE default_nettype_value
;

default_nettype_value
    : WIRE
    | TRI
    | TRI0
    | TRI1
    | WAND
    | TRIAND
    | WOR
    | TRIOR
    | TRIREG
    | UWIRE
    | NONE
    | {self.language_version >= hdlConvertor.Language.VERILOG2005}? UWIRE
    ;

line_directive:
   LINE NUM STR NUM
;

timing_spec:
   TIMESCALE Time_Identifier TIMING_SPEC_MODE_SLASH Time_Identifier
;

protected_block:
	PROTECTED PROTECTED_LINE* ENDPROTECTED
;
resetall: RESETALL;
undefineall: UNDEFINEALL;

keywords_directive:
   BEGIN_KEYWORDS version_specifier
;

version_specifier:
   STR
   //   {self.language_version >= hdlConvertor::Language::SV2017}? V18002017
   // | {self.language_version >= hdlConvertor::Language::SV2012}? V18002012
   // | {self.language_version >= hdlConvertor::Language::SV2009}? V18002009
   // | {self.language_version >= hdlConvertor::Language::SV2005}? V18002005
   // | {self.language_version >= hdlConvertor::Language::VERILOG2005}? V13642005
   // | {self.language_version >= hdlConvertor::Language::VERILOG2001}? V13642001
   // | {self.language_version >= hdlConvertor::Language::VERILOG2001_NOCONFIG }? V13642001noconfig
   // | V13641995
;

endkeywords_directive: END_KEYWORDS;
include: INCLUDE (
		 STR
	    | {self.language_version >= hdlConvertor.Language.SV2005}? macro_call
    );


pragma:
    PRAGMA pragma_name ( pragma_expression ( COMMA pragma_expression )* )? (NEW_LINE | EOF)
;

pragma_name : ID;
pragma_expression:
    pragma_keyword
    | pragma_keyword EQUAL pragma_value
    | pragma_value
;

pragma_value :
    LP pragma_expression ( COMMA pragma_expression )* RP
    | NUM
    | STR
    | ID
;

pragma_keyword : ID;

