const std = @import("std");

pub const EntityPool = struct {
    allocator: std.mem.Allocator,
    entities: std.ArrayListUnmanaged(usize),

    pub fn init(allocator: std.mem.Allocator) EntityPool {
        const entities: std.ArrayListUnmanaged(usize) = .empty;

        return EntityPool{
            .allocator = allocator,
            .entities = entities,
        };
    }

    pub fn deinit(self: *EntityPool) void {
        self.entities.deinit(self.allocator);
    }

    pub fn addEntity(self: *EntityPool) !usize {
        const entity: usize = self.entities.items.len;
        try self.entities.append(self.allocator, entity);

        return self.entities.getLast();
    }
};
