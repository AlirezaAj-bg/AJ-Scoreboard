Config = Config or {}

-- Branding ----------------------------------------------------------------
Config.ServerName = 'AJ ROLEPLAY'
Config.ServerTag = 'AJ'              -- short text used as the logo mark
Config.Accent = '#8b5cf6'            -- panel accent colour (hex)

-- Opening -----------------------------------------------------------------
Config.Toggle = true                 -- true = press to open/close, false = hold to show
Config.OpenKey = 'HOME'
Config.MaxPlayers = GetConvarInt('sv_maxclients', 48)
Config.RefreshInterval = 4000        -- ms between server refreshes while the board is open

-- Player list ---------------------------------------------------------------
-- 'fivem'     = FiveM / Steam name (like the old in-game list)
-- 'character' = in-character firstname + lastname
-- 'hidden'    = only "Citizen" + server ID (strict anti-metagaming)
Config.NameMode = 'fivem'
Config.ShowStaffBadge = true         -- small STAFF tag next to admins / gods
Config.ShowJob = false               -- show each player's job label under their name
Config.NearbyDistance = 50.0         -- metres, used for the "Nearby" tab / tile

-- Overhead IDs ------------------------------------------------------------------
Config.ShowIDforALL = false          -- false = only admins with opt-in see overhead IDs
Config.OverheadDistance = 15.0

-- Recently disconnected -------------------------------------------------------
Config.Disconnected = {
    enabled = true,
    keepMinutes = 15,                -- drop entries older than this
    max = 30,                        -- max entries kept
    showReason = true,               -- show the quit / crash reason
}

-- On-duty service counters shown in the header strip ---------------------------
-- icon: police | medic | wrench | taxi | gavel | star
Config.JobCounters = {
    { job = 'police',    label = 'Police',   icon = 'police' },
    { job = 'ambulance', label = 'EMS',      icon = 'medic' },
    { job = 'mechanic',  label = 'Mechanic', icon = 'wrench' },
    { job = 'taxi',      label = 'Taxi',     icon = 'taxi' },
}

-- Heists / illegal activities (Activities tab) --------------------------------
-- Other resources toggle "busy" through qb-scoreboard:server:SetActivityBusy.
Config.IllegalActions = {
    ['storerobbery'] = {
        minimumPolice = 1,
        busy = false,
        label = 'Store Robbery',
    },
    ['bankrobbery'] = {
        minimumPolice = 3,
        busy = false,
        label = 'Bank Robbery'
    },
    ['jewellery'] = {
        minimumPolice = 2,
        busy = false,
        label = 'Jewelery'
    },
    ['pacific'] = {
        minimumPolice = 5,
        busy = false,
        label = 'Pacific Bank'
    },
    ['paleto'] = {
        minimumPolice = 4,
        busy = false,
        label = 'Paleto Bay Bank'
    }
}
