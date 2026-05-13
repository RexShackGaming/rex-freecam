# rex-freecam

A feature-rich freecam resource for RedM, built with standalone RedM natives. Provides full camera control for cinematic capture, location scouting, and development workflows.

## Features

### Client Components (`client/client.lua`, `client/timecycles.lua`)

**Camera Movement & Control**
- Full 3D navigation with WASD movement
- Vertical movement (Spacebar up, Shift down)
- Mouse rotation for pitch/yaw control
- Camera roll (C/V keys)
- Adjustable movement speed (Page Up/Page Down or mouse wheel)
- FOV zoom control (Z/X keys)
- Reset camera to defaults (B key)

**Camera Modes**
- **Free Mode**: Unrestricted camera movement
- **Locked Mode**: Freeze camera position while maintaining view
- **Attached Mode**: Lock camera relative to player ped
- **Follow Mode**: Camera follows behind player ped

**Visual Tools**
- 993 timecycle filters for cinematic effects (cycled with F/G)
- Toggle filter on/off (H key)
- Camera grid overlay for composition (J key)
- HUD display with real-time coordinates, rotation, FOV, and mode info
- Hide HUD toggle (Q key)

**Developer Utilities**
- Copy camera coordinates, rotation, and FOV to clipboard (ENTER key)
- Coordinates printed to F8 console for easy reference
- Chat confirmation when copying

### Server Components (`server/versionchecker.lua`)

- Automatic version checking against GitHub repository
- Console alerts when updates are available

> **Note**: The version checker references `rsg-core`. For standalone use, this file can be removed or modified.

## Installation

1. Download or clone this repository
2. Place the `rex-freecam` folder in your server's `resources` directory
3. Ensure `ox_lib` is installed and started before this resource
4. Add `ensure rex-freecam` to your `server.cfg` (after ox_lib)
5. Restart your server or refresh resources

## Configuration

All settings are in `shared/config.lua`:

### Controls

| Setting | Default | Description |
|---------|---------|-------------|
| `IncreaseSpeedControl` | Page Up, Mouse Wheel Up | Increase movement speed |
| `DecreaseSpeedControl` | Page Down, Mouse Wheel Down | Decrease movement speed |
| `UpControl` | Spacebar | Move camera up |
| `DownControl` | Shift | Move camera down |
| `ForwardControl` | W | Move forward |
| `BackwardControl` | S | Move backward |
| `LeftControl` | A | Move left |
| `RightControl` | D | Move right |
| `IncreaseFovControl` | Z | Zoom in (decrease FOV) |
| `DecreaseFovControl` | X | Zoom out (increase FOV) |
| `RollLeftControl` | C | Roll camera left |
| `RollRightControl` | V | Roll camera right |
| `ToggleHudControl` | Q | Toggle HUD visibility |
| `ResetCamControl` | B | Reset camera roll and FOV |
| `PrevFilterControl` | F | Previous timecycle filter |
| `NextFilterControl` | G | Next timecycle filter |
| `ToggleFilterControl` | H | Toggle filter on/off |
| `ToggleGridControl` | J | Toggle grid overlay |
| `ExitLockedCamControl` | V | Exit locked/attached modes |

### Movement Parameters

| Setting | Default | Description |
|---------|---------|-------------|
| `MaxSpeed` | 1.0 | Maximum movement speed |
| `MinSpeed` | 0.001 | Minimum movement speed |
| `SpeedIncrement` | 0.001 | Speed change per input |
| `Speed` | 0.05 | Initial movement speed |

### Camera Parameters

| Setting | Default | Description |
|---------|---------|-------------|
| `MaxFov` | 120.0 | Maximum field of view |
| `MinFov` | 20.0 | Minimum field of view |
| `ZoomSpeed` | 1.0 | FOV change rate |
| `SpeedLr` | 8.0 | Horizontal rotation speed |
| `SpeedUd` | 8.0 | Vertical rotation speed |
| `RollSpeed` | 1.0 | Camera roll speed |
| `ControllerModel` | `scriptedball` | Dummy entity for camera |

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `/freecam` | Toggle freecam on/off |
| `/lockcam` | Toggle camera lock |
| `/attachcam` | Attach camera to player |
| `/followcam` | Camera follows player |
| `/copycam` | Print coordinates to console |

### Events

These can be triggered from other resources:

```lua
TriggerEvent('freecam:toggle')        -- Toggle freecam
TriggerEvent('freecam:toggleLock')    -- Toggle lock mode
TriggerEvent('freecam:toggleAttached') -- Toggle attached mode
TriggerEvent('freecam:toggleFollow')   -- Toggle follow mode
```

### Example: Copy Output

When pressing ENTER or using `/copycam`:

```
X: 1234.56, Y: -789.01, Z: 45.67, Pitch: 15.00, Roll: 0.00, Yaw: 180.00, FOV: 60.00
```

## Dependencies

| Dependency | Required | Notes |
|------------|----------|-------|
| ox_lib | Yes | Used for clipboard functionality (`lib.setClipboard`) |

## Troubleshooting

**Camera doesn't activate**
- Verify `ox_lib` is running before `rex-freecam`
- Check server console for errors on resource start

**Controls not responding**
- Ensure no other resources are conflicting with controls
- Check `config.lua` for custom control mappings

**Filters not applying**
- Timecycle filters are RDR2-specific; ensure you're on RedM
- Some filters may not be visible in all lighting conditions

**Version checker errors**
- The version checker requires `rsg-core` export. Remove `server/versionchecker.lua` from `fxmanifest.lua` for standalone use:
  ```lua
  server_scripts {
      -- 'server/versionchecker.lua'  -- Comment out for standalone
  }
  ```

**Clipboard not working**
- Ensure `ox_lib` is properly installed and initialized
- Clipboard functionality requires the ox_lib UI to be available

## License

Refer to the original repository for license information.
