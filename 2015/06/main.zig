//! https://adventofcode.com/2015/day/6
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const result = try part_1(input);
    std.debug.print("part 1 result: {}\n", .{result});
}

fn part_1(input: []const u8) !usize {
    var lights = LightSet{};
    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line_str| {
        const instr = try parseInstruction(line_str);
        try lights.execute(instr);
    }
    return lights.onCount();
}

fn parseInstruction(line_str: []const u8) !LightSet.Instruction {
    const Tokens = struct {
        const Toggle = "toggle ";
        const TurnOn = "turn on ";
        const TurnOff = "turn off ";
        const Through = " through ";
    };

    var op: LightSet.Op = undefined;
    var remainder: []const u8 = undefined;
    if (std.mem.eql(u8, Tokens.Toggle, line_str[0..Tokens.Toggle.len])) {
        op = .Toggle;
        remainder = line_str[Tokens.Toggle.len..];
    } else if (std.mem.eql(u8, Tokens.TurnOn, line_str[0..Tokens.TurnOn.len])) {
        op = .TurnOn;
        remainder = line_str[Tokens.TurnOn.len..];
    } else if (std.mem.eql(u8, Tokens.TurnOff, line_str[0..Tokens.TurnOff.len])) {
        op = .TurnOff;
        remainder = line_str[Tokens.TurnOff.len..];
    } else {
        return error.Unexpected;
    }

    var point_iter = std.mem.tokenizeSequence(u8, remainder, Tokens.Through);
    const start_point_str = point_iter.next() orelse return error.Unexpected;
    const end_point_str = point_iter.next() orelse return error.Unexpected;
    if (point_iter.next()) |_| {
        return error.Unexpected;
    }
    return LightSet.Instruction{
        .op = op,
        .start = try parsePosition(start_point_str),
        .end = try parsePosition(end_point_str),
    };
}

fn parsePosition(point_str: []const u8) !LightSet.Position {
    var iter = std.mem.tokenizeSequence(u8, point_str, ",");
    const col_str = iter.next() orelse return error.Unexpected;
    const row_str = iter.next() orelse return error.Unexpected;
    if (iter.next()) |_| {
        return error.Unexpected;
    }
    return LightSet.Position{
        .col = try std.fmt.parseInt(usize, col_str, 10),
        .row = try std.fmt.parseInt(usize, row_str, 10),
    };
}

const LightSet = LightSetT(1000, 1000);

fn LightSetT(comptime C: usize, comptime R: usize) type {
    return struct {
        const Self = @This();

        light_set: std.StaticBitSet(C * R) = std.StaticBitSet(C * R).initEmpty(),

        pub const Op = enum {
            Toggle,
            TurnOn,
            TurnOff,
        };

        pub const Position = struct {
            col: usize,
            row: usize,
        };

        pub const Instruction = struct {
            op: Op,
            start: Position,
            end: Position,
        };

        pub fn execute(self: *Self, instr: Instruction) !void {
            for (instr.start.col..(instr.end.col + 1)) |col| {
                for (instr.start.row..(instr.end.row + 1)) |row| {
                    const idx = try indexOf(.{ .row = row, .col = col });
                    switch (instr.op) {
                        .Toggle => self.light_set.toggle(idx),
                        .TurnOn => self.light_set.set(idx),
                        .TurnOff => self.light_set.unset(idx),
                    }
                }
            }
        }

        pub fn onCount(self: *const Self) usize {
            return self.light_set.count();
        }

        fn indexOf(pos: Position) !usize {
            if (pos.row >= R) {
                return error.Unexpected;
            }
            if (pos.col >= C) {
                return error.Unexpected;
            }
            return pos.col + pos.row * C;
        }
    };
}

const testing = std.testing;

test "part 1 example input" {
    var lights = LightSet{};
    {
        const instr = try parseInstruction("turn on 0,0 through 999,999");
        try lights.execute(instr);
        try testing.expectEqual(lights.onCount(), 1000000);
    }
    {
        const instr = try parseInstruction("toggle 0,0 through 999,0");
        try lights.execute(instr);
        try testing.expectEqual(lights.onCount(), 1000000 - 1000);
    }
    {
        const instr = try parseInstruction("turn off 499,499 through 500,500");
        try lights.execute(instr);
        try testing.expectEqual(lights.onCount(), 1000000 - 1000 - 4);
    }
}
