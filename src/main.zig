const std = @import("std");
const ops = @import("op");
const regs = @import("reg");
const parser = @import("parser");
const mem = std.mem;
const ArrayList = std.ArrayList;
const builtin = @import("builtin");

const Op = ops.Op;
const Reg = regs.Reg;
const Mode = regs.Mode;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    if (args.len < 2) {
        std.debug.print("usage: zig-8086 <file>\n", .{});
        return;
    }

    // START: onto OpCode patterns
    const raw_data = try std.Io.Dir.cwd().readFileAlloc(io, args[1], gpa, .limited(0xFFFFFFFF));
    defer gpa.free(raw_data);

    var data: parser.IStream = .{
        .buffer = raw_data,
        .iptr = 0,
    };

    const results: []parser.Instruction = try parser.parse(&data);

    for (results) |r| {
        std.debug.print("{s}\n", .{parser.showInstruction(r)});
    }
}
