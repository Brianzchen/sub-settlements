const std = @import("std");
const components = @import("components");

pub const Collision = struct {
    allocator: std.mem.Allocator,
    entities: std.ArrayListUnmanaged(Entity),
    influence_entities: std.ArrayListUnmanaged(InfluenceEntity),

    pub const Entity = struct {
        id: usize,
        position: components.Position,
        moveable: components.Moveable,
        direction: components.Direction,
    };

    pub fn pullEntity(entity: anytype) Entity {
        return Entity{
            .id = entity.id,
            .position = entity.position,
            .moveable = entity.moveable,
            .direction = entity.direction,
        };
    }

    pub const InfluenceEntity = struct {
        id: usize,
        position: components.Position,
    };

    pub fn pullInfluenceEntity(entity: anytype) InfluenceEntity {
        return InfluenceEntity{
            .id = entity.id,
            .position = entity.position,
        };
    }

    pub fn init(allocator: std.mem.Allocator) Collision {
        return Collision{
            .allocator = allocator,
            .entities = std.ArrayListUnmanaged(Entity).empty,
            .influence_entities = std.ArrayListUnmanaged(InfluenceEntity).empty,
        };
    }

    pub fn deinit(self: *Collision) void {
        self.entities.deinit(self.allocator);
    }

    pub fn addEntity(self: *Collision, entity: Entity) !void {
        try self.entities.append(self.allocator, entity);
    }

    pub fn addInfluenceEntity(self: *Collision, influence_entity: InfluenceEntity) !void {
        try self.influence_entities.append(self.allocator, influence_entity);
    }

    /// Runs every tick
    pub fn update(self: *const Collision, delta: i64) void {
        _ = delta;
        for (self.entities.items) |entity| {
            if (!entity.moveable.moving.*) {
                continue;
            }
            const direction = entity.direction.direction.*;
            var moving_up = false;
            var moving_down = false;
            var moving_left = false;
            var moving_right = false;

            if (direction < 90 or direction > 270) {
                moving_up = true;
            }
            if (direction > 90 and direction < 270) {
                moving_down = true;
            }
            if (direction > 180) {
                moving_left = true;
            }
            if (direction > 180) {
                moving_right = true;
            }

            for (self.influence_entities.items) |influencer| {
                if (moving_up) {
                    //
                }
                if (moving_down) {
                    //
                }
                if (moving_left) {
                    const right_block = influencer.position.position.x + (influencer.position.width / 2);
                    // TODO: calculation not right
                    if (entity.position.position.x < right_block) {
                        entity.moveable.stopMoving();
                    }
                }
                if (moving_right) {
                    //
                }
            }
        }
    }
};
