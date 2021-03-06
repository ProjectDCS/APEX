_SETTINGS:SetPlayerMenuOff()
----------------------------------------------------------------------------
----------------------------------------------------------------------------
do
    -- declare local variables
    --// exportstring( string )
    --// returns a "Lua" portable version of the string
    local function exportstring( s )
       return string.format("%q", s)
    end
 
    --// The Save Function
    function table.save(  tbl,filename )
       local charS,charE = "   ","\n"
       local file,err = io.open( filename, "wb" )
       if err then return err end
 
       -- initiate variables for save procedure
       local tables,lookup = { tbl },{ [tbl] = 1 }
       file:write( "return {"..charE )
 
       for idx,t in ipairs( tables ) do
          file:write( "-- Table: {"..idx.."}"..charE )
          file:write( "{"..charE )
          local thandled = {}
 
          for i,v in ipairs( t ) do
             thandled[i] = true
             local stype = type( v )
             -- only handle value
             if stype == "table" then
                if not lookup[v] then
                   table.insert( tables, v )
                   lookup[v] = #tables
                end
                file:write( charS.."{"..lookup[v].."},"..charE )
             elseif stype == "string" then
                file:write(  charS..exportstring( v )..","..charE )
             elseif stype == "number" then
                file:write(  charS..tostring( v )..","..charE )
             end
          end
 
          for i,v in pairs( t ) do
             -- escape handled values
             if (not thandled[i]) then
             
                local str = ""
                local stype = type( i )
                -- handle index
                if stype == "table" then
                   if not lookup[i] then
                      table.insert( tables,i )
                      lookup[i] = #tables
                   end
                   str = charS.."[{"..lookup[i].."}]="
                elseif stype == "string" then
                   str = charS.."["..exportstring( i ).."]="
                elseif stype == "number" then
                   str = charS.."["..tostring( i ).."]="
                end
             
                if str ~= "" then
                   stype = type( v )
                   -- handle value
                   if stype == "table" then
                      if not lookup[v] then
                         table.insert( tables,v )
                         lookup[v] = #tables
                      end
                      file:write( str.."{"..lookup[v].."},"..charE )
                   elseif stype == "string" then
                      file:write( str..exportstring( v )..","..charE )
                   elseif stype == "number" then
                      file:write( str..tostring( v )..","..charE )
                   end
                end
             end
          end
          file:write( "},"..charE )
       end
       file:write( "}" )
       file:close()
    end
    
    --// The Load Function
    function table.load( sfile )
       local ftables,err = loadfile( sfile )
       if err then return _,err end
       local tables = ftables()
       for idx = 1,#tables do
          local tolinki = {}
          for i,v in pairs( tables[idx] ) do
             if type( v ) == "table" then
                tables[idx][i] = tables[v[1]]
             end
             if type( i ) == "table" and tables[i[1]] then
                table.insert( tolinki,{ i,tables[i[1]] } )
             end
          end
          -- link indices
          for _,v in ipairs( tolinki ) do
             tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
          end
       end
       return tables[1]
    end
 -- close do
 end
----------------------------------------------------------------------------
----------------------------------------------------------------------------


----------------------------------------------------------------------------
----------------------------------------------------------------------------

----------------------------------------------------------------------------
----------------------------------------------------------------------------

ConquestPersistenceStore = {}
local zoneFileName = "Frontlines.lua"
local zoneFilePath = lfs.writedir() .. zoneFileName
env.info(string.format("CON: Persisted path %s", zoneFilePath))


local someTable = {
    ["Coast"] = {
        [1] = {
            ["ZoneName"] = "Red Capture Zone #1",
            ["Coalition"] = 1,
        },
        [2] = {
            ["ZoneName"] = "Red Capture Zone #2",
            ["Coalition"] = 1,
        },
        [3] = {
            ["ZoneName"] = "Red Capture Zone #3",
            ["Coalition"] = 1,
        },
        [4] = {
            ["ZoneName"] = "Red Capture Zone #4",
            ["Coalition"] = 1,
        },
        [5] = {
            ["ZoneName"] = "Blue Capture Zone #4",
            ["Coalition"] = 2,
        },
        [6] = {
            ["ZoneName"] = "Blue Capture Zone #3",
            ["Coalition"] = 2,
        },
        [7] = {
            ["ZoneName"] = "Blue Capture Zone #2",
            ["Coalition"] = 2,
        },
        [8] = {
            ["ZoneName"] = "Blue Capture Zone #1",
            ["Coalition"] = 2,
        },
    },
    -- sample below
    ["AAAAA"] = 3,
    ["Resources"] = {
        ["tank"] = 10,
        ["arty"] = 10,
        ["apc"] = 10,
        ["repair"] = 10,
        ["result"] = 234356
    },
    ["Support"] = {
        ["Helos"] = 2
    }
}


--------------------------------------------------------------------------------------------
-- Persistence engine core -----------------------------------------------------------------
function readOrCreateZoneFile(stopLoop)
    local zoneFileTable,error = table.load( zoneFilePath )
    if not zoneFileTable and not stopLoop then
        env.info(string.format("CON: no file error %s, creating one from source", error))
        saveZoneFile(someTable)

        return readOrCreateZoneFile(true)
    else
        env.info(string.format("CON: We found a persisted table, using it "))
    end
    return zoneFileTable
end
function saveZoneFile(zoneTableToSave)
    table.save(zoneTableToSave, zoneFilePath)
   --  env.info("CON: Persistence Save file complete")
end

function startPersistenceEngine(something)
    local persistedTable = readOrCreateZoneFile(false)
    if not persistedTable then
        env.info(string.format("CON: ERROR can't read or create persisted file"))
        return
    end
    ConquestPersistenceStore = persistedTable
end

function savePersistenceEngine(something)
    saveZoneFile(ConquestPersistenceStore)
end
SCHEDULER:New(nil, startPersistenceEngine, {"something"}, 1)
SCHEDULER:New(nil, savePersistenceEngine, {"something"}, 30, 160)