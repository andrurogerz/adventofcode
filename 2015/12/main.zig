//! https://adventofcode.com/2015/day/12
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const result = try part_1(input);
    std.debug.print("part 1 result: {}\n", .{result});
}

fn part_1(input: []const u8) !isize {
    var sum: isize = 0;
    var number_start: ?usize = null;
    for (0..input.len) |idx| {
        const ch = input[idx];
        switch (ch) {
            '-' => {
                if (number_start) |_| {
                    return error.Unexpected;
                }
                number_start = idx;
            },
            '0'...'9' => {
                if (number_start) |_| {
                    continue;
                }
                number_start = idx;
            },
            else => {
                if (number_start) |start_idx| {
                    sum += try std.fmt.parseInt(isize, input[start_idx..idx], 10);
                    number_start = null;
                }
            },
        }
    }
    std.debug.assert(number_start == null);
    return sum;
}

const testing = std.testing;

test "part 1 example input" {
    try testing.expectEqual(try part_1("[1,2,3]"), 6);
    try testing.expectEqual(try part_1("{\"a\":2,\"b\":4}"), 6);
    try testing.expectEqual(try part_1("[[[3]]]"), 3);
    try testing.expectEqual(try part_1("{\"a\":{\"b\":4},\"c\":-1}"), 3);
    try testing.expectEqual(try part_1("{\"a\":[-1,1]}"), 0);
    try testing.expectEqual(try part_1("[-1,{\"a\":1}]"), 0);
    try testing.expectEqual(try part_1("[]"), 0);
    try testing.expectEqual(try part_1("{}"), 0);
}
