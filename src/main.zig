const rl = @import("raylib");
const inputs = @import("./inputs/main.zig");

const keyboardEvents = inputs.keyboardEvents;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "Sub Settlements");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    const player = try rl.loadImage("assets/player-1.png");
    const texture = try rl.loadTextureFromImage(player);
    rl.unloadImage(player);

    var player_position = rl.Vector2.init(100, 100);

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
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

        texture.drawV(player_position, .white);

        keyboardEvents(&player_position);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        //----------------------------------------------------------------------------------
    }
}
