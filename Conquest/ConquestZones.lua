env.info('CON: Zones loading')
function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
function randomizeSelectTable(maxIndex, maxCount)
    local SelectedTable = {}
        
    local i = 1
    repeat
        local zoneSelectRandom = math.random( 1, maxIndex )
        SelectedTable[zoneSelectRandom] = true
    until (tableLength(SelectedTable) == maxCount)
        -- i = i + 1
    -- until (i == 20)

    return SelectedTable
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
CaptureZoneString = "Capture Zone #"

local ZoneCount = 15
local ZoneToPopulateCount = 5

ConquestZones = {
    ["Blue"] = {},
    ["Red"] = {}
}

function startZoneCoalition(zone, coalitionString)

    local ZoneCaptureCoalition
    if coalitionString == 'Blue' then
        ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( zone, coalition.side.BLUE )
        ZoneCaptureCoalition:Start( 5, 10 )
        ZoneCaptureCoalition:__Guard(2)
    elseif coalitionString == 'Red' then
        ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( zone, coalition.side.RED )
        ZoneCaptureCoalition:Start( 5, 10 )
        ZoneCaptureCoalition:__Guard(1)
    end

    local zoneName = ZoneCaptureCoalition:GetZoneName()
    ConquestZones[coalitionString][zoneName] = ZoneCaptureCoalition

    ---------------------------------------------------------------------------------------
    
    function ZoneCaptureCoalition:OnAfterDestroyedUnit(From, Event, To, unit, PlayerName)
        env.info(string.format('CON: Detected destroyed unit %s', Event))
        env.info("CON: Detected hit in zone " .. ZoneCaptureCoalition:GetZoneName())
    end
    function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
        env.info("CON: Detected Guarded in zone " .. ZoneCaptureCoalition:GetZoneName())
    end
    function ZoneCaptureCoalition:OnEnterAttacked(From, Event, To)
        env.info("CON: Detected Atack in zone " .. ZoneCaptureCoalition:GetZoneName())
    end
    function ZoneCaptureCoalition:OnEnterCaptured( From, Event, To )
        env.info("CON: Detected captured in zone " .. ZoneCaptureCoalition:GetZoneName())
    end
    function ZoneCaptureCoalition:OnEnterEmpty()
        env.info("CON: Detected Empty in zone " .. ZoneCaptureCoalition:GetZoneName())
        local Coalition = self:GetCoalition()
        local newCoalition = 0
        if Coalition == coalition.side.BLUE then
            SpawnZoneCaptureRandomSpawn("Red", zone)
            newCoalition = 1
        else
            SpawnZoneCaptureRandomSpawn("Blue", zone)
            newCoalition = 2
        end
        local function spawnReinforcement(CoalitionToReinforce, zoneToReinforce)
            if CoalitionToReinforce == coalition.side.BLUE then
                SpawnZoneBaseRandomSpawn("Red", zoneToReinforce)
            else
                SpawnZoneBaseRandomSpawn("Blue", zoneToReinforce)
            end
        end
        SCHEDULER:New(nil, spawnReinforcement, {Coalition, zone}, 700)
        ZoneCaptureCoalition:__Guard(newCoalition)
    end

    -------------------------------------------------------------------------------------

    local function refreshMark(something)
        ZoneCaptureCoalition:Mark()
    end
    SCHEDULER:New(nil, refreshMark, {"something"}, 10, 10)

    -- ZoneCaptureCoalition:MonitorDestroyedUnits()
    ZoneCaptureCoalition:Mark()
end


function populateZones(coalitionString, selectedZones)
    for index, value in pairs(selectedZones) do
        local zoneString = coalitionString .. " " .. CaptureZoneString .. tostring(index)
        local zone = ZONE:New(zoneString)
        SpawnZoneBaseRandomSpawn(coalitionString, zone)
        startZoneCoalition(zone, coalitionString)
    end
end

function startPopulateZones(something)
    local SelectedBlueZonesTable = randomizeSelectTable(ZoneCount, ZoneToPopulateCount)
    local SelectedRedZonesTable = randomizeSelectTable(ZoneCount, ZoneToPopulateCount)
    -- env.info("CON: Selected Blue Zones " .. UTILS.OneLineSerialize(SelectedBlueZonesTable))

    populateZones("Blue", SelectedBlueZonesTable)
    populateZones("Red", SelectedRedZonesTable)

    local keyset={}
    for k,v in pairs(ConquestZones["Red"]) do
        keyset[#keyset + 1]=k
    end
    VoteResult["Blue"] = keyset[math.random( 1, #keyset)]

    keyset = {}
    for k,v in pairs(ConquestZones["Blue"]) do
        keyset[#keyset + 1]=k
    end
    VoteResult["Red"] = keyset[math.random( 1, #keyset)]

    -- env.info("CON: Blue Zones " .. UTILS.OneLineSerialize(ConquestZones["Blue"]))
    -- env.info('CON: Red Focus Zone ' .. UTILS.OneLineSerialize(VoteResult["Red"]))
end

SCHEDULER:New(nil, startPopulateZones, {"sdfsdfd"}, 2)









-- local function debugTrigger(something)
--     SpawnZoneBaseRandomSpawn(coalitionString, zone)
-- end

-- SCHEDULER:New(nil, debugTrigger, {"somethine"}, 45)

env.info('CON: Zones finished')
