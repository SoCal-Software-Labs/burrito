const std = @import("std");

pub fn burrito_plugin_entry(install_dir: []const u8, program_manifest_json: []const u8) void {
    std.debug.print("Zig Plugin Init!", .{});
    std.debug.print("Install Dir: {s}", .{install_dir});
    std.debug.print(": {s}", .{program_manifest_json});

    var exists = if (std.fs.cwd().access("only_one.lock", .{ .read = true })) true else |_| false;

    if (exists) {
        std.log.err("We found a lockfile! Can't run two of this application at one!", .{});
        std.os.exit(1);
    }
}
