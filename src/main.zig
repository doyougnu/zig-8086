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

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("usage: zig-8086 <file>\n", .{});
        return;
    }

    const raw_data = try std.fs.cwd().readFileAlloc(allocator, args[1], 0xFFFFFFFF);
    defer allocator.free(raw_data);

    var data: parser.IStream = .{
        .buffer = raw_data,
        .iptr = 0,
    };

    const results: []parser.Instruction = try parser.parse(&data);

    for (results) |r| {
        std.debug.print("{s}\n", .{parser.showInstruction(r)});
    }
}
