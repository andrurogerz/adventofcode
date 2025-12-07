//! https://adventofcode.com/2025/day/7
const std = @import("std");
const Grid = @import("grid.zig").Grid;

pub fn main() !void {
    const input = @embedFile("input.txt");
    {
        const result = try part_1(input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();
        const result = try part_2(allocator, input);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

pub fn part_1(comptime input: []const u8) !usize {
    @setEvalBranchQuota(21000);
    const grid = comptime Grid.init(input);
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

const SolutionCache = std.AutoHashMap(Grid.Position, usize);

pub fn part_2(allocator: std.mem.Allocator, comptime input: []const u8) !usize {
    @setEvalBranchQuota(21000);
    const grid = comptime Grid.init(input);
    var col_beam: usize = grid.cols;
    for (0..grid.cols) |col| {
        if (grid.get(.{ .row = 0, .col = col }) == 'S') {
            col_beam = col;
            break;
        }
    }

    if (col_beam == grid.cols) return error.InvalidInput;

    var cache = SolutionCache.init(allocator);
    defer cache.deinit();

    const row_next: usize = 1;
    return try solve(&cache, col_beam, row_next, grid);
}

fn solve(cache: *SolutionCache, col_beam: usize, row_next: usize, grid: Grid) !usize {
    if (row_next == grid.rows) return 1;

    const pos = Grid.Position{ .col = col_beam, .row = row_next };
    if (cache.getEntry(pos)) |entry| return entry.value_ptr.*;

    var result: usize = 0;
    switch (grid.get(pos)) {
        '.' => result = try solve(cache, col_beam, row_next + 1, grid),
        '^' => {
            if (col_beam > 0) result += try solve(cache, col_beam - 1, row_next + 1, grid);
            if (col_beam < grid.cols - 1) result += try solve(cache, col_beam + 1, row_next + 1, grid);
            return result;
        },
        else => return error.InvalidInput,
    }

    try cache.put(pos, result);
    return result;
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

test "part 2 example input" {
    try testing.expectEqual(part_2(testing.allocator, EXAMPLE_INPUT), 40);
}
