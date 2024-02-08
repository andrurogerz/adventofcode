//! https://adventofcode.com/2015/day/16
const std = @import("std");

pub fn main() !void {
    const INPUT = @embedFile("input.txt");
    const pattern = [PropCount]usize{
        3, 7, 2, 3, 0, 0, 5, 3, 2, 1,
    };
    const items = try parse(500, INPUT);

    var result_1: ?usize = null;
    var result_2: ?usize = null;
    for (items, 1..) |item, idx| {
        if (match_1(item, pattern)) {
            if (result_1) |_| {
                // Only one item must match the pattern.
                return error.Unexpected;
            }
            result_1 = idx;
        }

        if (match_2(item, pattern)) {
            if (result_2) |_| {
                // Only one item must match the pattern.
                return error.Unexpected;
            }
            result_2 = idx;
        }
    }

    if (result_1) |result| {
        std.debug.print("part 1 result: {}\n", .{result});
    } else {
        return error.Unexpected;
    }

    if (result_2) |result| {
        std.debug.print("part 2 result: {}\n", .{result});
    } else {
        return error.Unexpected;
    }
}

fn calculate(comptime N: usize, comptime INPUT: []const u8) !usize {
    const props = [PropCount]usize{
        3, 7, 2, 3, 0, 0, 5, 3, 2, 1,
    };
    const items = try parse(N, INPUT);
    for (items, 0..) |item, idx| {
        if (match_1(item, props)) {
            return idx + 1;
        }
    }
    return error.Unexpected;
}

fn part_2(comptime N: usize, comptime INPUT: []const u8) !usize {
    const props = [PropCount]usize{
        3, 7, 2, 3, 0, 0, 5, 3, 2, 1,
    };
    const items = try parse(N, INPUT);
    for (items, 0..) |item, idx| {
        if (match_2(item, props)) {
            return idx + 1;
        }
    }
    return error.Unexpected;
}

// NOTE: names must match raw property strings in input
const Prop = enum(usize) {
    children,
    cats,
    samoyeds,
    pomeranians,
    akitas,
    vizslas,
    goldfish,
    trees,
    cars,
    perfumes,
};

const PropCount = std.meta.fields(Prop).len;

fn parse(comptime N: usize, comptime INPUT: []const u8) ![N][PropCount]?usize {
    var items: [N][PropCount]?usize = undefined;
    var line_iter = std.mem.tokenizeSequence(u8, INPUT, "\n");
    var count: usize = 0;
    while (line_iter.next()) |line_str| {
        items[count] = try parseLine(line_str);
        count += 1;
    }
    return items;
}

fn parseLine(line_str: []const u8) ![PropCount]?usize {
    var props = [PropCount]?usize{
        null, null, null, null, null, null, null, null, null, null,
    };

    var part_iter = std.mem.tokenizeSequence(u8, line_str, " ");
    _ = part_iter.next() orelse return error.Unexpected; // Sue
    _ = part_iter.next() orelse return error.Unexpected; // NN:
    while (true) {
        const prop_name_str = part_iter.next() orelse break;
        if (prop_name_str.len == 0 or prop_name_str[prop_name_str.len - 1] != ':') {
            return error.Unexpected;
        }
        const prop_name = prop_name_str[0..(prop_name_str.len - 1)];

        const prop_value_str = part_iter.next() orelse return error.Unexpected;
        if (prop_value_str.len == 0) {
            return error.Unexpected;
        }
        const len: usize = if (prop_value_str[prop_value_str.len - 1] == ',') prop_value_str.len - 1 else prop_value_str.len;
        const prop_value = try std.fmt.parseInt(usize, prop_value_str[0..len], 10);

        const prop = std.meta.stringToEnum(Prop, prop_name) orelse return error.Unexpected;
        props[@intFromEnum(prop)] = prop_value;
    }
    return props;
}

fn match_1(item: [PropCount]?usize, pattern: [PropCount]usize) bool {
    for (0..PropCount) |idx| {
        if (item[idx]) |value| {
            if (value != pattern[idx]) {
                return false;
            }
        }
    }
    return true;
}

fn match_2(item: [PropCount]?usize, pattern: [PropCount]usize) bool {
    for (0..PropCount) |idx| {
        const value = item[idx] orelse continue;
        const prop = std.meta.intToEnum(Prop, idx) catch unreachable;
        switch (prop) {
            .trees, .cats => {
                if (value <= pattern[idx]) {
                    return false;
                }
            },
            .pomeranians, .goldfish => {
                if (value >= pattern[idx]) {
                    return false;
                }
            },
            else => {
                if (value != pattern[idx]) {
                    return false;
                }
            },
        }
    }
    return true;
}
