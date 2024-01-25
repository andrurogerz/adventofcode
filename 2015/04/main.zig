//! https://adventofcode.com/2015/day/4
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input[0..8]);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(input[0..8]);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

const Md5 = std.crypto.hash.Md5;

fn part_1(input: []const u8) !usize {
    var value: usize = 1;
    while (true) {
        const digest = try hash(input, value);
        if (digest[0] == 0 and digest[1] == 0 and digest[2] <= 0xF) {
            break;
        }
        value += 1;
    }
    return value;
}

fn part_2(input: []const u8) !usize {
    var value: usize = 1;
    while (true) {
        const digest = try hash(input, value);
        if (digest[0] == 0 and digest[1] == 0 and digest[2] == 0) {
            break;
        }
        value += 1;
    }
    return value;
}

fn hash(key: []const u8, value: usize) ![Md5.digest_length]u8 {
    var input: [128]u8 = undefined;
    @memcpy(input[0..key.len], key);
    const fmt = try std.fmt.bufPrint(input[key.len..], "{}", .{value});

    var digest: [Md5.digest_length]u8 = undefined;
    Md5.hash(input[0..(fmt.len + key.len)], &digest, .{});
    return digest;
}

const testing = std.testing;

test "part 1 example input" {
    try testing.expectEqual(part_1("abcdef"), 609043);
    try testing.expectEqual(part_1("pqrstuv"), 1048970);
}
