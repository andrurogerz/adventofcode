//! https://adventofcode.com/2015/day/5
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

fn part_1(input: []const u8) !usize {
    var nice_string_count: usize = 0;
    var string_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (string_iter.next()) |string| {
        if (stringIsNice1(string)) {
            nice_string_count += 1;
        }
    }
    return nice_string_count;
}

fn part_2(input: []const u8) !usize {
    var nice_string_count: usize = 0;
    var string_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (string_iter.next()) |string| {
        if (stringIsNice2(string)) {
            nice_string_count += 1;
        }
    }
    return nice_string_count;
}

fn stringIsNice1(string: []const u8) bool {
    var has_double_letter = false;
    var vowel_count: usize = 0;
    for (0..string.len) |idx| {
        const ch = string[idx];
        vowel_count += switch (ch) {
            'a' => 1,
            'e' => 1,
            'i' => 1,
            'o' => 1,
            'u' => 1,
            else => 0,
        };

        if (idx == 0) {
            continue;
        }

        has_double_letter = has_double_letter or (string[idx] == string[idx - 1]);

        const naughty_strings = [_]*const [2:0]u8{ "ab", "cd", "pq", "xy" };
        for (naughty_strings) |naughty_string| {
            if (std.mem.eql(u8, naughty_string, string[(idx - 1)..(idx + 1)])) {
                return false;
            }
        }
    }

    return has_double_letter and (vowel_count > 2);
}

fn stringIsNice2(string: []const u8) bool {
    const MAX_PAIR_ENCODED = ('z' - 'a' + 1) * ('z' - 'a' + 1);
    var seen_repeats = false;
    var seen_two_pairs = false;
    var pair_offsets = [_]usize{std.math.maxInt(usize)} ** MAX_PAIR_ENCODED;
    for (0..string.len) |idx| {
        std.debug.assert(string[idx] >= 'a');
        std.debug.assert(string[idx] <= 'z');

        if (idx == 0) continue;

        const pair_encoded: usize = @as(usize, (string[idx - 1] - 'a')) + (@as(usize, string[idx] - 'a') * 26);
        if (pair_offsets[pair_encoded] == std.math.maxInt(usize)) {
            pair_offsets[pair_encoded] = idx - 1;
        } else if (!seen_two_pairs) {
            seen_two_pairs = ((idx - 1) - pair_offsets[pair_encoded] > 1);
        }

        if (idx <= 1) continue;

        seen_repeats = seen_repeats or string[idx] == string[idx - 2];
    }

    return seen_repeats and seen_two_pairs;
}

const testing = std.testing;

test "part 1 example input" {
    try testing.expect(stringIsNice1("ugknbfddgicrmopn"));
    try testing.expect(stringIsNice1("aaa"));
    try testing.expect(!stringIsNice1("jchzalrnumimnmhp"));
    try testing.expect(!stringIsNice1("haegwjzuvuyypxyu"));
    try testing.expect(!stringIsNice1("dvszwmarrgswjxmb"));
}

test "part 2 example input" {
    try testing.expect(stringIsNice2("qjhvhtzxzqqjkmpb"));
    try testing.expect(stringIsNice2("xxyxx"));
    try testing.expect(stringIsNice2("aaaa"));
    try testing.expect(!stringIsNice2("uurcxstgmygtbstg"));
    try testing.expect(!stringIsNice2("ieodomkazucvgmuy"));
    try testing.expect(!stringIsNice2("aaa"));
}
