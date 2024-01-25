//! https://adventofcode.com/2015/day/3
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

const Position = struct {
    x: i64,
    y: i64,
};

fn part_1(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var visited_set = std.AutoHashMap(Position, void).init(allocator);
    defer visited_set.deinit();

    var pos = Position{ .x = 0, .y = 0 };
    try visited_set.put(pos, {});

    for (input) |ch| {
        if (ch == '\n') break;
        pos = try nextPosition(pos, ch);
        try visited_set.put(pos, {});
    }
    return visited_set.count();
}

fn part_2(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var visited_set = std.AutoHashMap(Position, void).init(allocator);
    defer visited_set.deinit();

    var santa_pos = Position{ .x = 0, .y = 0 };
    var robot_pos = Position{ .x = 0, .y = 0 };
    try visited_set.put(santa_pos, {});

    for (0..input.len / 2) |idx| {
        santa_pos = try nextPosition(santa_pos, input[2 * idx]);
        robot_pos = try nextPosition(robot_pos, input[2 * idx + 1]);
        try visited_set.put(santa_pos, {});
        try visited_set.put(robot_pos, {});
    }
    return visited_set.count();
}

fn nextPosition(pos: Position, ch: u8) !Position {
    return switch (ch) {
        '^' => Position{ .x = pos.x, .y = pos.y - 1 },
        'v' => Position{ .x = pos.x, .y = pos.y + 1 },
        '>' => Position{ .x = pos.x + 1, .y = pos.y },
        '<' => Position{ .x = pos.x - 1, .y = pos.y },
        else => return error.Unexpected,
    };
}

const testing = std.testing;

test "part 1 example input" {
    try testing.expectEqual(try part_1(">"), 2);
    try testing.expectEqual(try part_1("^>v<"), 4);
    try testing.expectEqual(try part_1("^v^v^v^v^v"), 2);
}

test "part 2 example input" {
    try testing.expectEqual(try part_2("^v"), 3);
    try testing.expectEqual(try part_2("^>v<"), 3);
    try testing.expectEqual(try part_2("^v^v^v^v^v"), 11);
}
