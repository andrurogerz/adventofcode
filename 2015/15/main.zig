//! https://adventofcode.com/2015/day/15
const std = @import("std");

pub fn main() !void {
    const INPUT = @embedFile("input.txt");
    {
        const result = try part_1(4, INPUT);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(4, INPUT);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

fn part_1(comptime N: usize, comptime INPUT: []const u8) !usize {
    var ingredient_props = try parse(N, INPUT);
    // calories are ignored for part 1
    for (0..N) |idx| {
        ingredient_props[idx].calories = 0;
    }
    const counts: [N]usize = [_]usize{0} ** N;
    return maximize(N, 0, 0, counts, ingredient_props);
}

fn part_2(comptime N: usize, comptime INPUT: []const u8) !usize {
    const ingredient_props = try parse(N, INPUT);
    const target_calories: usize = 500;
    const counts: [N]usize = [_]usize{0} ** N;
    return maximize(N, 0, target_calories, counts, ingredient_props);
}

const IngredientProps = struct {
    name: []const u8,
    capacity: isize,
    durability: isize,
    flavor: isize,
    texture: isize,
    calories: isize,
};

fn maximize(comptime N: usize, idx: usize, target_calories: usize, counts: [N]usize, props: [N]IngredientProps) usize {
    var remaining: usize = 100;
    for (0..idx) |i| {
        remaining -= counts[i];
    }

    if (idx == N - 1) {
        var counts_new = counts;
        counts_new[idx] = remaining;
        return calculate(N, target_calories, counts_new, props);
    }

    var best: usize = 0;
    for (0..(remaining + 1)) |count| {
        var counts_new = counts;
        counts_new[idx] = count;
        best = @max(best, maximize(N, idx + 1, target_calories, counts_new, props));
    }

    return best;
}

fn calculate(comptime N: usize, target_calories: usize, counts: [N]usize, props: [N]IngredientProps) usize {
    var totals = IngredientProps{
        .name = "total",
        .capacity = 0,
        .durability = 0,
        .flavor = 0,
        .texture = 0,
        .calories = 0,
    };

    for (0..N) |idx| {
        totals.capacity += @as(isize, @intCast(counts[idx])) * props[idx].capacity;
        totals.durability += @as(isize, @intCast(counts[idx])) * props[idx].durability;
        totals.flavor += @as(isize, @intCast(counts[idx])) * props[idx].flavor;
        totals.texture += @as(isize, @intCast(counts[idx])) * props[idx].texture;
        totals.calories += @as(isize, @intCast(counts[idx])) * props[idx].calories;
    }

    var result: usize = 1;
    result *= if (totals.capacity < 0) 0 else @intCast(totals.capacity);
    result *= if (totals.durability < 0) 0 else @intCast(totals.durability);
    result *= if (totals.flavor < 0) 0 else @intCast(totals.flavor);
    result *= if (totals.texture < 0) 0 else @intCast(totals.texture);
    return if (totals.calories == target_calories) result else 0;
}

fn parse(comptime N: usize, comptime INPUT: []const u8) ![N]IngredientProps {
    var ingredient_props: [N]IngredientProps = undefined;
    var ingredient_count: usize = 0;
    var line_iter = std.mem.tokenizeSequence(u8, INPUT, "\n");
    while (line_iter.next()) |line_str| {
        ingredient_props[ingredient_count] = try parseLine(line_str);
        ingredient_count += 1;
    }

    if (N != ingredient_count) {
        return error.Unexpected;
    }

    return ingredient_props;
}

fn parseLine(line_str: []const u8) !IngredientProps {
    var part_iter = std.mem.tokenizeSequence(u8, line_str, " ");
    var props: IngredientProps = undefined;

    const name_str = part_iter.next() orelse return error.Unexpected;
    props.name = name_str[0..(name_str.len - 1)]; // remove trailing ':'
    if (!std.mem.eql(u8, "capacity", part_iter.next() orelse return error.Unexpected)) {
        return error.Unexpected;
    }
    const capacity_str = part_iter.next() orelse return error.Unexpected;
    props.capacity = try std.fmt.parseInt(isize, capacity_str[0..(capacity_str.len - 1)], 10);

    if (!std.mem.eql(u8, "durability", part_iter.next() orelse return error.Unexpected)) {
        return error.Unexpected;
    }
    const durability_str = part_iter.next() orelse return error.Unexpected;
    props.durability = try std.fmt.parseInt(isize, durability_str[0..(durability_str.len - 1)], 10);

    if (!std.mem.eql(u8, "flavor", part_iter.next() orelse return error.Unexpected)) {
        return error.Unexpected;
    }
    const flavor_str = part_iter.next() orelse return error.Unexpected;
    props.flavor = try std.fmt.parseInt(isize, flavor_str[0..(flavor_str.len - 1)], 10);

    if (!std.mem.eql(u8, "texture", part_iter.next() orelse return error.Unexpected)) {
        return error.Unexpected;
    }
    const texture_str = part_iter.next() orelse return error.Unexpected;
    props.texture = try std.fmt.parseInt(isize, texture_str[0..(texture_str.len - 1)], 10);

    if (!std.mem.eql(u8, "calories", part_iter.next() orelse return error.Unexpected)) {
        return error.Unexpected;
    }
    const calories_str = part_iter.next() orelse return error.Unexpected;
    props.calories = try std.fmt.parseInt(isize, calories_str, 10);

    if (part_iter.next()) |_| {
        return error.Unexpected;
    }

    return props;
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
    \\Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3
;

test "part 1 example input" {
    try testing.expectEqual(part_1(2, EXAMPLE_INPUT), 62842880);
}

test "part 2 example input" {
    try testing.expectEqual(part_2(2, EXAMPLE_INPUT), 57600000);
}
