//! https://adventofcode.com/2015/day/12
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
                if (number_start == null) {
                    number_start = idx;
                }
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

fn part_2(input: []const u8) !isize {
    var idx: usize = 0;
    return switch (input[0]) {
        '{' => parseObjectSum(input, &idx),
        '[' => parseArraySum(input, &idx),
        else => error.Unexpected,
    };
}

fn parseObjectSum(input: []const u8, idx: *usize) anyerror!isize {
    if (input[idx.*] != '{') {
        return error.Unexpected;
    }

    var sum: isize = 0;
    var is_red: bool = false;
    var number_start: ?usize = null;

    while (idx.* < input.len) {
        idx.* += 1;
        const ch = input[idx.*];
        switch (ch) {
            '{' => sum += try parseObjectSum(input, idx),
            '[' => sum += try parseArraySum(input, idx),
            '"' => {
                const string = try parseString(input, idx);
                is_red = is_red or std.mem.eql(u8, string, "red");
            },
            '-' => {
                if (number_start) |_| {
                    return error.Unexpected;
                }
                number_start = idx.*;
            },
            '0'...'9' => {
                if (number_start == null) {
                    number_start = idx.*;
                }
            },
            else => {
                if (number_start) |start_idx| {
                    sum += try std.fmt.parseInt(isize, input[start_idx..idx.*], 10);
                    number_start = null;
                }

                if (ch == '}') {
                    break;
                }
            },
        }
    }
    return if (is_red) 0 else sum;
}

fn parseArraySum(input: []const u8, idx: *usize) anyerror!isize {
    if (input[idx.*] != '[') {
        return error.Unexpected;
    }

    var sum: isize = 0;
    var number_start: ?usize = null;

    while (idx.* < input.len) {
        idx.* += 1;
        const ch = input[idx.*];
        switch (ch) {
            '{' => sum += try parseObjectSum(input, idx),
            '[' => sum += try parseArraySum(input, idx),
            '-' => {
                if (number_start) |_| {
                    return error.Unexpected;
                }
                number_start = idx.*;
            },
            '0'...'9' => {
                if (number_start == null) {
                    number_start = idx.*;
                }
            },
            else => {
                if (number_start) |start_idx| {
                    sum += try std.fmt.parseInt(isize, input[start_idx..idx.*], 10);
                    number_start = null;
                }

                if (ch == ']') {
                    break;
                }
            },
        }
    }
    return sum;
}

fn parseString(input: []const u8, idx: *usize) anyerror![]const u8 {
    if (input[idx.*] != '"') {
        return error.Unexpected;
    }

    const string_start: usize = idx.* + 1;

    while (idx.* < input.len) {
        idx.* += 1;
        const ch = input[idx.*];
        switch (ch) {
            '"' => return input[string_start..idx.*],
            'a'...'z' => {},
            else => return error.Unexpected,
        }
    }
    return error.Unexpected;
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

test "part 2 example input" {
    try testing.expectEqual(try part_2("[1,2,3]"), 6);
    try testing.expectEqual(try part_2("[1,{\"c\":\"red\",\"b\":2},3]"), 4);
    try testing.expectEqual(try part_2("{\"d\":\"red\",\"e\":[1,2,3,4],\"f\":5}"), 0);
    try testing.expectEqual(try part_2("[1,\"red\",5]"), 6);
}
