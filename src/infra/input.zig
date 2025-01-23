//! adapter over io

// const std = @import("std");

// pub fn stream() !void {
//     const args = std.process.args;
//     const stdout = std.io.getStdOut().writer();

//     if (args.len < 2) {
//         try stdout.print("Usage: {} <command>\nCommands: start, stop, status\n", .{args[0]});
//         return;
//     }

//     const command = try parseCommand(args[1]);

//     switch (command) {
//         .disassemble => try stdout.print("Command: start\n", .{}),
//         .debug => try stdout.print("Command: stop\n", .{}),
//     }
// }

// pub const Command = enum {
//     disassemble,
//     debug,
// };

// fn parseCommand(arg: []const u8) !Command {
//     switch (arg) {
//         "disassemble" => return Command.start,
//         "debug" => return Command.stop,
//         else => return error.InvalidCommand,
//     }
