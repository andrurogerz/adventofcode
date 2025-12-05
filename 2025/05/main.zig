//! https://adventofcode.com/2025/day/5
const std = @import("std");
const Ranges = @import("ranges.zig").Ranges;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = @embedFile("input.txt");
    {
        const result = try part_1(allocator, input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(allocator, input);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

pub fn part_1(allocator: std.mem.Allocator, input: []const u8) !usize {
    var ranges = Ranges(usize).init(allocator);
    defer ranges.deinit();

    var line_iter = std.mem.splitSequence(u8, input, "\n");

    // Parse the ranges.
    while (line_iter.next()) |range| {
        if (range.len == 0) break;

        // Parse the range.
        var iter = std.mem.tokenizeSequence(u8, range, "-");
        const start_str = iter.next() orelse return error.InvalidInput;
        const end_str = iter.next() orelse return error.InvalidInput;
        if (iter.next()) |_| return error.InvalidInput;
        const new_range = Ranges(usize).Range{ .start = try std.fmt.parseInt(usize, start_str, 10), .end = try std.fmt.parseInt(usize, end_str, 10) };
        if (new_range.end < new_range.start) return error.InvalidInput;

        // Add the new range to the end of the list of ranges. The list is not sorted.
        try ranges.add(new_range);
    }

    // Parse the item IDs and determine if they land in any of the ranges.
    var result: usize = 0;
    while (line_iter.next()) |item_str| {
        if (item_str.len == 0) break;
        const item = try std.fmt.parseInt(usize, item_str, 10);
        for (ranges.items()) |range| {
            if (item >= range.start and item <= range.end) {
                result += 1;
                break;
            }
        }
    }

    // No more input expected.
    if (line_iter.next()) |_| return error.InvalidInput;

    return result;
}

pub fn part_2(allocator: std.mem.Allocator, input: []const u8) !usize {
    var ranges = Ranges(usize).init(allocator);
    defer ranges.deinit();

    // Parse the ranges from the input.
    var line_iter = std.mem.splitSequence(u8, input, "\n");

    // Parse the ranges.
    while (line_iter.next()) |range| {
        if (range.len == 0) break;

        // Parse the range.
        var iter = std.mem.tokenizeSequence(u8, range, "-");
        const start_str = iter.next() orelse return error.InvalidInput;
        const end_str = iter.next() orelse return error.InvalidInput;
        if (iter.next()) |_| return error.InvalidInput;
        const new_range = Ranges(usize).Range{ .start = try std.fmt.parseInt(usize, start_str, 10), .end = try std.fmt.parseInt(usize, end_str, 10) };
        if (new_range.end < new_range.start) return error.InvalidInput;

        // Add the new range to the end of the list of ranges. The list is not sorted.
        try ranges.add(new_range);
    }

    var result: usize = 0;
    for (ranges.items()) |range| result += range.end - range.start + 1;
    return result;
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
    try testing.expectEqual(part_1(testing.allocator, EXAMPLE_INPUT), 3);
}

test "part 2 example input" {
    try testing.expectEqual(part_2(testing.allocator, EXAMPLE_INPUT), 14);
}
