
SupportHandler = EVENTHANDLER:New()

--------------------------------------------------------------------------------------
local voteOn = true -- DEBUG
local voteTable = {}

local function handleVote(coord, coalitionZones) --assumes ZONE_CAPTURE_COALITION table and not ZONE
    if voteOn == false then
        env.info("CON: Vote is not in progress") -- notify user
        return
    end

    local minDistance = 1000000000000000
    local associatedZone = nil
    for zoneName, ZoneCaptureCoalition in pairs(coalitionZones) do
        local distance = coord:Get2DDistance(ZoneCaptureCoalition:GetZone():GetCoordinate())
        env.info(string.format( "CON: new Distance %d compared to %d", distance, minDistance))
        if distance < minDistance then
            minDistance = distance
            associatedZone = zoneName
        end
    end

    env.info("CON: voting result " .. associatedZone)

    if voteTable[associatedZone] == nil then
        voteTable[associatedZone] = 0
    end
    voteTable[associatedZone] = voteTable[associatedZone] + 1
    env.info("CON: voteTable " .. UTILS.OneLineSerialize(voteTable))
end


function endVote()
    local maxVote = 0
    local associatedZone = nil
    for zoneName, voteValue in pairs(voteTable) do
        if voteValue > maxVote then
            associatedZone = zoneName
        end
    end

    if associatedZone ~= nil then
        env.info("CON: We have a winner ! " .. associatedZone)
        -- do something!
    end
end

function initiateVote(votingDelay)
    voteTable = {}
    voteOn = true
    SCHEDULER:New(nil, endVote, {"something"}, votingDelay)
    -- reset results
    -- switch vote to true
    -- schedule end of vote
end


--------------------------------------------------------------------------------------
local function spawnTanks(coord)
    local tankSpawn = SPAWN:New("Debug Tanks")
    tankSpawn:SpawnFromCoordinate(coord)
end

local function markRemoved(Event)
    if Event.text~=nil and Event.text:lower():find("-") then 
        env.info("CON: mark removed event " .. UTILS.OneLineSerialize(Event))
        local text = Event.text:lower()
        local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
        local coord = COORDINATE:NewFromVec3(vec3)
        coord.y = coord:GetLandHeight()

        if Event.text:lower():find("-tanks") then
            spawnTanks(coord)
        elseif Event.text:lower():find("-redtanks") then
            -- handleTankerRequest(text, coord)
        elseif Event.text:lower():find("-vote") then
            local coalitionString = "Red"
            if Event.coalition == coalition.side.BLUE then
                coalitionString = "Blue"
            end
            local coalitionZones = ConquestZones[coalitionString]
            handleVote(coord, coalitionZones)
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