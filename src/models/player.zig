const std = @import("std");
const rl = @import("raylib");

const Direction = @import("./direction.zig").Direction;

fn distanceBySpeed(speedPerSecond: f32, diff: i64) f32 {
    return speedPerSecond * (@as(f32, @floatFromInt(diff)) / 1000.0);
}

pub const Player = struct {
    allocator: std.mem.Allocator,
    position: *rl.Vector2,
    direction: Direction,
    moving: bool,

    pub fn init(allocator: std.mem.Allocator, position: rl.Vector2) !Player {
        const alloc_position = try allocator.create(rl.Vector2);
        alloc_position.* = position;

        return Player{
            .allocator = allocator,
            .position = alloc_position,
            .direction = Direction.LEFT,
            .moving = false,
        };
    }

    pub fn deinit(self: *const Player) void {
        self.allocator.destroy(self.position);
    }

    pub fn draw(self: *const Player, diff: i64) void {
        if (self.moving) {
            const speed: f32 = 20.0;
            if (self.direction == Direction.LEFT) {
                self.position.x -= distanceBySpeed(speed, diff);
            }
            if (self.direction == Direction.RIGHT) {
                self.position.x += distanceBySpeed(speed, diff);
            }
        }
    }

    pub fn startMoving(self: *Player, direction: Direction) void {
        self.direction = direction;
        self.moving = true;
    }

    pub fn stopMoving(self: *Player) void {
        self.moving = false;
    }

    pub fn jump(self: *Player) void {
        self.position.y -= 10;
    }
};

test "Player - init" {
    const allocator = std.testing.allocator;

    const v = rl.Vector2.init(1, 1);
    const player = try Player.init(allocator, v);
    player.deinit();
}
