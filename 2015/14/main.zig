//! https://adventofcode.com/2015/day/14
const std = @import("std");

const Mode = enum { MIN, MAX };

pub fn main() !void {
    const INPUT = @embedFile("input.txt");
    const result = try part_1(INPUT, 2503);
    std.debug.print("part 1 result: {}\n", .{result});
}

fn part_1(comptime INPUT: []const u8, duration: usize) !usize {
    var farthest_distance: usize = 0;
    var line_iter = std.mem.tokenizeSequence(u8, INPUT, "\n");
    while (line_iter.next()) |line_str| {
        var part_iter = std.mem.tokenizeSequence(u8, line_str, " ");
        const name = part_iter.next() orelse return error.Unexpected;
        _ = part_iter.next() orelse return error.Unexpected; // "can"
        _ = part_iter.next() orelse return error.Unexpected; // "fly"
        const speed = try std.fmt.parseInt(u8, part_iter.next() orelse return error.Unexpected, 10);
        _ = part_iter.next() orelse return error.Unexpected; // "km/s"
        _ = part_iter.next() orelse return error.Unexpected; // "for"
        const fly_period = try std.fmt.parseInt(u8, part_iter.next() orelse return error.Unexpected, 10);
        _ = part_iter.next() orelse return error.Unexpected; // "seconds,"
        _ = part_iter.next() orelse return error.Unexpected; // "but"
        _ = part_iter.next() orelse return error.Unexpected; // "then"
        _ = part_iter.next() orelse return error.Unexpected; // "must"
        _ = part_iter.next() orelse return error.Unexpected; // "rest"
        _ = part_iter.next() orelse return error.Unexpected; // "for"
        const rest_period = try std.fmt.parseInt(u8, part_iter.next() orelse return error.Unexpected, 10);
        _ = part_iter.next() orelse return error.Unexpected; // "seconds."
        if (part_iter.next()) |_| {
            return error.Unexpected;
        }

        _ = name; // Don't actually need this string
        const total_period = fly_period + rest_period;
        var distance = (speed * fly_period) * (duration / total_period);
        if ((duration % total_period) > fly_period) {
            distance += speed * fly_period;
        } else {
            distance += speed * (duration % total_period);
        }

        if (distance > farthest_distance) {
            farthest_distance = distance;
        }
    }
    return farthest_distance;
}

const testing = std.testing;

test "part 1 example input" {
    const EXAMPLE_INPUT =
        \\Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
        \\Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
    ;
    try testing.expectEqual(try part_1(EXAMPLE_INPUT, 1000), 1120);
}
