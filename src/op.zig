const std = @import("std");

pub const byte = u8;
pub const opcode = u8;

pub const Op = enum(u8) {
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
    _CountSentinel,
};

pub const Direction = enum { source, destination };
pub const ByteOrWord = enum { isbyte, isword };

pub const Byte1 = struct {
    op: Op,
    direction: Direction,
    byte_or_word: ByteOrWord,
};

pub const OpDispatch = struct {
    op: Op,
    bytes_to_read: u8 = 0,
};

// NOTE: bytes_to_read should be a mininum but is a maximum. This encodes Table
// 4-13 but depending on the mod field we may need to read more or less bytes.
// For example, in 0x8b with mod = 00 we need to fetch 2 bytes for a direct
// memory address, but with mod = 01 we need to fetch only 1 byte for a single
// 8-bit displacement
// START: remove bytes_to_read
pub const OP_TABLE = [_]OpDispatch{
    .{ .op = ._add, .bytes_to_read = 2 },
    .{ .op = ._add, .bytes_to_read = 2 },
    .{ .op = ._add, .bytes_to_read = 2 },
    .{ .op = ._add, .bytes_to_read = 2 },
    .{ .op = ._add, .bytes_to_read = 1 },
    .{ .op = ._add, .bytes_to_read = 2 },
    .{ .op = ._push },
    .{ .op = ._pop },
    .{ .op = ._or, .bytes_to_read = 2 }, // 0x08
    .{ .op = ._or, .bytes_to_read = 2 },
    .{ .op = ._or, .bytes_to_read = 2 },
    .{ .op = ._or, .bytes_to_read = 2 },
    .{ .op = ._or, .bytes_to_read = 1 },
    .{ .op = ._or, .bytes_to_read = 2 },
    .{ .op = ._push },
    .{ .op = ._notused },
    .{ .op = ._adc, .bytes_to_read = 3 }, // 0x10
    .{ .op = ._adc, .bytes_to_read = 3 },
    .{ .op = ._adc, .bytes_to_read = 3 },
    .{ .op = ._adc, .bytes_to_read = 3 },
    .{ .op = ._adc, .bytes_to_read = 1 },
    .{ .op = ._adc, .bytes_to_read = 2 },
    .{ .op = ._push },
    .{ .op = ._pop },
    .{ .op = ._sbb, .bytes_to_read = 2 }, // 0x18
    .{ .op = ._sbb, .bytes_to_read = 2 },
    .{ .op = ._sbb, .bytes_to_read = 2 },
    .{ .op = ._sbb, .bytes_to_read = 2 },
    .{ .op = ._sbb, .bytes_to_read = 1 },
    .{ .op = ._sbb, .bytes_to_read = 2 },
    .{ .op = ._push },
    .{ .op = ._pop },
    .{ .op = ._and, .bytes_to_read = 2 }, // 0x20
    .{ .op = ._and, .bytes_to_read = 2 },
    .{ .op = ._and, .bytes_to_read = 2 },
    .{ .op = ._and, .bytes_to_read = 2 },
    .{ .op = ._and, .bytes_to_read = 1 },
    .{ .op = ._and, .bytes_to_read = 2 },
    .{ .op = ._es },
    .{ .op = ._daa },

    .{ .op = ._sub, .bytes_to_read = 2 },
    .{ .op = ._sub, .bytes_to_read = 2 },
    .{ .op = ._sub, .bytes_to_read = 2 },
    .{ .op = ._sub, .bytes_to_read = 2 },
    .{ .op = ._sub, .bytes_to_read = 1 },
    .{ .op = ._sub, .bytes_to_read = 2 },
    .{ .op = ._cs },
    .{ .op = ._das },

    .{ .op = ._xor, .bytes_to_read = 2 },
    .{ .op = ._xor, .bytes_to_read = 2 },
    .{ .op = ._xor, .bytes_to_read = 2 },
    .{ .op = ._xor, .bytes_to_read = 2 },
    .{ .op = ._xor, .bytes_to_read = 1 },
    .{ .op = ._xor, .bytes_to_read = 2 },
    .{ .op = ._ss },
    .{ .op = ._aaa },

    .{ .op = ._cmp, .bytes_to_read = 2 },
    .{ .op = ._cmp, .bytes_to_read = 2 },
    .{ .op = ._cmp, .bytes_to_read = 2 },
    .{ .op = ._cmp, .bytes_to_read = 2 },
    .{ .op = ._cmp, .bytes_to_read = 1 },
    .{ .op = ._cmp, .bytes_to_read = 2 },
    .{ .op = ._ds },
    .{ .op = ._aas },

    .{ .op = ._inc },
    .{ .op = ._inc },
    .{ .op = ._inc },
    .{ .op = ._inc },
    .{ .op = ._inc },
    .{ .op = ._inc },
    .{ .op = ._inc },
    .{ .op = ._inc },

    .{ .op = ._dec },
    .{ .op = ._dec },
    .{ .op = ._dec },
    .{ .op = ._dec },
    .{ .op = ._dec },
    .{ .op = ._dec },
    .{ .op = ._dec },
    .{ .op = ._dec },

    .{ .op = ._push },
    .{ .op = ._push },
    .{ .op = ._push },
    .{ .op = ._push },
    .{ .op = ._push },
    .{ .op = ._push },
    .{ .op = ._push },
    .{ .op = ._push },

    .{ .op = ._pop },
    .{ .op = ._pop },
    .{ .op = ._pop },
    .{ .op = ._pop },
    .{ .op = ._pop },
    .{ .op = ._pop },
    .{ .op = ._pop },
    .{ .op = ._pop },

    // 0x60–0x6F
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._notused },

    // jumps 0x70–0x7F
    .{ .op = ._jo, .bytes_to_read = 1 },
    .{ .op = ._jno, .bytes_to_read = 1 },
    .{ .op = ._jb_jnae_jc, .bytes_to_read = 1 },
    .{ .op = ._jnb_jae_jnc, .bytes_to_read = 1 },
    .{ .op = ._je_jz, .bytes_to_read = 1 },
    .{ .op = ._jne_jnz, .bytes_to_read = 1 },
    .{ .op = ._jbe_jna, .bytes_to_read = 1 },
    .{ .op = ._jnbe_ja, .bytes_to_read = 1 },
    .{ .op = ._js, .bytes_to_read = 1 },
    .{ .op = ._jns, .bytes_to_read = 1 },
    .{ .op = ._jp_jpe, .bytes_to_read = 1 },
    .{ .op = ._jnp_jpo, .bytes_to_read = 1 },
    .{ .op = ._jl_jnge, .bytes_to_read = 1 },
    .{ .op = ._jnl_jge, .bytes_to_read = 1 },
    .{ .op = ._jle_jng, .bytes_to_read = 1 },
    .{ .op = ._jnle_jg, .bytes_to_read = 1 },

    // 0x80+
    .{ .op = ._byte2, .bytes_to_read = 3 },
    .{ .op = ._byte2, .bytes_to_read = 4 },
    .{ .op = ._byte2, .bytes_to_read = 3 },
    .{ .op = ._byte2, .bytes_to_read = 3 },
    .{ .op = ._test, .bytes_to_read = 2 },
    .{ .op = ._test, .bytes_to_read = 2 },
    .{ .op = ._xchg, .bytes_to_read = 2 }, // 0x86
    .{ .op = ._xchg, .bytes_to_read = 2 }, // 0x87
    .{ .op = ._mov, .bytes_to_read = 2 }, // 0x88
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 }, // 0x8A
    .{ .op = ._mov, .bytes_to_read = 2 }, // 0x8B
    .{ .op = ._mov, .bytes_to_read = 2 }, // 0x8C
    .{ .op = ._lea, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._pop, .bytes_to_read = 2 },
    .{ .op = ._nop }, // 0x90
    .{ .op = ._xchg },
    .{ .op = ._xchg },
    .{ .op = ._xchg },
    .{ .op = ._xchg },
    .{ .op = ._xchg },
    .{ .op = ._xchg },
    .{ .op = ._xchg },

    .{ .op = ._cbw },
    .{ .op = ._cwd },
    .{ .op = ._call, .bytes_to_read = 4 },
    .{ .op = ._wait },
    .{ .op = ._pushf },
    .{ .op = ._popf },
    .{ .op = ._sahf },
    .{ .op = ._lahf },

    // MOV immediates + string ops
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._movs },
    .{ .op = ._movs },
    .{ .op = ._cmps },
    .{ .op = ._cmps },

    .{ .op = ._test, .bytes_to_read = 1 },
    .{ .op = ._test, .bytes_to_read = 2 },
    .{ .op = ._stos },
    .{ .op = ._stos },
    .{ .op = ._lods },
    .{ .op = ._lods },
    .{ .op = ._scas },
    .{ .op = ._scas },

    .{ .op = ._mov, .bytes_to_read = 1 },
    .{ .op = ._mov, .bytes_to_read = 1 },
    .{ .op = ._mov, .bytes_to_read = 1 },
    .{ .op = ._mov, .bytes_to_read = 1 },
    .{ .op = ._mov, .bytes_to_read = 1 },
    .{ .op = ._mov, .bytes_to_read = 1 },
    .{ .op = ._mov, .bytes_to_read = 1 },
    .{ .op = ._mov, .bytes_to_read = 1 },

    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 2 },

    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._ret, .bytes_to_read = 2 },
    .{ .op = ._ret },
    .{ .op = ._les, .bytes_to_read = 2 }, // 0xC4
    .{ .op = ._lds, .bytes_to_read = 2 },
    .{ .op = ._mov, .bytes_to_read = 3 },
    .{ .op = ._notused },

    .{ .op = ._mov, .bytes_to_read = 4 },
    .{ .op = ._notused },
    .{ .op = ._notused },
    .{ .op = ._ret, .bytes_to_read = 2 },
    .{ .op = ._ret },
    .{ .op = ._int },
    .{ .op = ._int, .bytes_to_read = 1 },
    .{ .op = ._into },
    .{ .op = ._iret }, // 0xCF

    .{ .op = ._byte2, .bytes_to_read = 2 },
    .{ .op = ._byte2, .bytes_to_read = 2 },
    .{ .op = ._byte2, .bytes_to_read = 2 },
    .{ .op = ._aam, .bytes_to_read = 1 },
    .{ .op = ._aad, .bytes_to_read = 1 },
    .{ .op = ._notused },
    .{ .op = ._xlat },

    .{ .op = ._esc, .bytes_to_read = 3 },
    .{ .op = ._esc, .bytes_to_read = 3 },
    .{ .op = ._esc, .bytes_to_read = 3 },
    .{ .op = ._esc, .bytes_to_read = 3 },
    .{ .op = ._esc, .bytes_to_read = 3 },
    .{ .op = ._esc, .bytes_to_read = 3 },
    .{ .op = ._esc, .bytes_to_read = 3 },
    .{ .op = ._esc, .bytes_to_read = 1 },

    .{ .op = ._loopne_loopze, .bytes_to_read = 1 },
    .{ .op = ._loope_loopz, .bytes_to_read = 1 },
    .{ .op = ._loop, .bytes_to_read = 1 },
    .{ .op = ._jcxz, .bytes_to_read = 1 },

    .{ .op = ._in, .bytes_to_read = 1 },
    .{ .op = ._in, .bytes_to_read = 1 },
    .{ .op = ._out, .bytes_to_read = 1 },
    .{ .op = ._out, .bytes_to_read = 1 },

    .{ .op = ._call, .bytes_to_read = 2 },
    .{ .op = ._jmp, .bytes_to_read = 2 },
    .{ .op = ._jmp, .bytes_to_read = 4 },
    .{ .op = ._jmp, .bytes_to_read = 1 },

    .{ .op = ._in },
    .{ .op = ._in },
    .{ .op = ._out },
    .{ .op = ._out },

    .{ .op = ._lock },
    .{ .op = ._notused },
    .{ .op = ._repne_repnz },
    .{ .op = ._rep_repe_repz },
    .{ .op = ._hlt },
    .{ .op = ._cmc },

    .{ .op = ._byte2, .bytes_to_read = 4 },
    .{ .op = ._byte2, .bytes_to_read = 3 },

    .{ .op = ._clc },
    .{ .op = ._stc },
    .{ .op = ._cli },
    .{ .op = ._sti },
    .{ .op = ._cld },
    .{ .op = ._std },

    .{ .op = ._byte2, .bytes_to_read = 3 },
    .{ .op = ._byte2, .bytes_to_read = 3 },
};

