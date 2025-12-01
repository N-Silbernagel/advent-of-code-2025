const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const example =
\\L68
\\L30
\\R48
\\L5
\\R60
\\L55
\\L1
\\L99
\\R14
\\L82
;

const real = @embedFile("data/day01.txt");

fn part1(input: []const u8) u16 {
    var zeros: u16 = 0;
    var position: u8 = 50;

    var lines = std.mem.tokenizeAny(u8, input, "\r\n");

    while (lines.next()) |line| {
        const direction = line[0];
        const number_str = line[1..];
        const number = std.fmt.parseInt(u16, number_str, 10) catch std.debug.panic("Could not parse int {s}", .{number_str});

        switch (direction) {
            'L' => position = @intCast(@mod((@as(i16, position) - @as(i32, number)), 100)),
            'R' => position = @intCast((position + number) % 100),
            else => std.debug.panic("Unexpected direction: '{c}' (value: {d})", .{ direction, direction }),
        }

        if (position == 0) {
            zeros += 1;
        }
    }

    return zeros;
}

pub fn main() !void {
    std.debug.print("{}", .{part1(real)});
}

test "correct part 1 example output" {
    try std.testing.expectEqual(3, part1(example));
}

test "correct part 1 real output" {
    try std.testing.expectEqual(1135, part1(real));
}
