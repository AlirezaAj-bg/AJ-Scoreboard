local QBCore = exports['qb-core']:GetCoreObject({ 'Functions' })

local disconnected = {}
local charNames = {}   -- src -> character name, cached so playerDropped can still resolve it

-- Functions

local function CharacterName(Player)
    local info = Player.PlayerData.charinfo
    if not info then return nil end
    local name = ('%s %s'):format(info.firstname or '', info.lastname or ''):match('^%s*(.-)%s*$')
    return name ~= '' and name or nil
end

local function DisplayName(src, Player)
    if Config.NameMode == 'character' then
        return (Player and CharacterName(Player)) or charNames[src] or GetPlayerName(src) or 'Unknown'
    elseif Config.NameMode == 'hidden' then
        return 'Citizen'
    end
    return GetPlayerName(src) or 'Unknown'
end

local function IsStaff(src)
    return QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god')
end

local function PruneDisconnected()
    local cutoff = os.time() - (Config.Disconnected.keepMinutes * 60)
    for i = #disconnected, 1, -1 do
        if disconnected[i].time < cutoff then
            table.remove(disconnected, i)
        end
    end
    while #disconnected > Config.Disconnected.max do
        table.remove(disconnected)
    end
end

-- Is this player counted as police for heist requirements?
local function IsPolice(job)
    return Config.PoliceJobs[job.name] or (job.type ~= nil and Config.PoliceJobTypes[job.type]) or false
end

local function MaxPlayers()
    if Config.MaxPlayers and Config.MaxPlayers > 0 then return Config.MaxPlayers end
    return GetConvarInt('sv_maxclients', 48)
end

-- The board data is the same for everyone, so it's built at most once per
-- CACHE_MS and shared by every player who has the board open.
local CACHE_MS = 1000
local cache, cacheAt = nil, 0

local function BuildSnapshot()
    local now = os.time()
    local players = {}
    local jobs = {}
    local policeCount = 0

    for i = 1, #Config.JobCounters do
        jobs[Config.JobCounters[i].job] = 0
    end

    for _, Player in pairs(QBCore.Functions.GetQBPlayers()) do
        if Player then
            local src = Player.PlayerData.source
            local job = Player.PlayerData.job or {}
            charNames[src] = CharacterName(Player) or charNames[src]

            if job.onduty then
                if IsPolice(job) then policeCount += 1 end
                for i = 1, #Config.JobCounters do
                    local c = Config.JobCounters[i]
                    if c.job == job.name or (c.type and c.type == job.type) then
                        jobs[c.job] = jobs[c.job] + 1
                    end
                end
            end

            players[#players + 1] = {
                id = src,
                name = DisplayName(src, Player),
                ping = GetPlayerPing(src),
                staff = Config.ShowStaffBadge and IsStaff(src) or false,
                job = Config.ShowJob and job.label or nil,
            }
        end
    end

    table.sort(players, function(a, b) return a.id < b.id end)

    local left = {}
    if Config.Disconnected.enabled then
        PruneDisconnected()
        for i = 1, #disconnected do
            local d = disconnected[i]
            left[i] = { id = d.id, name = d.name, reason = d.reason, ago = now - d.time }
        end
    end

    return {
        players = players,
        maxPlayers = MaxPlayers(),
        police = policeCount,
        jobs = jobs,
        disconnected = left,
        activities = Config.IllegalActions,
    }
end

-- Callbacks

QBCore.Functions.CreateCallback('aj-scoreboard:server:GetScoreboardData', function(source, cb)
    local t = GetGameTimer()
    if not cache or t - cacheAt >= CACHE_MS then
        cache, cacheAt = BuildSnapshot(), t
    end
    -- Only tell the caller whether *they* may see overhead IDs; the list of
    -- opted-in admins is never sent to clients.
    cb(cache, QBCore.Functions.IsOptin(source) and true or false)
end)

-- Events

AddEventHandler('playerDropped', function(reason)
    local src = source
    if Config.Disconnected.enabled then
        local Player = QBCore.Functions.GetPlayer(src)
        table.insert(disconnected, 1, {
            id = src,
            name = DisplayName(src, Player),
            reason = Config.Disconnected.showReason and tostring(reason or ''):sub(1, 80) or nil,
            time = os.time(),
        })
        PruneDisconnected()
    end
    charNames[src] = nil
    cache = nil
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    if Player and Player.PlayerData then
        charNames[Player.PlayerData.source] = CharacterName(Player)
    end
end)

-- Heist state. Server-side only (AddEventHandler, not RegisterNetEvent) so
-- clients can't mark heists busy/free themselves.
local function SetActivityBusy(activity, bool)
    if not Config.IllegalActions[activity] then return end
    Config.IllegalActions[activity].busy = bool and true or false
    cache = nil
    TriggerClientEvent('aj-scoreboard:client:SetActivityBusy', -1, activity, Config.IllegalActions[activity].busy)
end

AddEventHandler('aj-scoreboard:server:SetActivityBusy', SetActivityBusy)
AddEventHandler('qb-scoreboard:server:SetActivityBusy', SetActivityBusy) -- legacy name, for stock QBCore heist scripts

exports('SetActivityBusy', SetActivityBusy)
exports('IsActivityBusy', function(activity)
    return Config.IllegalActions[activity] and Config.IllegalActions[activity].busy or false
end)
