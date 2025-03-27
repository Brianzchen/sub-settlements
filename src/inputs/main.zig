const std = @import("std");
const rl = @import("raylib");

const models = @import("models");
const systems = @import("systems");

pub fn keyboardEvents(
    allocator: std.mem.Allocator,
    player: systems.MovementSys.Entity,
) !void {
    var currently_pressed_keys: std.ArrayListUnmanaged(rl.KeyboardKey) = .empty;

    if (rl.isKeyDown(.left)) {
        try currently_pressed_keys.append(allocator, .left);
    }
    if (rl.isKeyDown(.right)) {
        try currently_pressed_keys.append(allocator, .right);
    }
    if (rl.isKeyDown(.a)) {
        try currently_pressed_keys.append(allocator, .left);
    }
    if (rl.isKeyDown(.d)) {
        try currently_pressed_keys.append(allocator, .right);
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
            player.direction.updateDirection(270.0);
        }
        if (has_right) {
            player.direction.updateDirection(90.0);
        }
        player.moveable.startMoving();
    } else {
        player.moveable.stopMoving();
    }
}
