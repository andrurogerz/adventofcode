const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const result = try part_1(input);
    std.debug.print("part 1 result: {}\n", .{result});
}

fn part_1(input: []const u8) !usize {
    var nice_string_count: usize = 0;
    var string_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (string_iter.next()) |string| {
        if (stringIsNice(string)) {
            nice_string_count += 1;
        }
    }
    return nice_string_count;
}

fn stringIsNice(string: []const u8) bool {
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

const testing = std.testing;

test "part 1 example input" {
    try testing.expect(stringIsNice("ugknbfddgicrmopn"));
    try testing.expect(stringIsNice("aaa"));
    try testing.expect(!stringIsNice("jchzalrnumimnmhp"));
    try testing.expect(!stringIsNice("haegwjzuvuyypxyu"));
    try testing.expect(!stringIsNice("dvszwmarrgswjxmb"));
}
