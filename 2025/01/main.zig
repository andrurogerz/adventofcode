//! https://adventofcode.com/2025/day/1
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
}

pub fn part_1(input: []const u8) !usize {
    var dial_position: i64 = 50;
    var zero_position_count: usize = 0;
    var cmd_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (cmd_iter.next()) |cmd| {
        if (cmd.len < 2) return error.InvalidFormat;
        const rotation: i64 = @intCast(try std.fmt.parseInt(usize, cmd[1..], 10));
        dial_position = switch (cmd[0]) {
            'R' => @mod((dial_position + rotation), @as(i64, 100)),
            'L' => @mod((dial_position - rotation), @as(i64, 100)),
            else => return error.InvalidFormat,
        };
        zero_position_count += if (dial_position == 0) 1 else 0;
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
