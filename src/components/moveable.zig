const std = @import("std");

pub const Moveable = struct {
    allocator: std.mem.Allocator,
    /// Units typically pixels per second
    speed: *f32,
    moving: *bool,

    pub fn init(allocator: std.mem.Allocator, initialSpeed: f32) !Moveable {
        const speed = try allocator.create(f32);
        speed.* = initialSpeed;
        const moving = try allocator.create(bool);
        moving.* = false;

        return Moveable{
            .allocator = allocator,
            .speed = speed,
            .moving = moving,
        };
    }

    pub fn deinit(self: *const Moveable) void {
        self.allocator.destroy(self.speed);
        self.allocator.destroy(self.moving);
    }

    pub fn startMoving(self: *const Moveable) void {
        self.moving.* = true;
    }

    pub fn stopMoving(self: *const Moveable) void {
        self.moving.* = false;
    }

    pub fn updateSpeed(self: *const Moveable, speed: f32) void {
        self.speed.* = speed;
    }
};

test "Movement - init" {
    const allocator = std.testing.allocator;

    const movement = try Moveable.init(allocator, 5.0);
    defer movement.deinit();

    try std.testing.expect(movement.speed.* == 5.0);
    try std.testing.expect(movement.moving.* == false);
}

test "Movement - start moving" {
    const allocator = std.testing.allocator;

    const movement = try Moveable.init(allocator, 5.0);
    defer movement.deinit();

    movement.startMoving();

    try std.testing.expect(movement.speed.* == 5.0);
    try std.testing.expect(movement.moving.* == true);
}

test "Movement - stop moving" {
    const allocator = std.testing.allocator;

    const movement = try Moveable.init(allocator, 5.0);
    defer movement.deinit();

    movement.startMoving();
    movement.stopMoving();

    try std.testing.expect(movement.speed.* == 5.0);
    try std.testing.expect(movement.moving.* == false);
}

test "Movement - update speed" {
    const allocator = std.testing.allocator;

    const movement = try Moveable.init(allocator, 5.0);
    defer movement.deinit();

    movement.updateSpeed(5.1);

    try std.testing.expect(movement.speed.* == 5.1);
    try std.testing.expect(movement.moving.* == false);
}
