//! https://adventofcode.com/2015/day/2
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

fn part_1(input: []const u8) !usize {
    var total_area: usize = 0;
    var pkg_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (pkg_iter.next()) |pkg_str| {
        total_area += try paperAreaForPackage(pkg_str);
    }
    return total_area;
}

fn part_2(input: []const u8) !usize {
    var total_length: usize = 0;
    var pkg_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (pkg_iter.next()) |pkg_str| {
        total_length += try ribbonLengthForPackage(pkg_str);
    }
    return total_length;
}

fn parsePackageDimensions(pkg_str: []const u8) ![3]usize {
    var dim_iter = std.mem.tokenizeSequence(u8, pkg_str, "x");
    return [_]usize{
        try std.fmt.parseInt(usize, dim_iter.next() orelse return error.Unexpected, 10),
        try std.fmt.parseInt(usize, dim_iter.next() orelse return error.Unexpected, 10),
        try std.fmt.parseInt(usize, dim_iter.next() orelse return error.Unexpected, 10),
    };
}

fn paperAreaForPackage(pkg_str: []const u8) !usize {
    const edge_lengths = try parsePackageDimensions(pkg_str);
    const face_areas = [_]usize{
        edge_lengths[0] * edge_lengths[1],
        edge_lengths[1] * edge_lengths[2],
        edge_lengths[2] * edge_lengths[0],
    };
    const smallest_face_area = @min(@min(face_areas[0], face_areas[1]), @min(face_areas[1], face_areas[2]));
    return smallest_face_area + (2 * face_areas[0]) + (2 * face_areas[1]) + (2 * face_areas[2]);
}

fn ribbonLengthForPackage(pkg_str: []const u8) !usize {
    const edge_lengths = try parsePackageDimensions(pkg_str);
    const face_perimeter_lengths = [_]usize{
        2 * (edge_lengths[0] + edge_lengths[1]),
        2 * (edge_lengths[1] + edge_lengths[2]),
        2 * (edge_lengths[2] + edge_lengths[0]),
    };
    const smallest_face_perimeter_length = @min(@min(face_perimeter_lengths[0], face_perimeter_lengths[1]), @min(face_perimeter_lengths[1], face_perimeter_lengths[2]));
    const volume = edge_lengths[0] * edge_lengths[1] * edge_lengths[2];
    return volume + smallest_face_perimeter_length;
}

const testing = std.testing;

test "part 1 example input" {
    try testing.expectEqual(try paperAreaForPackage("2x3x4"), 58);
    try testing.expectEqual(try paperAreaForPackage("1x1x10"), 43);
}

test "part 2 example input" {
    try testing.expectEqual(try ribbonLengthForPackage("2x3x4"), 34);
    try testing.expectEqual(try ribbonLengthForPackage("1x1x10"), 14);
}
