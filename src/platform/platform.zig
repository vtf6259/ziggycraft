const builtin = @import("builtin");

const impl = switch (builtin.target.os.tag) {
    .windows => @import("windows.zig"),
    .macos => @import("osx.zig"),
    .linux => @import("linux.zig"),
    else => @compileError("Unsupported target"),
};

pub const getDataDirectory = impl.getDataDirectory;
pub const getCacheDirectory = impl.getCacheDirectory;
