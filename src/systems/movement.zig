const std = @import("std");
const rl = @import("raylib");
const components = @import("components");

fn distanceBySpeed(speedPerSecond: f32, diff: i64) f32 {
    return speedPerSecond * (@as(f32, @floatFromInt(diff)) / 1000.0);
}

fn updatePosition(x: f64, y: f32, degrees: f32, distance: f32) struct { x: f32, y: f32 } {
    const radians = degrees * std.math.pi / 180;
    const delta_x = distance * std.math.sin(radians);
    const delta_y = distance * std.math.cos(radians);
    return .{
        .x = @as(f32, @floatCast(x + delta_x)),
        .y = @as(f32, @floatCast(y + delta_y)),
    };
}

pub const Movement = struct {
    allocator: std.mem.Allocator,
    entities: std.ArrayListUnmanaged(Entity),

    pub const Entity = struct {
        id: usize,
        moveable: components.Moveable,
        position: components.Position,
        direction: components.Direction,
    };

    pub fn pullComponents(entity: anytype) Entity {
        return Entity{
            .id = entity.id,
            .moveable = entity.moveable,
            .position = entity.position,
            .direction = entity.direction,
        };
    }

    pub fn init(allocator: std.mem.Allocator) Movement {
        return Movement{
            .allocator = allocator,
            .entities = std.ArrayListUnmanaged(Entity).empty,
        };
    }

    pub fn deinit(self: *Movement) void {
        self.entities.deinit(self.allocator);
    }

    pub fn addEntity(self: *Movement, entity: Entity) !void {
        try self.entities.append(self.allocator, entity);
    }

    /// Runs every tick
    pub fn update(self: *const Movement, delta: i64) void {
        for (self.entities.items) |entity| {
            if (!entity.moveable.moving.*) {
                continue;
            }
            const x = entity.position.position.x;
            const y = entity.position.position.y;
            const degrees = entity.direction.direction;
            const distance = distanceBySpeed(entity.moveable.speed.*, delta);
            const new_position = updatePosition(x, y, degrees.*, distance);

            entity.position.position.* = rl.Vector2.init(new_position.x, new_position.y);
        }
    }
};

test "Movement - init" {
    const allocator = std.testing.allocator;

    var movement = Movement.init(allocator);
    defer movement.deinit();
}

test "Movement - add entity" {
    const allocator = std.testing.allocator;

    var movement = Movement.init(allocator);
    defer movement.deinit();

    const moveableComp = try components.Moveable.init(allocator, 5.0);
    defer moveableComp.deinit();
    const positionComp = try components.Position.init(allocator, 0, 0);
    defer positionComp.deinit();
    const directionComp = try components.Direction.init(allocator, 40);
    defer directionComp.deinit();

    try movement.addEntity(.{
        .moveable = moveableComp,
        .direction = directionComp,
        .position = positionComp,
    });

    try std.testing.expect(movement.entities.items.len == 1);
}

test "Movement - move entities basic" {
    const allocator = std.testing.allocator;

    var movement = Movement.init(allocator);
    defer movement.deinit();

    const moveableComp = try components.Moveable.init(allocator, 5.0);
    defer moveableComp.deinit();
    moveableComp.startMoving();
    const positionComp = try components.Position.init(allocator, 0, 0);
    defer positionComp.deinit();
    const directionComp = try components.Direction.init(allocator, 90.0);
    defer directionComp.deinit();

    try movement.addEntity(.{
        .moveable = moveableComp,
        .direction = directionComp,
        .position = positionComp,
    });

    movement.update(100);

    const final_position = movement.entities.items[0].position.position;
    try std.testing.expect(final_position.x == 0.5);
    try std.testing.expectApproxEqAbs(0, final_position.y, 1e-6);

    movement.update(100);
    movement.update(100);
    movement.update(100);

    try std.testing.expect(final_position.x == 2);
    try std.testing.expectApproxEqAbs(0, final_position.y, 1e-6);
}

test "Movement - move entities negative" {
    const allocator = std.testing.allocator;

    var movement = Movement.init(allocator);
    defer movement.deinit();

    const moveableComp = try components.Moveable.init(allocator, 5.0);
    defer moveableComp.deinit();
    moveableComp.startMoving();
    const positionComp = try components.Position.init(allocator, 0, 0);
    defer positionComp.deinit();
    const directionComp = try components.Direction.init(allocator, 240.0);
    defer directionComp.deinit();

    try movement.addEntity(.{
        .moveable = moveableComp,
        .direction = directionComp,
        .position = positionComp,
    });

    movement.update(100);

    const final_position = movement.entities.items[0].position.position;
    try std.testing.expectApproxEqAbs(-0.43, final_position.x, 1e-2);
    try std.testing.expectApproxEqAbs(-0.25, final_position.y, 1e-2);
}

test "Movement - does not move entity if not moving" {
    const allocator = std.testing.allocator;

    var movement = Movement.init(allocator);
    defer movement.deinit();

    const moveableComp = try components.Moveable.init(allocator, 5.0);
    defer moveableComp.deinit();
    const positionComp = try components.Position.init(allocator, 0, 0);
    defer positionComp.deinit();
    const directionComp = try components.Direction.init(allocator, 240.0);
    defer directionComp.deinit();

    try movement.addEntity(.{
        .moveable = moveableComp,
        .direction = directionComp,
        .position = positionComp,
    });

    movement.update(100);

    const final_position = movement.entities.items[0].position.position;
    try std.testing.expect(final_position.x == 0);
    try std.testing.expect(final_position.y == 0);
}

test "Movement - moves only entities that are moving" {
    const allocator = std.testing.allocator;

    var movement = Movement.init(allocator);
    defer movement.deinit();

    const moveableComp = try components.Moveable.init(allocator, 5.0);
    defer moveableComp.deinit();
    const positionComp = try components.Position.init(allocator, 0, 0);
    defer positionComp.deinit();
    const directionComp = try components.Direction.init(allocator, 240.0);
    defer directionComp.deinit();

    try movement.addEntity(.{
        .moveable = moveableComp,
        .direction = directionComp,
        .position = positionComp,
    });

    const moveableComp2 = try components.Moveable.init(allocator, 5.0);
    defer moveableComp2.deinit();
    moveableComp2.startMoving();
    const positionComp2 = try components.Position.init(allocator, 0, 0);
    defer positionComp2.deinit();
    const directionComp2 = try components.Direction.init(allocator, 240.0);
    defer directionComp2.deinit();

    try movement.addEntity(.{
        .moveable = moveableComp2,
        .direction = directionComp2,
        .position = positionComp2,
    });

    movement.update(100);

    const final_position = movement.entities.items[0].position.position;
    try std.testing.expect(final_position.x == 0);
    try std.testing.expect(final_position.y == 0);

    const final_position2 = movement.entities.items[1].position.position;
    try std.testing.expectApproxEqAbs(-0.43, final_position2.x, 1e-2);
    try std.testing.expectApproxEqAbs(-0.25, final_position2.y, 1e-2);
}
