function API.OpenDaily()
    local source = source
    local userId = Core:GetPlayerId(source)
    if not userId then return end
    if NEXT_UPDATE < os.time() then
        Core:NewMissions()
    end
    local data = Core:GetCache(userId)
    if not data and Core:SetCache(userId) then
        data = Core:GetCache(userId)
    end
    print(json.encode(data,{indent = true}))
    data.data['online'] = os.time() - data.connection_start
    return data.data
end


--- Insere uma missão para o jogador
--- @param userId number
--- @param mission string
function Core:InsertPlayerMission(userId,mission)
    local data = self:GetCache(userId)
    if not data then return end
    if not data.data[mission] then
        data.data[mission] = 0
    end
end

--- Adiciona progresso a missão
--- @param userId number
--- @param mission string
function Core:AddProgress(userId,mission)
    local data = self:GetCache(userId)
    if not data then return end
    if data.data[mission] and data.data[mission] == 'disable' then return end
    data.data[mission] += 1
end

local brokers = {}
function API.GetReawrd(missionKey)
    local source = source
    local userId = Core:GetPlayerId(source)
    if not userId then return end
    if brokers[userId] then return end
    brokers[userId] = true
    local cache = Core:GetCache(userId)
    if not cache then brokers[userId] = false return end
    if cache.data[missionKey] ~= 'disable' and cache.data[missionKey] >= Core.missions[missionKey]['objective'] then
        cache.data[missionKey] = 'disable'
        Core.missions[missionKey]['reward'](userId)
    end
    exports['oxmysql']:update_async('UPDATE daily SET data = ?,updatedAt = ?,expireAt = ? WHERE user_id = ?', {
        json.encode(cache.data),
        os.time(),
        NEXT_UPDATE,
        userId
    })
    brokers[userId] = false
    return cache.data
end

AddEventHandler('mission:playerLoaded',function(user_id)
    if Core:SetCache(user_id) then
        print('[mission:playerLoaded] - Cache criado para o jogador '..user_id)
    end
end)

AddEventHandler("playerDropped",function()
    local userId = Core:GetPlayerId(source)
    if brokers[userId] then
        brokers[userId] = false
    end
    if Core.cache[userId] then
        Core.cache[userId].data['online'] = os.time() - Core.cache[userId].connection_start
        exports['oxmysql']:update_async('UPDATE daily SET data = ? WHERE user_id = ?', {
            json.encode(Core.cache[userId].data),
            userId
        })
        Core.cache[userId] = nil
    end
end)