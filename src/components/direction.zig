const std = @import("std");

pub const Direction = struct {
    allocator: std.mem.Allocator,
    /// From 0 - 359 where 0 is top dead center
    direction: *f32,

    pub fn init(allocator: std.mem.Allocator, initialDirection: f32) !Direction {
        const direction = try allocator.create(f32);
        direction.* = initialDirection;

        return Direction{
            .allocator = allocator,
            .direction = direction,
        };
    }

    pub fn deinit(self: *const Direction) void {
        self.allocator.destroy(self.direction);
    }

    pub fn updateDirection(self: *const Direction, newDirection: f32) !void {
        self.direction.* = @mod(newDirection, 360);
    }
};

test "Direction - creation" {
    const allocator = std.testing.allocator;

    const direction = try Direction.init(allocator, 0.0);
    defer direction.deinit();

    try std.testing.expect(direction.direction.* == 0.0);
}

test "Direction - change direction" {
    const allocator = std.testing.allocator;

    const direction = try Direction.init(allocator, 0.0);
    defer direction.deinit();

    try direction.updateDirection(240.0);

    try std.testing.expect(direction.direction.* == 240.0);
}

test "Direction - change direction overflow" {
    const allocator = std.testing.allocator;

    const direction = try Direction.init(allocator, 0.0);
    defer direction.deinit();

    try direction.updateDirection(480.0);
    try std.testing.expect(direction.direction.* == 120.0);

    try direction.updateDirection(360.0);
    try std.testing.expect(direction.direction.* == 0.0);
}
