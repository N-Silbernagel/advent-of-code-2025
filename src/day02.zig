const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const example = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

const real = @embedFile("data/day02.txt");

fn part1(input: []const u8) u64 {
    const trimmedInput = std.mem.trim(u8, input, " \r\n");
    var rangeStrings = std.mem.tokenizeAny(u8, trimmedInput, ",");

    var total: u64 = 0;
    while (rangeStrings.next()) |rangeString| {
        var rangeElements = std.mem.tokenizeAny(u8, rangeString, "-");
        const fromString = rangeElements.next().?;
        const toString = rangeElements.next().?;
        std.debug.assert(rangeElements.next() == null);
        const from = std.fmt.parseInt(u64, fromString, 10) catch std.debug.panic("Could not parse int {s}", .{fromString});
        const to = std.fmt.parseInt(u64, toString, 10) catch std.debug.panic("Could not parse int {s}", .{toString});
        std.debug.assert(to > from);

        var buf: [256]u8 = undefined;
        for (from..to+1) |i| {
            const iAsString = std.fmt.bufPrint(&buf, "{}", .{i}) catch std.debug.panic("Could convert {d} to string", .{i});

            const mid = iAsString.len / 2;

            const first_half = iAsString[0..mid];
            const second_half = iAsString[mid..];

            if (std.mem.eql(u8, first_half, second_half)) {
                total += @intCast(i);
            }
        }
    }

    return total;
}

fn part2(input: []const u8) u64 {
    const trimmedInput = std.mem.trim(u8, input, " \r\n");
    var rangeStrings = std.mem.tokenizeAny(u8, trimmedInput, ",");

    var total: u64 = 0;
    while (rangeStrings.next()) |rangeString| {
        var rangeElements = std.mem.tokenizeAny(u8, rangeString, "-");
        const fromString = rangeElements.next().?;
        const toString = rangeElements.next().?;
        std.debug.assert(rangeElements.next() == null);
        const from = std.fmt.parseInt(u64, fromString, 10) catch std.debug.panic("Could not parse int {s}", .{fromString});
        const to = std.fmt.parseInt(u64, toString, 10) catch std.debug.panic("Could not parse int {s}", .{toString});
        std.debug.assert(to > from);

        var buf: [256]u8 = undefined;
        for (from..to+1) |probeId| {
            const probeIdString = std.fmt.bufPrint(&buf, "{}", .{probeId}) catch std.debug.panic("Could convert {d} to string", .{probeId});

            const mid = probeIdString.len / 2;

            for (1..mid+1) |sequenceLength| {
                const pattern = probeIdString[0..sequenceLength];

                var all_match = true;

                var a: usize = sequenceLength;
                while (a < probeIdString.len) : (a += sequenceLength) {
                    if (a + sequenceLength > probeIdString.len) {
                        all_match = false;
                        break;
                    }

                    const chunk = probeIdString[a .. a + sequenceLength];

                    if (!std.mem.eql(u8, chunk, pattern)) {
                        all_match = false;
                        break;
                    }
                }

                if (all_match) {
                    total += @intCast(probeId);
                    break;
                }
            }
        }
    }

    return total;
}

pub fn main() !void {
    std.debug.print("test {d}", .{part2(example)});
}

test "correct part 1 example input" {
    try std.testing.expectEqual(1227775554, part1(example));
}

test "correct part 1 real input" {
    try std.testing.expectEqual(38158151648, part1(real));
}

test "correct part 2 example input" {
    try std.testing.expectEqual(4174379265, part2(example));
}

test "correct part 2 real input" {
    try std.testing.expectEqual(45283684555, part2(real));
}
