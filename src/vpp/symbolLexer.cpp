
// Generated from /home/tom/prog/git/hdlConvertor/grammars/symbol.g4 by ANTLR 4.7.1


#include "symbolLexer.h"


using namespace antlr4;


symbolLexer::symbolLexer(CharStream *input) : Lexer(input) {
  _interpreter = new atn::LexerATNSimulator(this, _atn, _decisionToDFA, _sharedContextCache);
}

symbolLexer::~symbolLexer() {
  delete _interpreter;
}

std::string symbolLexer::getGrammarFileName() const {
  return "symbol.g4";
}

const std::vector<std::string>& symbolLexer::getRuleNames() const {
  return _ruleNames;
}

const std::vector<std::string>& symbolLexer::getChannelNames() const {
  return _channelNames;
}

const std::vector<std::string>& symbolLexer::getModeNames() const {
  return _modeNames;
}

const std::vector<std::string>& symbolLexer::getTokenNames() const {
  return _tokenNames;
}

dfa::Vocabulary& symbolLexer::getVocabulary() const {
  return _vocabulary;
}

const std::vector<uint16_t> symbolLexer::getSerializedATN() const {
  return _serializedATN;
}

const atn::ATN& symbolLexer::getATN() const {
  return _atn;
}




// Static vars and initialization.
std::vector<dfa::DFA> symbolLexer::_decisionToDFA;
atn::PredictionContextCache symbolLexer::_sharedContextCache;

// We own the ATN which in turn owns the ATN states.
atn::ATN symbolLexer::_atn;
std::vector<uint16_t> symbolLexer::_serializedATN;

std::vector<std::string> symbolLexer::_ruleNames = {
  u8"T__0", u8"T__1", u8"T__2", u8"SYMBOL", u8"LETTER", u8"WS"
};

std::vector<std::string> symbolLexer::_channelNames = {
  "DEFAULT_TOKEN_CHANNEL", "HIDDEN"
};

std::vector<std::string> symbolLexer::_modeNames = {
  u8"DEFAULT_MODE"
};

std::vector<std::string> symbolLexer::_literalNames = {
  "", u8"'('", u8"','", u8"')'"
};

std::vector<std::string> symbolLexer::_symbolicNames = {
  "", "", "", "", u8"SYMBOL", u8"LETTER", u8"WS"
};

dfa::Vocabulary symbolLexer::_vocabulary(_literalNames, _symbolicNames);

std::vector<std::string> symbolLexer::_tokenNames;

