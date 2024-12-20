Core.missions = Missions

--- Processa uma missão, validando se ela ja foi recolhida ou não, e se o jogador tiver atingido o objetivo da missao nao ira salvar no banco de dados
--- @param event string
--- @param userId number
function Core:ProcessMission(event,userId)
    self:MissionTimeIsOver()
    if Core.missions[event] then
        if not Core:GetCache(userId) then
            Core:SetCache(userId)
        end
        if self.cache[userId].data[event] and self.cache[userId].data[event] == 'disable' then return end
        self:InsertPlayerMission(userId,event)
        self:AddProgress(userId,event)
        if self.cache[userId].data[event] <=  Core.missions[event]['objective'] then
            exports['oxmysql']:update_async('UPDATE daily SET data = ?,expireAt = ? WHERE user_id = ?', {
                json.encode(self.cache[userId].data),
                NEXT_UPDATE,
                userId
            })
        end
    end
end

--- Verifica se o tempo da missão acabou e renova as missões
function Core:MissionTimeIsOver()
    if NEXT_UPDATE < os.time() then
        self:NewMissions()
    end
end

--- Executa uma missão
--- @param event string
--- @vararg any
AddEventHandler('missions:execute',function(event, userId)
    if Core.missions[event] then
        Core:ProcessMission(event,userId)
    end
end)