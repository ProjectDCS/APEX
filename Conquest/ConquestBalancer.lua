
local function ternary ( cond , T , F )
    if cond then return T else return F end
end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end
-------------------------------------------------------------------------------

local classPrefixTable = {
    "A2A",
    "MR",
    "A2G",
    "X"
}

local startAirbaseZone = "Start Zone"

BalancerTable = {}

function refreshBalancer(something)
    for playerID, alive in pairs(PlayerMenuMap) do
        local playerClient = CLIENT:FindByName(playerID)
        local playerGroup = playerClient:GetGroup()
        local playerOpposition = BalancerTable[playerID]

        if alive and playerGroup ~= nil and playerOpposition == nil then
            local coalitionString = ternary(playerClient:GetCoalition() == coalition.side.BLUE, "Blue", "Red" )
            local oppositionString = ternary(playerClient:GetCoalition() == coalition.side.BLUE, "Red", "Blue" )

            local classString = nil
            for i = 1, #classPrefixTable do
                -- local prefixString = coalitionString .. " " .. classPrefixTable[i]
                local prefixString = classPrefixTable[i]
                if string.match(playerID, prefixString) then
                    classString = classPrefixTable[i]
                end
            end

            
            local focusZone = ZONE:FindByName(VoteResult[oppositionString])
            env.info("CON: Selected class string " .. classString .. " at zone " .. VoteResult[oppositionString] )
            local oppositionGroup = SpawnOppositionClass(classString, oppositionString, focusZone)
            BalancerTable[playerID] = oppositionGroup
        elseif playerOpposition ~= nil and playerGroup == nil then
            env.info("CON: Balancer deleting Player Opposition " .. UTILS.OneLineSerialize(playerOpposition))
            local coalitionString = ternary(playerOpposition:GetCoalition() == coalition.side.BLUE, "Blue", "Red" )
            local baseZoneString = coalitionString .. " " .. startAirbaseZone
            local baseZone = ZONE:FindByName(baseZoneString)
            -- playerOpposition.TaskLandAtZone(baseZone, 10, false)
            playerOpposition:Destroy()
            BalancerTable[playerID] = nil
        end
    end
    env.info("CON:Balancer Table " .. UTILS.OneLineSerialize(BalancerTable))
end

SCHEDULER:New(nil, refreshBalancer, {"something"}, 15, 15)
