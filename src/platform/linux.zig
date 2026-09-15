const std = @import("std");

pub fn getDataDirectory(
    allocator: std.mem.Allocator,
    environ: *const std.process.Environ.Map,
) ![]u8 {
    if (environ.get("XDG_DATA_HOME")) |data_home| {
        return std.fs.path.join(
            allocator,
            &.{ data_home, "ziggycraft" },
        );
    }

    const home = environ.get("HOME") orelse
        return error.HomeDirectoryNotFound;

    return std.fs.path.join(
        allocator,
        &.{ home, ".local", "share", "ziggycraft" },
    );
}

pub fn getCacheDirectory(
    allocator: std.mem.Allocator,
    environ: *const std.process.Environ.Map,
) ![]u8 {
    if (environ.get("XDG_CACHE_HOME")) |cache_home| {
        return std.fs.path.join(
            allocator,
            &.{ cache_home, "ziggycraft" },
        );
    }

    const home = environ.get("HOME") orelse
        return error.HomeDirectoryNotFound;

    return std.fs.path.join(
        allocator,
        &.{ home, ".cache", "ziggycraft" },
    );
}
