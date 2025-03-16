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
    const emptyTexture = try utils.loadImage(allocator, "assets/empty-block.png");
    defer allocator.destroy(emptyTexture);

    var player = try models.Player.init(allocator, rl.Vector2.init(100, 100));
    defer player.deinit();

    const floor = try models.Floor.init(allocator);

    // Time since start of game
    var time = std.time.milliTimestamp();

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        const now = std.time.milliTimestamp();
        const diff = now - time;
        time = now;

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);
        rl.drawFPS(8, 8);

        player.draw(diff);
        playerTexture.drawV(player.position.*, .white);

        const offset = 100 + playerTexture.height;

        for (floor.grid.items, 0..) |row, y_ind| {
            for (row.items, 0..) |tile, x_ind| {
                var texture = emptyTexture;
                if (tile == models.TileType.GRASS) {
                    texture = grassTexture;
                }
                const width: i32 = @intCast(texture.width);
                const x: i32 = @intCast(x_ind);
                const height: i32 = @intCast(texture.height);
                const y: i32 = @intCast(y_ind);
                texture.draw(
                    x * width,
                    y * height + offset,
                    .white,
                );
            }
        }

        try keyboardEvents(allocator, &player);

        rl.drawText("Sub Settlements", 190, 50, 20, .light_gray);
    }
}
