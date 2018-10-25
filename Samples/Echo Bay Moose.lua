
GoalScore = 200

FlagMissionEnd = USERFLAG:New( "66" )

RU_VictorySound = USERSOUND:New( "MotherRussia.ogg" )
US_VictorySound = USERSOUND:New( "outro.ogg" )

-- When a zone is capture, 200 points are shared amoung contributors who captured the zone.

do -- Setup the Command Centers
  
  RU_CC = COMMANDCENTER:New( GROUP:FindByName( "REDHQ" ), "Russia HQ" )
  US_CC = COMMANDCENTER:New( GROUP:FindByName( "BLUEHQ" ), "USA HQ" )

end


do -- Setup the groups that can capture the zones

  US_ZoneCaptureGroupSet = SET_GROUP:New():FilterCoalitions("blue"):FilterStart()
  RU_ZoneCaptureGroupSet = SET_GROUP:New():FilterCoalitions("red"):FilterStart()

end


do -- Missions

  -- Setup the Scoring system.
  Scoring = SCORING:New( "Echo Bay Carrier Edition" )
  
  -- The US mission.
  US_Mission_EchoBay = MISSION:New( US_CC, "Echo Bay", "Primary",
    "Welcome Pilot. Echo Bay has been captured by enemy forces. We need to take it back.\n" ..
    "There are capture zones located in the small town of Echo Bay.\n" ..
    "Move to one of the capture zones, destroy the fuel tanks in the capture zone, " ..
    "and occupy each capture zone with a platoon.\n " .. 
    "Your orders are to hold position until all capture zones are taken.\n" ..
    "Use the map (F10) for a clear indication of the location of each capture zone.\n" ..
    "Note that heavy resistance can be expected!\n" ..
    "Mission 'Echo Bay' is complete when all capture zones are taken, and held for at least 5 minutes!"
    , coalition.side.RED)
    
  -- Connect the scoring to the US mission.
  US_Mission_EchoBay:AddScoring( Scoring )
  
  US_Mission_EchoBay:Start()

  RU_Mission_Rastov = MISSION:New( RU_CC, "Rastov", "Primary",
    "Welcome Pilot. The zones in Echo Bay needs to be protected and recaptured if taken.\n" ..
    "There are capture zones located in and around the town of Echo Bay.\n" ..
    "Move to one of the capture zones, destroy the fuel tanks in the capture zone, " ..
    "and occupy each capture zone with a platoon.\n " .. 
    "Your orders are to hold position until all capture zones are taken.\n" ..
    "Use the map (F10) for a clear indication of the location of each capture zone.\n" ..
    "Note that if we can destroy all the fuel tanks along the coast of Lake Mead towards their farp they will run out of resources!\n" ..
    "Mission 'Rastov' is complete when all fuel tanks along the coast are destroyed!"
    , coalition.side.BLUE)
    
  RU_Mission_Rastov:AddScoring( Scoring )
  
  RU_Mission_Rastov:Start()

end


do -- Setup the designation of targets for US

  local US_FAC = SET_GROUP:New():FilterPrefixes( "US_FAC" ):FilterOnce()
  local US_Detection = DETECTION_AREAS:New( US_FAC, 500 )
  US_Designate = DESIGNATE:New( US_CC, US_Detection, US_ZoneCaptureGroupSet, US_Mission_EchoBay )

end




-- These Spawn objects will be used to randomly spawn a new A2G_CAS plane when a zone has been captured from the Russian side.
RU_A2G_CAS_Spawn = {
  SPAWN:New( "RU_A2G_CAS_S #001" ):InitRandomizeTemplatePrefixes( "RU_A2G_CAS_T" ):InitLimit( 2, 12 ),
  SPAWN:New( "RU_A2G_CAS_S #002" ):InitRandomizeTemplatePrefixes( "RU_A2G_CAS_T" ):InitLimit( 2, 12 ),
  SPAWN:New( "RU_A2G_CAS_S #003" ):InitRandomizeTemplatePrefixes( "RU_A2G_CAS_T" ):InitLimit( 2, 12 ),
  SPAWN:New( "RU_A2G_CAS_S #004" ):InitRandomizeTemplatePrefixes( "RU_A2G_CAS_T" ):InitLimit( 2, 12 ),
  SPAWN:New( "RU_A2G_CAS_S #005" ):InitRandomizeTemplatePrefixes( "RU_A2G_CAS_T" ):InitLimit( 2, 12 ),
  SPAWN:New( "RU_A2G_CAS_S #006" ):InitRandomizeTemplatePrefixes( "RU_A2G_CAS_T" ):InitLimit( 2, 12 ),
  }

