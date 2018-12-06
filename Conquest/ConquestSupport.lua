
SupportHandler = EVENTHANDLER:New()

local function spawnTanks(coord)
    local tankSpawn = SPAWN:New("Debug Tanks")
    tankSpawn:SpawnFromCoordinate(coord)
end

local function markRemoved(Event)
    if Event.text~=nil and Event.text:lower():find("-") then 
        local text = Event.text:lower()
        local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
        local coord = COORDINATE:NewFromVec3(vec3)
        coord.y = coord:GetLandHeight()

        if Event.text:lower():find("-tanks") then
            spawnTanks(coord)
        elseif Event.text:lower():find("-redtanks") then
            -- handleTankerRequest(text, coord)
        end
    end
end

function SupportHandler:onEvent(Event)
    if Event.id == world.event.S_EVENT_MARK_REMOVED then
        markRemoved(Event)
    end
end

world.addEventHandler(SupportHandler)

env.info("CON: Support ready")