const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const example =
\\.......S.......
\\...............
\\.......^.......
\\...............
\\......^.^......
\\...............
\\.....^.^.^.....
\\...............
\\....^.^...^....
\\...............
\\...^.^...^.^...
\\...............
\\..^...^.....^..
\\...............
\\.^.^.^.^.^...^.
\\...............
;

const real = @embedFile("data/day07.txt");

fn part1(allocator: Allocator, input: []const u8) u128 {
    return calculate_timelines(allocator, input, false) - 1;
}

fn part2(allocator: Allocator, input: []const u8) u128 {
    return calculate_timelines(allocator, input, true);
}

fn calculate_timelines(allocator: Allocator, input: []const u8, allow_duplicate: bool) u128 {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    var lines = std.mem.tokenizeAny(u8, input, "\n");

    var grid = std.ArrayList([]const u8).init(arena_allocator);

    var line_length: usize = 0;
    while (lines.next()) |line| {
        line_length = line.len;
        grid.append(line) catch @panic("Could not append.");
    }

    const start_position = Point{
        .x = @intCast(line_length / 2),
        .y = 0,
    };

    const BeamList = std.SinglyLinkedList(BeamNode);

    var beam_list = BeamList{};

    const start_node = arena_allocator.create(BeamList.Node) catch @panic("OOM");
    start_node.* = BeamList.Node{ .data = BeamNode {
        .point = start_position,
        .visited = false,
        .parent = null,
        .output_count = 1,
        .input_count = 1,
    } };
    beam_list.prepend(start_node);

    var split_cache = std.AutoHashMap(Point, u128).init(arena_allocator);

    while (beam_list.first) |current_node| {
        const current_position = current_node.data.point;

        const is_in_boundaries = isPointInBoundaries(current_position, grid);
        if (!is_in_boundaries) {
            beam_list.remove(current_node);
            continue;
        }

        const cached_value = split_cache.get(current_position);
        if (cached_value != null) {
            beam_list.remove(current_node);

            // for part1 we dont allow duplicates, if something has been cached, it has been visited, ignore id
            // for part2 we do allow duplicates, reuse cached value
            if (allow_duplicate) {
                current_node.data.parent.?.output_count += cached_value orelse @panic("Could not get cached value.");
            }
            continue;
        }

        if (current_node.data.visited) {
            // if the node has already been visited and we have now returned to it, cache it's count and remove it from
            // the stack
            beam_list.remove(current_node);
            const intrinsic_count = current_node.data.output_count - current_node.data.input_count;
            split_cache.put(current_position, intrinsic_count) catch @panic("Couldnt add position to split cache.");

            if (current_node.data.parent != null) {
                current_node.data.parent.?.output_count += intrinsic_count;
            }
            continue;
        }

        const grid_cell = grid.items[@intCast(current_position.y)][@intCast(current_position.x)];
        switch (grid_cell) {
            '.', 'S' => {
                const next_node = arena_allocator.create(BeamList.Node) catch @panic("OOM");
                next_node.* = BeamList.Node{ .data = BeamNode {
                    .point = Point{
                        .x = current_position.x,
                        .y = current_position.y + 1,
                    },
                    .visited = false,
                    .parent = &current_node.data,
                    .output_count = current_node.data.output_count,
                    .input_count = current_node.data.output_count,
                } };
                beam_list.prepend(next_node);
            },
            '^' => {
                current_node.data.output_count += 1;

                const next_node_right = arena_allocator.create(BeamList.Node) catch @panic("OOM");
                next_node_right.* = BeamList.Node{ .data = BeamNode {
                    .point = Point{
                        .x = current_position.x + 1,
                        .y = current_position.y,
                    },
                    .visited = false,
                    .parent = &current_node.data,
                    .output_count = current_node.data.output_count,
                    .input_count = current_node.data.output_count,
                } };
                beam_list.prepend(next_node_right);

                const next_node_left = arena_allocator.create(BeamList.Node) catch @panic("OOM");
                next_node_left.* = BeamList.Node{ .data = BeamNode {
                    .point = Point{
                        .x = current_position.x - 1,
                        .y = current_position.y,
                    },
                    .visited = false,
                    .parent = &current_node.data,
                    .output_count = current_node.data.output_count,
                    .input_count = current_node.data.output_count,
                } };
                beam_list.prepend(next_node_left);
            },
            else => {
                std.debug.panic("Unexpected character {c}", .{grid_cell});
            }
        }

        current_node.data.visited = true;
    }

    return start_node.data.output_count;
}

const BeamNode = struct {
    point: Point,
    visited: bool,
    parent: ?*BeamNode,
    output_count: u128,
    input_count: u128,
};

const Point = struct {
    x: isize,
    y: isize,
};

fn isPointInBoundaries(point: Point, grid: std.ArrayList([]const u8)) bool {
    if (point.y < 0) {
        return false;
    }

    if (point.y > grid.items.len - 1) {
        return false;
    }

    if (point.x < 0) {
        return false;
    }

    if (point.x > grid.getLast().len - 1) {
        return false;
    }

    return true;
}

pub fn main() !void {
    std.debug.print("{d}", .{part2(gpa, real)});
}

test "correct part 1 example input" {
    try std.testing.expectEqual(21, part1(std.testing.allocator, example));
}

test "correct part 1 real input" {
    try std.testing.expectEqual(1672, part1(std.testing.allocator, real));
}

test "correct part 2 example input" {
    try std.testing.expectEqual(40, part2(std.testing.allocator, example));
}

test "correct part 2 real input" {
    try std.testing.expectEqual(231229866702355, part2(std.testing.allocator, real));
}
