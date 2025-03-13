const std = @import("std");
const rl = @import("raylib");

pub fn keyboardEvents(player_position: *rl.Vector2) void {
    if (rl.isKeyDown(.left)) {
        player_position.x = player_position.x - 1;
    }
    if (rl.isKeyUp(.left)) {
        //
    }
    if (rl.isKeyDown(.right)) {
        player_position.x = player_position.x + 1;
    }
    if (rl.isKeyUp(.right)) {
        //
    }
}
