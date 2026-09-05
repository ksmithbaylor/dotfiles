---
name: pebble-dev
description: >-
  Pebble smartwatch development: building watchapps/watchfaces with the pebble
  CLI (v5+), running and controlling emulators (qemu + pypkjs), taking
  screenshots to iterate on layouts, and driving or scripting the pebbletui
  terminal UI. Use whenever working in a Pebble project (package.json with
  targetPlatforms, src/c, wscript), when asked to build/install/debug a Pebble
  app, or when interacting with Pebble emulators.
---

# Pebble development

Everything here was verified against Pebble Tool v5.0.39 (the Core Devices
rewrite, Python via uv) with SDK 4.33.1 on macOS. Older v4.x tools differ
(notably `emu-button` syntax).

## Platforms

Tab/build targets, in canonical order. Marketing names come from the SDK's own
templates.

| Codename | Device | Display | App RAM | Notes |
|---|---|---|---|---|
| aplite | Pebble Classic | 144x168 rect, b&w | 24KB | original hardware; see Aplite memory |
| basalt | Pebble Time | 144x168 rect, 64-color | 64KB | |
| chalk | Pebble Time Round | 180x180 round, 64-color | 64KB | |
| diorite | Pebble 2 | 144x168 rect, b&w | 64KB | |
| emery | Pebble Time 2 | 200x228 rect, 64-color | ~128KB | verified via screenshot |
| flint | Pebble 2 Duo | 144x168 rect, b&w | 64KB | new (2025); verified; clay needs patching (see Library packages) |
| gabbro | Pebble Round 2 | 260x260 round, 64-color | ~128KB | new (2025); verified; clay needs patching |

A screenshot is ground truth for display geometry: capture one and check the
PNG's pixel size. The build prints a per-platform memory report (footprint +
free heap); aplite fails at link with "region `APP' overflowed" when statics
are too big.

## Project shape

`pebble new-project [--c|--rocky|--alloy] [--javascript] name` scaffolds:
`package.json` (with `pebble.targetPlatforms`), `wscript` (waf build),
`src/c/*.c`, `src/pkjs/*.js` (with --javascript). Artifacts land in `build/`,
final bundle at `build/<name>.pbw`. A full 7-platform build takes ~1-2s warm.

## CLI reference (v5 syntax, verified)

```sh
pebble build                       # colored + line-streamed ONLY on a TTY (see gotchas)
pebble install --emulator emery    # installs build/*.pbw; BOOTS the emulator if not running
pebble logs --emulator emery --color        # long-running stream; --color forces color sans TTY
pebble screenshot --emulator emery --no-open out.png   # --no-open avoids popping a viewer
pebble screenshot --all-platforms --no-open # every RUNNING emulator at once
pebble emu-button --emulator emery click select        # click|push|release; back|up|select|down
pebble emu-button --emulator emery click select --duration 600   # long press = long click
pebble kill [--force]              # stop ALL emulators (SIGTERM; --force = SIGKILL)
pebble wipe                        # delete persisted emulator state for the active SDK
```

State staging before screenshots: `emu-set-time`, `emu-battery`, `emu-tap`,
`emu-accel`, `emu-compass`, `emu-bt-connection`, `emu-time-format`,
`emu-heart-rate` (emery only), `emu-steps` and friends.

## Emulator internals

- `pebble install` spawns two DETACHED processes per platform that outlive the
  command: qemu (the watch) and pypkjs (the phone side). They keep running
  until `pebble kill`.
- Registry: `$TMPDIR/pb-emulator.json`, shaped
  `{platform: {sdkVersion: {qemu: {pid, port, serial, gdb, monitor}, pypkjs: {pid, port}}}}`.
  Entries go STALE when processes die; liveness = `os.kill(pid, 0)` succeeds.
  Never trust the file alone. `scripts/emu-status` does this correctly.
- Installed apps persist across emulator reboots in
  `~/Library/Application Support/Pebble SDK/<sdk>/<platform>` (pypkjs
  `--persist` dir). Old apps from previous sessions stick around until
  `pebble wipe` (run it with emulators stopped: `pebble kill` first).
- First boot of an emulator takes ~15-30s; reinstalls into a running emulator
  take a few seconds.

## Multi-platform layout strategy

- SDK 4.33 has NO `PBL_DISPLAY_WIDTH`/`HEIGHT` macros. Branch on the
  compiler-defined `PBL_PLATFORM_<NAME>` flags (plus `PBL_COLOR` via
  `PBL_IF_COLOR_ELSE`/`COLOR_FALLBACK`). A central `layout.h` defining
  per-platform metrics (header heights, row heights, font tiers, tick counts)
  keeps the drawing code free of ifdef sprawl.
