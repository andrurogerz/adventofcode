//! https://adventofcode.com/2025/day/9
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
}

const Tile = struct {
    x: usize,
    y: usize,
};

pub fn part_1(comptime input: []const u8) !usize {
    @setEvalBranchQuota(50000);
    const tiles = try parse_input(comptime count_lines(input), input);
    var largest_area: usize = 0;
    for (0..tiles.len) |tile_1_idx| {
        for ((tile_1_idx + 1)..tiles.len) |tile_2_idx| {
            const tile_1 = tiles[tile_1_idx];
            const tile_2 = tiles[tile_2_idx];
            const x = if (tile_1.x > tile_2.x) (tile_1.x - tile_2.x) else (tile_2.x - tile_1.x);
            const y = if (tile_1.y > tile_2.y) (tile_1.y - tile_2.y) else (tile_2.y - tile_1.y);
            const area = (x + 1) * (y + 1);
            if (area > largest_area) largest_area = area;
        }
    }
    return largest_area;
}

fn count_lines(input: []const u8) usize {
    var result: usize = 0;
    for (input) |ch| {
        result += if (ch == '\n') 1 else 0;
    }
    return result;
}

fn parse_input(comptime N: usize, input: []const u8) ![N]Tile {
    var tile_idx: usize = 0;
    var tiles: [N]Tile = undefined;
    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line| {
        var val_iter = std.mem.tokenizeSequence(u8, line, ",");
        tiles[tile_idx].x = try std.fmt.parseInt(usize, val_iter.next() orelse return error.InvalidInput, 10);
        tiles[tile_idx].y = try std.fmt.parseInt(usize, val_iter.next() orelse return error.InvalidInput, 10);
        if (val_iter.next()) |_| return error.InvalidInput;
        tile_idx += 1;
    }
    if (tile_idx != N) return error.InvalidInput;
    return tiles;
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\7,1
    \\11,1
    \\11,7
    \\9,7
    \\9,5
    \\2,5
    \\2,3
    \\7,3
    \\
;

test "part 1 example input" {
    try testing.expectEqual(part_1(EXAMPLE_INPUT), 50);
}
