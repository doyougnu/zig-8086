const std = @import("std");
const Allocator = std.mem.Allocator;

const R = @import("reg");
const Reg = R.Reg;
const op = @import("op");
const Op = op.Op;

pub const RM = u8;
pub const Mask = u8;

pub const MEMORY_MODE: u8 = 0;
pub const MEMORY_8BIT_MODE: u8 = 0b0100_0000;
pub const MEMORY_16BIT_MODE: u8 = 0b1000_0000;
pub const REG_MODE: u8 = 0b1100_0000;
pub const MOV_MOD_MASK: Mask = 0b1100_0000;
pub const MOV_RM_MASK: Mask = 0b0000_0111;
pub const MOV_REG_MASK: Mask = 0b0011_1000;

pub const NO_DISPLACEMENT: u32 = 0xFFFFFFFF;
pub const NEEDS_DISPLACEMENT: u32 = 0;
pub const PARSER_PAGE_SIZE: u32 = 4096;

const Mod = enum {
    reg_mode,
    mem_mode,
    mem8_mode,
    mem16_mode,

    pub fn mk(b: u8) ?Mod {
        return switch (b & MOV_MOD_MASK) {
            REG_MODE => .reg_mode,
            MEMORY_MODE => .mem_mode,
            MEMORY_8BIT_MODE => .mem8_mode,
            MEMORY_16BIT_MODE => .mem16_mode,
            else => null,
        };
    }

    pub fn asByte(m: Mod) u8 {
        return switch (m) {
            .reg_mode => REG_MODE,
            .mem_mode => MEMORY_MODE,
            .mem8_mode => MEMORY_8BIT_MODE,
            .mem16_mode => MEMORY_16BIT_MODE,
        };
    }
};

// AddrCalc represents an address calculation
pub const AddrCalc = struct {
    tag: u8 = 0,
    base: ?Reg = null,
    index: ?Reg = null,
    displacement: ?u32 = null,
};

// Imm wrapper
pub const Imm = u16; // could wrap for newtype, for now simple alias

pub const Addr = union(enum) {
    TReg: Reg,
    T16Imm: Imm,
    TCalc: AddrCalc,
};

// Instruction
pub const Instruction = struct {
    op: Op = Op._CountSentinel,
    dest: ?Addr,
    source: ?Addr,
};

pub const IStream = struct {
    buffer: []const u8,
    iptr: usize,

    pub fn done(self: *const IStream) bool {
        return self.iptr >= self.buffer.len;
    }

    pub fn read(self: *IStream) ?u8 {
        if (self.done()) return null;
        const result = self.buffer[self.iptr];
        self.iptr += 1;
        return result;
    }
};

// Effective address table
pub const EFF_ADDR_CALC_TABLE: [24]AddrCalc = .{
    // tag and index into the table is [MOD][R/M] (5-bits)
    // MOD == 00: memory, no displacement
    AddrCalc{ .tag = 0b0000_0000, .base = ._bx, .index = ._si, .displacement = null },
    AddrCalc{ .tag = 0b0000_0001, .base = ._bx, .index = ._di, .displacement = null },
    AddrCalc{ .tag = 0b0000_0010, .base = ._bp, .index = ._si, .displacement = null },
    AddrCalc{ .tag = 0b0000_0011, .base = ._bp, .index = ._di, .displacement = null },
    AddrCalc{ .tag = 0b0000_0100, .base = null, .index = ._si, .displacement = null },
    AddrCalc{ .tag = 0b0000_0101, .base = null, .index = ._di, .displacement = null },
    AddrCalc{ .tag = 0b0000_0110, .base = null, .index = null, .displacement = null },
    AddrCalc{ .tag = 0b0000_0111, .base = null, .index = ._bx, .displacement = null },
    // MOD == 01: 8-bit displacement
    AddrCalc{ .tag = 0b0000_1000, .base = ._bx, .index = ._si, .displacement = null },
    AddrCalc{ .tag = 0b0000_1001, .base = ._bx, .index = ._di, .displacement = null },
    AddrCalc{ .tag = 0b0000_1010, .base = ._bp, .index = ._si, .displacement = null },
    AddrCalc{ .tag = 0b0000_1011, .base = ._bp, .index = ._di, .displacement = null },
    AddrCalc{ .tag = 0b0000_1100, .base = ._si, .index = null, .displacement = null },
    AddrCalc{ .tag = 0b0000_1101, .base = ._di, .index = null, .displacement = null },
    AddrCalc{ .tag = 0b0000_1110, .base = ._bp, .index = null, .displacement = null },
    AddrCalc{ .tag = 0b0000_1111, .base = ._bx, .index = null, .displacement = null },
    // MOD == 10: 16-bit displacement
    AddrCalc{ .tag = 0b0001_0000, .base = ._bx, .index = ._si, .displacement = null },
    AddrCalc{ .tag = 0b0001_0001, .base = ._bx, .index = ._di, .displacement = null },
    AddrCalc{ .tag = 0b0001_0010, .base = ._bp, .index = ._si, .displacement = null },
    AddrCalc{ .tag = 0b0001_0011, .base = ._bp, .index = ._di, .displacement = null },
    AddrCalc{ .tag = 0b0001_0100, .base = ._si, .index = null, .displacement = null },
    AddrCalc{ .tag = 0b0001_0101, .base = ._di, .index = null, .displacement = null },
    AddrCalc{ .tag = 0b0001_0110, .base = ._bp, .index = null, .displacement = null },
    AddrCalc{ .tag = 0b0001_0111, .base = ._bx, .index = null, .displacement = null },
};

