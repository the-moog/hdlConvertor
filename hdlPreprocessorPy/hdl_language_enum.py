from enum import IntEnum

class HDLLanguageEnum(IntEnum):
    VHDL = 0
    VERILOG1995 = 1
    VERILOG2001 = 2
    VERILOG2001_NOCONFIG = 3
    VERILOG2005 = 4
    VERILOG = 2
    SV2005 = 5
    SV2009 = 6
    SV2012 = 7
    SV2017 = 8
    SYSTEM_VERILOG = 8
    HWT = 9

    # Added +/- functions otherwise it's very easy to generate
    # invalid int values for HDLLangauge constants without throwing
    # an exception
    # e.g.
    # HDLLanguage(-28) would generate an exception
    # HDLLanguage.VERILOG - 30 = -28  would not

    @property
    def _i(self):
        return int(self)

    def __add__(self, other):
        val = self._i + other
        return self.__class__(val)
    __radd__ = __add__

    def __sub__(self, other):
        val = self._i - other
        return self.__class__(val)

    def __rsub__(self, other):
        val = other - self._i
        return self.__class__(val)