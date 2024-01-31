//! https://adventofcode.com/2015/day/9
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const result = try part_1(input);
    std.debug.print("part 1 result: {}\n", .{result});
}

fn part_1(comptime input: []const u8) !usize {
    const MAX_CITIES: usize = 8;
    var names = NameMap(MAX_CITIES){};
    var distances = AdjacencyMatrix(MAX_CITIES){};

    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line_str| {
        var part_iter = std.mem.tokenizeSequence(u8, line_str, " ");
        const depart_city = part_iter.next() orelse return error.Unexpected;
        _ = part_iter.next() orelse return error.Unexpected; // "to"
        const arrive_city = part_iter.next() orelse return error.Unexpected;
        _ = part_iter.next() orelse return error.Unexpected; // "="
        const distance_str = part_iter.next() orelse return error.Unexpected;
        if (part_iter.next()) |_| {
            return error.Unexpected;
        }

        const distance = try std.fmt.parseInt(usize, distance_str, 10);
        const depart_id = names.add(depart_city);
        const arrive_id = names.add(arrive_city);

        distances.put(depart_id, arrive_id, distance);
        distances.put(arrive_id, depart_id, distance);
    }

    const visited = std.StaticBitSet(MAX_CITIES).initEmpty();
    return shortestTraversal(MAX_CITIES, 0, &visited, &names, &distances);
}

fn shortestTraversal(comptime N: usize, prev_id: usize, visited: *const std.StaticBitSet(N), names: *const NameMap(N), distances: *const AdjacencyMatrix(N)) usize {
    std.debug.assert(names.count() <= N);
    if (visited.count() == names.count()) {
        return 0;
    }

    var result: usize = std.math.maxInt(usize);
    const is_first = (visited.count() == 0);
    for (0..names.count()) |next_id| {
        if (visited.isSet(next_id)) {
            continue;
        }

        var visited_new = visited.*;
        visited_new.set(next_id);

        const next_distance = if (!is_first) distances.get(prev_id, next_id) else 0;
        result = @min(result, shortestTraversal(N, next_id, &visited_new, names, distances) + next_distance);
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

fn AdjacencyMatrix(comptime N: usize) type {
    return struct {
        const Self = @This();

        items: [N * N]usize = [_]usize{0} ** (N * N),

        pub fn put(self: *Self, col: usize, row: usize, value: usize) void {
            const idx = index(col, row);
            std.debug.assert(idx < N * N);
            self.items[idx] = value;
        }

        pub fn get(self: *const Self, col: usize, row: usize) usize {
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
        \\London to Dublin = 464
        \\London to Belfast = 518
        \\Dublin to Belfast = 141
    ;
    try testing.expectEqual(try part_1(EXAMPLE_INPUT), 605);
}
