const std = @import("std");
const rl = @import("raylib");

const models = @import("models");
const components = @import("components");

pub const Input = struct {
    allocator: std.mem.Allocator,
    player_entity: PlayerEntity,

    pub const PlayerEntity = struct {
        id: usize,
        direction: components.Direction,
        moveable: components.Moveable,
    };

    pub fn pullEntity(entity: anytype) PlayerEntity {
        return PlayerEntity{
            .id = entity.id,
            .direction = entity.direction,
            .moveable = entity.moveable,
        };
    }

    pub fn init(allocator: std.mem.Allocator, player: PlayerEntity) Input {
        return Input{
            .allocator = allocator,
            .player_entity = player,
        };
    }

    pub fn deinit(_: *const Input) void {}

    pub fn update(self: *const Input, _: i64) !void {
        var currently_pressed_keys: std.ArrayListUnmanaged(rl.KeyboardKey) = .empty;
        defer currently_pressed_keys.deinit(self.allocator);

        if (rl.isKeyDown(.left)) {
            try currently_pressed_keys.append(self.allocator, .left);
        }
        if (rl.isKeyDown(.right)) {
            try currently_pressed_keys.append(self.allocator, .right);
        }
        if (rl.isKeyDown(.a)) {
            try currently_pressed_keys.append(self.allocator, .left);
        }
        if (rl.isKeyDown(.d)) {
            try currently_pressed_keys.append(self.allocator, .right);
        }
        if (rl.isKeyDown(.space)) {
            // player.jump();
        }

        var has_left = false;
        var has_right = false;
        var direction: models.Direction = .LEFT;
        for (currently_pressed_keys.items) |key| {
            if (key == rl.KeyboardKey.left) {
                has_left = true;
                direction = .LEFT;
            } else if (key == rl.KeyboardKey.right) {
                has_right = true;
                direction = .RIGHT;
            }
        }

        if ((has_left and !has_right) or (!has_left and has_right)) {
            if (has_left) {
                self.player_entity.direction.updateDirection(270.0);
            }
            if (has_right) {
                self.player_entity.direction.updateDirection(90.0);
            }
            self.player_entity.moveable.startMoving();
        } else {
            self.player_entity.moveable.stopMoving();
        }
    }
};
