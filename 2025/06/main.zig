//! https://adventofcode.com/2025/day/6
const std = @import("std");
const Grid = @import("grid.zig").Grid;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = @embedFile("input.txt");
    {
        const result = try part_1(allocator, input);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(allocator, input);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

pub fn part_1(allocator: std.mem.Allocator, comptime input: []const u8) !usize {
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

pub fn part_2(_: std.mem.Allocator, comptime input: []const u8) !usize {
    @setEvalBranchQuota(20000);
    const grid = comptime Grid(input.len).init(input);

    // We can avoid heap-allocating this array because grid is comptime initialized.
    var numbers = [_]usize{0} ** grid.cols;

    // Parse the numbers in vertical columns. Assumes the data is well-formed and that there are no
    // gaps between number characters in any given column. The implementation does not enforce this
    // property because it would require additional overhead.
    for (0..grid.cols) |col_idx| {
        for (0..(grid.rows - 1)) |row_idx| {
            const ch = grid.get(.{ .row = row_idx, .col = col_idx });
            if (ch == ' ') continue;
            if (ch < '0' or ch > '9') return error.InvalidInput;
            numbers[col_idx] *= 10;
            numbers[col_idx] += ch - '0';
        }
    }

    // Extract the last line of the input from the grid and tokenize it. It should consist entirely
    // of + and * characters, separated by spaces.
    const last_line_idx = comptime grid.getIndex(.{ .col = 0, .row = grid.rows - 1 });
    var op_iter = std.mem.tokenizeAny(u8, grid.data[last_line_idx..], "\n ");

    var result: usize = 0;
    var number_idx: usize = 0;
    while (op_iter.next()) |op_str| {
        // Input must be a sequence of * and + chars separated by spaces.
        if (op_str.len != 1) return error.InvalidInput;
        const op: enum { Multiply, Add } = switch (op_str[0]) {
            '*' => .Multiply,
            '+' => .Add,
            else => return error.InvalidInput,
        };

        var col_result: usize = switch (op) {
            .Multiply => 1,
            .Add => 0,
        };

        while (number_idx < numbers.len and numbers[number_idx] != 0) {
            const number = numbers[number_idx];
            col_result = switch (op) {
                .Multiply => col_result * number,
                .Add => col_result + number,
            };
            number_idx += 1;
        }

        result += col_result;
        number_idx += 1;
    }
    return result;
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\123 328  51 64 
    \\ 45 64  387 23 
    \\  6 98  215 314
    \\*   +   *   +  
    \\
;

test "part 1 example input" {
    try testing.expectEqual(part_1(testing.allocator, EXAMPLE_INPUT), 4277556);
}

test "part 2 example input" {
    try testing.expectEqual(part_2(testing.allocator, EXAMPLE_INPUT), 3263827);
}
