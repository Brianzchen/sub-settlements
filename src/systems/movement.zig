const std = @import("std");
const rl = @import("raylib");
const components = @import("components");

const ActOn = struct {
    moveable: components.Moveable,
    position: components.Position,
    direction: components.Direction,
};

pub const Movement = struct {
    allocator: std.mem.Allocator,
    act_on: std.ArrayListUnmanaged(ActOn),

    pub fn init(allocator: std.mem.Allocator) Movement {
        return Movement{
            .allocator = allocator,
            .act_on = std.ArrayListUnmanaged(ActOn).empty,
        };
    }

    pub fn deinit(self: *Movement) void {
        self.act_on.deinit(self.allocator);
    }

    pub fn addEntity(self: *Movement, entity: ActOn) !void {
        try self.act_on.append(self.allocator, entity);
    }

    /// Runs every tick
    pub fn update(delta: i32) void {
        _ = delta;
        // TODO:
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

    try std.testing.expect(movement.act_on.items.len == 1);
}
