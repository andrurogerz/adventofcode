//! https://adventofcode.com/2025/day/3
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
    return solve(2, input);
}

pub fn part_2(input: []const u8) !usize {
    return solve(12, input);
}

fn solve(comptime N: usize, input: []const u8) !usize {
    var sum: usize = 0;
    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line| {
        if (line.len < N) return error.InvalidInput;
        var start_idx: usize = 0;
        var values: [N]usize = [_]usize{0} ** N;
        for (0..N) |idx| {
            const end_idx = line.len - (N - idx) + 1;
            const next = try find_max(line[start_idx..(end_idx)]);
            values[idx] = next.val;
            start_idx += next.pos + 1;
        }

        var row_sum: usize = 0;
        for (0..N) |idx| {
            row_sum *= 10;
            row_sum += values[idx];
        }
        sum += row_sum;
    }
    return sum;
}

fn find_max(line: []const u8) !struct { val: usize, pos: usize } {
    if (line.len == 0) return error.InvalidInput;
    var max_val: usize = 0;
    var max_pos: usize = 0;
    for (line, 0..) |ch, pos| {
        const val: usize = ch - '0';
        if (val < 1 or val > 9) return error.InvalidInput;
        if (val <= max_val) continue;
        max_val = val;
        max_pos = pos;
    }
    return .{ .val = max_val, .pos = max_pos };
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

test "part 1 example input" {
    try testing.expectEqual(part_1(EXAMPLE_INPUT), 357);
}

test "part 2 example input" {
    try testing.expectEqual(part_2(EXAMPLE_INPUT), 3121910778619);
}
