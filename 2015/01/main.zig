const std = @import("std");

pub fn part_1(input: []const u8) i64 {
    var floor: i64 = 0;
    for (input) |c| {
        floor += switch (c) {
            '(' => 1,
            ')' => -1,
            '\n' => break,
            else => unreachable,
        };
    }
    return floor;
}

pub fn part_2(input: []const u8) usize {
    var floor: i64 = 0;
    for (input, 1..) |c, i| {
        floor += switch (c) {
            '(' => 1,
            ')' => -1,
            '\n' => break,
            else => unreachable,
        };

        if (floor < 0) {
            return i;
        }
    }
    unreachable;
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = part_2(input);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

const testing = std.testing;

test "part 1 example input" {
    try testing.expectEqual(part_1("(())"), 0);
    try testing.expectEqual(part_1("()()"), 0);
    try testing.expectEqual(part_1("((("), 3);
    try testing.expectEqual(part_1("(()(()("), 3);
    try testing.expectEqual(part_1("))((((("), 3);
    try testing.expectEqual(part_1("())"), -1);
    try testing.expectEqual(part_1("))("), -1);
    try testing.expectEqual(part_1(")))"), -3);
    try testing.expectEqual(part_1(")())())"), -3);
}

test "part 2 example input" {
    try testing.expectEqual(part_2(")"), 1);
    try testing.expectEqual(part_2("()())"), 5);
}
