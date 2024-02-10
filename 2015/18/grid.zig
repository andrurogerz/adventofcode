const std = @import("std");

/// Parses a grid in text form with uniform row length and provides a read-only
/// interface to access its contents.
pub fn Grid(comptime N: usize) type {
    return struct {
        const Self = @This();

        /// An addressible position within a grid.
        pub const Position = struct {
            col: usize,
            row: usize,
        };

        /// Iterates the valid grid positions surrounding the specified position.
        pub const NeighborIterator = struct {
            origin: Position,
            cur_pos: Position,
            start_pos: Position,
            end_pos: Position,

            fn init(pos: Position, grid: *const Grid(N)) @This() {
                var origin = pos;
                var start_pos = pos;
                var end_pos = pos;

                if (start_pos.row > 0) {
                    start_pos.row -= 1;
                }

                if (end_pos.row < grid.rows - 1) {
                    end_pos.row += 1;
                }

                if (start_pos.col > 0) {
                    start_pos.col -= 1;
                }

                if (end_pos.col < grid.cols - 1) {
                    end_pos.col += 1;
                }

                return @This(){
                    .origin = origin,
                    .cur_pos = start_pos,
                    .start_pos = start_pos,
                    .end_pos = end_pos,
                };
            }

            pub fn next(self: *@This()) ?Position {
                if (self.cur_pos.row > self.end_pos.row) {
                    return null;
                }

                const pos = self.cur_pos;
                self.cur_pos.col += 1;
                if (self.cur_pos.col > self.end_pos.col) {
                    self.cur_pos.col = self.start_pos.col;
                    self.cur_pos.row += 1;
                }

                if (self.origin.row == pos.row and self.origin.col == pos.col) {
                    return self.next(); // skip the origin point during enumeration
                }
                return pos;
            }
        };

        /// Iterates every valid position in the grid one at a time.
        pub const Iterator = struct {
            cur_pos: Position,
            end_pos: Position,

            pub fn init(grid: *const Grid(N)) @This() {
                return @This(){
                    .cur_pos = .{ .row = 0, .col = 0 },
                    .end_pos = .{ .row = grid.rows - 1, .col = grid.cols - 1 },
                };
            }

            pub fn next(self: *@This()) ?Position {
                if (self.cur_pos.row > self.end_pos.row) {
                    return null;
                }

                const pos = self.cur_pos;
                self.cur_pos.col += 1;
                if (self.cur_pos.col > self.end_pos.col) {
                    self.cur_pos.col = 0;
                    self.cur_pos.row += 1;
                }
                return pos;
            }
        };

        cols: usize,
        rows: usize,
        data: []const u8,

        pub fn init(data: []const u8) Self {
            std.debug.assert(data.len <= N);

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

            return Self{
                .rows = rows,
                .cols = cols,
                .data = data,
            };
        }

        /// Get the character at the specified grid position.
        pub fn get(self: *const Self, pos: Position) u8 {
            return self.data[self.getIndex(pos)];
        }

        /// Return an iterator to enumerate every valid position in the grid.
        pub fn iterate(self: *const Self) Iterator {
            return Iterator.init(self);
        }

        /// Return an iterator to enumerate every valid position in the grid
        /// that is adjacent to the specified position.
        pub fn neighbors(self: *const Self, pos: Position) NeighborIterator {
            return NeighborIterator.init(pos, self);
        }

        /// Gets the unique index into the original string for the specified
        /// grid position.
        pub fn getIndex(self: *const Self, pos: Position) usize {
            std.debug.assert(pos.col < self.cols);
            std.debug.assert(pos.row < self.rows);
            return pos.col + (pos.row * (self.cols + 1));
        }
    };
}
