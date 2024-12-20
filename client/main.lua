-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
Remote = Tunnel.getInterface(GetCurrentResourceName())

function GetMissions()
    local missionsClone = {}
    for k,v in pairs(Missions) do
        missionsClone[k] = {
            id = k,
            name = v.name,
            available = true,
            objective = v.objective,
            current = 0,
        }
    end
    return missionsClone
end

function UpdateMission(data)
    local missionsClone = GetMissions()
    for mission,current in pairs(data or Remote.OpenDaily()) do
        if mission then
            missionsClone[mission].current = current
            missionsClone[mission].available = current ~= 'disable'
        end
    end
    return missionsClone
end

RegisterCommand('opendaily', function()
    ToggleNuiFrame(true)
    SendReactMessage('setList', UpdateMission())
end)

RegisterNUICallback('mission:get:reward',function(missionKey,cb)
    local data = Remote.GetReawrd(missionKey)
    print(json.encode(data,{indent = true}))
    local update = UpdateMission(data)
    print(json.encode(update,{indent = true}))
    cb(update)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- UTILS
-----------------------------------------------------------------------------------------------------------------------------------------
SendReactMessage = function(event, data)
    SendNUIMessage({
        action = event,
        data = data,
    })
end

ToggleNuiFrame = function(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end

RegisterNUICallback('hideFrame', function()
    ToggleNuiFrame(false)
end)