- Useful tiers in practice: big (emery, gabbro: full fonts, full precision),
  small rect (144x168: tighter rows, smaller fonts, rounder numbers), round
  (chalk, gabbro: rearranged pages). gabbro is big AND round.
- PebbleKit JS can tailor payloads per watch:
  `Pebble.getActiveWatchInfo().platform` (wrap in try/catch). Use it to slice
  data down for constrained platforms before it ever crosses AppMessage.

## 1-bit (b&w) display rendering

- Only FILLS dither grays. TEXT renders solid black-or-white: GColorLightGray
  text comes out pure white. To dim text, draw it white then overdraw a
  checkerboard of background-color pixels over the measured glyph rect.
- `GColorFromHEX` quantizes by luminance: dark hex colors become black,
  invisible on a black background. Force white for server/user-fed colors.
- Convey direction/state without color: hollow vs solid shapes (classic
  candlestick convention), texture, weight. Disable color-flash feedback
  entirely; an inverted band reads as a glitch.
- Keep dither/shading patterns sparse (1 px in 16, not 1 in 4) and make small
  glyph-scale marks bigger than on color: fine details drown in dither.

## Round display layout

- Chord math: usable half-width at dy pixels from center = sqrt(r^2 - dy^2)
  (integer binary-search sqrt; no float needed). Size each grid row to its
  worst-edge chord; a row touching the top/bottom of the circle has chord ~0
  and vanishes, so cap grids at 3 rows on 180px and widen underfull rows.
- Order page content by band width: put the widest content (charts, grids) in
  the vertical middle; headers/footers get centered, inset content.
- Left/right-edge text (chart axis labels) needs extra x-inset because the
  circle allows less vertical range near the edges; compute or iterate with
  screenshots at the exact y band the text occupies.
- Draw divider lines full-width/full-height and let the bezel clip them; it
  looks intentional, insets look broken.
- Draw borders AFTER any content that paints opaque plates over them.

## Aplite memory (24KB)

Levers that fit a data-heavy app into 24KB, in order of payoff:
- Shrink per-platform array bounds (fewer items, shorter history) via
  `#ifdef PBL_PLATFORM_APLITE` in the data header; have pkjs pre-slice the
  wire payload to match so the inbox shrinks too.
- `__attribute__((packed))` on hot structs; Cortex-M3 handles unaligned
  word access fine.
- Size `app_message_open` from the actual largest message, not a round 4096.
- Leave ~3KB+ heap free: AppMessage buffers alloc from the app heap.

## Library packages (pebble-clay, etc.)

- The SDK's per-library platform check is literally a directory listing under
  `node_modules/<lib>/dist/include/<lib>/<platform>`. But `dist/` is deleted
  and re-extracted from the package's `dist.zip` on EVERY build
  (rmtree + extractall), so patches must go INTO dist.zip (Python `zipfile`
  in append mode preserves the zip comment, which the SDK uses).
- Do NOT edit the library's own package.json: npm treats the package as
  modified and re-extracts it pristine on the next install.
- `pebble build` runs `npm install`, so a project `postinstall` script is the
  right hook for such patches.
- pebble-clay 1.0.4 predates flint/gabbro. Its per-platform artifacts are
  trivial stubs (8-byte empty ar archive + boilerplate header); clone
  diorite's entries under new platform names inside dist.zip and it works.

## Gotchas (each of these cost real debugging time)

1. **`pebble logs`, `pebble emu-button`, and `pebble screenshot` BOOT the
   emulator if it is not running.** Always gate on detected-running state
   (see `scripts/emu-status` / `scripts/emu-screenshot`) or you will spawn
   surprise qemu instances.
2. `pebble build` output is colored and line-buffered only on a TTY: run it
   under a PTY to capture colors/progress live. On pipes, waf drops color and
   Python block-buffers; set `PYTHONUNBUFFERED=1` for any piped pebble
   subcommand you stream.
3. Build progress uses bare `\r` rewrites; when capturing, collapse a line on
   `\r` instead of appending, or the log fills with duplicates.
4. `emu-button` presses occasionally fail transiently (pypkjs connection).
   Retry on a nonzero exit, but never after a timeout: the press may already
   have landed and a retry double-presses.
5. `touch` does not trigger file watchers that filter Chmod events; editors
   writing content do.
6. `pebble kill` stops all emulators but keeps their persisted apps;
   `pebble wipe` clears the apps. "Reset" = kill, then wipe, then reinstall.
   Prefer per-emulator recovery over `pebble kill`: killing everything
   destroys the user's window arrangement and boots cost 15-30s each.
7. Changing `messageKeys` or `pebble.displayName` requires `pebble clean`:
   the generated `message_keys.auto.h` and appinfo are cached by the build.
   A stale launcher name additionally needs `pebble wipe`.
