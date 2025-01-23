const std = @import("std");

pub const byte = u8;
pub const opcode = u8;

pub const Op = enum {
    _nop,
    _mov,
    _movs,
    _cmp,
    _cmps,
    _add,
    _lea,
    _push,
    _pop,
    _notused,
    _byte2,
    _ret,
    _xor,
    _jo,
    _sbb,
    _sub,
    _ds,
    _cs,
    _es,
    _das_,
    _adc,
    _daa,
    _aaa,
    _aas,
    _das,
    _ss,
    _jno,
    _or,
    _and,
    _inc,
    _dec,
    _jb_jnae_jc,
    _jnb_jae_jnc,
    _je_jz,
    _jne_jnz,
    _jbe_jna,
    _jnbe_ja,
    _js,
    _jns,
    _jp_jpe,
    _jnp_jpo,
    _jl_jnge,
    _jnl_jge,
    _jle_jng,
    _jnle_jg,
    _test,
    _xchg,
    _cbw,
    _cwd,
    _call,
    _wait,
    _pushf,
    _popf,
    _sahf,
    _lahf,
    _stos,
    _lods,
    _scas,
    _les,
    _lds,
    _int,
    _into,
    _iret,
    _rol,
    _ror,
    _rcl,
    _rcr,
    _sal_shl,
    _shr,
    _sar,
    _aam,
    _aad,
    _xlat,
    _esc,
    _loopne_loopze,
    _loope_loopz,
    _loop,
    _jcxz,
    _in,
    _out,
    _jmp,
    _lock,
    _repne_repnz,
    _rep_repe_repz,
    _hlt,
    _cmc,
    _not,
    _neg,
    _mul,
    _imul,
    _div,
    _idiv,
    _clc,
    _stc,
    _cli,
    _sti,
    _cld,
    _std,
};

pub const Direction = enum { source, destination };
pub const ByteOrWord = enum { isbyte, isword };
pub const byte1 = struct { op: Op, direction: Direction, byte_or_word: ByteOrWord };

// look dependant types!
// pub fn foo(t: type) type {
//     var ty: type = bool;
//     if (t == bool) {
//         ty = u32;
//     } else {
//         ty = Op;
//     }
//     return ty;
// }

// const ok = foo(opcode);

// pub fn bar() ok {
//     return 2;
// }

