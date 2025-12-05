//! https://adventofcode.com/2025/day/3
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
}

pub fn part_1(input: []const u8) !usize {
    var sum: usize = 0;
    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line| {
        if (line.len < 2) return error.InvalidInput;
        const first = try find_max(line[0..(line.len - 1)]);
        const second = try find_max(line[(first.pos + 1)..]);
        sum += first.val * 10 + second.val;
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
