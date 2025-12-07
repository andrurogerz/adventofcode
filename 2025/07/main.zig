//! https://adventofcode.com/2025/day/7
const std = @import("std");
const Grid = @import("grid.zig").Grid;

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
}

pub fn part_1(comptime input: []const u8) !usize {
    @setEvalBranchQuota(21000);
    const grid = comptime Grid(input.len).init(input);
    var beam_positions = [_]bool{false} ** grid.cols;
    for (0..grid.cols) |col| {
        if (grid.get(.{ .row = 0, .col = col }) == 'S') {
            beam_positions[col] = true;
        }
    }

    var split_count: usize = 0;
    for (1..grid.rows) |row| {
        var next_beam_positions = [_]bool{false} ** grid.cols;
        for (0..grid.cols) |col| {
            if (!beam_positions[col]) continue;
            switch (grid.get(.{ .row = row, .col = col })) {
                '.' => {
                    next_beam_positions[col] = true;
                },
                '^' => {
                    split_count += 1;
                    next_beam_positions[col] = false;
                    if (col > 0) next_beam_positions[col - 1] = true;
                    if (col < grid.cols - 1) next_beam_positions[col + 1] = true;
                },
                else => return error.InvalidInput,
            }
        }
        beam_positions = next_beam_positions;

        for (0..beam_positions.len) |col| {
            const ch: u8 = if (beam_positions[col]) '|' else grid.get(.{ .row = row, .col = col });
            std.debug.print("{c}", .{ch});
        }
        std.debug.print(" {}\n", .{split_count});
    }
    return split_count;
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\.......S.......
    \\...............
    \\.......^.......
    \\...............
    \\......^.^......
    \\...............
    \\.....^.^.^.....
    \\...............
    \\....^.^...^....
    \\...............
    \\...^.^...^.^...
    \\...............
    \\..^...^.....^..
    \\...............
    \\.^.^.^.^.^...^.
    \\...............
    \\
;

test "part 1 example input" {
    try testing.expectEqual(part_1(EXAMPLE_INPUT), 21);
}
