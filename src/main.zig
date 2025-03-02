const std = @import("std");
const mecha = @import("mecha");
const ops = @import("op");
const mem = std.mem;
const regs = @import("reg");
const builtin = @import("builtin");

const Op = ops.Op;
const Reg = regs.Reg;
const Mode = regs.Mode;

const Instruction = struct {
    op: ops.Op,
    // todo allow dest/src from mem and immediates
    dest: regs.Reg,
    source: regs.Reg,
};

pub fn main() !void {
    // const args = std.process.args;
    // const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn(); // Get the standard input strea

    const BUF_LIMIT = 256; // 64 bytes at a time
    var buffer: [BUF_LIMIT]u8 = undefined; // Temporary buffer for reading
    var reader = stdin.reader();
    const bytes_read = try reader.read(&buffer);
    var byte: u32 = 0;

    std.debug.print("\nbytes_read: {}\n", .{bytes_read});
    // TODO: use a ring buffer
    while (byte < bytes_read) {
        // Process or print the bytes read
        const b = buffer[byte];

        // we get a byte, then destruct, then seek or iterate
        const this_instruction = dispatch(&buffer, b);
        const offset = this_instruction.offset;
        const output = this_instruction.output;

        // std.debug.print("Destinaton is in RegField: {}\n", .{is_dest});
        // std.debug.print("Operates on word: {}\n", .{w});
        std.debug.print("byte: {}\n", .{byte});
        std.debug.print("Byte: {b}\n", .{b});
        std.debug.print("Result: {}\n", .{output});
        std.debug.print("----------------------------\n\n", .{});

        // iterate
        byte += offset; // iterate to the next byte, each instruction decides
        // the offset to the next instruction
    }
}

// returns the offset to the next byte to read
fn dispatch(buf: []u8, bptr: u32) struct { offset: u8, output: Instruction } {

    // the byte itself will tell us where to seek to
    const b = buf[bptr];
    const op = ops.lookup(b);
    const is_dest: bool = (b & 0x2) > 0;
    const w: bool = (b & 0x1) > 0;

    // these fields must come from the next byte
    // const next, const newOutput = dispatch(buf, bptr + 1, output);
    const h = dispatchByte2(buf[bptr + 1], op);
    const reg0 = if (w) regs.SHORT_REGISTERS_TABLE[h.reg] else regs.LONG_REGISTERS_TABLE[h.reg];
    const reg1 = if (w) regs.SHORT_REGISTERS_TABLE[h.rm] else regs.LONG_REGISTERS_TABLE[h.rm];
    // we default to reg0 being dest
    var result = Instruction{ .op = op, .dest = reg0, .source = reg1 };

    if (!is_dest) { // then reg1 is the destination
        result.dest = reg1;
        result.source = reg0;
    }
    return .{ .offset = 2, .output = result };
}

// we can dispatch by instruction, and then return a struct with the decomp
// functions that will read the second byte

// Question: does the second byte dictate whether we need to read the third and
// fourth?
// Answer: No, the mod field does
const Byte2 = struct { mod: u8, reg: u8, rm: u8 };

// TODO: rename, this function reads the second byte
fn dispatchByte2(b: u8, op: ops.Op) Byte2 {
    if (op == Op._mov) {
        return .{ .mod = b >> 5, .reg = (b & 0b00111000) >> 3, .rm = (b & 0x3) };
    }
    return .{ .mod = b >> 5, .reg = (b & 0b00111000) >> 3, .rm = (b & 0x3) };
}

// fn movByte2(b: u8) struct { u8, std.ArrayList(Instruction) } {
//     const mod: u8 = b >> 5;
//     const reg: u8 = (b & 0b00111000) >> 3;
//     const rm: u8 = (b & 0x3);
// }

// fn movByte3(b:u8) {
// }
// pub fn load(reader: anytype, allocator: mem.Allocator) ![]const u8 {
//     var bytes: [2]u8 = undefined;
//     var res = try reader.readAll(&bytes);
//     if (res != 2) return StringError.ReadError;
//     const len = mem.readIntLittle(u16, &bytes);
//     var s = try allocator.alloc(u8, @as(usize, len));
//     res = try reader.readAll(s);
//     if (res != @as(usize, len)) return StringError.ReadError;
//     return s;
// }
// const expect = std.testing.expect;

// test "always succeeds" {
//     try expect(true);
// }
