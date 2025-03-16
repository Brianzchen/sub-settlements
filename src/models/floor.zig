const std = @import("std");

const TileType = enum {
    EMPTY,
    GRASS,
};

pub const Floor = struct {
    allocator: std.mem.Allocator,
    /// 2d array of the ground that is will be placed at y axis 0
    /// Anything above the floor like trees or mountains will be a different asset
    grid: std.ArrayListUnmanaged(std.ArrayListUnmanaged(TileType)),

    pub fn init(allocator: std.mem.Allocator) !Floor {
        var grid: std.ArrayListUnmanaged(std.ArrayListUnmanaged(TileType)) = .empty;

        var row1: std.ArrayListUnmanaged(TileType) = .empty;
        try row1.append(allocator, TileType.GRASS);
        try row1.append(allocator, TileType.GRASS);
        try row1.append(allocator, TileType.GRASS);
        try row1.append(allocator, TileType.GRASS);
        try row1.append(allocator, TileType.GRASS);
        try row1.append(allocator, TileType.GRASS);
        try row1.append(allocator, TileType.EMPTY);
        try row1.append(allocator, TileType.GRASS);

        try grid.append(allocator, row1);

        var row2: std.ArrayListUnmanaged(TileType) = .empty;
        try row2.append(allocator, TileType.GRASS);
        try row2.append(allocator, TileType.GRASS);
        try row2.append(allocator, TileType.GRASS);
        try row2.append(allocator, TileType.GRASS);
        try row2.append(allocator, TileType.GRASS);
        try row2.append(allocator, TileType.GRASS);
        try row2.append(allocator, TileType.GRASS);
        try row2.append(allocator, TileType.GRASS);

        try grid.append(allocator, row2);

        var row3: std.ArrayListUnmanaged(TileType) = .empty;
        try row3.append(allocator, TileType.GRASS);
        try row3.append(allocator, TileType.GRASS);
        try row3.append(allocator, TileType.GRASS);
        try row3.append(allocator, TileType.GRASS);
        try row3.append(allocator, TileType.GRASS);
        try row3.append(allocator, TileType.GRASS);
        try row3.append(allocator, TileType.GRASS);
        try row3.append(allocator, TileType.GRASS);

        try grid.append(allocator, row3);

        return Floor{
            .allocator = allocator,
            .grid = grid,
        };
    }

    pub fn deinit(self: *const Floor) void {
        for (self.grid) |row| {
            row.deinit(self.allocator);
        }
    }
};

test "Floor - init and deinit" {
    const allocator = std.testing.allocator;

    const floor = try Floor.init(allocator);
    floor.deinit();
}
