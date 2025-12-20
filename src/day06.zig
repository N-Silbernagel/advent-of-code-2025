const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const example = @embedFile("data/day06_example.txt");

const real = @embedFile("data/day06.txt");

fn part1(input: []const u8, alloc: Allocator) u128 {
    var lines = std.mem.tokenizeAny(u8, input, "\n");

    var grand_total: u128 = 0;

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const arena_allocator = arena.allocator();

    var spreadsheet = std.ArrayList(std.ArrayList(u16)).init(arena_allocator);

    while (lines.next()) |line| {
        var row = std.ArrayList(u16).init(arena_allocator);

        var cell_strings = std.mem.tokenizeAny(u8, line, " ");

        var column_index: usize = 0;
        while (cell_strings.next()) |cell_string| {
            const is_multiplication = std.mem.eql(u8, cell_string, "*");
            const is_addition = std.mem.eql(u8, cell_string, "+");
            if (is_multiplication or is_addition) {
                var column_result: u128 = if (is_multiplication) 1 else 0;

                for (spreadsheet.items) |numbers_row| {
                    if (is_addition) {
                        column_result += numbers_row.items[column_index];
                    }

                    if (is_multiplication) {
                        column_result *= numbers_row.items[column_index];
                    }
                }

                column_index += 1;
                grand_total += column_result;
                continue;
            }

            const number = std.fmt.parseInt(u16, cell_string, 10) catch std.debug.panic("Couldn't parse number {s}", .{cell_string});

            row.append(number) catch @panic("Couldnt append number");
        }

        spreadsheet.append(row) catch @panic("Couldnt append row");
    }

    return grand_total;
}

fn part2(input: []const u8, alloc: Allocator) u128 {
    var lines = std.mem.tokenizeAny(u8, input, "\n");

    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    const arena_allocator = arena.allocator();
    var columns = std.ArrayList(std.ArrayList(u8)).init(arena_allocator);

    while (lines.next()) |line| {
        var reverse_line = std.mem.reverseIterator(line);

        var column_index: usize = 0;
        while (reverse_line.next()) |character| : (column_index += 1) {
            if (columns.items.len < column_index + 1) {
                columns.append(std.ArrayList(u8).init(arena_allocator)) catch @panic("Failed to append.");
            }

            var column = &columns.items[column_index];
            if (character != ' ') {
                column.append(character) catch @panic("Failed to append.");
            }
        }
    }

    var number_buffer = std.ArrayList(u16).init(arena_allocator);

    var total: u128 = 0;

    for (columns.items, 0..columns.items.len) |column, i| {
        if (column.items.len == 0) {
            number_buffer.clearAndFree();
            continue;
        }

        const is_addition = column.getLast() == '+';
        const is_multiplication = column.getLast() == '*';

        const column_string = if (is_addition or is_multiplication) column.items[0 .. column.items.len - 1] else column.items;

        const number = std.fmt.parseInt(u16, column_string, 10) catch std.debug.panic("Failed parsing int '{s}' in {d}", .{column.items, i});
        number_buffer.append(number) catch @panic("Failed appending.");

        if (is_addition) {
            var sum: u16 = 0;
            for (number_buffer.items) |buffered_number| {
                sum += buffered_number;
            }
            total += sum;
        }

        if (is_multiplication) {
            var sum: u64 = 1;
            for (number_buffer.items) |buffered_number| {
                sum *= buffered_number;
            }
            total += sum;
        }
    }

    return total;
}

pub fn main() !void {

}

test "correct part 1 example input" {
    try std.testing.expectEqual(4277556, part1(example, std.testing.allocator));
}

test "correct part 1 real input" {
    try std.testing.expectEqual(8108520669952, part1(real, std.testing.allocator));
}

test "correct part 2 example input" {
    try std.testing.expectEqual(3263827, part2(example, std.testing.allocator));
}

test "correct part 2 real input" {
    try std.testing.expectEqual(11708563470209, part2(real, std.testing.allocator));
}
