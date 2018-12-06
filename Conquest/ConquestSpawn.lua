env.info("CON: Preparing troops")
-- "Blue Capture Zone Spawn #2(g)"
-- "Blue Zone Assault #1(b)"
-- "Blue Zone Escort #1(a)"

CaptureZoneBaseString = "Capture Zone Spawn #"
CaptureZoneBaseTemplateCount = 4
CaptureZoneBaseTemplateGroupCount = 7


-- BLUECaptureZoneBaseString = "Blue Capture Zone Spawn #"
-- REDCaptureZoneBaseString = "Red Capture Zone Spawn #"
-- REDCaptureZoneBaseTemplateCount = 4

-- BLUEZoneAssaultString = "Blue Zone Assault #1"
-- BLUEZONEEscortString = "Blue Zone Escort #1"
-- REDZoneAssaultString = "Red Zone Assault #1"
-- REDZONEEscortString = "Red Zone Escort #1"

local SpawnsTable = {
    ["Blue"] = {},
    ["Red"] = {}
}

function SpawnZoneBaseRandomSpawn(coalitionString, zone)
    local random = math.random( 1, CaptureZoneBaseTemplateCount )
    local baseString = coalitionString .. " " .. CaptureZoneBaseString .. tostring(random)
    for i = 1, CaptureZoneBaseTemplateGroupCount do
        local spawnString = baseString .. "(" .. tostring(i) .. ")"
        local spawn = SpawnsTable[coalitionString][spawnString]
        if spawn == nil then
            local newSpawn = SPAWN:New(spawnString)
            SpawnsTable[coalitionString][spawnString] = newSpawn
            spawn = newSpawn
        end
        spawn:SpawnInZone(zone, true)
    end
end

env.info("CON: Troops are ready")
