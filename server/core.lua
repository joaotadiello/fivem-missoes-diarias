-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
API = {}
Tunnel.bindInterface(GetCurrentResourceName(),API)

Core = {}
Core.cache = {}
NEXT_UPDATE = nil

function Core:GetPlayerId(source)
    return vRP.getUserId(source)
end

function Core:GetCache(userId)
    return self.cache[userId]
end

function Core:SetCache(userId)
    if not userId then return end
    local data = exports['oxmysql']:query_async('SELECT * FROM daily WHERE user_id = ?', {userId})
    if data and data[1] then
        data[1].data = json.decode(data[1].data)
        if data[1].expireAt <= os.time() then
            data[1].data = {}
            data[1].updatedAt = os.time()
            data[1].expireAt = NEXT_UPDATE
            data[1].connection_start = os.time()
            exports['oxmysql']:update_async('UPDATE daily SET data = ?,updatedAt = ?,expireAt = ?,connection_start = ? WHERE user_id = ?', {
                json.encode(data[1].data),
                os.time(),
                NEXT_UPDATE,
                os.time(),
                userId
            })
        end
        self.cache[userId] = data[1]
        return true
    end
    self.cache[userId] = {
        data = {},
        updatedAt = os.time(),
        connectionStart = os.time(),
        expireAt = NEXT_UPDATE
    }
    exports['oxmysql']:insert_async('INSERT INTO daily (user_id,data,updatedAt,expireAt,connection_start) VALUES (?,?,?,?,?)', {
        userId,
        json.encode({}),
        os.time(),
        NEXT_UPDATE,
        os.time()
    })
    return true
end

--- Renova as missões diariamente
function Core:NewMissions()
    print('[Core:NewMissions()] - Renovando missões e progresso.')
    self.cache = {}
    local data = LoadResourceFile(GetCurrentResourceName(), 'renew.json')
    if not data then
        data = {}
        data.lastUpdate = os.time()
        data.nextUpdate = os.time() + 86400
        NEXT_UPDATE = data.nextUpdate

        SaveResourceFile(GetCurrentResourceName(), 'renew.json', json.encode(data), -1)
        return
    end
    data = json.decode(data)
    data.lastUpdate = os.time()
    if (data.nextUpdate and data.lastUpdate) and data.lastUpdate > data.nextUpdate then
        data.nextUpdate = os.time() + 86400 
    end    
    NEXT_UPDATE = data.nextUpdate
    
    SaveResourceFile(GetCurrentResourceName(), 'renew.json', json.encode(data), -1)
    print('[Core:NewMissions()] - Missões e progresso renovado.')
end

Citizen.CreateThread(function()
    Wait(1000)
    Core:NewMissions()
end)

RegisterCommand('debug_daily',function()
    for i=1,10 do
        TriggerEvent('missions:execute', 'daily', 36)
        Wait(100)
    end
    for i=1,5 do
        TriggerEvent('missions:execute', 'police', 36)
        Wait(100)
    end
end)



