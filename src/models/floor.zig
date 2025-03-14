const std = @import("std");

const TileType = enum {
    EMPTY,
    GRASS,
};

pub const Floor = struct {
    /// 2d array of the ground that is will be placed at y axis 0
    /// Anything above the floor like trees or mountains will be a different asset
    grid: [][]TileType,

    pub fn init() Floor {
        return Floor{
            .grid = &[_][]TileType{
                // std.mem.sliceTo(ptr: anytype, comptime end: std.meta.Elem(@TypeOf(ptr)))
                // [_]TileType{ TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS },
                // [_]TileType{ TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS },
                // [_]TileType{ TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS },
                // [_]TileType{ TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS },
                // [_]TileType{ TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS },
                // [_]TileType{ TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS },
                // [_]TileType{ TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS },
                // [_]TileType{ TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS },
                // [_]TileType{ TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS, TileType.GRASS },
            },
        };
    }
};
