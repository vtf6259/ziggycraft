const std = @import("std");

pub fn getDataDirectory(
    allocator: std.mem.Allocator,
    environ: *const std.process.Environ.Map,
) ![]u8 {
    const home = environ.get("HOME") orelse
        return error.HomeDirectoryNotFound;

    return std.fs.path.join(
        allocator,
        &.{ home, "Library", "Application Support", "ziggycraft" },
    );
}

pub fn getCacheDirectory(
    allocator: std.mem.Allocator,
    environ: *const std.process.Environ.Map,
) ![]u8 {
    const home = environ.get("HOME") orelse
        return error.HomeDirectoryNotFound;

    return std.fs.path.join(
        allocator,
        &.{ home, "Library", "Caches", "ziggycraft" },
    );
}
