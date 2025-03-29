const std = @import("std");
const components = @import("components");

pub const Movement = struct {
    allocator: std.mem.Allocator,
    entities: std.ArrayListUnmanaged(Entity),

    pub const Entity = struct {
        id: usize,
        position: components.Position,
    };

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
        _ = delta;
        for (self.entities.items) |_| {}
    }
};
