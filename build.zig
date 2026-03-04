const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -------------------------------------------------------------------------
    // Dependencies
    // -------------------------------------------------------------------------

    // -------------------------------------------------------------------------
    // Reusable project modules (modern pattern = createModule)
    // -------------------------------------------------------------------------
    const op = b.createModule(.{
        .root_source_file = b.path("src/op.zig"),
        .target = target,
        .optimize = optimize,
    });

    const reg = b.createModule(.{
        .root_source_file = b.path("src/reg.zig"),
        .target = target,
        .optimize = optimize,
    });

    const parser = b.createModule(.{
        .root_source_file = b.path("src/parser/parser.zig"),
        .target = target,
        .optimize = optimize,
    });

    parser.addImport("op", op);
    parser.addImport("reg", reg);

    // -------------------------------------------------------------------------
    // Library
    // -------------------------------------------------------------------------
    const lib = b.addLibrary(.{
        .name = "default",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // attach imports
    // lib.root_module.addImport("mecha", mecha);
    lib.root_module.addImport("op", op);
    lib.root_module.addImport("reg", reg);
    lib.root_module.addImport("parser", parser);

    b.installArtifact(lib);

    // -------------------------------------------------------------------------
    // Executable
    // -------------------------------------------------------------------------
    const exe = b.addExecutable(.{
        .name = "default",
        .use_llvm = true,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // exe.root_module.addImport("mecha", mecha);
    exe.root_module.addImport("op", op);
    exe.root_module.addImport("reg", reg);
    exe.root_module.addImport("parser", parser);

    b.installArtifact(exe);

    // -------------------------------------------------------------------------
    // Run command
    // -------------------------------------------------------------------------
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // -------------------------------------------------------------------------
    // Tests  (modern test module pattern)
    // -------------------------------------------------------------------------
    const exe_unit_tests = b.addTest(.{
        .name = "unit_tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe_unit_tests.root_module.addImport("op", op);
    exe_unit_tests.root_module.addImport("parser", parser);

    const run_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("tests", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
