//! https://adventofcode.com/2015/day/18
const std = @import("std");
const Grid = @import("grid.zig").Grid;

pub fn main() !void {
    const input = @embedFile("./input.txt");
    {
        const result = try part_1(100, input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(100, input);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

fn part_1(rounds: usize, comptime input: []const u8) !usize {
    const light_grid = LightGrid(input.len).init(input);
    return simulate(input.len, rounds, light_grid, &.{});
}

fn part_2(rounds: usize, comptime input: []const u8) !usize {
    const light_grid = LightGrid(input.len).init(input);
    const corners = [_]Grid(input.len).Position{
        .{ .row = 0, .col = 0 },
        .{ .row = 0, .col = light_grid.grid.cols - 1 },
        .{ .row = light_grid.grid.rows - 1, .col = light_grid.grid.cols - 1 },
        .{ .row = light_grid.grid.rows - 1, .col = 0 },
    };
    return simulate(input.len, rounds, light_grid, &corners);
}

fn simulate(comptime N: usize, rounds: usize, grid: LightGrid(N), always_on: []const Grid(N).Position) usize {
    var light_grid = grid;
    for (always_on) |pos| {
        light_grid.turnOn(pos);
    }

    for (0..rounds) |_| {
        var light_grid_new = light_grid;
        var iter = light_grid.iterate();
        while (iter.next()) |pos| {
            const count = light_grid.countOnNeighbors(pos);
            switch (count) {
                3 => {
                    light_grid_new.turnOn(pos);
                },
                2 => {},
                else => {
                    light_grid_new.turnOff(pos);
                },
            }
        }

        light_grid = light_grid_new;
        for (always_on) |pos| {
            light_grid.turnOn(pos);
        }
    }
    return light_grid.countOn();
}

fn LightGrid(comptime N: usize) type {
    return struct {
        const Self = @This();

        grid: Grid(N),
        lights_on: std.StaticBitSet(N),

        pub fn init(data: []const u8) Self {
            const grid = Grid(N).init(data);
            var lights_on = std.StaticBitSet(N).initEmpty();
            var iter = grid.iterate();
            while (iter.next()) |pos| {
                switch (grid.get(pos)) {
                    '#' => {
                        lights_on.set(grid.getIndex(pos));
                    },
                    '.' => {},
                    else => unreachable,
                }
            }
            return Self{
                .grid = grid,
                .lights_on = lights_on,
            };
        }

        pub fn iterate(self: *const Self) Grid(N).Iterator {
            return self.grid.iterate();
        }

        pub fn countOn(self: *const Self) usize {
            return self.lights_on.count();
        }

        pub fn isOn(self: *const Self, pos: Grid(N).Position) bool {
            return self.lights_on.isSet(self.grid.getIndex(pos));
        }

        pub fn turnOn(self: *Self, pos: Grid(N).Position) void {
            self.lights_on.set(self.grid.getIndex(pos));
        }

        pub fn turnOff(self: *Self, pos: Grid(N).Position) void {
            self.lights_on.unset(self.grid.getIndex(pos));
        }

        pub fn countOnNeighbors(self: *const Self, pos: Grid(N).Position) usize {
            var count: usize = 0;
            var neighbor_iter = self.grid.neighbors(pos);
            while (neighbor_iter.next()) |neighbor_pos| {
                count += if (self.isOn(neighbor_pos)) 1 else 0;
            }
            return count;
        }

        pub fn print(self: *const Self) void {
            std.debug.print("\n", .{});
            for (0..self.grid.rows) |row| {
                for (0..self.grid.cols) |col| {
                    if (self.isOn(.{ .row = row, .col = col })) {
                        std.debug.print("#", .{});
                    } else {
                        std.debug.print(".", .{});
                    }
                }
                std.debug.print("\n", .{});
            }
        }
    };
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\.#.#.#
    \\...##.
    \\#....#
    \\..#...
    \\#.#..#
    \\####..
    \\
;

test "part 1 example input" {
    try testing.expectEqual(try part_1(4, EXAMPLE_INPUT), 4);
}

test "part 2 example input" {
    try testing.expectEqual(try part_2(4, EXAMPLE_INPUT), 14);
}
