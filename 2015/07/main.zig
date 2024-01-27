//! https://adventofcode.com/2015/day/7
const std = @import("std");

pub fn main() !void {
    const input = @embedFile("input.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var circuit = Circuit.init(allocator);
    defer circuit.deinit();

    // Part 1: read signal at gate a.
    try parseCircuit(&circuit, input);
    const signal = try circuit.getSignalAt("a");
    std.debug.print("part 1 result: {}\n", .{signal});

    // Part 2: replace gate b input with signal value from part 1.
    const gate = Circuit.Gate{ .SIGNAL = .{
        .in = .{ .IMMEDIATE = signal },
    } };
    try circuit.connect(gate, "b");

    // Clear cached signal values and reread gate a.
    circuit.reset();
    const signal_2 = try circuit.getSignalAt("a");
    std.debug.print("part 2 result: {}\n", .{signal_2});
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
        Circuit.GateType.SIGNAL
    else if (token_3 == null)
        std.meta.stringToEnum(Circuit.GateType, token_1) orelse return error.Unexpected
    else
        std.meta.stringToEnum(Circuit.GateType, token_2 orelse unreachable) orelse return error.Unexpected;

    return .{
        .id = output_str,
        .in = switch (gate_type) {
            .SIGNAL => .{
                .SIGNAL = .{ .in = try parseInputToken(token_1) },
            },
            .AND => .{
                .AND = .{
                    .in_1 = try parseInputToken(token_1),
                    .in_2 = try parseInputToken(token_3.?),
                },
            },
            .OR => .{
                .OR = .{
                    .in_1 = try parseInputToken(token_1),
                    .in_2 = try parseInputToken(token_3.?),
                },
            },
            .LSHIFT => .{ .LSHIFT = .{
                .in = try parseInputToken(token_1),
                .value = try std.fmt.parseInt(u16, token_3.?, 10),
            } },
            .RSHIFT => .{ .RSHIFT = .{
                .in = try parseInputToken(token_1),
                .value = try std.fmt.parseInt(u16, token_3.?, 10),
            } },
            .NOT => .{
                .NOT = .{ .in = try parseInputToken(token_2.?) },
            },
        },
    };
}

pub fn parseInputToken(token: []const u8) !Circuit.Input {
    if (std.ascii.isDigit(token[0])) {
        return Circuit.Input{
            .IMMEDIATE = try std.fmt.parseInt(u16, token, 10),
        };
    }
    for (token) |ch| {
        if (!std.ascii.isLower(ch)) {
            return error.Unexpected;
        }
    }
    return Circuit.Input{ .GATE = token };
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

    pub const InputType = enum {
        GATE, // Input comes from another gate
        IMMEDIATE, // Input is an immediate 16-bit value
    };

    pub const Input = union(InputType) {
        GATE: []const u8,
        IMMEDIATE: u16,
    };

    // NOTE: enum names must exactly match input string literals
    pub const GateType = enum {
        SIGNAL,
        AND,
        OR,
        LSHIFT,
        RSHIFT,
        NOT,
    };

    pub const Signal = struct {
        in: Input,
    };

    pub const And = struct {
        in_1: Input,
        in_2: Input,
    };

    pub const Or = struct {
        in_1: Input,
        in_2: Input,
    };

    pub const LShift = struct {
        in: Input,
        value: u16,
    };

    pub const RShift = struct {
        in: Input,
        value: u16,
    };

    pub const Not = struct {
        in: Input,
    };

    pub const Gate = union(GateType) {
        SIGNAL: Signal,
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

    pub fn getSignalAt(self: *Self, id: []const u8) anyerror!u16 {
        const connection = self.connections.getPtr(id) orelse return error.Unexpected;
        if (connection.cached_value) |value| {
            return value;
        }

        const value = switch (connection.gate) {
            .SIGNAL => |gate| try self.getSignalAtInput(gate.in),
            .AND => |gate| try self.getSignalAtInput(gate.in_1) & try self.getSignalAtInput(gate.in_2),
            .OR => |gate| return try self.getSignalAtInput(gate.in_1) | try self.getSignalAtInput(gate.in_2),
            .LSHIFT => |gate| return try self.getSignalAtInput(gate.in) << @intCast(gate.value),
            .RSHIFT => |gate| return try self.getSignalAtInput(gate.in) >> @intCast(gate.value),
            .NOT => |gate| return ~(try self.getSignalAtInput(gate.in)),
        };

        connection.cached_value = value;
        return value;
    }

    fn getSignalAtInput(self: *Self, in: Input) anyerror!u16 {
        return switch (in) {
            .IMMEDIATE => |value| value,
            .GATE => |id| try self.getSignalAt(id),
        };
    }

    pub fn connect(self: *Self, in: Gate, out: []const u8) !void {
        try self.connections.put(out, .{
            .gate = in,
            .cached_value = null,
        });
    }

    pub fn reset(self: *Self) void {
        var connection_iter = self.connections.valueIterator();
        while (connection_iter.next()) |connection| {
            connection.cached_value = null;
        }
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
    try testing.expectEqual(circuit.getSignalAt("d"), 72);
    try testing.expectEqual(circuit.getSignalAt("e"), 507);
    try testing.expectEqual(circuit.getSignalAt("f"), 492);
    try testing.expectEqual(circuit.getSignalAt("g"), 114);
    try testing.expectEqual(circuit.getSignalAt("h"), 65412);
    try testing.expectEqual(circuit.getSignalAt("i"), 65079);
    try testing.expectEqual(circuit.getSignalAt("x"), 123);
    try testing.expectEqual(circuit.getSignalAt("y"), 456);
}
