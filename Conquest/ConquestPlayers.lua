--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

function initiateBlueVoting()
    InitiateVote("Blue", 20)
end

function initiateRedVoting()
    InitiateVote("Red", 20)
end

local function permanentPlayerMenu(something)
    -- env.info(string.format( "BTI: Starting permanent menus"))
    for playerID, alive in pairs(PlayerMenuMap) do
        -- env.info(string.format( "BTI: Commencing Menus for playerID %s alive %s", playerID, tostring(alive)))
        local playerClient = CLIENT:FindByName(playerID)
        local playerGroup = playerClient:GetGroup()
        if alive and playerGroup ~= nil then
            local IntelMenu = MENU_GROUP:New( playerGroup, "Vote" )
            
            local groupMenu = nil
            if playerClient:GetCoalition() == coalition.side.BLUE then
                groupMenu = MENU_GROUP_COMMAND:New( playerGroup, "Bombers Voting", IntelMenu, initiateBlueVoting, playerClient )
            elseif playerClient:GetCoalition() == coalition.side.RED then
                groupMenu = MENU_GROUP_COMMAND:New( playerGroup, "Bombers Voting", IntelMenu, initiateRedVoting, playerClient )
            end

            PlayerMenuMap[playerID] = groupMenu
        else
            -- groupMenu is actually Boolean
            -- local deleteGroupMenu = PlayerMenuMap[playerID]
            -- if deleteGroupMenu ~= nil then
            --     deleteGroupMenu:Remove()
            -- end
            -- PlayerMenuMap[playerID] = nil
        end
    end
end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
PlayerMenuMap = {}
PlayerMap = {
    ["Blue"] = {},
    ["Red"] = {}
}

RedSetPlayer = SET_CLIENT:New():FilterCoalitions("red"):FilterActive():FilterStart()
BlueSetPlayer = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive():FilterStart()


local function permanentPlayerCheck(something)
    BlueSetPlayer:ForEachClient(
        function (PlayerClient)
            env.info("CON: Checking blue player " .. UTILS.OneLineSerialize(PlayerClient))
            local PlayerID = PlayerClient.ObjectName
            PlayerClient:AddBriefing("Welcome to Conquest! \\o/!\n\n Remember to vote to steer your team to victory using the user marks!")

            if PlayerClient:IsAlive() then
                PlayerMap["Blue"][PlayerID] = true
                PlayerMenuMap[PlayerID] = true
            else
                PlayerMap["Blue"][PlayerID] = false
                PlayerMenuMap[PlayerID] = false
            end
        end
    )
    RedSetPlayer:ForEachClient(
        function (PlayerClient)
            env.info("CON: Checking red player " .. UTILS.OneLineSerialize(PlayerClient))
            local PlayerID = PlayerClient.ObjectName
            PlayerClient:AddBriefing("Welcome to Conquest! \\o/!\n\n Remember to vote to steer your team to victory using the user marks!")

            if PlayerClient:IsAlive() then
                PlayerMap["Red"][PlayerID] = true
                PlayerMenuMap[PlayerID] = true
            else
                PlayerMap["Red"][PlayerID] = false
                PlayerMenuMap[PlayerID] = false
            end
        end
    )

    env.info("CON: Permanent Blue Players " .. UTILS.OneLineSerialize(PlayerMap["Blue"]))
    env.info("CON: Permanent Red Players " .. UTILS.OneLineSerialize(PlayerMap["Red"]))
end

SCHEDULER:New(nil, permanentPlayerCheck, {"Something"}, 3, 10)
SCHEDULER:New(nil, permanentPlayerMenu, {"something"}, 11, 15)

env.info(string.format("CON: CIA ready at the safe house"))
