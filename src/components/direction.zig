const std = @import("std");

pub const Direction = struct {
    allocator: std.mem.Allocator,
    /// From 0 - 359 where 0 is top dead center
    direction: *u9,

    pub fn init(allocator: std.mem.Allocator, initialDirection: u9) !Direction {
        const direction = try allocator.create(u9);
        direction.* = initialDirection;

        return Direction{
            .allocator = allocator,
            .direction = direction,
        };
    }

    pub fn deinit(self: *const Direction) void {
        self.allocator.destroy(self.direction);
    }

    pub fn updateDirection(self: *const Direction, newDirection: u9) !void {
        self.direction.* = newDirection % 359;
    }
};

test "Direction - creation" {
    const allocator = std.testing.allocator;

    const direction = try Direction.init(allocator, 0);
    defer direction.deinit();

    try std.testing.expect(direction.direction.* == 0);
}

test "Direction - change direction" {
    const allocator = std.testing.allocator;

    const direction = try Direction.init(allocator, 0);
    defer direction.deinit();

    try direction.updateDirection(240);

    try std.testing.expect(direction.direction.* == 240);
}

test "Direction - change direction overflow" {
    const allocator = std.testing.allocator;

    const direction = try Direction.init(allocator, 0);
    defer direction.deinit();

    try direction.updateDirection(480);

    try std.testing.expect(direction.direction.* == 121);
}