8. pypkjs connections wedge occasionally (`libpebble2.exceptions.TimeoutError`
   from emu commands). Reinstalling into that one emulator usually clears it.
9. `menuIcon` resources max out at 25x25 and watchAPPS render them
   greyscale-by-luminance even on color watches (only watchFACE icons show
   color). Store listing icons are separate uploads, so design the menu icon
   for luminance contrast.
10. Persist storage survives reinstalls (keyed by UUID), which makes
    persisted-state features easy to test: set state, reinstall, verify.
    `pebble wipe` is what actually clears it.
11. AppMessage byte arrays: pack int32 little-endian by hand on both sides;
    a chunked send queue with one retry per message is enough for reliable
    multi-message pushes from pkjs.

## Screenshot-driven layout iteration (agent loop)

The emulator screen is fully inspectable, so layout work can iterate without
a human describing pixels:

1. `pebble build`
2. `pebble install --emulator <p>` (boots if needed; wait for it)
3. Optionally stage state (`emu-set-time ...`) and navigate
   (`emu-button ... click ...`)
4. `scripts/emu-screenshot <p>` and read the PNG
5. Adjust layout code, repeat from 1

Round displays (chalk, gabbro): verify nothing clips against the circular
bezel; the screenshot shows the full square framebuffer.

Colors render noticeably hotter/more saturated in the qemu window than in
screenshots. Screenshots are the framebuffer truth, but confirm final color
choices against the emulator window (or hardware).

After a reinstall the app relaunches automatically, but if it isn't running,
`emu-button` presses land on the watchface/timeline instead: check the next
screenshot actually shows the app before trusting a navigation sequence.

## pebbletui

`pebbletui [projectDir]` (defaults to cwd; assume it is on PATH) is the
full-screen TUI wrapping all of the above: build tab plus one tab per
platform, mouse support throughout. Source: the pebble-dev-tools repo.

- Opening it starts nothing. Quitting (confirmed) tears down EVERYTHING it
  manages, including all emulators, via `pebble kill`.
- **Active** toggle on an emulator tab = successful builds auto-deploy there
  (several can be active). Activating also enables key-press forwarding;
  deactivating disables it.
- **Auto-build** watches `src/`, `resources/`, `worker_src/`, `package.json`,
  `wscript`; mid-build changes coalesce into one follow-up build, and only
  the final build deploys.
- **Reset** kills all emulators, runs `pebble wipe`, then boots active
  emulators fresh with the current build.
- Logs attach automatically to running emulators that are active or being
  viewed; the Clear button empties the pane without detaching.

| Keys | |
|---|---|
| `b` / `a` / `r` | build / toggle auto-build / redeploy to active |
| `up` `down` | switch tabs |
| `;` `[` `'` `/` | watch buttons Back/Up/Select/Down (forwarded to running emulators with key presses on) |
| `space` `d` `c` | on an emulator tab: toggle Active / deploy / clear logs |
| `pgup` `pgdn` `home` `end` | scroll pane (`end` re-follows the tail) |
| `q` / `ctrl+c` | quit with confirmation; second `ctrl+c` during teardown = immediate exit |

Flags and env:

- `-light`: light-terminal colors (theme is a flag on purpose: terminal
  background queries hang/eat input on terminals that never answer them)
- `-dump WxH [-dump-tab N]`: print one frame headlessly and exit, useful for
  layout inspection without a terminal
- `PEBBLETUI_PEBBLE_BIN`: override the pebble binary (used by its tests)
- Minimum terminal size: 118x36
- Headless driving for tests: run under `script -q /dev/null sh -c
  'stty rows 40 cols 130; exec pebbletui <dir>'` and feed keys via stdin;
  mouse clicks can be injected as SGR sequences (`\033[<0;COL;ROWM` press +
  `...m` release, 1-based coordinates).

## Physical watch and store

- Install on a real watch through the phone's Developer Connection
  (CloudPebble relay): `pebble login` once, then
  `pebble install --cloudpebble`. No IP address needed.
- Store submission is a single point: https://dev-portal.rebble.io.
  apps.repebble.com / store.repebble.com are frontends over the same Rebble
  appstore backend, so one listing covers all of them and the phone apps.
- Store screenshots are per-platform at native resolution; take them with
  `pebble screenshot` (no `--scale`).

## Scripts

- `scripts/emu-status [--json]`: which emulators are actually running
  (pid-verified), with qemu/pypkjs pids and ports. Read-only, never boots.
- `scripts/emu-screenshot [-o DIR] [platform ...]`: screenshot running
  emulators to `DIR/<platform>.png` (default `./screenshots`). Refuses
  stopped platforms instead of booting them; no args = all running.
