const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const example =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

const real = @embedFile("data/day03.txt");

fn part1(input: []const u8) u64 {
    var banks = std.mem.tokenizeAny(u8, input, "\r\n");

    var joltage: u64 = 0;
    while (banks.next()) |bank| {
        var biggestBattery: u8 = 1;
        var secondBiggestBattery: u8 = 1;

        var batteryIndex: u8 = 0;
        while (batteryIndex < bank.len) : (batteryIndex += 1) {
            const battery = bank[batteryIndex] - '0';

            if (battery > biggestBattery) {
                if (batteryIndex == bank.len - 1) {
                    secondBiggestBattery = battery;
                    continue;
                }

                secondBiggestBattery = 1;
                biggestBattery = battery;
                continue;
            }

            if (battery > secondBiggestBattery) {
                secondBiggestBattery = battery;
            }
        }

        const bankJoltageString = [_]u8{ biggestBattery + '0', secondBiggestBattery + '0' };

        const bankjoltage = std.fmt.parseInt(u8, &bankJoltageString, 10) catch std.debug.panic("Could not parse int {s}", .{bankJoltageString});
        joltage += bankjoltage;
    }

    return joltage;
}

fn part2(input: []const u8) u64 {
    var banks = std.mem.tokenizeAny(u8, input, "\r\n");

    var joltage: u64 = 0;

    const target_len: usize = 12;

    while (banks.next()) |bank| {
        var bank_joltage_string = [target_len]u8{ '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0' };

        var current_search_start: usize = 0;

        for (0..target_len) |i| {
            const digits_needed = (target_len - 1) - i;

            const search_end = bank.len - digits_needed;

            const window = bank[current_search_start..search_end];

            const max_val = std.mem.max(u8, window);
            const relative_index = std.mem.indexOfScalar(u8, window, max_val).?;

            bank_joltage_string[i] = max_val;

            current_search_start += (relative_index + 1);
        }

        const bank_joltage = std.fmt.parseInt(u64, &bank_joltage_string, 10) catch std.debug.panic("args", .{});
        joltage += bank_joltage;
    }

    return joltage;
}

pub fn main() !void {
    std.debug.print("test {d}", .{part2(example)});
}

test "correct part 1 example input" {
    try std.testing.expectEqual(357, part1(example));
}

test "correct part 1 real input" {
    try std.testing.expectEqual(17321, part1(real));
}

test "correct part 2 example input" {
    try std.testing.expectEqual(3121910778619, part2(example));
}

test "correct part 2 real input" {
    try std.testing.expectEqual(171989894144198, part2(real));
}
