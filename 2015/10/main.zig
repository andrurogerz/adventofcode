//! https://adventofcode.com/2015/day/2
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const result = try part_1(input);
    std.debug.print("part 1 result: {}\n", .{result});
}

fn part_1(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var expanded_str: []const u8 = try allocator.dupe(u8, input);
    defer allocator.free(expanded_str);
    for (0..40) |_| {
        var prev_str = expanded_str;
        defer allocator.free(prev_str);
        expanded_str = try expand(allocator, prev_str);
    }

    return expanded_str.len;
}

fn expand(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var buf: [8]u8 = [_]u8{0} ** 8;
    var result = std.ArrayList(u8).init(allocator);
    var prev: u8 = 0;
    var count: usize = 0;
    for (input) |ch| {
        switch (ch) {
            '0'...'9' => {
                if (ch == prev) {
                    count += 1;
                    continue;
                }

                if (prev != 0) {
                    try result.appendSlice(try std.fmt.bufPrint(&buf, "{}", .{count}));
                    try result.append(prev);
                }

                count = 1;
                prev = ch;
            },
            '\n', 0 => break,
            else => return error.Unexpected,
        }
    }

    if (prev != 0) {
        try result.appendSlice(try std.fmt.bufPrint(&buf, "{}", .{count}));
        try result.append(prev);
    }

    return try result.toOwnedSlice();
}

const testing = std.testing;

test "part 1 example input" {
    const expand_sequence = [_][]const u8{ "1", "11", "21", "1211", "111221", "312211" };
    for (0..(expand_sequence.len - 1)) |idx| {
        var expanded = try expand(testing.allocator, expand_sequence[idx]);
        defer testing.allocator.free(expanded);
        try testing.expectEqualSlices(u8, expanded, expand_sequence[idx + 1]);
    }
}
