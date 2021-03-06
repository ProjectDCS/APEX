
SupportHandler = EVENTHANDLER:New()

local function ternary ( cond , T , F )
    if cond then return T else return F end
end

--------------------------------------------------------------------------------------
local voteOn = true -- DEBUG
local voteInProgressCoalition = ""
local voteTables = {
    ["Blue"] = {},
    ["Red"] = {}
}
VoteResult = {
    ["Blue"] = nil,
    ["Red"] = nil
}

local function handleVote(coord, coalitionZones, coalitionString) --assumes ZONE_CAPTURE_COALITION table and not ZONE
    if voteOn == false or voteInProgressCoalition ~= coalitionString then
        env.info("CON: Vote is not in progress") -- notify user
        return
    end

    local minDistance = 1000000000000000
    local associatedZone = nil
    for zoneName, ZoneCaptureCoalition in pairs(coalitionZones) do
        local distance = coord:Get2DDistance(ZoneCaptureCoalition:GetZone():GetCoordinate())
        -- env.info(string.format( "CON: new Distance %d compared to %d", distance, minDistance))
        if distance < minDistance then
            minDistance = distance
            associatedZone = zoneName
        end
    end

    env.info("CON: 1 vote casted:" .. associatedZone)

    if voteTables[coalitionString][associatedZone] == nil then
        voteTables[coalitionString][associatedZone] = 0
    end
    voteTables[coalitionString][associatedZone] = voteTables[coalitionString][associatedZone] + 1
    env.info("CON: voteTables " .. UTILS.OneLineSerialize(voteTables[coalitionString]))
end


function endVote(coalitionString)
    local maxVote = 0
    local associatedZone = nil
    for zoneName, voteValue in pairs(voteTables[coalitionString]) do
        if voteValue > maxVote then
            associatedZone = zoneName
        end
    end

    if associatedZone ~= nil then
        VoteResult[coalitionString] = associatedZone
        env.info("CON: We have a winner ! " .. VoteResult[coalitionString])
        trigger.action.outTextForCoalition( ternary(coalitionString == "Blue", 2, 1), "Votes are in!\n\nYou have selected " .. VoteResult[coalitionString] .. " as the focus zone", 35)
        -- do something!
        local zone = ZONE:New(associatedZone)
        SpawnJTAC(coalitionString, zone)
    end
    voteOn = false
end

function InitiateVote(coalitionString, votingDelay)
    if voteInProgress == true then
        -- disable voting until current vote in progress is finished
        -- message coalition
        return
    end

    voteTables[coalitionString] = {}
    VoteResult[coalitionString] = nil
    voteOn = true
    voteInProgressCoalition = coalitionString
    SCHEDULER:New(nil, endVote, {coalitionString}, votingDelay)
end


--------------------------------------------------------------------------------------
local function spawnTanks(coord)
    local tankSpawn = SPAWN:New("Debug Tanks")
    tankSpawn:SpawnFromCoordinate(coord)
end

local destroyZoneCount = 0
local function destroyRequest(coord)
    local destroyZoneName = string.format("destroy %d", destroyZoneCount)
    local zoneRadiusToDestroy = ZONE_RADIUS:New(destroyZoneName, coord:GetVec2(), 8000)
    destroyZoneCount = destroyZoneCount + 1
    local function destroyUnit(zoneUnit)
        env.info(string.format("BTI: Found unit in zone %s", destroyZoneName))
        env.info(string.format("BTI: Salvaging command received, executing"))
        zoneUnit:Destroy()
        return true
    end
    zoneRadiusToDestroy:SearchZone(destroyUnit, Object.Category.UNIT)
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
        elseif Event.text:lower():find("-vote") then
            -- Red coalition
            local voteCoalitionString = "Red"
            local zoneCoalitionString = "Blue"
            if Event.coalition == coalition.side.BLUE then
                voteCoalitionString = "Blue"
                zoneCoalitionString = "Red"
            end
            local coalitionZones = ConquestZones[zoneCoalitionString]
            handleVote(coord, coalitionZones, voteCoalitionString)
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