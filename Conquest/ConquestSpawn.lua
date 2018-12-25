env.info("CON: Preparing troops")
-- "Blue Capture Zone Spawn #2(g)"
-- "Blue Zone Assault #1(b)"
-- "Blue Zone Escort #1(a)"

CaptureZoneFirstSpawnString = "Capture Zone Initial"
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

SpawnsTableConcurrent = {
    ["Blue"] = {},
    ["Red"] = {}
}
--------------------------------------------------------------------------------------------

function SpawnJTAC(coalitionString, zone)
    local spawnJTACString = coalitionString .. " JTAC"
    local spawn = SPAWN:New(spawnJTACString)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            ctld.JTACAutoLase(spawnGroup:GetName(), 1688, true, "all", 3)
            local routeTask = spawnGroup:TaskOrbitCircleAtVec2( zone:GetCoordinate():GetVec2(), UTILS.FeetToMeters(10000),  UTILS.KnotsToMps(110) )
            spawnGroup:SetTask(routeTask, 2)
        end
    )
    
    spawn:SpawnInZone(zone)
end

function SpawnOppositionClass(classString, coalitionString, zone)
    local startZoneString = coalitionString .. " Start Zone"
    local spawnString = coalitionString .. " " .. classString
    local spawn = SPAWN:New(spawnString)
    spawn:OnSpawnGroup(
        function(spawnGroup)
            local casTask = spawnGroup:EnRouteTaskEngageTargets( 20000, { "All" }, 1 )
            spawnGroup:SetTask(casTask, 2)
            local orbitTask = spawnGroup:TaskOrbitCircleAtVec2( zone:GetCoordinate():GetVec2(), UTILS.FeetToMeters(8000), UTILS.KnotsToMps(270))
            spawnGroup:PushTask(orbitTask, 4)
        end
    )
    
    local spawnedGroup = spawn:SpawnInZone(ZONE:FindByName(startZoneString))
    return spawnedGroup
end

function SpawnTaskforce(classString, coalitionString, zoneName)
    local spawnString = coalitionString .. " Taskforce " .. classString
    local zone = ZONE:FindByName(zoneName)
    local spawn = SpawnsTableConcurrent[coalitionString][spawnString]
    if spawn == nil then
        env.info("CON: Trying to create spawn from " .. spawnString)
        local newSpawn = SPAWN:New(spawnString)
        SpawnsTableConcurrent[coalitionString][spawnString] = newSpawn
        spawn = newSpawn
    end


    spawn:OnSpawnGroup(
        function(spawnGroup)
            local casTask = spawnGroup:EnRouteTaskEngageTargets( 20000, { "All" }, 1 )
            spawnGroup:SetTask(casTask, 2)
            local orbitTask = spawnGroup:TaskOrbitCircleAtVec2( zone:GetCoordinate():GetVec2(), UTILS.FeetToMeters(8000), UTILS.KnotsToMps(270))
            spawnGroup:PushTask(orbitTask, 4)
        end
    )
    
    local spawnedGroup = spawn:SpawnInZone(zone)
    return spawnedGroup
end

--------------------------------------------------------------------------------------------

function SpawnZoneBaseRandomSpawn(coalitionString, zone)
    local random = math.random( 1, CaptureZoneBaseTemplateCount )
    local baseString = coalitionString .. " " .. CaptureZoneBaseString .. tostring(random)
    for i = 1, CaptureZoneBaseTemplateGroupCount do
        local spawnString = baseString .. "(" .. tostring(i) .. ")"
        local spawn = SpawnsTableConcurrent[coalitionString][spawnString]
        if spawn == nil then
            local newSpawn = SPAWN:New(spawnString)
            SpawnsTableConcurrent[coalitionString][spawnString] = newSpawn
            spawn = newSpawn
        end
        spawn:SpawnInZone(zone, true)
    end
end

function SpawnZoneCaptureRandomSpawn(coalitionString, zone)
    -- spawn after capture units
    local spawnString = coalitionString .. " " .. CaptureZoneFirstSpawnString
    local spawn = SpawnsTableConcurrent[coalitionString][spawnString]
    if spawn == nil then
        local newSpawn = SPAWN:New(spawnString)
        SpawnsTableConcurrent[coalitionString][spawnString] = newSpawn
        spawn = newSpawn
    end
    spawn:SpawnInZone(zone, true)
end

function ScheduledSpawnTaskforce(coalitionString)
    env.info("CON: Spawning " .. coalitionString .. " Taskforce")
    SpawnTaskforce("A2A", coalitionString, VoteResult[coalitionString])
    SpawnTaskforce("MR", coalitionString, VoteResult[coalitionString])
    SpawnTaskforce("A2G", coalitionString, VoteResult[coalitionString])
    SpawnTaskforce("X", coalitionString, VoteResult[coalitionString])
end

function scheduleTaskforce(something)
    local blueTimer = math.random (1500, 2000)
    local redTimer = math.random(1500, 2000)

    env.info(string.format( "CON: Blue Taskforce timer %d Red Taskforce timer %d", blueTimer, redTimer))
    SCHEDULER:New(nil, ScheduledSpawnTaskforce, {"Blue"}, blueTimer)
    SCHEDULER:New(nil, ScheduledSpawnTaskforce, {"Red"}, redTimer)
end

SCHEDULER:New(nil, scheduleTaskforce, {"Blue"}, 100, 1800) -- Recurrent Spawn
SCHEDULER:New(nil, ScheduledSpawnTaskforce, {"Blue"}, 25) -- Initial Spawn
SCHEDULER:New(nil, ScheduledSpawnTaskforce, {"Red"}, 26) -- Initial Spawn

---------------------------------------------------------------------------------------------
env.info("CON: Troops are ready")
