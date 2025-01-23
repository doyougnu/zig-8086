const std = @import("std");
const parser = @import("parser/parser.zig");
const testing = std.testing;

const op = @import("op");
const byte = op.byte;
const Op = op.Op;
const opcode = op.opcode;

const e = switch (bool) {
    u32 => u8,
    else => bool,
};

pub fn parseOpcode(b: byte) Op {
    const opcode_mask = 0xFC;
    return b & opcode_mask >> 2;
}

pub fn getDirection(b: byte) opcode {
    const dir_mask = 0x2;
    return b & dir_mask >> 1;
}

pub fn getByteOrWord(b: byte) opcode {
    const opcode_mask = 0x1;
    return b & opcode_mask >> 2;
}
const rgb = parser.rgb;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

test "rgb" {
    const allocator = testing.allocator;
    const a = (try rgb.parse(allocator, "#aabbcc")).value;
    try testing.expectEqual(@as(u8, 0xaa), a.r);
    try testing.expectEqual(@as(u8, 0xbb), a.g);
    try testing.expectEqual(@as(u8, 0xcc), a.b);

    const b = (try rgb.parse(allocator, "#abc")).value;
    try testing.expectEqual(@as(u8, 0xaa), b.r);
    try testing.expectEqual(@as(u8, 0xbb), b.g);
    try testing.expectEqual(@as(u8, 0xcc), b.b);

    const c = (try rgb.parse(allocator, "#000000")).value;
    try testing.expectEqual(@as(u8, 0), c.r);
    try testing.expectEqual(@as(u8, 0), c.g);
    try testing.expectEqual(@as(u8, 0), c.b);

    const d = (try rgb.parse(allocator, "#000")).value;
    try testing.expectEqual(@as(u8, 0), d.r);
    try testing.expectEqual(@as(u8, 0), d.g);
    try testing.expectEqual(@as(u8, 0), d.b);
}
const expect = std.testing.expect;

test "always succeeds" {
    try expect(true);
}
