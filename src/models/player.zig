const std = @import("std");
const rl = @import("raylib");

const Direction = enum { LEFT, RIGHT };

pub const Player = struct {
    allocator: std.mem.Allocator,
    position: *rl.Vector2,
    texture: *rl.Texture,
    direction: Direction,

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
        };
    }

    pub fn deinit(self: *const Player) void {
        self.allocator.destroy(self.position);
        self.allocator.destroy(self.texture);
    }

    pub fn draw(self: *const Player, diff: i64) void {
        std.debug.print("{d}", .{diff});
        self.texture.drawV(self.position.*, .white);
    }
};

// TODO: Figure out how to load assets during testing
// test "Player - init" {
//     const allocator = std.testing.allocator;

//     const v = rl.Vector2.init(1, 1);
//     const player = try Player.init(allocator, v);
//     player.deinit();
// }