-- These Spawn objects will be used to automatically ensure that there are enough defenses on the Russian side on the zones.
RU_A2G_ARM_Spawn = {
  SPAWN:New( "RU_G2G_ARM_S #001" ):InitRandomizeTemplatePrefixes( "RU_G2G_ARM_T" ):InitLimit( 8, 12 ):InitRandomizeRoute( 3, 0, 1000 ),
  SPAWN:New( "RU_G2G_ARM_S #002" ):InitRandomizeTemplatePrefixes( "RU_G2G_ARM_T" ):InitLimit( 8, 12 ):InitRandomizeRoute( 3, 0, 1000 ),
  SPAWN:New( "RU_G2G_ARM_S #003" ):InitRandomizeTemplatePrefixes( "RU_G2G_ARM_T" ):InitLimit( 8, 12 ):InitRandomizeRoute( 3, 0, 1000 ),
}

local RU_ZoneCount = 13
local US_ZoneCount = 0

local ZoneRandom = 13

local US_ZoneNames = { "Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juilett","Kilo","Lima","Mike","November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-Ray","Yankee","Zulu",}
local RU_ZoneNames = { "Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juilett","Kilo","Lima","Mike","November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-Ray","Yankee","Zulu",}

local RU_ZonesCapture = {}

for RU_ZoneID = 1, RU_ZoneCount do
  RU_ZonesCapture[RU_ZoneID] = ZONE:New( "RU_CAPTURE_" .. RU_ZoneID )
  -- We keep the Zone ID for later reference to respawn the fuel tanks.
  RU_ZonesCapture[RU_ZoneID].ZoneID = RU_ZoneID
end


--local US_ZonesCapture = {}
--
--for US_ZoneID = 1, US_ZoneCount do
--  US_ZonesCapture[US_ZoneID] = ZONE:New( "US_CAPTURE_" .. US_ZoneID )
--  -- We keep the Zone ID for later reference to respawn the fuel tanks.
--  US_ZonesCapture[US_ZoneID].ZoneID = US_ZoneID
--end

--- Model the MISSION for RED

ZonesCaptureCoalition = {}
RU_FuelTanks = {}
US_FuelTanks = {}