// ---------------- Show utils ----------------

pub fn showAddrCalc(ac: AddrCalc) []const u8 {
    var buf = std.heap.page_allocator.alloc(u8, 64) catch unreachable;
    var writer = std.Io.Writer.fixed(buf);
    var first: bool = false;

    writer.print("[", .{}) catch unreachable;
    if (ac.base) |b| {
        writer.print("{s}", .{R.showReg(b)}) catch unreachable;
    }

    if (ac.index) |i| {
        if (!first) writer.print(" + ", .{}) catch unreachable;
        writer.print("{s}", .{R.showReg(i)}) catch unreachable;
        first = false;
    }

    if (ac.displacement) |d| if (d > 0) {
        if (!first) writer.print(" + ", .{}) catch unreachable;
        writer.print("{d}", .{d}) catch unreachable;
    };

    writer.print("]", .{}) catch unreachable;

    return buf[0..writer.end];
}

pub fn showAddr(a: ?Addr) ?[]const u8 {
    // TODO: there must be a better way to switch on an optional than this:
    if (a) |addr| {
        return switch (addr) {
            .TReg => R.showReg(addr.TReg),
            .T16Imm => std.fmt.allocPrint(std.heap.page_allocator, "{d}", .{addr.T16Imm}) catch unreachable,
            .TCalc => showAddrCalc(addr.TCalc),
        };
    } else return null;
}

pub fn showInstruction(i: Instruction) []const u8 {
    return std.fmt.allocPrint(std.heap.page_allocator, "| op: {s} | dest: {?s} | source: {?s} |", .{ op.showOp(i.op), showAddr(i.dest), showAddr(i.source) }) catch unreachable;
}

pub fn parse(buf: *IStream) ![]Instruction {
    var results: std.ArrayList(Instruction) = .empty;
    const alloca = std.heap.page_allocator;
    defer results.deinit(alloca);

    while (_parse(buf)) |result| {
        try results.append(alloca, result);
    } else |err| {
        switch (err) {
            error.EndOfStream => {}, // all done, consume the error
            error.BadEncoding => return err,
        }
    }

    return results.toOwnedSlice(alloca);
}

fn _parse(buf: *IStream) !Instruction {
    if (buf.done()) return error.EndOfStream;
    const b: u8 = buf.read() orelse return error.BadEncoding;
    const dispatch = op.lookup(b);

    return switch (dispatch.op) {
        ._mov => handleMov(buf, b, dispatch.bytes_to_read),
        else => unreachable,
    };
}

