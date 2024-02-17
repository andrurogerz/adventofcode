//! https://adventofcode.com/2015/day/19
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("./input.txt");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var line_iter = std.mem.tokenizeSequence(u8, input, "\n\n"); // Input sections are separated by two newlines.
    const replacement_map = try parseReplacements(allocator, line_iter.next() orelse return error.Unexpected);

    var sequence_str = line_iter.next() orelse return error.Unexpected;
    if (sequence_str[sequence_str.len - 1] == '\n') {
        // Remove trailling newline.
        sequence_str = sequence_str[0..(sequence_str.len - 1)];
    }

    {
        const result = try part_1(allocator, replacement_map, sequence_str);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(allocator, replacement_map, sequence_str);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

fn part_1(allocator: std.mem.Allocator, replacement_map: StringMultiMap, sequence_str: []const u8) !usize {
    var sequence_set = try replace(allocator, replacement_map, sequence_str);
    return sequence_set.count();
}

fn part_2(allocator: std.mem.Allocator, replacement_map: StringMultiMap, sequence_str: []const u8) !usize {
    // Invert the transformations and try to reduce the target string to the
    // origin string "e"
    const inverted_map = try invertStringMultiMap(allocator, &replacement_map);
    const origin_str = "e";

    var banned_set = std.StringArrayHashMap(void).init(allocator);
    while (true) {
        const result = try reduceByReplacement(allocator, inverted_map, banned_set, sequence_str);
        if (std.mem.eql(u8, result.str, origin_str)) {
            return result.iteration_count;
        }

        // There is no path to the origin string, so ban this result from
        // future rounds so the reduction takes a different path.
        try banned_set.put(result.str, {});
    }

    return error.Unexpected;
}

fn reduceByReplacement(allocator: std.mem.Allocator, inverted_map: StringMultiMap, banned_set: std.StringArrayHashMap(void), sequence_str: []const u8) !struct { iteration_count: usize, str: []const u8 } {
    var iteration_count: usize = 0;
    var reduced_str = sequence_str;
    while (true) {
        var replaced_set = try replace(allocator, inverted_map, reduced_str);
        var replaced = false;
        for (replaced_set.keys()) |key_str| {
            // Choose the shortest string in the replacement set that isn't in
            // the set of banned strings. It must also be shorter than the input.
            if (key_str.len <= reduced_str.len and !banned_set.contains(key_str)) {
                reduced_str = key_str;
                replaced = true;
            }
        }

        if (!replaced) {
            break;
        }

        iteration_count += 1;
    }

    // Returns the original seuqence string an an iteration count of 0 if there
    // were no possible reductions.
    return .{
        .iteration_count = iteration_count,
        .str = reduced_str,
    };
}

fn replace(allocator: std.mem.Allocator, replacement_map: StringMultiMap, sequence_str: []const u8) !std.StringArrayHashMap(void) {
    var replaced_set = std.StringArrayHashMap(void).init(allocator);
    for (0..sequence_str.len) |idx| {
        if (!std.ascii.isAlphabetic(sequence_str[idx])) {
            return error.Unexpected;
        }

        for (replacement_map.keys()) |key_str| {
            if (idx + key_str.len > sequence_str.len) {
                continue;
            }

            const match_str = sequence_str[idx..(idx + key_str.len)];
            if (!std.mem.eql(u8, key_str, match_str)) {
                continue;
            }

            const values = replacement_map.getPtr(match_str) orelse unreachable;
            for (values.items) |value_str| {
                var replaced_sequence = try std.ArrayList(u8).initCapacity(allocator, sequence_str.len + value_str.len - match_str.len);
                try replaced_sequence.appendSlice(sequence_str[0..idx]);
                try replaced_sequence.appendSlice(value_str);
                try replaced_sequence.appendSlice(sequence_str[(idx + match_str.len)..]);

                const replaced_sequence_str = try replaced_sequence.toOwnedSlice();
                const result = try replaced_set.getOrPut(replaced_sequence_str);
                if (result.found_existing) {
                    allocator.free(replaced_sequence_str);
                }
            }
        }
    }
    return replaced_set;
}

fn printStringMultiMap(map: *const StringMultiMap) void {
    for (map.keys()) |key_str| {
        std.debug.print("{s} => ", .{key_str});
        const vals = map.getPtr(key_str) orelse continue;
        for (vals.items) |val| {
            std.debug.print("{s}, ", .{val});
        }
        std.debug.print("\n", .{});
    }
}

const StringMultiMap = std.StringArrayHashMap(std.ArrayList([]const u8));

fn invertStringMultiMap(allocator: std.mem.Allocator, map: *const StringMultiMap) !StringMultiMap {
    var inverted_map = StringMultiMap.init(allocator);
    var iter = map.iterator();
    while (iter.next()) |entry| {
        const new_value = entry.key_ptr.*;
        for (entry.value_ptr.items) |new_key| {
            if (inverted_map.getPtr(new_key)) |values| {
                try values.append(new_value);
            } else {
                var values = std.ArrayList([]const u8).init(allocator);
                try values.append(new_value);
                try inverted_map.put(new_key, values);
            }
        }
    }
    return inverted_map;
}

fn parseReplacements(allocator: std.mem.Allocator, sequence_str: []const u8) !StringMultiMap {
    var map = StringMultiMap.init(allocator);
    var line_iter = std.mem.tokenizeSequence(u8, sequence_str, "\n");
    while (line_iter.next()) |line_str| {
        var part_iter = std.mem.tokenizeSequence(u8, line_str, " => ");
        const key = part_iter.next() orelse return error.Unexpected;
        const value = part_iter.next() orelse return error.Unexpected;
        if (part_iter.next()) |_| {
            return error.Unexpected;
        }
        if (map.getPtr(key)) |values| {
            try values.append(value);
        } else {
            var values = std.ArrayList([]const u8).init(allocator);
            try values.append(value);
            try map.put(key, values);
        }
    }
    return map;
}

const testing = std.testing;

test "part 1 example input" {
    const EXAMPLE_MAPPING =
        \\H => HO
        \\H => OH
        \\O => HH
    ;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var replacement_map = try parseReplacements(arena.allocator(), EXAMPLE_MAPPING);
    defer replacement_map.deinit();

    try testing.expectEqual(try part_1(arena.allocator(), replacement_map, "HOH"), 4);
    try testing.expectEqual(try part_1(arena.allocator(), replacement_map, "HOHOHO"), 7);
}

test "part 2 example input" {
    const EXAMPLE_MAPPING =
        \\e => H
        \\e => O
        \\H => HO
        \\H => OH
        \\O => HH
    ;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var replacement_map = try parseReplacements(arena.allocator(), EXAMPLE_MAPPING);
    defer replacement_map.deinit();

    try testing.expectEqual(try part_2(arena.allocator(), replacement_map, "HOH"), 3);
    try testing.expectEqual(try part_2(arena.allocator(), replacement_map, "HOHOHO"), 6);
}
