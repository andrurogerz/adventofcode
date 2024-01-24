const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const result = try part_1(input);
    std.debug.print("part 1 result: {}\n", .{result});
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
        pos = switch (ch) {
            '^' => Position{ .x = pos.x, .y = pos.y - 1 },
            'v' => Position{ .x = pos.x, .y = pos.y + 1 },
            '>' => Position{ .x = pos.x + 1, .y = pos.y },
            '<' => Position{ .x = pos.x - 1, .y = pos.y },
            '\n' => break,
            else => return error.Unexpected,
        };
        try visited_set.put(pos, {});
    }
    return visited_set.count();
}

const testing = std.testing;

test "part 2 example input" {
    try testing.expectEqual(try part_1(">"), 2);
    try testing.expectEqual(try part_1("^>v<"), 4);
    try testing.expectEqual(try part_1("^v^v^v^v^v"), 2);
}
