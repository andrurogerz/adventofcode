//! https://adventofcode.com/2025/day/6
const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = @embedFile("input.txt");
    {
        const result = try part_1(allocator, input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
}

pub fn part_1(allocator: std.mem.Allocator, input: []const u8) !usize {
    var numbers = std.ArrayList(usize).init(allocator);
    defer numbers.deinit();

    var column_count: usize = 0;
    var row_count: usize = 0;
    var cur_column_count: usize = undefined;
    var operator_line: ?[]const u8 = null;
    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line| {
        if (line[0] == '+' or line[0] == '*') {
            operator_line = line;
            break;
        }

        row_count += 1;
        cur_column_count = 0;
        var token_iter = std.mem.tokenizeAny(u8, line, "\t ");
        while (token_iter.next()) |token| {
            try numbers.append(try std.fmt.parseInt(usize, token, 10));
            cur_column_count += 1;
        }

        if (column_count == 0) column_count = cur_column_count;
        if (column_count != cur_column_count) return error.InvalidInput;
    }

    // Operator line must be the final line in the input.
    if (line_iter.next()) |_| return error.InvalidInput;

    var result: usize = 0;
    var col_idx: usize = 0;
    var op_iter = std.mem.tokenizeAny(u8, operator_line orelse return error.InvalidInput, "\t ");
    while (op_iter.next()) |op_str| {
        var col_result: usize = 1;
        if (op_str.len != 1) return error.InvalidInput;
        for (0..row_count) |row_idx| {
            const idx = col_idx + row_idx * column_count;
            const val = numbers.items[idx];
            switch (op_str[0]) {
                '*' => col_result *= val,
                '+' => col_result += val,
                else => return error.InvalidInput,
            }
            //std.debug.print("{} {s} ", .{val, op_str});
        }
        if (op_str[0] == '+') col_result -= 1;
        //std.debug.print("= {}\n", .{col_result});
        result += col_result;
        col_idx += 1;
    }

    return result;
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\123 328  51 64 
    \\45 64  387 23 
    \\6 98  215 314
    \\*   +   *   +  
;

test "part 1 example input" {
    try testing.expectEqual(part_1(testing.allocator, EXAMPLE_INPUT), 4277556);
}