for RU_ZoneID = 1, ZoneRandom do

  local RandomZoneID = math.random( 1, #RU_ZonesCapture )
  local RandomZoneNameID = math.random( 1, #RU_ZoneNames )
  local ZoneID = RU_ZonesCapture[RandomZoneID].ZoneID
  
  local ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( RU_ZonesCapture[RandomZoneID], coalition.side.RED ) 
  ZoneCaptureCoalition:GetZone():SetName( RU_ZoneNames[RandomZoneNameID] )
  
  RU_FuelTanks[ZoneID] = {}
  RU_FuelTanks[ZoneID][1] = SPAWNSTATIC:NewFromStatic( string.format( "FUEL_TANK #%03d-A", ZoneID ), country.id.RUSSIA )
  RU_FuelTanks[ZoneID][2] = SPAWNSTATIC:NewFromStatic( string.format( "FUEL_TANK #%03d-B", ZoneID ), country.id.RUSSIA )
  RU_FuelTanks[ZoneID][3] = SPAWNSTATIC:NewFromStatic( string.format( "FUEL_TANK #%03d-C", ZoneID ), country.id.RUSSIA )

  US_FuelTanks[ZoneID] = {}
  US_FuelTanks[ZoneID][1] = SPAWNSTATIC:NewFromStatic( string.format( "FUEL_TANK #%03d-A", ZoneID ), country.id.USA )
  US_FuelTanks[ZoneID][2] = SPAWNSTATIC:NewFromStatic( string.format( "FUEL_TANK #%03d-B", ZoneID ), country.id.USA )
  US_FuelTanks[ZoneID][3] = SPAWNSTATIC:NewFromStatic( string.format( "FUEL_TANK #%03d-C", ZoneID ), country.id.USA )
  
  
  table.insert( ZonesCaptureCoalition, ZoneCaptureCoalition )
  
  table.remove( RU_ZonesCapture, RandomZoneID )
  table.remove( RU_ZoneNames, RandomZoneNameID )
end

--for US_ZoneID = 1, ZoneRandom do
--
--  local RandomZoneID = math.random( 1, #US_ZonesCapture )
--  local RandomZoneNameID = math.random( 1, #US_ZoneNames )
--  
--  local ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( US_ZonesCapture[RandomZoneID], coalition.side.BLUE )
--  ZoneCaptureCoalition:GetZone():SetName( US_ZoneNames[RandomZoneNameID] )
--  table.insert( ZonesCaptureCoalition, ZoneCaptureCoalition )
--  
--  table.remove( US_ZonesCapture, RandomZoneID )
--  table.remove( US_ZoneNames, RandomZoneNameID )
--end

TasksRed = {}
TasksBlue = {}


for CaptureZoneID = 1, ZoneRandom do

  local ZoneCaptureCoalition = ZonesCaptureCoalition[CaptureZoneID] -- Functional.ZoneCaptureCoalition#ZONE_CAPTURE_COALITION
  
  --- @param Functional.ZoneCaptureCoalition#ZONE_CAPTURE_COALITION self
  function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
    if From ~= To then
      local Coalition = self:GetCoalition()
      self:E( { Coalition = Coalition } )
      if Coalition == coalition.side.BLUE then
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
        US_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        --TasksRed[ZoneCaptureCoalition] = TASK_ZONE_CAPTURE:New( RU_Mission_Rastov, RU_ZoneCaptureGroupSet, ZoneCaptureCoalition:GetZoneName(), ZoneCaptureCoalition )
        RU_CC:SetMenu()
      else
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
        RU_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        US_CC:MessageTypeToCoalition( string.format( "%s is under protection of Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        --TasksBlue[ZoneCaptureCoalition] = TASK_ZONE_CAPTURE:New( US_Mission_EchoBay, US_ZoneCaptureGroupSet, ZoneCaptureCoalition:GetZoneName(), ZoneCaptureCoalition )
        US_CC:SetMenu()
      end
    end
  end

  --- @param Functional.Protect#ZONE_CAPTURE_COALITION self
  function ZoneCaptureCoalition:OnEnterEmpty()
    ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
    US_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    RU_CC:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
  end
  
  
  --- @param Functional.Protect#ZONE_CAPTURE_COALITION self
  function ZoneCaptureCoalition:OnEnterAttacked()
    ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
    local Coalition = self:GetCoalition()
    self:E({Coalition = Coalition})
    if Coalition == coalition.side.BLUE then
      US_CC:MessageTypeToCoalition( string.format( "%s is under attack by Russia", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    else
      RU_CC:MessageTypeToCoalition( string.format( "%s is under attack by the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end
  end
  
  --- @param Functional.Protect#ZONE_CAPTURE_COALITION self
  function ZoneCaptureCoalition:OnEnterCaptured()
    local Coalition = self:GetCoalition()
    self:E({Coalition = Coalition})
    if Coalition == coalition.side.BLUE then
      RU_CC:MessageTypeToCoalition( string.format( "%s is captured by the USA, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      US_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      --TasksBlue[ZoneCaptureCoalition]:Remove()
      --TasksBlue[ZoneCaptureCoalition] = nil
      local ZoneID = ZoneCaptureCoalition:GetZone().ZoneID
      US_FuelTanks[ZoneID][1]:Spawn( 0 ) 
      US_FuelTanks[ZoneID][2]:Spawn( 0 )
      US_FuelTanks[ZoneID][3]:Spawn( 0 )
    else
      US_CC:MessageTypeToCoalition( string.format( "%s is captured by Russia, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RU_CC:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      --TasksRed[ZoneCaptureCoalition]:Remove()
      --TasksRed[ZoneCaptureCoalition] = nil
      local ZoneID = ZoneCaptureCoalition:GetZone().ZoneID
      RU_FuelTanks[ZoneID][1]:Spawn( 0 ) 
      RU_FuelTanks[ZoneID][2]:Spawn( 0 )
      RU_FuelTanks[ZoneID][3]:Spawn( 0 )
    end
    
    RU_A2G_CAS_Spawn[math.random(#RU_A2G_CAS_Spawn)]:Spawn()
    RU_A2G_ARM_Spawn[math.random(#RU_A2G_ARM_Spawn)]:Spawn()

    --self:AddScore( "Captured", "Zone captured: Extra points granted.", 200 )    

    local TotalContributions = ZoneCaptureCoalition.Goal:GetTotalContributions()
    local PlayerContributions = ZoneCaptureCoalition.Goal:GetPlayerContributions()
    self:E( { TotalContributions = TotalContributions, PlayerContributions = PlayerContributions } )
    for PlayerName, PlayerContribution in pairs( PlayerContributions ) do
      Scoring:AddGoalScorePlayer( PlayerName, "Zone " .. self.ZoneGoal:GetZoneName() .." captured", PlayerContribution * GoalScore / TotalContributions )
    end

    local AllBlueZonesGuarded = true
--    local AllRedZonesGuarded = true
    for ZoneID = 1, ZoneRandom do
      local ZoneCaptureCoalition = ZonesCaptureCoalition[ZoneID] -- Functional.ZoneCaptureCoalition#ZONE_CAPTURE_COALITION
      if not ZoneCaptureCoalition.Goal:IsAchieved() then
        if ZoneCaptureCoalition:GetCoalition() ~= coalition.side.BLUE then
          AllBlueZonesGuarded = false
        end
--        if ZoneCaptureCoalition:GetCoalition() ~= coalition.side.RED then
--          AllRedZonesGuarded = false
--        end
      end
    end

    if AllBlueZonesGuarded == true then
      US_Mission_EchoBay:Complete()
      FlagMissionEnd:Set( 1 )
      US_VictorySound:ToAll()
    end

--    if AllRedZonesGuarded == true then
--      RU_Mission_Rastov:Complete()
--      FlagMissionEnd:Set( 1 )
--      RU_VictorySound:ToAll()
--    end
    
    self:__Guard( 30 )
  end
  
  -- Create the tasks under the mission
  
  
  ZoneCaptureCoalition:__Guard( 1 )
  
end


-- Validate Blue Victory

--FF: changed zone name since US_Attack zone did not exist.
US_Attack = ZONE:New( "EchoBayAttackZone" )

BlueVictoryCheck = BASE:ScheduleRepeat( 30, 30, 0, nil,
  function()
    local AllBlueDestroyed = US_Attack:IsNoneInZoneOfCoalition( coalition.side.BLUE )
    if AllBlueDestroyed == true then
      RU_Mission_Rastov:Complete()
      FlagMissionEnd:Set( 1 )
      RU_VictorySound:ToAll()
    end
  end
)


-- RAT
local rat={}
rat.blue={}
rat.red={}

-- Disable ATC messages for all RAT objects.
RAT.ATC.messages=false
RAT.ATC.Nclearance=1

-- BLUE RAT
rat.blue.zones={"RAT Zone West Blue", "RAT Zone East Blue", "RAT Zone South Blue", "RAT Zone Center Blue"}
rat.blue.airports={"Jean Airport", "Laughlin Airport", "Boulder City Airport", "Henderson Executive Airport"}

-- C-130
rat.blue.C130={}

-- Blue zones to blue zones.
rat.blue.C130.Group01=RAT:New("RAT_C130", "C130 Group 01")
rat.blue.C130.Group01:SetTakeoff("air")
rat.blue.C130.Group01:SetDeparture(rat.blue.zones)
rat.blue.C130.Group01:DestinationZone()
rat.blue.C130.Group01:SetDestination(rat.blue.zones)
rat.blue.C130.Group01:ContinueJourney()
rat.blue.C130.Group01.f10menu=false
rat.blue.C130.Group01:Spawn(3)

-- F/A-18
rat.blue.F18={}

-- Blue zones to blue zones.
rat.blue.F18.Group01=RAT:New("RAT_F18", "F/A-18 Group 01")
rat.blue.F18.Group01:SetTakeoff("air")
rat.blue.F18.Group01:SetDeparture(rat.blue.zones)
rat.blue.F18.Group01:DestinationZone()
rat.blue.F18.Group01:SetDestination(rat.blue.zones)
rat.blue.F18.Group01:ContinueJourney()
rat.blue.F18.Group01.f10menu=false
rat.blue.F18.Group01:Spawn(3)

-- A-10C
rat.blue.A10={}

-- Blue Zones to blue airports.
rat.blue.A10.Group01=RAT:New("RAT_A10C", "A-10C Group 01")
rat.blue.A10.Group01:SetTakeoff("air")
rat.blue.A10.Group01:SetDeparture(rat.blue.zones)
rat.blue.A10.Group01:SetDestination(rat.blue.airports)
rat.blue.A10.Group01:RespawnAfterLanding(120)
rat.blue.A10.Group01.f10menu=false
rat.blue.A10.Group01:Spawn(3)

-- F-16
rat.blue.F16={}

-- Blue Zones to blue airports.
rat.blue.F16.Group01=RAT:New("RAT_F16", "F-16 Group 01")
rat.blue.F16.Group01:SetTakeoff("air")
rat.blue.F16.Group01:SetDeparture(rat.blue.zones)
rat.blue.F16.Group01:SetDestination(rat.blue.airports)
rat.blue.F16.Group01:RespawnAfterLanding(120)
rat.blue.F16.Group01.f10menu=false
rat.blue.F16.Group01:Spawn(3)


-- RED RAT
rat.red.zones={"RAT Zone West Red", "RAT Zone East Red", "RAT Zone North Red", "RAT Zone Center Red"}
rat.red.airports={"Nellis AFB", "Creech AFB", "Mesquite", "Groom Lake AFB", "Lincoln County"}

-- Tu-160
rat.red.TU160={}

-- Red zones to red zones.
rat.red.TU160.Group01=RAT:New("RAT_TU160", "Tu-160 Group 01")
rat.red.TU160.Group01:SetTakeoff("air")
rat.red.TU160.Group01:SetDeparture(rat.red.zones)
rat.red.TU160.Group01:DestinationZone()
rat.red.TU160.Group01:SetDestination(rat.red.zones)
rat.red.TU160.Group01:ContinueJourney()
rat.red.TU160.Group01.f10menu=false
rat.red.TU160.Group01:Spawn(3)

-- Su-27
rat.red.SU27={}

-- Red zones to red zones.
rat.red.SU27.Group01=RAT:New("RAT_SU25", "Su-27 Group 01")
rat.red.SU27.Group01:SetTakeoff("air")
rat.red.SU27.Group01:SetDeparture(rat.red.zones)
rat.red.SU27.Group01:DestinationZone()
rat.red.SU27.Group01:SetDestination(rat.red.zones)
rat.red.SU27.Group01:ContinueJourney()
rat.red.SU27.Group01.f10menu=false
rat.red.SU27.Group01:Spawn(3)

-- Su-25T
rat.red.SU25={}

-- Red zones to red airports.
rat.red.SU25.Group01=RAT:New("RAT_SU25", "Su-25T Group 01")
rat.red.SU25.Group01:SetTakeoff("air")
rat.red.SU25.Group01:SetDeparture(rat.red.zones)
rat.red.SU25.Group01:SetDestination(rat.red.airports)
rat.red.SU25.Group01:RespawnAfterLanding(120)
rat.red.SU25.Group01.f10menu=false
rat.red.SU25.Group01:Spawn(3)

-- MiG-25PD
rat.red.MIG25={}

-- Red Zones to red airports.
rat.red.MIG25.Group01=RAT:New("RAT_MIG25", "MiG-25PD Group 01")
rat.red.MIG25.Group01:SetTakeoff("air")
rat.red.MIG25.Group01:SetDeparture(rat.red.zones)
rat.red.MIG25.Group01:SetDestination(rat.red.airports)
rat.red.MIG25.Group01:RespawnAfterLanding(120)
rat.red.MIG25.Group01.f10menu=false
rat.red.MIG25.Group01:Spawn(3)


--local ATC_Ground = ATC_GROUND_NEVADA:New()
--ATC_Ground:SetKickSpeedKmph(70)