//! https://adventofcode.com/2025/day/5
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

const Range = struct {
    start: usize,
    end: usize,
};

pub fn part_1(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ranges = std.ArrayList(Range).init(allocator);
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
        const new_range = Range{ .start = try std.fmt.parseInt(usize, start_str, 10), .end = try std.fmt.parseInt(usize, end_str, 10) };
        if (new_range.end < new_range.start) return error.InvalidInput;

        // Add the new range to the end of the list of ranges. The list is not sorted.
        try ranges.append(new_range);
    }

    // Parse the item IDs and determine if they land in any of the ranges.
    var fresh_item_count: usize = 0;
    while (line_iter.next()) |item_str| {
        if (item_str.len == 0) break;
        const item = try std.fmt.parseInt(usize, item_str, 10);
        for (ranges.items) |range| {
            if (item >= range.start and item <= range.end) {
                fresh_item_count += 1;
                break;
            }
        }
    }

    // No more input expected.
    if (line_iter.next()) |_| return error.InvalidInput;

    return fresh_item_count;
}

pub fn part_2(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // An unordered list of ranges.
    var ranges = std.ArrayList(Range).init(allocator);
    defer ranges.deinit();

    // Parse the ranges from the input.
    var line_iter = std.mem.splitSequence(u8, input, "\n");
    while (line_iter.next()) |range_str| {
        if (range_str.len == 0) break; // Remaining input is ignored for part 2.

        // Parse the range.
        var iter = std.mem.tokenizeSequence(u8, range_str, "-");
        const start_str = iter.next() orelse return error.InvalidInput;
        const end_str = iter.next() orelse return error.InvalidInput;
        if (iter.next()) |_| return error.InvalidInput;
        var new_range = Range{ .start = try std.fmt.parseInt(usize, start_str, 10), .end = try std.fmt.parseInt(usize, end_str, 10) };
        if (new_range.end < new_range.start) return error.InvalidInput;

        // Check existing ranges to see if this one can be merged with it.
        while (true) {
            var merged = false;
            for (0..ranges.items.len) |idx| {
                const range = ranges.items[idx];
                if (range.end < new_range.start or new_range.end < range.start) continue;

                // Remove the overlapping item from the existing list of ranges and merge it with
                // the new range that has not been added to the list yet..
                _ = ranges.swapRemove(idx);
                new_range = .{ .start = @min(new_range.start, range.start), .end = @max(new_range.end, range.end) };
                merged = true;
                break;
            }

            if (!merged) {
                // The range did not merge with any other ranges, so just append it to the list and
                // move on.
                try ranges.append(.{ .start = new_range.start, .end = new_range.end });
                break;
            }
        }
    }

    var result: usize = 0;
    for (ranges.items) |range| result += range.end - range.start + 1;
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
    try testing.expectEqual(part_1(EXAMPLE_INPUT), 3);
}

test "part 2 example input" {
    try testing.expectEqual(part_2(EXAMPLE_INPUT), 14);
}
