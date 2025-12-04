//! https://adventofcode.com/2025/day/2
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
}

pub fn part_1(input: []const u8) !usize {
    var invalid_id_sum: usize = 0;

    // Input must be a single line.
    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    const line = line_iter.next() orelse return error.InvalidInput;
    if (line_iter.next()) |_| return error.InvalidInput;

    // Iterate comma-separated ranges.
    var range_iter = std.mem.tokenizeSequence(u8, line, ",");
    while (range_iter.next()) |range| {

        // Split the range into two integers.
        var iter = std.mem.tokenizeSequence(u8, range, "-");
        const start_str = iter.next() orelse return error.InvalidInput;
        const end_str = iter.next() orelse return error.InvalidInput;
        if (iter.next()) |_| return error.InvalidInput;

        // Input strings must not have leading zeros (per spec).
        if (start_str[0] == '0') return error.InvalidInput;
        if (end_str[0] == '0') return error.InvalidInput;

        const start = try std.fmt.parseInt(usize, start_str, 10);
        const end = try std.fmt.parseInt(usize, end_str, 10);

        // Deal with odd length start string by rounding up to the next power of 10.
        const start_half_len = @divTrunc(start_str.len + 1, 2);
        const start_half = switch (start_str.len) {
            0 => return error.InvalidInput,
            1 => 1,
            3, 5, 7, 9, 11, 13, 15, 17, 19 => roundUp10(try std.fmt.parseInt(usize, start_str[0 .. start_str.len / 2], 10)),
            else => try std.fmt.parseInt(usize, start_str[0 .. start_str.len / 2], 10),
        };

        // Deal with odd length end string by rounding up to the next power of 10 minus 1.
        const end_half_len = @divTrunc(end_str.len, 2);
        const end_half = switch (end_str.len) {
            0 => return error.InvalidInput,
            1 => 0, // possible for a single digit range
            3, 5, 7, 9, 11, 13, 15, 17, 19 => roundUp10(try std.fmt.parseInt(usize, start_str[0 .. start_str.len / 2], 10)) - 1,
            else => try std.fmt.parseInt(usize, end_str[0 .. end_str.len / 2], 10),
        };

        if (start_half > end_half) continue; // No possible invalid values.

        // For now, don't handle the scenario where the range covers multiple lengths.
        if (start_half_len != end_half_len) return error.NotSupported;

        //std.debug.print("range:{s}-{s}\n", .{start_str, end_str});
        for (start_half..end_half + 1) |half| {
            var value: usize = half;
            for (0..start_half_len) |_| {
                value *= 10;
            }

            value += half;

            if (value < start) continue;
            if (value > end) continue;

            //std.debug.print("found:{}\n", .{value});
            invalid_id_sum += value;
        }
    }
    return invalid_id_sum;
}

fn roundUp10(value: usize) usize {
    if (value == 0) return 1;
    var result: usize = 10;
    while (result < value) result *= 10;
    return result;
}

const testing = std.testing;

const EXAMPLE_INPUT = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

test "part 1 example input" {
    try testing.expectEqual(part_1(EXAMPLE_INPUT), 1227775554);
}
