const std = @import("std");
const rl = @import("raylib");
const inputs = @import("./inputs/main.zig");
const models = @import("models");
const utils = @import("./utils/main.zig");
// const systems = @import("systems");

const keyboardEvents = inputs.keyboardEvents;

const Controls = enum {
    MOVE_LEFT,
    MOVE_RIGHT,
    ATTACK,
    CROUCH,
    JUMP,
    INTERACT,
};

const HealthComponent = struct {};

const GravityComponent = struct {
    pub fn init() Component {
        return Component{ .gravity = GravityComponent{} };
    }
};

const Component = union(enum) {
    health: HealthComponent,
    gravity: GravityComponent,
};

const Entity = struct {
    allocator: std.mem.Allocator,
    id: u32,
    components: std.ArrayListUnmanaged(Component),

    pub fn init(allocator: std.mem.Allocator, id: u32) Entity {
        return Entity{
            .allocator = allocator,
            .id = id,
            .components = std.ArrayListUnmanaged(Component).empty,
        };
    }

    pub fn deinit(self: *Entity) void {
        self.components.deinit(self.allocator);
    }

    pub fn addComponent(self: *Entity, component: Component) !void {
        try self.components.append(
            self.allocator,
            component,
        );
    }
};

const EntityPool = struct {
    allocator: std.mem.Allocator,
    entities: std.ArrayListUnmanaged(Entity),

    pub fn init(allocator: std.mem.Allocator) EntityPool {
        const entities: std.ArrayListUnmanaged(Entity) = .empty;

        return EntityPool{
            .allocator = allocator,
            .entities = entities,
        };
    }

    pub fn deinit(self: *EntityPool) void {
        self.entities.deinit(self.allocator);
    }

    pub fn createEntity(self: *EntityPool, allocator: std.mem.Allocator) !Entity {
        const entity = Entity.init(self.allocator, @intCast(self.entities.items.len + 1));
        try self.entities.append(allocator, entity);

        return self.entities.getLast();
    }
};

const CollisionSystem = struct {
    allocator: std.mem.Allocator,
    entity_pool: EntityPool,

    pub fn init(allocator: std.mem.Allocator, entity_pool: EntityPool) CollisionSystem {
        return CollisionSystem{
            .allocator = allocator,
            .entity_pool = entity_pool,
        };
    }

    pub fn deinit(_: *const CollisionSystem) void {}

    /// Runs every tick checking if there is a collision or not between
    /// other entities on all directions, depending if there is or isn't then
    /// we influence entities in a particular way
    pub fn update(self: *const CollisionSystem) void {
        for (self.entity_pool.entities.items) |entity| {
            for (entity.components.items) |component| {
                switch (component) {
                    .health => |_| {
                        std.debug.print("i am health", .{});
                    },
                    .gravity => |_| {
                        std.debug.print("i am gravity", .{});
                    },
                }
            }
        }
    }
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

    var entity_pool = EntityPool.init(allocator);
    defer entity_pool.deinit();

    var player_entity = try entity_pool.createEntity(allocator);
    try player_entity.addComponent(GravityComponent.init());

    const floor = try models.Floor.init(allocator);

    const collisionSystem = CollisionSystem.init(allocator, entity_pool);

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

        collisionSystem.update();

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