symbolLexer::Initializer::Initializer() {
  // This code could be in a static initializer lambda, but VS doesn't allow access to private class members from there.
	for (size_t i = 0; i < _symbolicNames.size(); ++i) {
		std::string name = _vocabulary.getLiteralName(i);
		if (name.empty()) {
			name = _vocabulary.getSymbolicName(i);
		}

		if (name.empty()) {
			_tokenNames.push_back("<INVALID>");
		} else {
      _tokenNames.push_back(name);
    }
	}

  _serializedATN = {
    0x3, 0x608b, 0xa72a, 0x8133, 0xb9ed, 0x417c, 0x3be7, 0x7786, 0x5964, 
    0x2, 0x8, 0x26, 0x8, 0x1, 0x4, 0x2, 0x9, 0x2, 0x4, 0x3, 0x9, 0x3, 0x4, 
    0x4, 0x9, 0x4, 0x4, 0x5, 0x9, 0x5, 0x4, 0x6, 0x9, 0x6, 0x4, 0x7, 0x9, 
    0x7, 0x3, 0x2, 0x3, 0x2, 0x3, 0x3, 0x3, 0x3, 0x3, 0x4, 0x3, 0x4, 0x3, 
    0x5, 0x3, 0x5, 0x3, 0x5, 0x7, 0x5, 0x19, 0xa, 0x5, 0xc, 0x5, 0xe, 0x5, 
    0x1c, 0xb, 0x5, 0x3, 0x6, 0x3, 0x6, 0x3, 0x7, 0x6, 0x7, 0x21, 0xa, 0x7, 
    0xd, 0x7, 0xe, 0x7, 0x22, 0x3, 0x7, 0x3, 0x7, 0x2, 0x2, 0x8, 0x3, 0x3, 
    0x5, 0x4, 0x7, 0x5, 0x9, 0x6, 0xb, 0x7, 0xd, 0x8, 0x3, 0x2, 0x5, 0x4, 
    0x2, 0x32, 0x3b, 0x61, 0x61, 0x5, 0x2, 0x43, 0x5c, 0x61, 0x61, 0x63, 
    0x7c, 0x5, 0x2, 0xb, 0xc, 0xf, 0xf, 0x22, 0x22, 0x2, 0x28, 0x2, 0x3, 
    0x3, 0x2, 0x2, 0x2, 0x2, 0x5, 0x3, 0x2, 0x2, 0x2, 0x2, 0x7, 0x3, 0x2, 
    0x2, 0x2, 0x2, 0x9, 0x3, 0x2, 0x2, 0x2, 0x2, 0xb, 0x3, 0x2, 0x2, 0x2, 
    0x2, 0xd, 0x3, 0x2, 0x2, 0x2, 0x3, 0xf, 0x3, 0x2, 0x2, 0x2, 0x5, 0x11, 
    0x3, 0x2, 0x2, 0x2, 0x7, 0x13, 0x3, 0x2, 0x2, 0x2, 0x9, 0x15, 0x3, 0x2, 
    0x2, 0x2, 0xb, 0x1d, 0x3, 0x2, 0x2, 0x2, 0xd, 0x20, 0x3, 0x2, 0x2, 0x2, 
    0xf, 0x10, 0x7, 0x2a, 0x2, 0x2, 0x10, 0x4, 0x3, 0x2, 0x2, 0x2, 0x11, 
    0x12, 0x7, 0x2e, 0x2, 0x2, 0x12, 0x6, 0x3, 0x2, 0x2, 0x2, 0x13, 0x14, 
    0x7, 0x2b, 0x2, 0x2, 0x14, 0x8, 0x3, 0x2, 0x2, 0x2, 0x15, 0x1a, 0x5, 
    0xb, 0x6, 0x2, 0x16, 0x19, 0x5, 0xb, 0x6, 0x2, 0x17, 0x19, 0x9, 0x2, 
    0x2, 0x2, 0x18, 0x16, 0x3, 0x2, 0x2, 0x2, 0x18, 0x17, 0x3, 0x2, 0x2, 
    0x2, 0x19, 0x1c, 0x3, 0x2, 0x2, 0x2, 0x1a, 0x18, 0x3, 0x2, 0x2, 0x2, 
    0x1a, 0x1b, 0x3, 0x2, 0x2, 0x2, 0x1b, 0xa, 0x3, 0x2, 0x2, 0x2, 0x1c, 
    0x1a, 0x3, 0x2, 0x2, 0x2, 0x1d, 0x1e, 0x9, 0x3, 0x2, 0x2, 0x1e, 0xc, 
    0x3, 0x2, 0x2, 0x2, 0x1f, 0x21, 0x9, 0x4, 0x2, 0x2, 0x20, 0x1f, 0x3, 
    0x2, 0x2, 0x2, 0x21, 0x22, 0x3, 0x2, 0x2, 0x2, 0x22, 0x20, 0x3, 0x2, 
    0x2, 0x2, 0x22, 0x23, 0x3, 0x2, 0x2, 0x2, 0x23, 0x24, 0x3, 0x2, 0x2, 
    0x2, 0x24, 0x25, 0x8, 0x7, 0x2, 0x2, 0x25, 0xe, 0x3, 0x2, 0x2, 0x2, 
    0x6, 0x2, 0x18, 0x1a, 0x22, 0x3, 0x8, 0x2, 0x2, 
  };

  atn::ATNDeserializer deserializer;
  _atn = deserializer.deserialize(_serializedATN);

  size_t count = _atn.getNumberOfDecisions();
  _decisionToDFA.reserve(count);
  for (size_t i = 0; i < count; i++) { 
    _decisionToDFA.emplace_back(_atn.getDecisionState(i), i);
  }
}

symbolLexer::Initializer symbolLexer::_init;
