const std = @import("std");
const rl = @import("raylib");

pub const Position = struct {
    allocator: std.mem.Allocator,
    position: *rl.Vector2,
    /// Total width where position is center point
    width: f32,
    /// Total height where position is center point
    height: f32,

    pub fn init(allocator: std.mem.Allocator, x: f32, y: f32) !Position {
        const position = try allocator.create(rl.Vector2);
        position.* = rl.Vector2.init(x, y);

        return Position{
            .allocator = allocator,
            .position = position,
            .width = 0.0,
            .height = 0.0,
        };
    }

    pub fn deinit(self: *const Position) void {
        self.allocator.destroy(self.position);
    }

    pub fn updatePosition(self: *const Position, x: f32, y: f32) void {
        self.position.x = x;
        self.position.y = y;
    }

    pub fn updateSize(self: *Position, width: f32, height: f32) void {
        self.width = width;
        self.height = height;
    }
};

test "Position - init" {
    const allocator = std.testing.allocator;

    const position = try Position.init(allocator, 0, 0);
    defer position.deinit();
}

test "Position - update position" {
    const allocator = std.testing.allocator;

    const position = try Position.init(allocator, 0, 0);
    defer position.deinit();

    position.updatePosition(1.0, 2.0);

    try std.testing.expect(position.position.x == 1.0);
    try std.testing.expect(position.position.y == 2.0);
}

test "Position - update size" {
    const allocator = std.testing.allocator;

    var position = try Position.init(allocator, 0, 0);
    defer position.deinit();

    position.updateSize(1.0, 2.0);

    try std.testing.expect(position.width == 1.0);
    try std.testing.expect(position.height == 2.0);
}
