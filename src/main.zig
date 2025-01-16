const std = @import("std");
const mecha = @import("mecha");
const ops = @import("op");

// pub fn parse

pub fn main() !void {

    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("16 bit\n", .{});
    std.debug.print("{}\n", .{ops.op_table[0b10111]});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();

    // try stdout.print("Run {}", .{foo(0b101)});

    try bw.flush(); // don't forget to flush!
}
