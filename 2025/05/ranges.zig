const std = @import("std");

/// General purpose collection of numeric ranges. Ranges in the collection are unordered. Ranges
/// that overlap are merged into existing ranges when they are added.
pub fn Ranges(T: type) type {
    return struct {
        const Self = @This();

        pub const Range = struct {
            start: T,
            end: T,
        };

        ranges: std.ArrayList(Range),

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{ .ranges = std.ArrayList(Range).init(allocator) };
        }

        pub fn deinit(self: Self) void {
            self.ranges.deinit();
        }

        /// Add a new range to the collection. If the range overlaps with existing ranges, ranges
        /// are merged until no overlapping ranges exist. Adjacent ranges are not merged because
        /// only the client know if ranges are inclusive.
        pub fn add(self: *Self, range: Range) !void {
            if (range.end < range.start) return error.InvalidInput;

            // Check existing ranges to see if this one can be merged with it.
            var new_range = range;
            while (true) {
                var merged = false;
                for (0..self.ranges.items.len) |idx| {
                    const existing_range = self.ranges.items[idx];
                    if (existing_range.end < new_range.start or new_range.end < existing_range.start) continue;

                    // Remove the overlapping item from the existing list of ranges and merge it with
                    // the new range that has not been added to the list yet..
                    _ = self.ranges.swapRemove(idx);
                    new_range = .{ .start = @min(new_range.start, existing_range.start), .end = @max(new_range.end, existing_range.end) };
                    merged = true;
                    break;
                }

                if (!merged) {
                    // The range did not merge with any other ranges, so just append it to the list and
                    // move on.
                    try self.ranges.append(.{ .start = new_range.start, .end = new_range.end });
                    break;
                }
            }
        }

        /// Returns an array of the current ranges. The ranges are unorderd.
        pub fn items(self: *const Self) []Range {
            return self.ranges.items;
        }
    };
}

const testing = std.testing;

test "overlapping range merge" {
    var ranges = Ranges(usize).init(testing.allocator);
    defer ranges.deinit();

    try ranges.add(.{ .start = 10, .end = 12 });
    try testing.expectEqual(1, ranges.items().len);
    {
        const range = ranges.items()[0];
        try testing.expectEqual(10, range.start);
        try testing.expectEqual(12, range.end);
    }

    try ranges.add(.{ .start = 12, .end = 15 });
    try testing.expectEqual(1, ranges.items().len);
    {
        const range = ranges.items()[0];
        try testing.expectEqual(10, range.start);
        try testing.expectEqual(15, range.end);
    }

    try ranges.add(.{ .start = 17, .end = 25 });
    try testing.expectEqual(2, ranges.items().len);
    {
        const range = ranges.items()[1];
        try testing.expectEqual(17, range.start);
        try testing.expectEqual(25, range.end);
    }

    try ranges.add(.{ .start = 11, .end = 20 });
    try testing.expectEqual(1, ranges.items().len);
    {
        const range = ranges.items()[0];
        try testing.expectEqual(10, range.start);
        try testing.expectEqual(25, range.end);
    }
}
