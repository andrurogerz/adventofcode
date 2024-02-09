//! https://adventofcode.com/2015/day/17
const std = @import("std");

pub fn main() !void {
    const INPUT = @embedFile("input.txt");
    {
        const result = try part_1(150, INPUT);
        std.debug.print("part 1 result: {}\n", .{result});
    }
    {
        const result = try part_2(150, INPUT);
        std.debug.print("part 2 result: {}\n", .{result});
    }
}

fn part_1(target: usize, comptime INPUT: []const u8) !usize {
    comptime var entries: [32]usize = undefined;
    const buckets = comptime try parse(entries.len, &entries, INPUT);
    const buckets_used = std.StaticBitSet(buckets.len).initEmpty();
    return findCombinations(buckets.len, 0, target, buckets.len, buckets_used, buckets);
}

fn part_2(target: usize, comptime INPUT: []const u8) !usize {
    comptime var entries: [32]usize = undefined;
    const buckets = comptime try parse(entries.len, &entries, INPUT);
    const buckets_used = std.StaticBitSet(buckets.len).initEmpty();
    const max_buckets = findMinBuckets(buckets.len, 0, target, buckets_used, buckets);
    return findCombinations(buckets.len, 0, target, max_buckets, buckets_used, buckets);
}

fn parse(comptime MAX: usize, entries: *[MAX]usize, comptime INPUT: []const u8) ![]usize {
    var bucket_count: usize = 0;
    var line_iter = std.mem.tokenizeSequence(u8, INPUT, "\n");
    while (line_iter.next()) |bucket_size_str| {
        if (bucket_count == MAX) {
            return error.Unexpected; // MAX is too small
        }

        entries[bucket_count] = try std.fmt.parseInt(usize, bucket_size_str, 10);
        bucket_count += 1;
    }

    return entries[0..bucket_count];
}

/// Count the the number of bucket combinations, with up to max_buckets buckets, that can hold exatly the target size when combined.
fn findCombinations(comptime N: usize, start_idx: usize, target: usize, max_buckets: usize, buckets_used: std.StaticBitSet(N), buckets: []usize) usize {
    std.debug.assert(buckets.len == N);
    if (buckets_used.count() > max_buckets) {
        return 0;
    }

    const sum = sumBuckets(N, buckets_used, buckets);
    if (sum > target) {
        return 0;
    }

    if (sum == target) {
        return 1;
    }

    if (start_idx == N) {
        return 0;
    }

    // else: sum < target
    var count = findCombinations(N, start_idx + 1, target, max_buckets, buckets_used, buckets);
    var buckets_used_new = buckets_used;
    buckets_used_new.set(start_idx);
    count += findCombinations(N, start_idx + 1, target, max_buckets, buckets_used_new, buckets);
    return count;
}

/// Find the smallest combination of buckets that can hold exatly the target size when combined.
fn findMinBuckets(comptime N: usize, start_idx: usize, target: usize, buckets_used: std.StaticBitSet(N), buckets: []usize) usize {
    std.debug.assert(buckets.len == N);
    const sum = sumBuckets(N, buckets_used, buckets);
    if (sum > target) {
        return std.math.maxInt(usize);
    }

    if (sum == target) {
        return buckets_used.count();
    }

    if (start_idx == N) {
        return std.math.maxInt(usize);
    }

    // else: sum < target
    const min_buckets = findMinBuckets(N, start_idx + 1, target, buckets_used, buckets);
    var buckets_used_new = buckets_used;
    buckets_used_new.set(start_idx);
    return @min(min_buckets, findMinBuckets(N, start_idx + 1, target, buckets_used_new, buckets));
}

fn sumBuckets(comptime N: usize, buckets_used: std.StaticBitSet(N), buckets: []usize) usize {
    std.debug.assert(buckets.len == N);
    var sum: usize = 0;
    for (0..N) |idx| {
        if (buckets_used.isSet(idx)) {
            sum += buckets[idx];
        }
    }
    return sum;
}

const testing = std.testing;

const EXAMPLE_INPUT =
    \\20
    \\15
    \\10
    \\5
    \\5
;

test "part 1 example input" {
    try testing.expectEqual(part_1(25, EXAMPLE_INPUT), 4);
}

test "part 2 example input" {
    try testing.expectEqual(part_2(25, EXAMPLE_INPUT), 3);
}
