const std = @import("std");
const rl = @import("raylib");
const inputs = @import("./inputs/main.zig");
const Player = @import("models").Player;

const keyboardEvents = inputs.keyboardEvents;

const Controls = enum {
    MOVE_LEFT,
    MOVE_RIGHT,
    ATTACK,
    CROUCH,
    JUMP,
    INTERACT,
};

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "Sub Settlements");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var player = try Player.init(allocator, rl.Vector2.init(100, 100));
    defer player.deinit();

    // Time since start of game
    var time = std.time.milliTimestamp();

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        const now = std.time.milliTimestamp();
        const diff = now - time;
        time = now;

        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);
        rl.drawFPS(8, 8);

        player.draw(diff);

        keyboardEvents(&player);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        //----------------------------------------------------------------------------------
    }
}
