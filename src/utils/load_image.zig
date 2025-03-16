const std = @import("std");
const rl = @import("raylib");

pub fn loadImage(allocator: std.mem.Allocator, comptime asset_path: [:0]const u8) !*rl.Texture {
    const image = try rl.loadImage(asset_path);
    const texture = try allocator.create(rl.Texture);
    texture.* = try rl.loadTextureFromImage(image);
    rl.unloadImage(image);

    return texture;
}
