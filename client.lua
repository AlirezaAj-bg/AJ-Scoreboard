local QBCore = exports['qb-core']:GetCoreObject({ 'Functions' })
local scoreboardOpen = false
local playerOptin = {}

-- Control ids used while the board is open (it never takes NUI focus, so the
-- player keeps walking / driving and we read these instead)
local CTRL_TAB_PREV = 44   -- Q
local CTRL_TAB_NEXT = 38   -- E
local CTRL_SCROLL_DOWN = 14
local CTRL_SCROLL_UP = 15

-- Functions

local function DrawText3D(coords, text, talking)
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(true)
    if talking then
        SetTextColour(167, 139, 250, 255)
    else
        SetTextColour(255, 255, 255, 230)
    end
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = string.len(text) / 370
    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 12, 10, 21, 150)
    ClearDrawOrigin()
end

local function GetNearbyPlayers(radius)
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local me = PlayerId()
    local list = {}
    local active = GetActivePlayers()
    for i = 1, #active do
        local player = active[i]
        if player ~= me then
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) then
                local dist = #(GetEntityCoords(ped) - myCoords)
                if dist <= radius then
                    list[#list + 1] = {
                        player = player,
                        ped = ped,
                        id = GetPlayerServerId(player),
                        dist = math.floor(dist + 0.5),
                        talking = NetworkIsPlayerTalking(player),
                    }
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

local function RefreshData()
    QBCore.Functions.TriggerCallback('aj-scoreboard:server:GetScoreboardData', function(data, optin)
        if not scoreboardOpen then return end
        playerOptin = optin or {}
        SendNUIMessage({ action = 'update', data = data })
    end)
end

local function CloseScoreboard()
    if not scoreboardOpen then return end
    scoreboardOpen = false
    SendNUIMessage({ action = 'close' })
end

local function OpenScoreboard()
    if scoreboardOpen or IsPauseMenuActive() then return end
    scoreboardOpen = true

    SendNUIMessage({
        action = 'open',
        myId = GetPlayerServerId(PlayerId()),
        maxPlayers = Config.MaxPlayers,
        nearbyDistance = Config.NearbyDistance,
    })
    RefreshData()

    -- periodic server refresh
    CreateThread(function()
        while scoreboardOpen do
            Wait(Config.RefreshInterval)
            if scoreboardOpen then RefreshData() end
        end
    end)

    -- nearby players (client-side, cheap)
    CreateThread(function()
        while scoreboardOpen do
            local nearby = GetNearbyPlayers(Config.NearbyDistance)
            local out = {}
            for i = 1, #nearby do
                out[i] = { id = nearby[i].id, dist = nearby[i].dist, talking = nearby[i].talking }
            end
            SendNUIMessage({ action = 'nearby', list = out })
            Wait(500)
        end
    end)

    -- per-frame: tab / scroll controls + overhead IDs
    CreateThread(function()
        while scoreboardOpen do
            if IsPauseMenuActive() then
                CloseScoreboard()
                break
            end

            DisableControlAction(0, CTRL_TAB_PREV, true)
            DisableControlAction(0, CTRL_TAB_NEXT, true)
            DisableControlAction(0, CTRL_SCROLL_DOWN, true)
            DisableControlAction(0, CTRL_SCROLL_UP, true)
            DisableControlAction(0, 16, true)
            DisableControlAction(0, 17, true)

            if IsDisabledControlJustPressed(0, CTRL_TAB_PREV) then
                SendNUIMessage({ action = 'tab', dir = -1 })
            elseif IsDisabledControlJustPressed(0, CTRL_TAB_NEXT) then
                SendNUIMessage({ action = 'tab', dir = 1 })
            end
            if IsDisabledControlJustPressed(0, CTRL_SCROLL_DOWN) then
                SendNUIMessage({ action = 'scroll', dir = 1 })
            elseif IsDisabledControlJustPressed(0, CTRL_SCROLL_UP) then
                SendNUIMessage({ action = 'scroll', dir = -1 })
            end

            for _, p in ipairs(GetNearbyPlayers(Config.OverheadDistance)) do
                local entry = playerOptin[p.id]
                if Config.ShowIDforALL or (entry and entry.optin) then
                    local c = GetEntityCoords(p.ped)
                    DrawText3D(vector3(c.x, c.y, c.z + 1.0), ('[%d]'):format(p.id), p.talking)
                end
            end

            Wait(0)
        end
    end)
end

-- Events

RegisterNetEvent('aj-scoreboard:client:SetActivityBusy', function(activity, busy)
    if not Config.IllegalActions[activity] then return end
    Config.IllegalActions[activity].busy = busy
end)

-- Command

if Config.Toggle then
    RegisterCommand('scoreboard', function()
        if scoreboardOpen then CloseScoreboard() else OpenScoreboard() end
    end, false)

    RegisterKeyMapping('scoreboard', 'AJ Scoreboard - open / close', 'keyboard', Config.OpenKey)
else
    RegisterCommand('+scoreboard', OpenScoreboard, false)
    RegisterCommand('-scoreboard', CloseScoreboard, false)

    RegisterKeyMapping('+scoreboard', 'AJ Scoreboard - hold to show', 'keyboard', Config.OpenKey)
end

-- Setup

CreateThread(function()
    Wait(1000)
    local counters = {}
    for i = 1, #Config.JobCounters do
        local c = Config.JobCounters[i]
        counters[i] = { job = c.job, label = c.label, icon = c.icon }
    end
    SendNUIMessage({
        action = 'setup',
        serverName = Config.ServerName,
        tag = Config.ServerTag,
        accent = Config.Accent,
        toggle = Config.Toggle,
        openKey = Config.OpenKey,
        jobCounters = counters,
        showDisconnected = Config.Disconnected.enabled,
    })
end)
