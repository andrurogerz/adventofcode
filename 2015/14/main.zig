//! https://adventofcode.com/2015/day/14
const std = @import("std");

pub fn main() !void {
    const INPUT = @embedFile("input.txt");
    {
        const result = try part_1(INPUT, 2503);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(9, INPUT, 2503);
        std.debug.print("part 1 result: {}\n", .{result});
    }
}

fn part_1(comptime INPUT: []const u8, duration: usize) !usize {
    var farthest_distance: usize = 0;
    var line_iter = std.mem.tokenizeSequence(u8, INPUT, "\n");
    while (line_iter.next()) |line_str| {
        var speed: usize = undefined;
        var fly_period: usize = undefined;
        var rest_period: usize = undefined;
        _ = try parseLine(line_str, &speed, &fly_period, &rest_period);

        const distance = calculate(duration, speed, fly_period, rest_period);
        if (distance > farthest_distance) {
            farthest_distance = distance;
        }
    }
    return farthest_distance;
}

fn part_2(comptime N: usize, comptime INPUT: []const u8, duration: usize) !usize {
    var speeds: [N]usize = undefined;
    var fly_periods: [N]usize = undefined;
    var rest_periods: [N]usize = undefined;

    var count: usize = 0;
    var line_iter = std.mem.tokenizeSequence(u8, INPUT, "\n");
    while (line_iter.next()) |line_str| {
        if (count >= N) {
            return error.Unexpected;
        }
        _ = try parseLine(line_str, &speeds[count], &fly_periods[count], &rest_periods[count]);
        count += 1;
    }

    if (count != N) {
        return error.Unexpected;
    }

    var scores: [N]usize = [_]usize{0} ** N;
    for (0..duration) |seconds| {
        var distances: [N]usize = undefined;
        for (0..N) |idx| {
            distances[idx] = calculate(1 + seconds, speeds[idx], fly_periods[idx], rest_periods[idx]);
        }

        var farthest: usize = distances[0];
        for (1..N) |idx| {
            if (distances[idx] > farthest) {
                farthest = distances[idx];
            }
        }

        // Account for ties: multiple may be at the same distance and each gets a point.
        for (0..N) |idx| {
            if (distances[idx] == farthest) {
                scores[idx] += 1;
            }
        }
    }

    var high_score: usize = scores[0];
    for (1..N) |idx| {
        if (scores[idx] > high_score) {
            high_score = scores[idx];
        }
    }

    return high_score;
}

fn parseLine(line_str: []const u8, speed: *usize, fly_period: *usize, rest_period: *usize) ![]const u8 {
    var part_iter = std.mem.tokenizeSequence(u8, line_str, " ");
    const name = part_iter.next() orelse return error.Unexpected;
    _ = part_iter.next() orelse return error.Unexpected; // "can"
    _ = part_iter.next() orelse return error.Unexpected; // "fly"
    speed.* = try std.fmt.parseInt(u8, part_iter.next() orelse return error.Unexpected, 10);
    _ = part_iter.next() orelse return error.Unexpected; // "km/s"
    _ = part_iter.next() orelse return error.Unexpected; // "for"
    fly_period.* = try std.fmt.parseInt(u8, part_iter.next() orelse return error.Unexpected, 10);
    _ = part_iter.next() orelse return error.Unexpected; // "seconds,"
    _ = part_iter.next() orelse return error.Unexpected; // "but"
    _ = part_iter.next() orelse return error.Unexpected; // "then"
    _ = part_iter.next() orelse return error.Unexpected; // "must"
    _ = part_iter.next() orelse return error.Unexpected; // "rest"
    _ = part_iter.next() orelse return error.Unexpected; // "for"
    rest_period.* = try std.fmt.parseInt(u8, part_iter.next() orelse return error.Unexpected, 10);
    _ = part_iter.next() orelse return error.Unexpected; // "seconds."
    if (part_iter.next()) |_| {
        return error.Unexpected;
    }

    return name;
}

fn calculate(duration: usize, speed: usize, fly_period: usize, rest_period: usize) usize {
    const total_period = fly_period + rest_period;
    var distance = (speed * fly_period) * (duration / total_period);
    if ((duration % total_period) > fly_period) {
        distance += speed * fly_period;
    } else {
        distance += speed * (duration % total_period);
    }
    return distance;
}

const testing = std.testing;

test "part 1 example input" {
    const EXAMPLE_INPUT =
        \\Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
        \\Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
    ;
    try testing.expectEqual(try part_1(EXAMPLE_INPUT, 1000), 1120);
}

test "part 2 example input" {
    const EXAMPLE_INPUT =
        \\Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
        \\Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
    ;
    try testing.expectEqual(try part_2(2, EXAMPLE_INPUT, 1000), 689);
}
