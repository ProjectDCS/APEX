env.info('CON: Zones loading')
function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
function randomizeSelectTable(maxIndex, maxCount)
    local SelectedTable = {}
    for order, zone in pairs(SelectedTable) do
        local zoneSelectRandom = math.random( 1, ZoneToPopulateCount )
        SelectedTable[zoneSelectRandom] = true
        if tableLength(SelectedTable) == maxCount then
            break
        end
    end
    return SelectedTable
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
CaptureZoneString = "Capture Zone #"
REDCaptureZoneString = "Red Capture Zone #"

local ZoneCount = 15
local ZoneToPopulateCount = 5


function populateZones(coalitionString, selectedZones)
    for index, value in pair(selectedZones) do
        local zoneString = coalitionString .. " " .. CaptureZoneString .. tostring(index)
        local zone = ZONE:New(zoneString)
        SpawnZoneBaseRandomSpawn(coalitionString, zone)
    end
end

function startPopulateZones(something)
    local SelectedBlueZonesTable = randomizeSelectTable(ZoneCount, ZoneToPopulateCount)
    local SelectedRedZonesTable = randomizeSelectTable(ZoneCount, ZoneToPopulateCount)
    env.info("CON: Selected Blue Zones " .. UTILS.OneLineSerialize(SelectedBlueZonesTable))

    populateZones("Blue", SelectedBlueZonesTable)
    populateZones("Red", SelectedRedZonesTable)
end
SCHEDULER:New(nil, populateZones, {"sdfsdfd"}, 5)

env.info('CON: Zones finished')
