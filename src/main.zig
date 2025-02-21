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

    const BUF_LIMIT = 256; // 64 bytes at a time
    var buffer: [BUF_LIMIT]u8 = undefined; // Temporary buffer for reading
    var reader = stdin.reader();
    const bytes_read = try reader.read(&buffer);
    var byte: u32 = 0;

    std.debug.print("\nbytes_read: {}\n", .{bytes_read});
    // TODO: use a ring buffer
    while (byte < bytes_read) {
        if (buffer[byte] == 0) break; // End of input (EOF)

        // Process or print the bytes read
        const b = buffer[byte];
        const op = ops.lookup(b);
        const d: bool = (b & 0x2) > 0; // D is second byte
        const w: bool = (b & 0x1) > 0; // W is first byte

        std.debug.print("\nwriting: {}\n", .{d});
        std.debug.print("dest: {}\n", .{w});
        std.debug.print("\niter: {}\n", .{byte});
        std.debug.print("Byte: {b}\n", .{b});
        std.debug.print("Result: {}", .{op});

        // iterate
        byte += 1; // iterate to the next byte
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
