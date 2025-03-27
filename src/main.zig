const std = @import("std");
const rl = @import("raylib");
const inputs = @import("./inputs/main.zig");
const models = @import("models");
const utils = @import("./utils/main.zig");
const components = @import("components");
const systems = @import("systems");

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

    var movementSystem = systems.MovementSys.init(allocator);
    const entity_1 = systems.MovementSys.Entity{
        .direction = try components.Direction.init(allocator, 20.0),
        .moveable = try components.Moveable.init(allocator, 20.0),
        .position = try components.Position.init(allocator, 0, 0),
    };
    try movementSystem.addEntity(entity_1);

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

    const floor = try models.Floor.init(allocator);

    // Time since start of game
    var time = std.time.milliTimestamp();

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        const now = std.time.milliTimestamp();
        const delta = now - time;
        time = now;

        try keyboardEvents(allocator, entity_1);

        // Systems
        movementSystem.update(delta);

        // Drawing
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);
        rl.drawFPS(8, 8);

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

        playerTexture.drawV(
            entity_1.position.position.add(rl.Vector2.init(100.0, 100.0)),
            .white,
        );
        rl.drawText("Sub Settlements", 190, 50, 20, .light_gray);
    }
}
