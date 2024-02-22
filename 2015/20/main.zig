//! https://adventofcode.com/2015/day/20
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const value = comptime if (input[input.len - 1] == '\n')
        try std.fmt.parseInt(usize, input[0..(input.len - 1)], 10)
    else
        try std.fmt.parseInt(usize, input, 10);
    {
        const result = try part_1(value);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(value);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

pub fn part_1(comptime target: usize) !usize {
    for (1..target) |house| {
        const count = sumDivisors(house, std.math.maxInt(usize));
        if (count * 10 > target) {
            return house;
        }
    }
    return error.Unexpected;
}

pub fn part_2(comptime target: usize) !usize {
    for (1..target) |house| {
        const count = sumDivisors(house, 50);
        if (count * 11 > target) {
            return house;
        }
    }
    return error.Unexpected;
}

fn sumDivisors(value: usize, comptime max: usize) usize {
    var sum: usize = if (value == 1) value else value + 1;
    var divisor: usize = 2;
    var increment: usize = 1;

    if (value % 3 != 0) {
        increment = 3;
    }

    if (value % 2 != 0) {
        divisor = 3;
        increment = 2;
    }

    while (divisor * divisor <= value) {
        if (value % divisor == 0) {
            if (value / divisor <= max) {
                sum += divisor;
            }

            const divisor_2 = value / divisor;
            if (divisor != divisor_2 and value / divisor_2 <= max) {
                sum += divisor_2;
            }
        }
        divisor += increment;
    }
    return sum;
}

const testing = std.testing;

test "part 1 example input" {
    try testing.expectEqual(sumDivisors(1, std.math.maxInt(usize)), 1);
    try testing.expectEqual(sumDivisors(2, std.math.maxInt(usize)), 3);
    try testing.expectEqual(sumDivisors(3, std.math.maxInt(usize)), 4);
    try testing.expectEqual(sumDivisors(4, std.math.maxInt(usize)), 7);
    try testing.expectEqual(sumDivisors(5, std.math.maxInt(usize)), 6);
    try testing.expectEqual(sumDivisors(6, std.math.maxInt(usize)), 12);
    try testing.expectEqual(sumDivisors(7, std.math.maxInt(usize)), 8);
    try testing.expectEqual(sumDivisors(8, std.math.maxInt(usize)), 15);
    try testing.expectEqual(sumDivisors(9, std.math.maxInt(usize)), 13);
}
