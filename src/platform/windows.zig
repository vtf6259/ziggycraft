const std = @import("std");

pub fn getDataDirectory(allocator: std.mem.Allocator, environ: *const std.process.Environ.Map) ![]u8 {
    const appdata = environ.get("APPDATA") orelse
        return error.AppDataDirectoryNotFound;

    return std.fs.path.join(
        allocator,
        &.{ appdata, "ziggycraft" },
    );
}

pub fn getCacheDirectory(
    allocator: std.mem.Allocator,
    environ: *const std.process.Environ.Map,
) ![]u8 {
    const local_app_data = environ.get("LOCALAPPDATA") orelse
        return error.LocalAppDataDirectoryNotFound;

    return std.fs.path.join(
        allocator,
        &.{ local_app_data, "ziggycraft" },
    );
}
