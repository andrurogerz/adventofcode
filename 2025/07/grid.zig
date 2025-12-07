const std = @import("std");

/// Parses a grid in text form with uniform row length and provides a read-only
/// interface to access its contents.
pub const Grid = struct {
    const Self = @This();

    /// An addressible position within a grid.
    pub const Position = struct {
        col: usize,
        row: usize,
    };

    cols: usize,
    rows: usize,
    data: []const u8,

    pub fn init(data: []const u8) Self {
        // Establish width/height of the grid.
        var cols: usize = 0;
        var rows: usize = 0;
        for (data, 0..) |ch, idx| {
            if (ch != '\n') {
                continue;
            }

            rows += 1;
            if (cols == 0) {
                cols = idx;
                continue;
            }

            // Every row in the input data must be the same length.
            std.debug.assert((idx + 1) % (cols + 1) == 0);
        }

        return .{
            .rows = rows,
            .cols = cols,
            .data = data,
        };
    }

    /// Get the character at the specified grid position.
    pub fn get(self: *const Self, pos: Position) u8 {
        return self.data[self.getIndex(pos)];
    }

    /// Gets the unique index into the original string for the specified
    /// grid position.
    pub fn getIndex(self: *const Self, pos: Position) usize {
        std.debug.assert(pos.col < self.cols);
        std.debug.assert(pos.row < self.rows);
        return pos.col + (pos.row * (self.cols + 1));
    }
};
