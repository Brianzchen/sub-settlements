const std = @import("std");
const rl = @import("raylib");

const Player = @import("models").Player;

pub fn keyboardEvents(player: *Player) void {
    if (rl.isKeyDown(.left)) {
        player.position.x = player.position.x - 1;
    }
    if (rl.isKeyUp(.left)) {
        //
    }
    if (rl.isKeyDown(.right)) {
        player.position.x = player.position.x + 1;
    }
    if (rl.isKeyUp(.right)) {
        //
    }
    if (rl.isKeyDown(.a)) {
        player.position.x = player.position.x - 1;
    }
    if (rl.isKeyDown(.d)) {
        player.position.x = player.position.x + 1;
    }
    if (rl.isKeyDown(.space)) {
        //
    }
}
