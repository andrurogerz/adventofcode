//! https://adventofcode.com/2015/day/19
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("./input.txt");
    const result = try part_1(input);
    std.debug.print("part 1 result: {}\n", .{result});
}

fn part_1(comptime INPUT: []const u8) !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var line_iter = std.mem.tokenizeSequence(u8, INPUT, "\n\n"); // Input sections are separated by two newlines.
    const replacement_map = try parseReplacements(allocator, line_iter.next() orelse return error.Unexpected);

    var sequence_str = line_iter.next() orelse return error.Unexpected;
    if (sequence_str[sequence_str.len - 1] == '\n') {
        // Remove trailling newline.
        sequence_str = sequence_str[0..(sequence_str.len - 1)];
    }

    var sequence_set = std.StringHashMap(void).init(allocator);

    for (0..sequence_str.len) |idx| {
        if (!std.ascii.isAlphabetic(sequence_str[idx])) {
            return error.Unexpected;
        }

        var key_iter = replacement_map.keyIterator();
        while (key_iter.next()) |key_str| {
            if (idx + key_str.len > sequence_str.len) {
                continue;
            }

            const match_str = sequence_str[idx..(idx + key_str.len)];
            if (std.mem.eql(u8, key_str.*, match_str)) {
                const values = replacement_map.getPtr(match_str) orelse unreachable;
                for (values.items) |value_str| {
                    var replaced_sequence = try std.ArrayList(u8).initCapacity(allocator, sequence_str.len + value_str.len - match_str.len);
                    try replaced_sequence.appendSlice(sequence_str[0..idx]);
                    try replaced_sequence.appendSlice(value_str);
                    try replaced_sequence.appendSlice(sequence_str[(idx + match_str.len)..]);

                    const replaced_sequence_str = try replaced_sequence.toOwnedSlice();
                    const result = try sequence_set.getOrPut(replaced_sequence_str);
                    if (result.found_existing) {
                        allocator.free(replaced_sequence_str);
                    }
                }
            }
        }
    }

    return sequence_set.count();
}

fn printStringMultiMap(map: *const StringMultiMap) void {
    var iter = map.keyIterator();
    while (iter.next()) |key_str| {
        std.debug.print("{s} => ", .{key_str.*});
        const vals = map.getPtr(key_str.*) orelse continue;
        for (vals.items) |val| {
            std.debug.print("{s}, ", .{val});
        }
        std.debug.print("\n", .{});
    }
}

const StringMultiMap = std.StringHashMap(std.ArrayList([]const u8));

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

test "part 1 example input 1" {
    const EXAMPLE_INPUT =
        \\H => HO
        \\H => OH
        \\O => HH
        \\
        \\HOH
        \\
    ;
    try testing.expectEqual(try part_1(EXAMPLE_INPUT), 4);
}

test "part 1 example input 2" {
    const EXAMPLE_INPUT =
        \\H => HO
        \\H => OH
        \\O => HH
        \\
        \\HOHOHO
        \\
    ;
    try testing.expectEqual(try part_1(EXAMPLE_INPUT), 7);
}
