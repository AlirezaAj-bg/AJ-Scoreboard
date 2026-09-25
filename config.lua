Config = Config or {}

-- Branding ----------------------------------------------------------------
Config.ServerName = 'AJ ROLEPLAY'
Config.ServerTag = 'AJ'              -- short text used as the logo mark
Config.Accent = '#8b5cf6'            -- panel accent colour (hex)

-- Opening -----------------------------------------------------------------
Config.Toggle = true                 -- true = press to open/close, false = hold to show
Config.OpenKey = 'HOME'
Config.MaxPlayers = 0                -- 0 = use the server's sv_maxclients
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
-- Optional `type` also counts every job of that QBCore job type
-- (e.g. type = 'leo' adds BCSO / SASP to the Police counter).
Config.JobCounters = {
    { job = 'police',    label = 'Police',   icon = 'police', type = 'leo' },
    { job = 'ambulance', label = 'EMS',      icon = 'medic' },
    { job = 'mechanic',  label = 'Mechanic', icon = 'wrench' },
    { job = 'taxi',      label = 'Taxi',     icon = 'taxi' },
}

-- Who counts as police for the heist requirements (on duty only).
-- Jobs listed by name, plus every job whose QBCore job `type` is listed
-- (stock QBCore gives police / bcso / sasp the type 'leo').
Config.PoliceJobs = { police = true }
Config.PoliceJobTypes = { leo = true }

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
