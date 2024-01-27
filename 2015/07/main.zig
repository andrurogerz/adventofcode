//! https://adventofcode.com/2015/day/6
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    const result = try part_1(input);
    std.debug.print("part 1 result: {}\n", .{result});
}

fn part_1(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var circuit = Circuit.init(allocator);
    defer circuit.deinit();

    try parseCircuit(&circuit, input);
    return try circuit.getValueAt("a");
}

fn parseCircuit(circuit: *Circuit, input: []const u8) !void {
    var line_iter = std.mem.tokenizeSequence(u8, input, "\n");
    while (line_iter.next()) |line_str| {
        const component = try parseConnection(line_str);
        try circuit.connect(component.in, component.id);
    }
}

fn parseConnection(line_str: []const u8) !struct { id: []const u8, in: Circuit.Gate } {
    var part_iter = std.mem.tokenizeSequence(u8, line_str, " -> ");
    const input_str = part_iter.next() orelse return error.Unexpected;
    const output_str = part_iter.next() orelse return error.Unexpected;
    if (part_iter.next()) |_| {
        return error.Unexpected;
    }

    var input_iter = std.mem.tokenizeSequence(u8, input_str, " ");
    const token_1: []const u8 = input_iter.next() orelse return error.Unexpected;
    const token_2: ?[]const u8 = input_iter.next();
    const token_3: ?[]const u8 = input_iter.next();

    const gate_type = if (token_2 == null and token_3 == null)
        Circuit.GateType.DIRECT
    else if (token_3 == null)
        std.meta.stringToEnum(Circuit.GateType, token_1) orelse return error.Unexpected
    else
        std.meta.stringToEnum(Circuit.GateType, token_2 orelse unreachable) orelse return error.Unexpected;

    return .{
        .id = output_str,
        .in = switch (gate_type) {
            .DIRECT => .{
                .DIRECT = .{ .in = token_1 },
            },
            .AND => .{
                .AND = .{ .in_1 = token_1, .in_2 = token_3.? },
            },
            .OR => .{
                .OR = .{ .in_1 = token_1, .in_2 = token_3.? },
            },
            .LSHIFT => .{ .LSHIFT = .{
                .in = token_1,
                .value = try std.fmt.parseInt(u16, token_3.?, 10),
            } },
            .RSHIFT => .{ .RSHIFT = .{
                .in = token_1,
                .value = try std.fmt.parseInt(u16, token_3.?, 10),
            } },
            .NOT => .{
                .NOT = .{ .in = token_2.? },
            },
        },
    };
}

const Circuit = struct {
    const Self = @This();

    connections: std.StringHashMap(Connection),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .connections = std.StringHashMap(Connection).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.connections.deinit();
    }

    // NOTE: enum names must exactly match input string literals
    pub const GateType = enum {
        DIRECT,
        AND,
        OR,
        LSHIFT,
        RSHIFT,
        NOT,
    };

    pub const Direct = struct {
        in: []const u8,
    };

    pub const And = struct {
        in_1: []const u8,
        in_2: []const u8,
    };

    pub const Or = struct {
        in_1: []const u8,
        in_2: []const u8,
    };

    pub const LShift = struct {
        in: []const u8,
        value: u16,
    };

    pub const RShift = struct {
        in: []const u8,
        value: u16,
    };

    pub const Not = struct {
        in: []const u8,
    };

    pub const Gate = union(GateType) {
        DIRECT: Direct,
        AND: And,
        OR: Or,
        LSHIFT: LShift,
        RSHIFT: RShift,
        NOT: Not,
    };

    pub const Connection = struct {
        gate: Gate,
        cached_value: ?u16,
    };

    pub fn getValueAt(self: *Self, id: []const u8) !u16 {
        if (std.ascii.isDigit(id[0])) {
            return try std.fmt.parseInt(u16, id, 10);
        }

        const connection = self.connections.getPtr(id) orelse return error.Unexpected;
        if (connection.cached_value) |value| {
            return value;
        }

        const value = switch (connection.gate) {
            .DIRECT => |gate| try self.getValueAt(gate.in),
            .AND => |gate| try self.getValueAt(gate.in_1) & try self.getValueAt(gate.in_2),
            .OR => |gate| return try self.getValueAt(gate.in_1) | try self.getValueAt(gate.in_2),
            .LSHIFT => |gate| return try self.getValueAt(gate.in) << @intCast(gate.value),
            .RSHIFT => |gate| return try self.getValueAt(gate.in) >> @intCast(gate.value),
            .NOT => |gate| return ~(try self.getValueAt(gate.in)),
        };

        connection.cached_value = value;
        return value;
    }

    pub fn connect(self: *Self, in: Gate, out: []const u8) !void {
        if (self.connections.contains(out)) {
            return error.Unexpected;
        }

        try self.connections.putNoClobber(out, .{
            .gate = in,
            .cached_value = null,
        });
    }
};

const testing = std.testing;

test "part 1 example input" {
    const EXAMPLE_INPUT =
        \\123 -> x
        \\456 -> y
        \\x AND y -> d
        \\x OR y -> e
        \\x LSHIFT 2 -> f
        \\y RSHIFT 2 -> g
        \\NOT x -> h
        \\NOT y -> i
    ;

    var circuit = Circuit.init(testing.allocator);
    defer circuit.deinit();

    try parseCircuit(&circuit, EXAMPLE_INPUT);
    try testing.expectEqual(circuit.getValueAt("d"), 72);
    try testing.expectEqual(circuit.getValueAt("e"), 507);
    try testing.expectEqual(circuit.getValueAt("f"), 492);
    try testing.expectEqual(circuit.getValueAt("g"), 114);
    try testing.expectEqual(circuit.getValueAt("h"), 65412);
    try testing.expectEqual(circuit.getValueAt("i"), 65079);
    try testing.expectEqual(circuit.getValueAt("x"), 123);
    try testing.expectEqual(circuit.getValueAt("y"), 456);
}
