const std = @import("std");
const Io = std.Io;

const platform = @import("platform/platform.zig");

const cacheDirPaths = [_][]const u8{
    "libraries",
    "resources",
    "clients",
};

fn createDirectory(io: Io, path: []const u8) !void {
    try Io.Dir.cwd().createDirPath(io, path);
}

fn folderInit(parentAllocator: std.mem.Allocator, io: std.Io, dataDir: []u8, cacheDir: []u8, changeDir: bool) !void {
    var arena = std.heap.ArenaAllocator.init(parentAllocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try createDirectory(io, dataDir);
    try createDirectory(io, cacheDir);

    for (cacheDirPaths) |path| {
        const dir = try std.fs.path.join(allocator, &.{ cacheDir, path });
        try createDirectory(io, dir);
    }

    if (changeDir) try std.process.setCurrentPath(io, dataDir);
}

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const dataDir = try platform.getDataDirectory(allocator, init.environ_map);
    const cacheDir = try platform.getCacheDirectory(allocator, init.environ_map);
    try folderInit(allocator, init.io, dataDir, cacheDir, true);
    std.log.debug("dataDir: {s} cacheDir: {s} cwd: {s}", .{ dataDir, cacheDir, try std.process.currentPathAlloc(init.io, allocator) });
}

test "folderInit" {
    const io = std.testing.io;
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const baseDir = try std.process.currentPathAlloc(io, allocator);
    const expectedDataDir = try std.fs.path.join(allocator, &.{ baseDir, ".zig-cache", "testing-data" });
    const expectedCacheDir = try std.fs.path.join(allocator, &.{ baseDir, ".zig-cache", "testing-cache" });

    try folderInit(allocator, io, expectedDataDir, expectedCacheDir, false);
    defer {
        Io.Dir.cwd().deleteTree(io, expectedCacheDir) catch |err| std.log.err("Error in cleanup: {s}", .{@errorName(err)});
        Io.Dir.cwd().deleteTree(io, expectedDataDir) catch |err| std.log.err("Error in cleanup: {s}", .{@errorName(err)});
    }
    const dataDir = Io.Dir.openDir(.cwd(), io, expectedCacheDir, .{}) catch |err| {
        std.log.err("{s} not created. Open error: {s}", .{ expectedDataDir, @errorName(err) });
        try std.testing.expect(false);
        return;
    };
    dataDir.close(io);
    try std.process.setCurrentPath(io, baseDir);

    for (cacheDirPaths) |path| {
        const dir = Io.Dir.openDir(.cwd(), io, try Io.Dir.path.join(allocator, &.{ expectedCacheDir, path }), .{}) catch |err| {
            std.log.err("{s} not created. Open error: {s}", .{ path, @errorName(err) });
            try std.testing.expect(false);
            return;
        };
        dir.close(io);
    }
}
