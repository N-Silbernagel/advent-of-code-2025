const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");

const example =
\\..@@.@@@@.
\\@@@.@.@.@@
\\@@@@@.@.@@
\\@.@@@@..@.
\\@@.@@@@.@@
\\.@@@@@@@.@
\\.@.@.@.@@@
\\@.@@@.@@@@
\\.@@@@@@@@.
\\@.@.@@@.@.
;

const real = @embedFile("data/day04.txt");

fn part1(input: []const u8) u16 {
    return iterate_rounds(input, 1);
}

fn part2(input: []const u8) u16 {
    return iterate_rounds(input, std.math.maxInt(u8));
}

fn getGridPosition(x: usize, y: usize, offset_x: i2, offset_y: i2, grid: std.ArrayList([]u8)) ?u8 {
    const target_y = @as(isize, @intCast(y)) + offset_y;
    const target_x = @as(isize, @intCast(x)) + offset_x;

    if (target_y < 0 or @as(usize, @intCast(target_y)) >= grid.items.len) return null;
    const row = grid.items[@intCast(target_y)];

    if (target_x < 0 or @as(usize, @intCast(target_x)) >= row.len) return null;
    return row[@intCast(target_x)];
}

fn iterate_rounds(input: []const u8, rounds: u8) u16 {
    var grid = std.ArrayList([]u8).init(util.gpa);
    defer {
        for (grid.items) |row| util.gpa.free(row);
        grid.deinit();
    }

    var lines = std.mem.tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        const mutable_line = util.gpa.dupe(u8, line) catch std.debug.panic("Failed duping line", .{});
        grid.append(mutable_line) catch std.debug.panic("Failed appending line", .{});
    }

    var removed_total: u16 = 0;

    var rounds_done: u16 = 0;
    var removed_round: u16 = std.math.maxInt(u16);
    while (removed_round > 0 and rounds_done < rounds) {
        removed_round = 0;
        var next_grid = std.ArrayList([]u8).init(util.gpa);

        for (grid.items, 0..) |row, y| {
            const mutable_row = util.gpa.dupe(u8, row) catch std.debug.panic("Failed duping row", .{});
            next_grid.append(mutable_row) catch std.debug.panic("Failed appending row", .{});

            for (row, 0..) |item, x| {
                if (item == '@') {
                    var neighbors: u4 = 0;

                    if (getGridPosition(x, y, -1, -1, grid) == '@') {
                        neighbors += 1;
                    }
                    if (getGridPosition(x, y, -1, 0, grid) == '@') {
                        neighbors += 1;
                    }
                    if (getGridPosition(x, y, -1, 1, grid) == '@') {
                        neighbors += 1;
                    }
                    if (getGridPosition(x, y, 0, -1, grid) == '@') {
                        neighbors += 1;
                    }
                    if (getGridPosition(x, y, 0, 1, grid) == '@') {
                        neighbors += 1;
                    }
                    if (getGridPosition(x, y, 1, -1, grid) == '@') {
                        neighbors += 1;
                    }
                    if (getGridPosition(x, y, 1, 0, grid) == '@') {
                        neighbors += 1;
                    }
                    if (getGridPosition(x, y, 1, 1, grid) == '@') {
                        neighbors += 1;
                    }

                    if (neighbors < 4) {
                        next_grid.items[y][x] = '.';
                        removed_round += 1;
                    }
                }
            }
        }

        removed_total += removed_round;
        for (grid.items) |row| util.gpa.free(row);
        grid.deinit();
        grid = next_grid;
        rounds_done += 1;
    }

    return removed_total;
}

pub fn main() !void {
    std.debug.print("test {d}", .{part2(example)});
}

test "correct part 1 example input" {
    try std.testing.expectEqual(13, part1(example));
}

test "correct part 1 real input" {
    try std.testing.expectEqual(1395, part1(real));
}

test "correct part 2 example input" {
    try std.testing.expectEqual(43, part2(example));
}

test "correct part 2 real input" {
    try std.testing.expectEqual(8451, part2(real));
}
