//! https://adventofcode.com/2015/day/11
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const len = input.len - 1;
    const result_1 = try nextPassword(len, input[0..len]);
    std.debug.print("part 1 result: {s}\n", .{result_1});
    const result_2 = try nextPassword(len, &result_1);
    std.debug.print("part 2 result: {s}\n", .{result_2});
}

fn nextPassword(comptime len: usize, input: []const u8) ![len]u8 {
    var new_pw = try increment(len, input);
    while (!try isValid(&new_pw)) {
        new_pw = try increment(len, &new_pw);
    }
    return new_pw;
}

fn increment(comptime len: usize, cur_pw: []const u8) ![len]u8 {
    var new_pw: [len]u8 = [_]u8{0} ** len;
    var carry: u1 = 1;
    for (0..len) |_idx| {
        const pos = len - _idx - 1;
        const ch = cur_pw[pos];
        if (ch > 'z' or ch < 'a') {
            return error.Unexpected;
        }

        if (ch + carry > 'z') {
            new_pw[pos] = 'a';
        } else {
            new_pw[pos] = ch + carry;
            carry = 0;
        }
    }

    if (carry != 0) {
        // result string would be longer than LEN
        return error.Unexpected;
    }

    return new_pw;
}

fn isValid(pw: []const u8) !bool {
    var pair_count: usize = 0;
    var run_count: usize = 0;
    var contains_sequence: bool = false;
    for (0..pw.len) |idx| {
        const ch = pw[idx];
        if (ch < 'a' or ch > 'z') {
            return error.Unexpected;
        }

        switch (ch) {
            'i', 'o', 'l' => return false,
            else => {},
        }

        if (idx == 0) {
            run_count = 1;
            continue;
        }

        if (ch == pw[idx - 1]) {
            run_count += 1;
        } else {
            // Instead of directly counting pairs, identify runs of the same
            // character and divide each run length by two. This technique
            // avoids counting sequences like "aaa" as two pair while properly
            // counting "aaaa" as two pair.
            pair_count += run_count / 2;
            run_count = 1;
        }

        if (idx >= 2 and (ch - 1) == pw[idx - 1] and (ch - 2) == pw[idx - 2]) {
            contains_sequence = true;
        }
    }

    pair_count += run_count / 2;

    return pair_count >= 2 and contains_sequence;
}

const testing = std.testing;

test "part 1 password increment" {
    try testing.expectEqualSlices(u8, &try increment(2, "xx"), "xy");
    try testing.expectEqualSlices(u8, &try increment(2, "xy"), "xz");
    try testing.expectEqualSlices(u8, &try increment(2, "xz"), "ya");
    try testing.expectEqualSlices(u8, &try increment(2, "ya"), "yb");
}

test "part 1 password validation" {
    try testing.expect(!try isValid("hijklmmn"));
    try testing.expect(!try isValid("abbceffg"));
    try testing.expect(!try isValid("abbcegjk"));
    try testing.expect(!try isValid("abbcegjk"));
}

test "part 1 example input" {
    try testing.expectEqualSlices(u8, &try nextPassword(8, "abcdefgh"), "abcdffaa");
    try testing.expectEqualSlices(u8, &try nextPassword(8, "ghijklmn"), "ghjaabcc");
}
