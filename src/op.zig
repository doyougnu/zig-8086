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

pub fn foo(t: type) type {
    var ty: type = bool;
    if (t == bool) {
        ty = u32;
    } else {
        ty = Op;
    }
    return ty;
}

const ok = foo(opcode);

pub fn bar() ok {
    return 2;
}

// the opcode is 6 bits, so max of 64 possible ops but the 6 bit encoding is not
// unique so we use the full byte to dispatch
// see table 4-13 in the 8086 1979 manual
pub const op_table = [355]Op{ ._add, ._add, ._add, ._add, ._add, ._add, ._push, ._pop, ._or, ._or, ._or, ._or, ._or, ._or, ._push, ._notused, ._adc, ._adc, ._adc, ._adc, ._adc, ._adc, ._push, ._pop, ._sbb, ._sbb, ._sbb, ._sbb, ._sbb, ._sbb, ._push, ._pop, ._and, ._and, ._and, ._and, ._and, ._and, ._es, ._daa, ._sub, ._sub, ._sub, ._sub, ._sub, ._sub, ._cs, ._das, ._xor, ._xor, ._xor, ._xor, ._xor, ._xor, ._ss, ._aaa, ._cmp, ._cmp, ._cmp, ._cmp, ._cmp, ._cmp, ._ds, ._aas, ._inc, ._inc, ._inc, ._inc, ._inc, ._inc, ._inc, ._inc, ._dec, ._dec, ._dec, ._dec, ._dec, ._dec, ._dec, ._dec, ._push, ._push, ._push, ._push, ._push, ._push, ._push, ._push, ._pop, ._pop, ._pop, ._pop, ._pop, ._pop, ._pop, ._pop, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._jo, ._jno, ._jb_jnae_jc, ._jnb_jae_jnc, ._je_jz, ._jne_jnz, ._jbe_jna, ._jnbe_ja, ._js, ._jns, ._jp_jpe, ._jnp_jpo, ._jl_jnge, ._jnl_jge, ._jle_jng, ._jnle_jg, ._add, ._or, ._adc, ._sbb, ._and, ._sub, ._xor, ._cmp, ._add, ._or, ._adc, ._sbb, ._and, ._sub, ._xor, ._cmp, ._add, ._notused, ._adc, ._sbb, ._notused, ._sub, ._notused, ._cmp, ._add, ._notused, ._adc, ._sbb, ._notused, ._sub, ._notused, ._cmp, ._test, ._test, ._xchg, ._xchg, ._mov, ._mov, ._mov, ._mov, ._mov, ._notused, ._lea, ._mov, ._notused, ._pop, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._nop, ._xchg, ._xchg, ._xchg, ._xchg, ._xchg, ._xchg, ._xchg, ._cbw, ._cwd, ._call, ._wait, ._pushf, ._popf, ._sahf, ._lahf, ._mov, ._mov, ._mov, ._mov, ._movs, ._movs, ._cmps, ._cmps, ._test, ._test, ._stos, ._stos, ._lods, ._lods, ._scas, ._scas, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._mov, ._notused, ._notused, ._ret, ._ret, ._les, ._lds, ._mov, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._mov, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._ret, ._ret, ._int, ._int, ._into, ._iret, ._rol, ._ror, ._rcl, ._rcr, ._sal_shl, ._shr, ._notused, ._sar, ._rol, ._ror, ._rcl, ._rcr, ._sal_shl, ._shr, ._notused, ._sar, ._rol, ._ror, ._rcl, ._rcr, ._sal_shl, ._shr, ._notused, ._sar, ._rol, ._ror, ._rcl, ._rcr, ._sal_shl, ._shr, ._notused, ._sar, ._aam, ._aad, ._notused, ._xlat, ._esc, ._loopne_loopze, ._loope_loopz, ._loop, ._jcxz, ._in, ._in, ._out, ._out, ._call, ._jmp, ._jmp, ._jmp, ._in, ._in, ._out, ._out, ._lock, ._notused, ._repne_repnz, ._rep_repe_repz, ._hlt, ._cmc, ._test, ._notused, ._not, ._neg, ._mul, ._imul, ._div, ._idiv, ._test, ._notused, ._not, ._neg, ._mul, ._imul, ._div, ._idiv, ._clc, ._stc, ._cli, ._sti, ._cld, ._std, ._inc, ._dec, ._notused, ._notused, ._notused, ._notused, ._notused, ._notused, ._inc, ._dec, ._call, ._jmp, ._jmp, ._push, ._notused };
