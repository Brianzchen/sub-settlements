const std = @import("std");

pub fn findNestedTestFiles(
    allocator: std.mem.Allocator,
    dirName: []const u8,
    file_pattern_optional: ?[]const u8,
) !std.ArrayListUnmanaged([]const u8) {
    var files: std.ArrayListUnmanaged([]const u8) = .empty;
    var dir = try std.fs.cwd().openDir(dirName, .{
        .iterate = true,
    });
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        if (entry.kind == std.fs.Dir.Entry.Kind.file and std.mem.endsWith(u8, entry.name, ".zig")) {
            const fileName = try std.mem.concat(
                allocator,
                u8,
                &.{
                    dirName,
                    "/",
                    entry.name,
                },
            );
            defer allocator.free(fileName);
            if (file_pattern_optional) |file_pattern| {
                if (std.mem.indexOf(u8, fileName, file_pattern)) |_| {
                    try files.append(allocator, try allocator.dupe(u8, fileName));
                }
            } else {
                try files.append(allocator, try allocator.dupe(u8, fileName));
            }
        } else if (entry.kind == std.fs.Dir.Entry.Kind.directory) {
            const nestedDirName = try std.mem.concat(allocator, u8, &.{ dirName, "/", entry.name });
            defer allocator.free(nestedDirName);
            var nestedFiles = try findNestedTestFiles(
                allocator,
                nestedDirName,
                file_pattern_optional,
            );
            defer {
                for (nestedFiles.items) |nestedFile| {
                    allocator.free(nestedFile);
                }
                nestedFiles.deinit(allocator);
            }
            for (nestedFiles.items) |nestedFile| {
                const fileName = try allocator.dupe(u8, nestedFile);
                try files.append(allocator, fileName);
            }
        }
    }
    return files;
}

test "findNestedTestFiles - Can find tested files" {
    const allocator = std.testing.allocator;

    var files = try findNestedTestFiles(allocator, "src", null);
    defer {
        for (files.items) |file| {
            allocator.free(file);
        }
        files.deinit(allocator);
    }
    for (files.items) |file| {
        try std.testing.expect(std.mem.startsWith(u8, file, "src/"));
        try std.testing.expect(std.mem.endsWith(u8, file, ".zig"));
    }
}

test "findNestedTestFiles - Can find only the files based on a pattern match" {
    const allocator = std.testing.allocator;

    var files = try findNestedTestFiles(allocator, "src", "find-nested");
    defer {
        for (files.items) |file| {
            allocator.free(file);
        }
        files.deinit(allocator);
    }
    try std.testing.expect(files.items.len == 1);
}
