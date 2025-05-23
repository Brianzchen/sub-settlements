const std = @import("std");
const rl = @import("raylib");
const models = @import("models");
const utils = @import("./utils/main.zig");
const components = @import("components");
const systems = @import("systems");

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

    var entity_pool = utils.EntityPool.init(allocator);

    var collisionSystem = systems.CollisionSys.init(allocator);
    defer collisionSystem.deinit();

    var movementSystem = systems.MovementSys.init(allocator);
    defer movementSystem.deinit();
    const player_entity = .{
        .id = try entity_pool.addEntity(),
        .direction = try components.Direction.init(allocator, 20.0),
        .moveable = try components.Moveable.init(allocator, 20.0),
        .position = try components.Position.init(allocator, 0, 0),
    };
    try movementSystem.addEntity(
        systems.MovementSys.pullComponents(player_entity),
    );
    try collisionSystem.addEntity(
        systems.CollisionSys.pullEntity(player_entity),
    );

    var tree_entity = .{
        .id = try entity_pool.addEntity(),
        .position = try components.Position.init(allocator, -20, 0),
    };
    tree_entity.position.updateSize(10, 100);
    try movementSystem.addEntity(
        systems.MovementSys.pullComponents(player_entity),
    );
    try collisionSystem.addInfluenceEntity(
        systems.CollisionSys.pullInfluenceEntity(tree_entity),
    );

    const inputSystem = systems.InputSys.init(
        allocator,
        systems.InputSys.pullEntity(player_entity),
    );
    defer inputSystem.deinit();

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

        // Systems
        try inputSystem.update(delta);
        collisionSystem.update(delta);
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
            player_entity.position.position.add(rl.Vector2.init(100.0, 100.0)),
            .white,
        );
        grassTexture.drawV(
            tree_entity.position.position.add(rl.Vector2.init(100.0, 100.0)),
            .white,
        );
        rl.drawText("Sub Settlements", 190, 50, 20, .light_gray);
    }
}
