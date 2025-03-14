const std = @import("std");
const findNestedTestFiles = @import("./tooling/find-nested-test-files.zig").findNestedTestFiles;

const LocalModule = struct {
    name: []const u8,
    module: *std.Build.Module,
};

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const file_pattern = b.option(
        []const u8,
        "pattern",
        "When running tests, a partial file pattern to match against",
    );

    const exe = b.addExecutable(.{
        .name = "sub-settlements",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib = raylib_dep.module("raylib"); // main raylib module
    const raygui = raylib_dep.module("raygui"); // raygui module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library
    exe.linkLibrary(raylib_artifact);

    // const domains = LocalModule{
    //     .name = "domains",
    //     .module = b.createModule(.{
    //         .root_source_file = std.Build.LazyPath{ .cwd_relative = "src/domains/main.zig" },
    //     }),
    // };
    // const inMemoryStore = LocalModule{
    //     .name = "inMemoryStore",
    //     .module = b.createModule(.{
    //         .root_source_file = std.Build.LazyPath{ .cwd_relative = "src/persistence/in-memory-store.zig" },
    //     }),
    // };
    // inMemoryStore.module.addImport(domains.name, domains.module);
    const localModules = [_]LocalModule{};

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    var testFiles = try findNestedTestFiles(allocator, "src", file_pattern);
    defer {
        for (testFiles.items) |file| {
            allocator.free(file);
        }
        testFiles.deinit(allocator);
    }
    for (testFiles.items) |testFile| {
        const exe_unit_tests = b.addTest(.{
            .root_source_file = b.path(testFile),
            .target = target,
            .optimize = optimize,
        });
        exe_unit_tests.root_module.addImport("raylib", raylib);
        exe_unit_tests.root_module.addImport("raygui", raygui);
        for (localModules) |localModule| {
            exe_unit_tests.root_module.addImport(localModule.name, localModule.module);
        }
        const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
        test_step.dependOn(&run_exe_unit_tests.step);
    }

    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);

    for (localModules) |localModule| {
        exe.root_module.addImport(localModule.name, localModule.module);
    }
}