/// Convert enum → string
pub fn showOp(op: Op) []const u8 {
    const name = @tagName(op);
    return name[1..];
}

/// Lookup opcode dispatch
pub fn lookup(b: u8) OpDispatch {
    return OP_TABLE[b];
}

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

test "ops lookup: mov 0xBB" {
    try std.testing.expectEqual(Op._mov, lookup(0xBB));
}

test "ops lookup: byte2 0xD1" {
    try std.testing.expectEqual(Op._byte2, lookup(0xD1));
}

test "ops lookup: aam 0xD4" {
    try std.testing.expectEqual(Op._aam, lookup(0xD4));
}

test "ops lookup: in 0xE4" {
    try std.testing.expectEqual(Op._in, lookup(0xE4));
}
test "ops lookup: in 0xE5" {
    try std.testing.expectEqual(Op._in, lookup(0xE5));
}

test "ops lookup: out 0xE6" {
    try std.testing.expectEqual(Op._out, lookup(0xE6));
}

test "ops lookup: out 0xE7" {
    try std.testing.expectEqual(Op._out, lookup(0xE7));
}

test "ops lookup: _call 0xE8" {
    try std.testing.expectEqual(Op._call, lookup(0xE8));
}

test "ops lookup: jmp 0xE9" {
    try std.testing.expectEqual(Op._jmp, lookup(0xE9));
}

test "ops lookup: jmp 0xEA" {
    try std.testing.expectEqual(Op._jmp, lookup(0xEA));
}

test "ops lookup: _lock in 0xF0" {
    try std.testing.expectEqual(Op._lock, lookup(0xF0));
}

test "ops lookup: _cmc 0xF5" {
    try std.testing.expectEqual(Op._cmc, lookup(0xF5));
}

test "ops lookup: _std 0xFD" {
    try std.testing.expectEqual(Op._std, lookup(0xFD));
}
