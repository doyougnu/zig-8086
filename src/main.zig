const std = @import("std");
const mecha = @import("mecha");
const ops = @import("op");
const mem = std.mem;

// pub fn parse

pub fn main() !void {
    // const args = std.process.args;
    const stdin = std.io.getStdIn(); // Get the standard input strea
    // const stdout = std.io.getStdOut().writer();

    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)

    // if (args.len < 2) {
    //     try stdout.print("Usage: {} <command>\nCommands: start, stop, status\n", .{args[0]});
    //     return;
    // }

    std.debug.print("16 bit\n", .{});
    for (ops.op_table, 0..) |item, i| {
        std.debug.print("Index 0x{x}: Value {}\n", .{ i, item });
    }
    var buffer: [256]u8 = undefined; // Temporary buffer for reading
    var reader = stdin.reader();

    while (true) {
        const bytes_read = try reader.read(&buffer);
        if (bytes_read == 0) break; // End of input (EOF)

        // Process or print the bytes read
        const b = buffer[0];
        const op = ops.lookup(b);
        std.debug.print("Byte: {}\n", .{ops.lookup(0xF)});
        std.debug.print("Byte: {b}\n", .{b});
        std.debug.print("Result: {}", .{op});
    }
}

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
