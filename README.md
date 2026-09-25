# AJ Scoreboard

A modern scoreboard for **QBCore**. It replaces `qb-scoreboard` with a side panel that shows who is online, who is near you, who just left, which services are on duty and which heists can be started.

- **Players**: everyone online, with a colour avatar, server ID, STAFF tag, 4-bar ping signal and distance if they are near you. Your own row is pinned to the top.
- **Nearby**: players within `Config.NearbyDistance` metres, closest first, with a live microphone icon for whoever is talking.
- **Left**: players who disconnected recently, with the quit / crash reason. Useful for spotting combat logging.
- **Heists**: every robbery with its status (Available, In progress, or "Need N more" police) and a police progress bar.
- **Header**: server name, player count against max slots, a capacity bar, Online / Nearby / Left tiles and an on-duty strip for Police, EMS, Mechanic and Taxi.
- **Overhead IDs**: staff with admin opt-in (or everyone, if you allow it) see `[ID]` above nearby heads. The ID turns violet while that player talks.

The panel **never takes mouse focus**, so players keep walking, driving and talking while it's open. The UI is fully offline: fonts and icons are bundled, and nothing loads from a CDN.

---

## Requirements

| Resource | Why |
|---|---|
| `qb-core` | player data, jobs, callbacks, permissions |

No SQL is needed. The "Left" list lives in server memory and clears on restart.

## Installation

1. Put `aj-scoreboard` in `resources/[aj]/`. The server already loads that folder with `ensure [aj]` in `server.cfg`.
2. **Remove the old `qb-scoreboard`**. Two scoreboards would register the same commands. `aj-scoreboard` declares `provide 'qb-scoreboard'`, so any resource that depends on the old name still works.
3. Restart the server, or run `ensure aj-scoreboard` in the console.

---

## Controls

| Key | Action |
|---|---|
| `HOME` | Open / close (or hold, if `Config.Toggle = false`) |
| `Q` / `E` | Previous / next tab |
| Mouse wheel | Scroll the list |

While the panel is open, the game's Q (cover) and E (interact) actions and the weapon wheel scroll are blocked, because the panel uses those keys. They work again as soon as it closes. Players can rebind the open key in **Settings → Key Bindings → FiveM → AJ Scoreboard**.

The panel also closes by itself when the pause menu opens.

---

## Configuration

Everything is in `config.lua`.

### Branding

| Option | Default | Description |
|---|---|---|
| `Config.ServerName` | `'AJ ROLEPLAY'` | Title in the header |
| `Config.ServerTag` | `'AJ'` | Text in the logo square. `''` hides the square. |
| `Config.Accent` | `'#8b5cf6'` | Accent colour (hex). Every highlight, glow and tab follows it. |

### Behaviour

| Option | Default | Description |
|---|---|---|
| `Config.Toggle` | `true` | `true` = press to open / close, `false` = hold to show |
| `Config.OpenKey` | `'HOME'` | Default key. Players can rebind it. |
| `Config.MaxPlayers` | `0` | Max slots shown in the header. `0` = read `sv_maxclients` on the server |
| `Config.RefreshInterval` | `4000` | How often (ms) the list refreshes from the server while open |

### Player list

| Option | Default | Description |
|---|---|---|
| `Config.NameMode` | `'fivem'` | `'fivem'` = FiveM name, `'character'` = character first + last name, `'hidden'` = only "Citizen" + ID (strict anti-metagaming) |
| `Config.ShowStaffBadge` | `true` | STAFF tag for players with `admin` or `god` permission |
| `Config.ShowJob` | `false` | Show each player's job under their name |
| `Config.NearbyDistance` | `50.0` | Radius (metres) for the Nearby tab and tile |
| `Config.ShowIDforALL` | `false` | `false` = only admins with opt-in see overhead IDs (above everyone nearby) |
| `Config.OverheadDistance` | `15.0` | How far away overhead IDs are drawn |

### Recently disconnected

```lua
Config.Disconnected = {
    enabled = true,     -- false hides the Left tab and tile
    keepMinutes = 15,   -- entries older than this are removed
    max = 30,           -- max entries kept
    showReason = true,  -- show the quit / crash reason
}
```

### On-duty counters

```lua
Config.JobCounters = {
    { job = 'police',    label = 'Police',   icon = 'police' },
    { job = 'ambulance', label = 'EMS',      icon = 'medic' },
    { job = 'mechanic',  label = 'Mechanic', icon = 'wrench' },
    { job = 'taxi',      label = 'Taxi',     icon = 'taxi' },
}
```

Only players who are **on duty** are counted. The optional `type` field also counts every job of that QBCore job type, so `type = 'leo'` adds BCSO / SASP to the Police counter. Available icons: `police`, `medic`, `wrench`, `taxi`, `gavel`, `star`. An empty table hides the strip.

### Heists

```lua
Config.IllegalActions = {
    ['storerobbery'] = { minimumPolice = 1, busy = false, label = 'Store Robbery' },
    ['bankrobbery']  = { minimumPolice = 3, busy = false, label = 'Bank Robbery' },
    ...
}
```

Police for heist requirements are on-duty players whose job is in `Config.PoliceJobs` or whose job type is in `Config.PoliceJobTypes` (default: `police` and every `leo` job).

A heist shows **Available** when enough police are on duty and it isn't busy, **In progress** while busy, and **Need N more** otherwise.

---

## Heist integration (for developers)

Heist scripts mark a heist busy or free **from the server**:

```lua
-- event
TriggerEvent('aj-scoreboard:server:SetActivityBusy', 'jewellery', true)

-- or export
exports['aj-scoreboard']:SetActivityBusy('jewellery', false)
local busy = exports['aj-scoreboard']:IsActivityBusy('jewellery')
```

The old event name `qb-scoreboard:server:SetActivityBusy` is still accepted, so stock QBCore heist scripts keep working without edits. In this pack, `qb-bankrobbery` and `qb-jewelery` already use the new name.

These events are **server-only**. Clients cannot trigger them, so a cheater can't lock or unlock heists for everyone.

### Events and callbacks

| Name | Side | Description |
|---|---|---|
| `aj-scoreboard:server:GetScoreboardData` | callback | Player list, on-duty counts, disconnects and heists. Built at most once per second and shared by everyone with the board open. |
| `aj-scoreboard:server:SetActivityBusy` | server event | `(activity, busy)` |
| `aj-scoreboard:client:SetActivityBusy` | client event | Broadcast to everyone when a heist changes |

---

## Files

```
aj-scoreboard/
├─ config.lua       all settings
├─ client.lua       open / close, keys, nearby scan, overhead IDs
├─ server.lua       player data, disconnect log, heist state
└─ html/
   ├─ ui.html
   ├─ style.css     AJ theme (never uses backdrop-filter, which renders black in FiveM)
   ├─ app.js        tabs and lists, plain JavaScript
   └─ fonts/        Kanit + Inter, bundled locally
```

## Credits

Based on [qb-scoreboard](https://github.com/qbcore-framework/qb-scoreboard) by the QBCore Framework team, and released under the same GPL-3.0 license (see `LICENSE`).
