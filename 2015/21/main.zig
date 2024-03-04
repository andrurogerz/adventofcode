//! https://adventofcode.com/2015/day/20
const std = @import("std");

pub fn main() !void {
    const enemy = Stats{ .health = 109, .damage = 8, .armor = 2 };
    var win_min_cost: usize = std.math.maxInt(usize);
    var lose_max_cost: usize = 0;
    for (0..WEAPONS.len) |weapon_idx| {
        const weapon = WEAPONS[weapon_idx];
        for (0..ARMORS.len) |armor_idx| {
            const armor = ARMORS[armor_idx];
            for (0..RINGS.len) |ring_1_idx| {
                const ring_1 = RINGS[ring_1_idx];
                for (0..RINGS.len) |ring_2_idx| {
                    if (ring_1_idx == ring_2_idx) {
                        continue;
                    }
                    const ring_2 = RINGS[ring_2_idx];
                    const cost = weapon.cost + armor.cost + ring_1.cost + ring_2.cost;
                    var player = Stats{
                        .health = 100,
                        .damage = weapon.damage + ring_1.damage + ring_2.damage,
                        .armor = armor.armor + ring_1.armor + ring_2.armor,
                    };
                    var enemy_copy = enemy;
                    var result = Result.Continue;
                    while (result == .Continue) {
                        result = turn(&player, &enemy_copy);
                        switch (result) {
                            .PlayerWins => {
                                win_min_cost = @min(win_min_cost, cost);
                            },
                            .EnemyWins => {
                                lose_max_cost = @max(lose_max_cost, cost);
                            },
                            .Continue => {},
                        }
                    }
                }
            }
        }
    }
    std.debug.print("part 1 result: {}\n", .{win_min_cost});
    std.debug.print("part 2 resulk: {}\n", .{lose_max_cost});
}

const Item = struct {
    cost: usize,
    damage: usize = 0,
    armor: usize = 0,
};

const Stats = struct {
    health: isize,
    damage: usize = 0,
    armor: usize = 0,
};

const WEAPONS = [_]Item{
    .{ .cost = 8, .damage = 4 },
    .{ .cost = 10, .damage = 5 },
    .{ .cost = 25, .damage = 6 },
    .{ .cost = 40, .damage = 7 },
    .{ .cost = 74, .damage = 8 },
};

const ARMORS = [_]Item{
    .{ .cost = 0 }, // No armor
    .{ .cost = 13, .armor = 1 },
    .{ .cost = 31, .armor = 2 },
    .{ .cost = 53, .armor = 3 },
    .{ .cost = 75, .armor = 4 },
    .{ .cost = 102, .armor = 5 },
};

const RINGS = [_]Item{
    .{ .cost = 0 }, // No ring for finger 1
    .{ .cost = 0 }, // No ring for finger 2
    .{ .cost = 25, .damage = 1 },
    .{ .cost = 50, .damage = 2 },
    .{ .cost = 100, .damage = 3 },
    .{ .cost = 20, .armor = 1 },
    .{ .cost = 40, .armor = 2 },
    .{ .cost = 80, .armor = 3 },
};

const Result = enum {
    Continue,
    PlayerWins,
    EnemyWins,
};

fn turn(player: *Stats, enemy: *Stats) Result {
    const player_damage = if (player.damage > enemy.armor) player.damage - enemy.armor else 1;
    enemy.health -= @intCast(player_damage);
    if (enemy.health <= 0) {
        return .PlayerWins;
    }

    const enemy_damage = if (enemy.damage > player.armor) enemy.damage - player.armor else 1;
    player.health -= @intCast(enemy_damage);
    if (player.health <= 0) {
        return .EnemyWins;
    }

    return .Continue;
}
