//! https://adventofcode.com/2015/day/13
const std = @import("std");

pub fn main() !void {
    const INPUT = @embedFile("input.txt");
    {
        const result = try part_1(8, INPUT);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(8, INPUT);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

fn part_1(comptime N: usize, comptime INPUT: []const u8) !isize {
    var sitters = NameMap(N){};
    var deltas = AdjacencyMatrix(isize, N){};

    try parse(N, INPUT, &sitters, &deltas);

    var seated = std.StaticBitSet(N).initEmpty();
    seated.set(0); // always seat id 0 first to seed the arrangement
    return traverse(N, 0, &seated, &sitters, &deltas);
}

fn part_2(comptime N: usize, comptime INPUT: []const u8) !isize {
    var sitters = NameMap(N + 1){};
    var deltas = AdjacencyMatrix(isize, N + 1){};

    // Add myself to the set with 0 value deltas with every other person.
    // AdjacencyMatrix values default to zero, so there is no need to add
    // these relationship values explicitly.
    try parse(N + 1, INPUT, &sitters, &deltas);
    _ = sitters.add("Me");

    var seated = std.StaticBitSet(N + 1).initEmpty();
    seated.set(0); // always seat id 0 first to seed the arrangement
    return traverse(N + 1, 0, &seated, &sitters, &deltas);
}

fn parse(comptime N: usize, comptime INPUT: []const u8, sitters: *NameMap(N), deltas: *AdjacencyMatrix(isize, N)) !void {
    var line_iter = std.mem.tokenizeSequence(u8, INPUT, "\n");
    while (line_iter.next()) |line_str| {
        var part_iter = std.mem.tokenizeSequence(u8, line_str, " ");
        const name = part_iter.next() orelse return error.Unexpected;
        _ = part_iter.next() orelse return error.Unexpected; // "would"
        const direction = part_iter.next() orelse return error.Unexpected;
        const delta_str = part_iter.next() orelse return error.Unexpected;
        const delta: isize = if (std.mem.eql(u8, direction, "gain"))
            try std.fmt.parseInt(isize, delta_str, 10)
        else if (std.mem.eql(u8, direction, "lose"))
            (0 - try std.fmt.parseInt(isize, delta_str, 10))
        else
            return error.Unexpected;
        _ = part_iter.next() orelse return error.Unexpected; // "happiness"
        _ = part_iter.next() orelse return error.Unexpected; // "units"
        _ = part_iter.next() orelse return error.Unexpected; // "by"
        _ = part_iter.next() orelse return error.Unexpected; // "sitting"
        _ = part_iter.next() orelse return error.Unexpected; // "next"
        _ = part_iter.next() orelse return error.Unexpected; // "to"
        const neighbor_str = part_iter.next() orelse return error.Unexpected;
        if (neighbor_str[neighbor_str.len - 1] != '.') return error.Unexpected;
        const neighbor = neighbor_str[0 .. neighbor_str.len - 1];
        if (part_iter.next()) |_| {
            return error.Unexpected;
        }

        const sitter_id = sitters.add(name);
        const neighbor_id = sitters.add(neighbor);

        deltas.put(sitter_id, neighbor_id, delta);
    }
}

fn traverse(comptime N: usize, prev_id: usize, seated: *const std.StaticBitSet(N), sitters: *const NameMap(N), deltas: *const AdjacencyMatrix(isize, N)) isize {
    std.debug.assert(sitters.count() <= N);

    if (seated.count() == sitters.count()) {
        return deltas.get(prev_id, 0) + deltas.get(0, prev_id);
    }

    std.debug.assert(seated.count() > 0);
    var result: isize = 0;
    for (0..sitters.count()) |next_id| {
        if (seated.isSet(next_id)) {
            continue;
        }

        var seated_new = seated.*;
        seated_new.set(next_id);

        // Weight of the graph edge is the sum of the deltas of the two ids.
        const delta = deltas.get(prev_id, next_id) + deltas.get(next_id, prev_id);
        const total_delta = delta + traverse(N, next_id, &seated_new, sitters, deltas);

        result = @max(result, total_delta);
    }

    return result;
}

fn NameMap(comptime N: usize) type {
    return struct {
        const Self = @This();

        names: [N][]const u8 = [_][]const u8{""} ** N,
        name_count: usize = 0,

        pub fn add(self: *Self, name: []const u8) usize {
            if (self.lookup(name)) |id| {
                return id;
            }

            const id = self.name_count;
            std.debug.assert(id < N);
            self.names[id] = name;
            self.name_count += 1;
            return id;
        }

        pub fn lookup(self: *const Self, name: []const u8) ?usize {
            const names = self.names[0..self.name_count];
            for (0..names.len) |id| {
                if (std.mem.eql(u8, names[id], name)) {
                    return id;
                }
            }
            return null;
        }

        pub fn get(self: *const Self, id: usize) []const u8 {
            std.debug.assert(id < N);
            return self.names[id];
        }

        pub fn count(self: *const Self) usize {
            return self.name_count;
        }
    };
}

fn AdjacencyMatrix(comptime T: type, comptime N: usize) type {
    return struct {
        const Self = @This();

        items: [N * N]T = [_]T{0} ** (N * N),

        pub fn put(self: *Self, col: usize, row: usize, value: T) void {
            const idx = index(col, row);
            std.debug.assert(idx < N * N);
            self.items[idx] = value;
        }

        pub fn get(self: *const Self, col: usize, row: usize) T {
            const idx = index(col, row);
            std.debug.assert(idx < N * N);
            return self.items[idx];
        }

        fn index(col: usize, row: usize) usize {
            std.debug.assert(row < N);
            std.debug.assert(col < N);
            return col + (row * N);
        }
    };
}

const testing = std.testing;

test "part 1 example input" {
    const EXAMPLE_INPUT =
        \\Alice would gain 54 happiness units by sitting next to Bob.
        \\Alice would lose 79 happiness units by sitting next to Carol.
        \\Alice would lose 2 happiness units by sitting next to David.
        \\Bob would gain 83 happiness units by sitting next to Alice.
        \\Bob would lose 7 happiness units by sitting next to Carol.
        \\Bob would lose 63 happiness units by sitting next to David.
        \\Carol would lose 62 happiness units by sitting next to Alice.
        \\Carol would gain 60 happiness units by sitting next to Bob.
        \\Carol would gain 55 happiness units by sitting next to David.
        \\David would gain 46 happiness units by sitting next to Alice.
        \\David would lose 7 happiness units by sitting next to Bob.
        \\David would gain 41 happiness units by sitting next to Carol.
    ;

    try testing.expectEqual(try part_1(4, EXAMPLE_INPUT), 330);
}
