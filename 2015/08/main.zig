//! https://adventofcode.com/2015/day/8
const std = @import("std");

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

fn part_1(input: []const u8) usize {
    var code_size: usize = 0;
    var mem_size: usize = 0;

    var idx: usize = 0;
    while (idx < input.len) {
        switch (input[idx]) {
            ' ', '\t', '\r', '\n', '\x0B', '\x0C' => idx += 1, // ignore whitespace
            '\"' => {
                idx += 1;
                code_size += 1;
            },
            '\\' => switch (input[idx + 1]) {
                'x' => { // \xNN
                    std.debug.assert(std.ascii.isHex(input[idx + 2]));
                    std.debug.assert(std.ascii.isHex(input[idx + 3]));
                    idx += 4;
                    code_size += 4;
                    mem_size += 1;
                },
                '\\', '\"' => { // \\ or \"
                    idx += 2;
                    code_size += 2;
                    mem_size += 1;
                },
                else => unreachable,
            },
            'a'...'z', 'A'...'Z', '0'...'9' => {
                idx += 1;
                code_size += 1;
                mem_size += 1;
            },
            else => unreachable,
        }
    }
    return code_size - mem_size;
}

fn part_2(input: []const u8) usize {
    var code_size: usize = 0;
    var encoded_size: usize = 0;

    for (input) |ch| {
        switch (ch) {
            ' ', '\t', '\r', '\x0B', '\x0C' => {}, // ignore whitespace
            '\n' => {
                // Every line is re-quoted ""
                encoded_size += 2;
            },
            '\\', '\"' => {
                code_size += 1;
                encoded_size += 2;
            },
            'a'...'z', 'A'...'Z', '0'...'9' => {
                code_size += 1;
                encoded_size += 1;
            },
            else => unreachable,
        }
    }

    if (input[input.len - 1] != '\n') {
        // Compensate for input that doesn't end on a newline.
        encoded_size += 2;
    }
    return encoded_size - code_size;
}

const testing = std.testing;

test "part 1 example input" {
    const EXAMPLE_INPUT =
        \\""
        \\"abc"
        \\"aaa\"aaa"
        \\"\x27"
    ;

    try testing.expectEqual(part_1(EXAMPLE_INPUT), 12);
}

test "part 2 example input" {
    const EXAMPLE_INPUT =
        \\""
        \\"abc"
        \\"aaa\"aaa"
        \\"\x27"
    ;

    try testing.expectEqual(part_2(EXAMPLE_INPUT), 19);
}
