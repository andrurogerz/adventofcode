//! https://adventofcode.com/2025/day/9
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
            const width = if (tile_1.x > tile_2.x) (tile_1.x - tile_2.x) else (tile_2.x - tile_1.x);
            const height = if (tile_1.y > tile_2.y) (tile_1.y - tile_2.y) else (tile_2.y - tile_1.y);
            const area = (width + 1) * (height + 1);
            if (area > largest_area) largest_area = area;
        }
    }
    return largest_area;
}

pub fn part_2(comptime input: []const u8) !usize {
    @setEvalBranchQuota(50000);
    const tiles = try parse_input(comptime count_lines(input), input);
    var largest_area: usize = 0;
    for (0..tiles.len) |tile_1_idx| {
        for ((tile_1_idx + 1)..tiles.len) |tile_2_idx| {
            // Calculate the rectangle difined by the consecutive pair of tiles.
            const x_min = @min(tiles[tile_1_idx].x, tiles[tile_2_idx].x);
            const x_max = @max(tiles[tile_1_idx].x, tiles[tile_2_idx].x);
            const y_min = @min(tiles[tile_1_idx].y, tiles[tile_2_idx].y);
            const y_max = @max(tiles[tile_1_idx].y, tiles[tile_2_idx].y);

            var intersect = false;
            for (0..tiles.len) |tile_idx| {
                // Consider each consecutive pair of tiles a line (with the last tile connecting
                // back to the first). If any line intersects with a rectangle edge, it is not a
                // valid solution.
                const tile_1 = tiles[tile_idx];
                const tile_2 = if (tile_idx < tiles.len - 1) tiles[tile_idx + 1] else tiles[0];

                if (tile_1.y == tile_2.y and tile_1.y > y_min and tile_1.y < y_max) {
                    // The line between the two tiles is horizontal.
                    if (tile_1.x == tile_2.x) return error.InvalidInput;

                    // Determine if any point on the horizontal line falls inside the rectangle by
                    // checking if it intersects the left or right side.
                    if ((tile_1.x > x_min and tile_1.x < x_max) or //
                        (tile_2.x > x_min and tile_2.x < x_max) or //
                        (tile_1.x <= x_min and tile_2.x >= x_max) or //
                        (tile_2.x <= x_min and tile_1.x >= x_max))
                    {
                        intersect = true;
                        break;
                    }
                }

                if (tile_1.x == tile_2.x and tile_1.x > x_min and tile_1.x < x_max) {
                    // The line between the two tiles is vertical.
                    if (tile_1.y == tile_2.y) return error.InvalidInput;

                    // Determine if any point on the vertical line falls inside the rectangle by
                    // checking if it intersects the top or bottom.
                    if ((tile_1.y > y_min and tile_1.y < y_max) or //
                        (tile_2.y > y_min and tile_2.y < y_max) or //
                        (tile_1.y <= y_min and tile_2.y >= y_max) or //
                        (tile_2.y <= y_min and tile_1.y >= y_max))
                    {
                        intersect = true;
                        break;
                    }
                }
            }

            if (intersect) continue;

            const height = y_max - y_min;
            const width = x_max - x_min;
            const area = (width + 1) * (height + 1);
            if (area > largest_area) {
                largest_area = area;
            }
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
        // Consecutive tiles must be either in the same column or the same row.
        if (tile_idx > 0 and !(tiles[tile_idx - 1].x == tiles[tile_idx].x or tiles[tile_idx - 1].y == tiles[tile_idx].y)) {
            return error.InvalidInput;
        }
        tile_idx += 1;
    }
    if (tile_idx != N) return error.InvalidInput;

    // The list wraps, so the last tile must be either in the same column or row as the first.
    if (!(tiles[N - 1].x == tiles[0].x or tiles[N - 1].y == tiles[0].y)) return error.InvalidInput;
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

test "part 2 example input" {
    try testing.expectEqual(part_2(EXAMPLE_INPUT), 24);
}
