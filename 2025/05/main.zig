//! https://adventofcode.com/2025/day/5
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
}

pub fn part_1(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ranges = std.ArrayList(struct { start: usize, end: usize }).init(allocator);
    defer ranges.deinit();

    var line_iter = std.mem.splitSequence(u8, input, "\n");

    // Parse the ranges.
    while (line_iter.next()) |range| {
        if (range.len == 0) break;

        // Split the range into two integers strings.
        var iter = std.mem.tokenizeSequence(u8, range, "-");
        const start_str = iter.next() orelse return error.InvalidInput;
        const end_str = iter.next() orelse return error.InvalidInput;
        if (iter.next()) |_| return error.InvalidInput;
        const start = try std.fmt.parseInt(usize, start_str, 10);
        const end = try std.fmt.parseInt(usize, end_str, 10);
        try ranges.append(.{ .start = start, .end = end });
    }

    // Parse the item IDs.
    var fresh_items: usize = 0;
    while (line_iter.next()) |item_str| {
        if (item_str.len == 0) break;
        const item = try std.fmt.parseInt(usize, item_str, 10);
        for (ranges.items) |range| {
            if (item >= range.start and item <= range.end) {
                fresh_items += 1;
                break;
            }
        }
    }

    if (line_iter.next()) |_| return error.InvalidInput;

    return fresh_items;
}
const testing = std.testing;

const EXAMPLE_INPUT =
    \\3-5
    \\10-14
    \\16-20
    \\12-18
    \\
    \\1
    \\5
    \\8
    \\11
    \\17
    \\32
;

test "part 1 example input" {
    try testing.expectEqual(part_1(EXAMPLE_INPUT), 3);
}
