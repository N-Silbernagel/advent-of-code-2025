const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const example =
    \\3-5
    \\10-14
    \\16-20
    \\12-18
    \\
    \\1
    \\5
    \\8
    \\11
    \\17
    \\32
;

const real = @embedFile("data/day05.txt");

fn part1(input: []const u8) u16 {
    var lines = std.mem.splitAny(u8, input, "\n");

    var isRangeMode = true;

    var ranges = std.ArrayList([2]u64).init(gpa);
    var fresh_ingredients: u16 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            isRangeMode = false;
            continue;
        }

        if (isRangeMode) {
            var range = [_]u64{ 0, 0 };
            var rangeElements = std.mem.tokenizeAny(u8, line, "-");

            var rangeCounter: u2 = 0;
            while (rangeElements.next()) |rangeElementString| {
                if (rangeCounter > 2) {
                    @panic("Too many range elements.");
                }

                range[rangeCounter] = std.fmt.parseInt(u64, rangeElementString, 10) catch std.debug.panic("Failed to parse int {s}", .{rangeElementString});
                rangeCounter += 1;
            }

            ranges.append(range) catch @panic("Couldnt add range");
            continue;
        }

        const ingredient_id = std.fmt.parseInt(u64, line, 10) catch std.debug.panic("Failed to parse int from line {s}", .{line});

        for (ranges.items) |range| {
            if (ingredient_id < range[0]) {
                continue;
            }

            if (ingredient_id > range[1]) {
                continue;
            }

            fresh_ingredients += 1;
            break;
        }
    }

    return fresh_ingredients;
}

fn part2(input: []const u8) u64 {
    var lines = std.mem.splitAny(u8, input, "\n");

    var ranges = std.ArrayList([2]u64).init(gpa);
    defer ranges.deinit();

    var fresh_ingredients: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var range = [_]u64{ 0, 0 };
        var rangeElements = std.mem.tokenizeAny(u8, line, "-");

        var rangeCounter: u2 = 0;
        while (rangeElements.next()) |rangeElementString| {
            if (rangeCounter > 2) {
                @panic("Too many range elements.");
            }

            range[rangeCounter] = std.fmt.parseInt(u64, rangeElementString, 10) catch std.debug.panic("Failed to parse int {s}", .{rangeElementString});
            rangeCounter += 1;
        }

        ranges.append(range) catch @panic("Couldnt add range");
    }

    std.mem.sort([2]u64, ranges.items, {}, comptime sortRangeAsc());

    var pointer: u64 = 0;
    for (ranges.items) |range| {
        if (range[0] > pointer) {
            pointer = range[0];
        }

        if (range[1] < pointer) {
            continue;
        }


        fresh_ingredients += range[1] - pointer + 1;
        pointer = range[1] + 1;
    }

    return fresh_ingredients;
}

fn sortRangeAsc() fn (void, [2]u64, [2]u64) bool {
    return struct {
        pub fn inner(_: void, a: [2]u64, b: [2]u64) bool {
            return a[0] < b[0];
        }
    }.inner;
}

pub fn main() !void {}

test "correct part 1 example input" {
    try std.testing.expectEqual(3, part1(example));
}

test "correct part 1 real input" {
    try std.testing.expectEqual(789, part1(real));
}

test "correct part 2 example input" {
    try std.testing.expectEqual(14, part2(example));
}

test "correct part 2 real input" {
    try std.testing.expectEqual(343329651880509, part2(real));
}
