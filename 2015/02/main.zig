const std = @import("std");

fn areaForPackage(pkg_str: []const u8) !usize {
    var dim_iter = std.mem.tokenizeSequence(u8, pkg_str, "x");
    const length = try std.fmt.parseInt(usize, dim_iter.next() orelse return error.Unexpected, 10);
    const width = try std.fmt.parseInt(usize, dim_iter.next() orelse return error.Unexpected, 10);
    const height = try std.fmt.parseInt(usize, dim_iter.next() orelse return error.Unexpected, 10);

    const sides = [_]usize{ length * width, width * height, height * length };
    const smallest_side = @min(@min(sides[0], sides[1]), @min(sides[1], sides[2]));

    return smallest_side + (2 * sides[0]) + (2 * sides[1]) + (2 * sides[2]);
}

pub fn part_1(input: []const u8) !usize {
    var total_area: usize = 0;
    var pkg_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (pkg_iter.next()) |pkg_str| {
        total_area += try areaForPackage(pkg_str);
    }
    return total_area;
}

pub fn main() !void {
    const input = @embedFile("input.txt");
    const result = try part_1(input);
    std.debug.print("part 1 result: {}\n", .{result});
}

const testing = std.testing;

test "part 1 example input" {
    try testing.expectEqual(try areaForPackage("2x3x4"), 58);
    try testing.expectEqual(try areaForPackage("1x1x10"), 43);
}