// // the opcode is 6 bits, so max of 64 possible ops but the 6 bit encoding is not
// unique so we use the full byte to dispatch
// see table 4-13 in the 8086 1979 manual
pub const op_table = [_]Op{
    ._add, ._add, ._add, ._add, ._add, ._add,
    ._push, //06
    ._pop, // 07
    ._or,
    ._or,
    ._or,
    ._or,
    ._or, ._or, // 0D
    ._push, // 0E
    ._notused, // 0F
    ._adc,
    ._adc,
    ._adc,
    ._adc,
    ._adc,
    ._adc, // 15
    ._push,
    ._pop,
    ._sbb,
    ._sbb,
    ._sbb,
    ._sbb,
    ._sbb,
    ._sbb, // 1D
    ._push,
    ._pop,
    ._and,
    ._and,
    ._and,
    ._and,
    ._and,
    ._and, // 0x25
    ._es,
    ._daa,
    ._sub,
    ._sub,
    ._sub,
    ._sub,
    ._sub,
    ._sub,
    ._cs,
    ._das,
    ._xor,
    ._xor,
    ._xor,
    ._xor,
    ._xor,
    ._xor,
    ._ss, // 0x36
    ._aaa,
    ._cmp,
    ._cmp,
    ._cmp,
    ._cmp,
    ._cmp,
    ._cmp,
    ._ds,
    ._aas,
    ._inc,
    ._inc,
    ._inc,
    ._inc,
    ._inc,
    ._inc,
    ._inc,
    ._inc, // 0x47
    ._dec,
    ._dec,
    ._dec,
    ._dec,
    ._dec,
    ._dec,
    ._dec,
    ._dec,
    ._push,
    ._push,
    ._push,
    ._push,
    ._push,
    ._push,
    ._push,
    ._push,
    ._pop,
    ._pop,
    ._pop,
    ._pop,
    ._pop,
    ._pop,
    ._pop,
    ._pop,
    ._notused, // 0x67
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._jo, // 0x70
    ._jno,
    ._jb_jnae_jc,
    ._jnb_jae_jnc,
    ._je_jz,
    ._jne_jnz,
    ._jbe_jna,
    ._jnbe_ja,
    ._js,
    ._jns,
    ._jp_jpe,
    ._jnp_jpo,
    ._jl_jnge,
    ._jnl_jge,
    ._jle_jng,
    ._jnle_jg,
    ._byte2, // 0x80
    ._byte2, // 0x81
    ._byte2, // 0x82
    ._byte2, // 0x83
    ._test, // 0x84
    ._test,
    ._xchg,
    ._xchg,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._lea,
    ._mov,
    ._pop, // 0x8F
    ._nop,
    ._xchg,
    ._xchg,
    ._xchg,
    ._xchg,
    ._xchg,
    ._xchg,
    ._xchg,
    ._cbw,
    ._cwd,
    ._call,
    ._wait,
    ._pushf,
    ._popf,
    ._sahf,
    ._lahf,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._movs,
    ._movs,
    ._cmps,
    ._cmps,
    ._test,
    ._test,
    ._stos,
    ._stos,
    ._lods,
    ._lods,
    ._scas,
    ._scas,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._mov,
    ._notused,
    ._notused,
    ._ret,
    ._ret,
    ._les,
    ._lds,
    ._mov,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._mov,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._ret,
    ._ret,
    ._int,
    ._int,
    ._into,
    ._iret,
    ._rol,
    ._ror,
    ._rcl,
    ._rcr,
    ._sal_shl,
    ._shr,
    ._notused,
    ._sar,
    ._rol,
    ._ror,
    ._rcl,
    ._rcr,
    ._sal_shl,
    ._shr,
    ._notused,
    ._sar,
    ._rol,
    ._ror,
    ._rcl,
    ._rcr,
    ._sal_shl,
    ._shr,
    ._notused,
    ._sar,
    ._rol,
    ._ror,
    ._rcl,
    ._rcr,
    ._sal_shl,
    ._shr,
    ._notused,
    ._sar,
    ._aam,
    ._aad,
    ._notused,
    ._xlat,
    ._esc,
    ._loopne_loopze,
    ._loope_loopz,
    ._loop,
    ._jcxz,
    ._in,
    ._in,
    ._out,
    ._out,
    ._call,
    ._jmp,
    ._jmp,
    ._jmp,
    ._in,
    ._in,
    ._out,
    ._out,
    ._lock,
    ._notused,
    ._repne_repnz,
    ._rep_repe_repz,
    ._hlt,
    ._cmc,
    ._test,
    ._notused,
    ._not,
    ._neg,
    ._mul,
    ._imul,
    ._div,
    ._idiv,
    ._test,
    ._notused,
    ._not,
    ._neg,
    ._mul,
    ._imul,
    ._div,
    ._idiv,
    ._clc,
    ._stc,
    ._cli,
    ._sti,
    ._cld,
    ._std,
    ._inc,
    ._dec,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._notused,
    ._inc,
    ._dec,
    ._call,
    ._jmp,
    ._jmp,
    ._push,
    ._notused,
};

pub fn lookup(b: u8) Op {
    return op_table[b];
}

// START: remake the op table to be 256 entries, then create a sentinal to check the second byte

const expect = std.testing.expect;

test "ops lookup: mov 0b10001000" {
    try std.testing.expectEqual(Op._mov, lookup(0b10001000));
}

test "ops lookup: adc 15" {
    try std.testing.expectEqual(Op._adc, lookup(0x15));
}

test "ops lookup: sbb 0x1D" {
    try std.testing.expectEqual(Op._sbb, lookup(0x1D));
}

test "ops lookup: and 0x25" {
    try std.testing.expectEqual(Op._and, lookup(0x25));
}

test "ops lookup: ss 0x36" {
    try std.testing.expectEqual(Op._ss, lookup(0x36));
}

test "ops lookup: inc 0x47" {
    try std.testing.expectEqual(Op._inc, lookup(0x47));
}

test "ops lookup: notused 0x67" {
    try std.testing.expectEqual(Op._notused, lookup(0x67));
}

test "ops lookup: jo 0x70" {
    try std.testing.expectEqual(Op._jo, lookup(0x70));
}

test "ops lookup: notused 0x82" {
    try std.testing.expectEqual(Op._byte2, lookup(0x82));
}

test "ops lookup: test 0x84" {
    try std.testing.expectEqual(Op._test, lookup(0x84));
}

test "ops lookup: pop 0x8F" {
    try std.testing.expectEqual(Op._pop, lookup(0x8F));
}