fn handleMov(buf: *IStream, byte1: u8, toRead: u8) !Instruction {
    const reg_is_dest: bool = (byte1 & 0x2) == 0x2;
    const w: bool = (byte1 & 0x1) != 0;

    // read remaining bytes
    var bytes: [6]?u8 = .{
        null,
        null,
        null,
        null,
        null,
        null,
    };

    var i: usize = 0;
    while (i < toRead) : (i += 1) {
        bytes[i] = buf.read();
    }

    // in a mov we will always need the next byte
    const byte2 = bytes[0] orelse return error.BadEncoding;
    const mod = Mod.mk(byte2) orelse return error.BadEncoding;

    var source: ?Addr = null;
    var dest: ?Addr = null;

    // dispatch, we assum that reg_is_dest if false throughout, meaning that we
    // assum that the source is in the reg field
    switch (byte1) {
        0x88...0x8C => {
            const reg = (byte2 & MOV_REG_MASK) >> 3;

            // TODO: lets use the type system to remove these masks with a packed
            // struct newtype. That is then a witness that reg,mod,rm are in range
            // of these tables
            switch (mod) {
                .reg_mode => {
                    const rm = byte2 & MOV_RM_MASK;

                    dest = Addr{
                        .TReg = if (w)
                            R.LONG_REGISTERS_TABLE[rm]
                        else
                            R.SHORT_REGISTERS_TABLE[rm],
                    };

                    source = Addr{
                        .TReg = if (w)
                            R.LONG_REGISTERS_TABLE[reg]
                        else
                            R.SHORT_REGISTERS_TABLE[reg],
                    };
                },
                .mem_mode => {},
                .mem8_mode => {
                    // 1 mapsto 3 because we already read byte1, then create an array (so off by one)
                    const byte3: u8 = bytes[1] orelse return error.BadEncoding;
                    const rm = byte2 & MOV_RM_MASK;

                    var d: AddrCalc = EFF_ADDR_CALC_TABLE[(mod.asByte() >> 3) | rm];
                    d.displacement = byte3;
                    dest = Addr{ .TCalc = d };

                    source = Addr{
                        .TReg = if (w)
                            R.LONG_REGISTERS_TABLE[reg]
                        else
                            R.SHORT_REGISTERS_TABLE[reg],
                    };
                },
                .mem16_mode => {
                    // 1 mapsto 3 because we already read byte1, then create an array (so off by one)
                    const byte3: u8 = bytes[1] orelse return error.BadEncoding;
                    const byte4: u8 = bytes[2] orelse return error.BadEncoding;
                    const rm = byte2 & MOV_RM_MASK;

                    var d: AddrCalc = EFF_ADDR_CALC_TABLE[(mod.asByte() >> 3) | rm];
                    d.displacement = (@as(u32, byte4) << 8) | byte3;

                    dest = Addr{ .TCalc = d };

                    source = Addr{
                        .TReg = if (w)
                            R.LONG_REGISTERS_TABLE[reg]
                        else
                            R.SHORT_REGISTERS_TABLE[reg],
                    };
                },
            }
        },
        0xA0...0xA3 => {
            const byte3 = bytes[1] orelse return error.BadEncoding;
            const w2 = byte2 & 1;

            dest = Addr{
                .TReg = if (w2 != 0)
                    R.LONG_REGISTERS_TABLE[0]
                else
                    R.SHORT_REGISTERS_TABLE[0],
            };

            source = Addr{ .T16Imm = (@as(u16, byte3) << 8) | byte2 };
        },
        0xB0...0xB7 => {
            const reg = (byte2 & MOV_REG_MASK) >> 3;

            dest = Addr{ .TReg = R.SHORT_REGISTERS_TABLE[reg] };
            source = Addr{ .T16Imm = byte2 };
        },
        0xB8...0xBF => {
            const byte3 = bytes[1] orelse return error.BadEncoding;
            const reg = (byte1 & MOV_REG_MASK) >> 3;

            dest = Addr{ .TReg = R.LONG_REGISTERS_TABLE[reg] };
            source = Addr{ .T16Imm = (@as(u16, byte3) << 8) | byte2 };
        },
        0xC6 => {
            const byte3 = bytes[1] orelse return error.BadEncoding;
            const byte4 = bytes[2] orelse return error.BadEncoding;
            const byte5 = bytes[3] orelse return error.BadEncoding;
            source = Addr{ .T16Imm = byte5 };

            const rm = byte2 & MOV_RM_MASK;

            const lea_idx = mod.asByte() | rm;

            var dest_addr = EFF_ADDR_CALC_TABLE[lea_idx];
            const dest_done: u32 = (@as(u32, byte4) << 8) | byte3;
            dest_addr.displacement = dest_done;

            dest = Addr{ .TCalc = dest_addr };
        },
        else => {
            const byte3: u8 = bytes[1] orelse return error.BadEncoding;
            const byte4: u8 = bytes[2] orelse return error.BadEncoding;
            const byte5: u8 = bytes[3] orelse return error.BadEncoding;
            const byte6: u8 = bytes[4] orelse return error.BadEncoding;

            source = Addr{ .T16Imm = (@as(u16, byte6) << 8) | byte5 };

            const rm = byte2 & MOV_RM_MASK;

            const lea_idx = mod.asByte() | rm;

            var dest_addr = EFF_ADDR_CALC_TABLE[lea_idx];
            dest_addr.displacement = (@as(u32, byte4) << 8) | byte3;

            dest = Addr{ .TCalc = dest_addr };
        },
    }

    // final construction, if reg_is_dest then we must swap the source and dest
    // because we assumed that source was in the reg field
    const instr = Instruction{
        .op = ._mov,
        .dest = if (reg_is_dest) source else dest,
        .source = if (reg_is_dest) dest else source,
    };

    return instr;
}
