const std = @import("std");

pub const Mode = enum { _memoryMode, _8bit, _16bit, _registerMode };

pub const MODE_TABLE = [_]Mode{
    ._memoryMode,
    ._8bit,
    ._16bit,
    ._registerMode,
};

// we'll try a flat heirarchy first
pub const Reg = enum {
    _al,
    _cl,
    _dl,
    _bl,
    _ah,
    _ch,
    _dh,
    _bh,
    _ax, // long regs
    _cx,
    _dx,
    _bx,
    _sp,
    _bp,
    _si,
    _di,
};

pub const SHORT_REGISTERS_TABLE = [_]Reg{ ._al, ._cl, ._dl, ._bl, ._ah, ._ch, ._dh, ._bh };

pub const LONG_REGISTERS_TABLE = [_]Reg{
    ._ax,
    ._cx,
    ._dx,
    ._bx,
    ._sp,
    ._bp,
    ._si,
    ._di,
};
