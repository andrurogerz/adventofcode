//! https://adventofcode.com/2025/day/4
const std = @import("std");
const Grid = @import("grid.zig").Grid;

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
}

fn part_1(comptime input: []const u8) !usize {
    var result: usize = 0;
    const grid = Grid(input.len).init(input);
    var grid_iter = grid.iterate();
    while (grid_iter.next()) |pos| {
        if (grid.get(pos) == '.') continue;
        if (grid.get(pos) != '@') return error.InvalidInput;

        var occupied_neighbor_count: usize = 0;
        var neighbor_iter = grid.neighbors(pos);
        while (neighbor_iter.next()) |neighbor_pos| {
            if (grid.get(neighbor_pos) == '@') occupied_neighbor_count += 1;
        }

        if (occupied_neighbor_count < 4) result += 1;
    }
    return result;
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
    \\
;

test "part 1 example input" {
    try testing.expectEqual(part_1(EXAMPLE_INPUT), 13);
}
