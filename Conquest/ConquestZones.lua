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
    function ZoneCaptureCoalition:OnEnterEmpty()
        env.info("CON: Detected Empty in zone " .. ZoneCaptureCoalition:GetZoneName())
        
    end
    function ZoneCaptureCoalition:OnEnterCaptured( From, Event, To )
        local Coalition = self:GetCoalition()
        if Coalition == coalition.side.BLUE then
            SpawnZoneBaseRandomSpawn("Blue", zone)
        else
            SpawnZoneBaseRandomSpawn("Red", zone)
        end
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
    env.info("CON: Selected Blue Zones " .. UTILS.OneLineSerialize(SelectedBlueZonesTable))

    populateZones("Blue", SelectedBlueZonesTable)
    populateZones("Red", SelectedRedZonesTable)

    env.info("CON: Blue Zones " .. UTILS.OneLineSerialize(ConquestZones["Blue"]))
end

SCHEDULER:New(nil, startPopulateZones, {"sdfsdfd"}, 2)









-- local function debugTrigger(something)
--     SpawnZoneBaseRandomSpawn(coalitionString, zone)
-- end

-- SCHEDULER:New(nil, debugTrigger, {"somethine"}, 45)

env.info('CON: Zones finished')
