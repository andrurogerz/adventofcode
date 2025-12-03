//! https://adventofcode.com/2025/day/1
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(input);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

pub fn part_1(input: []const u8) !usize {
    var dial_position: i64 = 50;
    var zero_position_count: usize = 0;
    var cmd_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (cmd_iter.next()) |cmd| {
        if (cmd.len < 2) return error.InvalidFormat;
        const rotation = try std.fmt.parseInt(usize, cmd[1..], 10);
        dial_position = switch (cmd[0]) {
            'R' => dial_position + @as(i64, @intCast(rotation)),
            'L' => dial_position - @as(i64, @intCast(rotation)),
            else => return error.InvalidFormat,
        };
        dial_position = @mod(dial_position, 100);
        zero_position_count += if (dial_position == 0) 1 else 0;
    }
    return zero_position_count;
}

pub fn part_2(input: []const u8) !usize {
    var dial_position: i64 = 50;
    var zero_position_count: usize = 0;
    var cmd_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (cmd_iter.next()) |cmd| {
        if (cmd.len < 2) return error.InvalidFormat;
        const rotation = try std.fmt.parseInt(usize, cmd[1..], 10);

        // Account for the number of full rotations up-front.
        const full_rotations = rotation / 100;
        const partial_rotation = rotation % 100;

        const dial_adjust = switch (cmd[0]) {
            'R' => dial_position + @as(i64, @intCast(partial_rotation)),
            'L' => dial_position - @as(i64, @intCast(partial_rotation)),
            else => return error.InvalidFormat,
        };

        const new_dial_position = @mod(dial_adjust, 100);

        zero_position_count += full_rotations;

        if (dial_position != 0) {
            // If it started at any position other than zero, we may have passed zero one additional
            // time or landed on it exactly. Account for that case here by checking for wrap-around.
            zero_position_count += if (new_dial_position == 0 or (dial_adjust != new_dial_position)) 1 else 0;
        }

        dial_position = new_dial_position;
    }

    return zero_position_count;
}

const testing = std.testing;

const EXAMPLE_INPUT =
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

test "part 1 example input" {
    try testing.expectEqual(part_1(EXAMPLE_INPUT), 3);
}

test "part 2 example input" {
    try testing.expectEqual(part_2(EXAMPLE_INPUT), 6);
}
