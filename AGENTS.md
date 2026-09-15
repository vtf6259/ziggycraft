# AGENTS.md

Work-in-progress Minecraft launcher written in Zig. The product/package name is **ziggycraft**.

## Build & test

Requires Zig **0.16.0+** (declared in `build.zig.zon`); verify with `zig version`.

- `zig build` — build to `zig-out/`
- `zig build run` — install then run the executable (args after `--`)
- `zig build test` — runs both the module (`root.zig`) and exe (`main.zig`) test executables; keep both tabs wired. There is one test so far: `folderInit` in `src/main.zig`, which creates/cleans `.zig-cache/testing-data` and `.zig-cache/testing-cache` in the repo cwd.

Both `zig build` and `zig build test` currently pass.

## Zig API quirks

This code targets Zig 0.16's newer I/O interfaces. Do not "fix" it back to older std conventions:

- `main(init: std.process.Init)` — use `init.io`, `init.arena`, `init.environ_map`
- file ops go through `std.Io` (e.g. `Io.Dir.cwd().createDirPath(io, path)`) rather than the old `std.fs.cwd()` API

## Layout & entrypoints

- `src/main.zig` — CLI entrypoint; sets up dirs and `chdir`s to the data directory
- `src/root.zig` — library module root (empty); must re-export anything made public via the `ziggycraft` module
- `src/platform/platform.zig` — dispatch by `builtin.target.os.tag`; each impl (`windows.zig`/`osx.zig`/`linux.zig`) must export `getDataDirectory` and `getCacheDirectory`. Unsupported OS → `@compileError`.
- Platform dir resolution: Windows reads `APPDATA`/`LOCALAPPDATA`; macOS reads `HOME` (`Library/Application Support` / `Caches`); Linux reads `XDG_DATA_HOME`/`XDG_CACHE_HOME` with `~/.local/share` / `~/.cache` fallbacks. Dir basename is always `ziggycraft`.

Directory conventions: cache dir is split into `libraries/`, `resources/`, `clients/`. The process `chdir`s to the data dir at startup (`folderInit` in `src/main.zig`), so under `zig build run` relative paths resolve from the data dir (e.g. `%APPDATA%\ziggycraft`), not the repo.

## Microsoft auth flow

`python-microsoft-auth-impl.py` is a reference implementation (not shipped; needs `requests`) of the Minecraft OAuth flow to be ported to Zig. Agent notes:

- Fixed `client_id=00000000402B5328` (official Minecraft launcher) and `redirect_uri=https://login.live.com/oauth20_desktop.srf`
- After browser login the user is left on a blank page; the auth `code` must be parsed out of the redirected URL (`redirectUrlFormat.txt` documents the format)
- Chain: MS token → XBL token → XSTS token (`uhs`+`Token`) → Minecraft token (`XBL3.0 x=<uhs>;<token>`) → `GET /minecraft/profile` for name+UUID
- Only two tokens are worth persisting: the Minecraft token (24h expiry) and the Microsoft refresh token (90d / revocable). The short-lived MS access token is never stored; refresh flow re-runs the whole chain.
- This reference implementation is not meant for end users to interact with; it's a slightly modified public-domain script, and the agent-side port should replace it.