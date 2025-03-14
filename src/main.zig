const std = @import("std");
const rl = @import("raylib");
const inputs = @import("./inputs/main.zig");
const models = @import("models");
const utils = @import("./utils/main.zig");

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

    const playerTexture = try utils.loadImage(allocator, "assets/player-1.png");
    defer allocator.destroy(playerTexture);

    const grassTexture = try utils.loadImage(allocator, "assets/grass.png");
    defer allocator.destroy(grassTexture);

    var player = try models.Player.init(allocator, rl.Vector2.init(100, 100));
    defer player.deinit();

    _ = models.Floor.init();

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
        playerTexture.drawV(player.position.*, .white);

        const offset = 100 + playerTexture.height;
        grassTexture.draw(0, 0 + offset, .white);
        grassTexture.draw(1 * 48, 0 + offset, .white);
        grassTexture.draw(2 * 48, 0 + offset, .white);
        grassTexture.draw(3 * 48, 0 + offset, .white);
        grassTexture.draw(4 * 48, 0 + offset, .white);
        grassTexture.draw(5 * 48, 0 + offset, .white);
        grassTexture.draw(6 * 48, 0 + offset, .white);
        grassTexture.draw(7 * 48, 0 + offset, .white);
        grassTexture.draw(8 * 48, 0 + offset, .white);
        // for (floor.grid, 0..) |row, y_ind| {
        //     for (row, 0..) |_, x_ind| {
        //         const texture = grassTexture;
        //         texture.draw(
        //             // TODO: Need to use texture.width/height but they are c_int
        //             x_ind * 48,
        //             y_ind * 48,
        //             .white,
        //         );
        //     }
        // }

        try keyboardEvents(allocator, &player);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        //----------------------------------------------------------------------------------
    }
}
