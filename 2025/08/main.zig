//! https://adventofcode.com/2025/day/8
const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = @embedFile("input.txt");
    {
        const result = try part_1(allocator, input, 1000);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(allocator, input);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

const Node = struct {
    const Self = @This();

    x: usize,
    y: usize,
    z: usize,

    fn distance_sqr(self: Self, other: Self) usize {
        const x = if (self.x > other.x) self.x - other.x else other.x - self.x;
        const y = if (self.y > other.y) self.y - other.y else other.y - self.y;
        const z = if (self.z > other.z) self.z - other.z else other.z - self.z;
        return x * x + y * y + z * z;
    }
};

const NodeDistance = struct {
    const Self = @This();

    node_1_idx: usize,
    node_2_idx: usize,
    distance_sqr: usize,

    pub fn isLessThan(_: void, lhs: Self, rhs: Self) bool {
        return lhs.distance_sqr < rhs.distance_sqr;
    }
};

pub fn part_1(allocator: std.mem.Allocator, comptime input: []const u8, comptime connection_count: usize) !usize {
    @setEvalBranchQuota(50000);
    const nodes = try parse_input(comptime count_lines(input), input);

    const distances = calculate_distances(nodes.len, nodes);
    if (connection_count >= distances.len) return error.InvalidInput;

    // Connect the N shortest distances. These are our graph edges.
    var connections = [_]std.ArrayList(usize){std.ArrayList(usize).init(allocator)} ** nodes.len;
    defer for (connections) |node| node.deinit();
    for (0..connection_count) |idx| {
        const connect = distances[idx];
        try connections[connect.node_1_idx].append(connect.node_2_idx);
        try connections[connect.node_2_idx].append(connect.node_1_idx);
    }

    const sorted_node_counts = traverse_graphs(nodes.len, connections);

    // Multiply the three largest to return as the solution.
    var result: usize = 1;
    for (0..3) |idx| {
        result *= sorted_node_counts[idx];
    }
    return result;
}

pub fn part_2(allocator: std.mem.Allocator, comptime input: []const u8) !usize {
    @setEvalBranchQuota(50000);
    const nodes = try parse_input(comptime count_lines(input), input);

    const distances = calculate_distances(nodes.len, nodes);

    // Connect the two unconnected closest nodes one at a time until there is a single fully-
    // connected graph. There is probably a more optimal way to solve, but this solution runs in
    // under 1s on a modern machine so its good enough.
    var connections = [_]std.ArrayList(usize){std.ArrayList(usize).init(allocator)} ** nodes.len;
    defer for (connections) |node| node.deinit();
    for (0..distances.len) |idx| {
        const connect = distances[idx];
        try connections[connect.node_1_idx].append(connect.node_2_idx);
        try connections[connect.node_2_idx].append(connect.node_1_idx);
        const sorted_node_counts = traverse_graphs(nodes.len, connections);
        if (sorted_node_counts[1] == 0) {
            // A zero in the first position of the traversal result indicates every node is
            // reachable from any other node. Once we hit this condition, return the prodcut of
            // the x coordinates from the two most recently connected nodes as the solution.
            return nodes[connect.node_1_idx].x * nodes[connect.node_2_idx].x;
        }
    }
    return error.Unexpected;
}

fn count_lines(input: []const u8) usize {
    var result: usize = 0;
    for (input) |ch| {
        result += if (ch == '\n') 1 else 0;
    }
    return result;
}

fn parse_input(comptime N: usize, input: []const u8) ![N]Node {
    var node_idx: usize = 0;
    var nodes: [N]Node = undefined;
    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line| {
        var val_iter = std.mem.tokenizeSequence(u8, line, ",");
        nodes[node_idx].x = try std.fmt.parseInt(usize, val_iter.next() orelse return error.InvalidInput, 10);
        nodes[node_idx].y = try std.fmt.parseInt(usize, val_iter.next() orelse return error.InvalidInput, 10);
        nodes[node_idx].z = try std.fmt.parseInt(usize, val_iter.next() orelse return error.InvalidInput, 10);
        if (val_iter.next()) |_| return error.InvalidInput;
        node_idx += 1;
    }
    if (node_idx != N) return error.InvalidInput;
    return nodes;
}

fn calculate_distances(comptime N: usize, nodes: [N]Node) [((N - 1) * N) / 2]NodeDistance {
    var distances: [((N - 1) * N) / 2]NodeDistance = undefined;
    var dist_idx: usize = 0;
    for (0..nodes.len) |node_1_idx| {
        for ((node_1_idx + 1)..nodes.len) |node_2_idx| {
            const distance_sqr = nodes[node_1_idx].distance_sqr(nodes[node_2_idx]);
            distances[dist_idx] = .{ .node_1_idx = node_1_idx, .node_2_idx = node_2_idx, .distance_sqr = distance_sqr };
            dist_idx += 1;
        }
    }
    std.debug.assert(dist_idx == distances.len);
    std.mem.sort(NodeDistance, &distances, {}, NodeDistance.isLessThan);
    return distances;
}

fn count_nodes(comptime N: usize, connections: [N]std.ArrayList(usize), node_1_idx: usize, visited: *[N]bool) usize {
    if (visited[node_1_idx]) return 0;
    visited[node_1_idx] = true;
    var result: usize = 1;
    for (connections[node_1_idx].items) |node_2_idx| {
        result += count_nodes(N, connections, node_2_idx, visited);
    }
    return result;
}

fn traverse_graphs(comptime N: usize, connections: [N]std.ArrayList(usize)) [N]usize {
    // Locate independent connected graphs and determine how many nodes are in each.
    var visited = [_]bool{false} ** N;
    var node_counts = [_]usize{0} ** N;
    for (0..N) |node_1_idx| {
        node_counts[node_1_idx] = count_nodes(N, connections, node_1_idx, &visited);
    }
    std.mem.sort(usize, &node_counts, {}, std.sort.desc(usize));
    return node_counts;
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\162,817,812
    \\57,618,57
    \\906,360,560
    \\592,479,940
    \\352,342,300
    \\466,668,158
    \\542,29,236
    \\431,825,988
    \\739,650,466
    \\52,470,668
    \\216,146,977
    \\819,987,18
    \\117,168,530
    \\805,96,715
    \\346,949,466
    \\970,615,88
    \\941,993,340
    \\862,61,35
    \\984,92,344
    \\425,690,689
    \\
;

test "part 1 example input" {
    try testing.expectEqual(part_1(testing.allocator, EXAMPLE_INPUT, 10), 40);
}

test "part 2 example input" {
    try testing.expectEqual(part_2(testing.allocator, EXAMPLE_INPUT), 25272);
}
