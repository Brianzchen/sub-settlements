const std = @import("std");
const rl = @import("raylib");

const Direction = @import("./direction.zig").Direction;

fn distanceBySpeed(speedPerSecond: f32, diff: i64) f32 {
    return speedPerSecond * (@as(f32, @floatFromInt(diff)) / 1000.0);
}

pub const Player = struct {
    allocator: std.mem.Allocator,
    position: *rl.Vector2,
    texture: *rl.Texture,
    direction: Direction,
    moving: bool,

    pub fn init(allocator: std.mem.Allocator, position: rl.Vector2) !Player {
        const alloc_position = try allocator.create(rl.Vector2);
        alloc_position.* = position;

        const player = try rl.loadImage("assets/player-1.png");
        const alloc_texture = try allocator.create(rl.Texture);
        alloc_texture.* = try rl.loadTextureFromImage(player);
        rl.unloadImage(player);

        return Player{
            .allocator = allocator,
            .position = alloc_position,
            .texture = alloc_texture,
            .direction = Direction.LEFT,
            .moving = false,
        };
    }

    pub fn deinit(self: *const Player) void {
        self.allocator.destroy(self.position);
        self.allocator.destroy(self.texture);
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

        self.texture.drawV(self.position.*, .white);
    }

    pub fn startMoving(self: *Player, direction: Direction) void {
        self.direction = direction;
        self.moving = true;
    }

    pub fn stopMoving(self: *Player) void {
        self.moving = false;
    }
};

// TODO: Figure out how to load assets during testing
// test "Player - init" {
//     const allocator = std.testing.allocator;

//     const v = rl.Vector2.init(1, 1);
//     const player = try Player.init(allocator, v);
//     player.deinit();
// }
