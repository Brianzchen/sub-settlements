const std = @import("std");

pub const CollisionSystem = struct {
    allocator: std.mem.Allocator,
    entities: std.ArrayListUnmanaged(u32),

    pub fn init(allocator: std.mem.Allocator) CollisionSystem {
        const entities: std.ArrayListUnmanaged(u32) = .empty;

        return CollisionSystem{
            .allocator = allocator,
            .entities = entities,
        };
    }

    pub fn deinit(self: *const CollisionSystem) void {
        self.entities.deinit(self.allocator);
    }

    pub fn addEntity(self: *CollisionSystem, entity: u32) !void {
        try self.entities.append(self.allocator, entity);
    }

    /// Runs every tick checking if there is a collision or not between
    /// other entities on all directions, depending if there is or isn't then
    /// we influence entities in a particular way
    pub fn update(self: *const CollisionSystem) void {
        _ = self;
    }
};
