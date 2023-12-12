-----------------------------
------- Highbridge ----------
------- by Yume -------------
------- version 1.1 ---------
--[[
1.1 changelog
-- Updated the cliff to be less super high. 
-- Fixed teammates being split across the map in certain configurations. 
-- Fixed the naval trading posts being weird in certain configurations. 


]]

terrainLayoutResult = {}
-- mapRes = 40
gridHeight, gridWidth, gridSize = SetCoarseGrid()
-- gridHeight, gridWidth, gridSize = SetCustomCoarseGrid(mapRes)

if (gridHeight % 2 == 0) then
	gridHeight = gridHeight -1
end

if (gridWidth % 2 == 0) then
	gridWidth = gridWidth -1
end

gridSize = gridWidth
gridHalf = math.ceil(gridSize / 2)
mapHalfSize = math.ceil(gridSize/2)
mapQuarterSize = math.ceil(gridSize/4)
mapEighthSize = math.ceil(gridSize/8)


-- start map
debug = false
if debug then
	playerTeams = {}
	worldPlayerCount = 6
	playerTeams[1] = 1 --player 1 on team 1
	playerTeams[2] = 1 --player 2 on team 1
	playerTeams[3] = 2 --player 3 on team 2
	playerTeams[4] = 2 --player 4 on team 2
	playerTeams[5] = 3 --player 5 on team 3
	playerTeams[6] = 3 --player 6 on team 3
--	playerTeams[7] = 2 --player 7 on team 3
--	playerTeams[8] = 4 --player 8 on team 3
end



n = tt_none
h = tt_hills
s = tt_mountains_small
m = tt_mountains
i = tt_impasse_mountains
b = tt_hills_low_rolling
mr = tt_hills_med_rolling
hr = tt_hills_high_rolling
low = tt_plateau_low
med = tt_plateau_med
high = tt_plateau_high
c_l = tt_plateau_low
c_m = tt_plateau_med
p = tt_plains
t = tt_impasse_trees_plains
v = tt_valley
r = tt_river
o = tt_ocean
low_trees = tt_hills_light_forest

lake = tt_lake_medium_mediterranean
highbridge = tt_plateau_low

holysite = tt_holy_site_plateau_low
holysite_low = tt_holy_site_hill_danger_lite
settlement = tt_settlement_naval_lake

bountyGold = tt_tactical_region_gold_plateau_low_d
bountyStone = tt_tactical_region_stone_plateau_low_b


playerStartTerrain = tt_player_start_classic_plains
startBufferTerrain = tt_plains


-- fill grid default
terrainLayoutResult = SetUpGrid(gridSize, p, terrainLayoutResult)

------------------
--- FUNCTIONS ----
------------------

--draws a box starting from top left coordinates and expands down and to the right
--rowCoord is the top left row of where your box draw begins
--colCoord is the top left col of where your box draw begins
--rowSize how far down do you want to draw your box
--colSize how far across do you want to draw your box
--pickedTerrain the terrainType e.g. tt_lake_shallow
function drawBox(rowCoord, colCoord, rowSize, colSize, pickedTerrain)
    
    --checks to see if coords exist in table
    --used to prevent out of bounds areas from being set
    local function isInTable(searchTable, row, col)
        if (searchTable[row] ~= nil and searchTable[col] ~= nil) then
            result = true
        else
            result = false
        end
        return result
    end
    
    drawRowSize = rowCoord + rowSize - 1
    drawColSize = colCoord + colSize - 1
    
    for row = rowCoord, drawRowSize do
        for col = colCoord, drawColSize do
            if (isInTable(terrainLayoutResult, row, col)) then
                terrainLayoutResult[row][col].terrainType = pickedTerrain
            end
        end
    end
end

-- check the tile above and below given coords and returns true if either of those tiles are the given terrain.
function CheckVerticalNeighbours(rowCoord, colCoord, checkUp, checkDown, gridSize, terrainToCheckFor)
    
    terrainFound = false
    
    if checkUp then
        if IsInMap(rowCoord + 1, colCoord, gridSize, gridSize) and terrainLayoutResult[rowCoord + 1][colCoord].terrainType == terrainToCheckFor then
            terrainFound = true
        end 
    end
    if checkDown then
        if IsInMap(rowCoord - 1, colCoord, gridSize, gridSize) and terrainLayoutResult[rowCoord - 1][colCoord].terrainType == terrainToCheckFor then
            terrainFound = true
        end 
    end
    return terrainFound
end

-- check the tile right and left of given coords and returns true if either of those tiles are the given terrain.
function CheckHorizontalNeighbours(rowCoord, colCoord, checkUp, checkDown, gridSize, terrainToCheckFor)
    
    terrainFound = false
    
    if checkUp then
        if IsInMap(rowCoord, colCoord + 1, gridSize, gridSize) and terrainLayoutResult[rowCoord][colCoord + 1].terrainType == terrainToCheckFor then
            terrainFound = true
        end 
    end
    if checkDown then
        if IsInMap(rowCoord, colCoord - 1, gridSize, gridSize) and terrainLayoutResult[rowCoord][colCoord - 1].terrainType == terrainToCheckFor then
            terrainFound = true
        end 
    end
    return terrainFound
end

-- check the 4 immediate neighbours and return true if any match terrain to check for
function Check4Neighbours(rowCoord, colCoord, gridSize, terrainToCheckFor)
    
    terrainFound = false
    
    if IsInMap(rowCoord + 1, colCoord, gridSize, gridSize) and terrainLayoutResult[rowCoord + 1][colCoord].terrainType == terrainToCheckFor then
            terrainFound = true
    elseif IsInMap(rowCoord - 1, colCoord, gridSize, gridSize) and terrainLayoutResult[rowCoord - 1][colCoord].terrainType == terrainToCheckFor then
        terrainFound = true
    elseif IsInMap(rowCoord, colCoord + 1, gridSize, gridSize) and terrainLayoutResult[rowCoord][colCoord + 1].terrainType == terrainToCheckFor then
        terrainFound = true
    elseif IsInMap(rowCoord, colCoord - 1, gridSize, gridSize) and terrainLayoutResult[rowCoord][colCoord - 1].terrainType == terrainToCheckFor then
        terrainFound = true
    end
    return terrainFound
end

-----------------
-- BUILD MAP!! --
-----------------
-- select map rotation
if worldGetRandom() <= 0.5 then
    mapDir = 0 -- vertical higbridge 
else
    mapDir = 1 -- horizontal highbridge
end

-- Select map size variables

--defaults

    
    playerStripThickness = 5
    highbridgeEdgeBuffer = 2
    highbridgeThickness = 4 
    highBridgeHalf = math.ceil(highbridgeThickness / 2)
    terrainChance = 0.2
    
--select
if(worldTerrainWidth <= 417) then
    -- Micro
    highbridgeThickness = 3 
    highBridgeHalf = math.ceil(highbridgeThickness / 2) - 1
    
    
    bountyGold = tt_tactical_region_gold_plateau_low_b
    bountyStone = tt_tactical_region_stone_plateau_low_a

elseif(worldTerrainWidth <= 513) then
    -- Small
    highbridgeThickness = 3 
    highBridgeHalf = math.ceil(highbridgeThickness / 2) - 1
    
    bountyGold = tt_tactical_region_gold_plateau_low_a
    bountyStone = tt_tactical_region_stone_plateau_low_b
    
elseif(worldTerrainWidth <= 641) then
    -- Medium
    highbridgeThickness = 3 
    highBridgeHalf = math.ceil(highbridgeThickness / 2) - 1
    
    
    
elseif(worldTerrainWidth <= 769) then
    -- Large
    playerStripThickness = 6
    highbridgeEdgeBuffer = 3
    highbridgeThickness = 5 
    highBridgeHalf = math.ceil(highbridgeThickness / 2) - 1

else
    -- giagantic
    playerStripThickness = 7
    highbridgeEdgeBuffer = 4
    highbridgeThickness = 6 
    highBridgeHalf = math.ceil(highbridgeThickness / 2)
    
    bountyGold = tt_tactical_region_gold_plateau_low_e
    bountyStone = tt_tactical_region_stone_plateau_low_c

end




-- DRAW MAP --
--------------

if mapDir == 0 then
    --vertical
    
    -- determine lakes start from variables    
    lakeStartSquare = {playerStripThickness + 1, 1}
    lakeRows = gridSize - playerStripThickness * 2
    lakeCols = gridSize
    lakeEndSquare = {lakeStartSquare[1] + lakeRows - 1, lakeStartSquare[2] + lakeCols - 1}
       
    --lake 
    drawBox(lakeStartSquare[1], lakeStartSquare[2], lakeRows, lakeCols, lake)
    -- bridge
    drawBox(highbridgeEdgeBuffer + 1, mapHalfSize - highBridgeHalf, gridSize - highbridgeEdgeBuffer * 2, highbridgeThickness, highbridge)

elseif mapDir == 1 then
     -- horizontal
    
    -- determine lakes start from variables    
    lakeStartSquare = {1, playerStripThickness + 1}
    lakeRows = gridSize 
    lakeCols = gridSize - playerStripThickness * 2
    lakeEndSquare = {lakeStartSquare[1] + lakeRows - 1, lakeStartSquare[2] + lakeCols - 1}
    
    --lake
    drawBox(lakeStartSquare[1], lakeStartSquare[2], lakeRows, lakeCols, lake)
    -- bridge
    drawBox(mapHalfSize - highBridgeHalf, highbridgeEdgeBuffer + 1, highbridgeThickness, gridSize - highbridgeEdgeBuffer * 2, highbridge)

end


-- check all the highbridge squares to make ramps at the end
for row = 1, gridSize do
	for col = 1, gridSize do
		if (terrainLayoutResult[row][col].terrainType == highbridge) then
			
			-- check if there is plains directly above or below
			if mapDir == 0 then
    			if CheckVerticalNeighbours(row, col, true, true, gridSize, p) then
    			    terrainLayoutResult[row][col].terrainType = hr
    			end
			elseif mapDir == 1 then
	            if CheckHorizontalNeighbours(row, col, true, true, gridSize, p) then
    			    terrainLayoutResult[row][col].terrainType = hr
    			end
	        end
			
		end
	end
end

-- Go over all the plains tiles and populate them with other terrain types randomly
for row = 1, gridSize do
	for col = 1, gridSize do
		if (terrainLayoutResult[row][col].terrainType == p) then
			    isBeach = false
			    -- check if this tile is a beach
			    if mapDir == 0 then
        			if CheckVerticalNeighbours(row, col, true, true, gridSize, lake) then
            			   isBeach = true
    					terrainLayoutResult[row][col].terrainType = tt_beach
    			    end
			    elseif mapDir == 1 then
           			if CheckHorizontalNeighbours(row, col, true, true, gridSize, lake) then
            			   isBeach = true
					    terrainLayoutResult[row][col].terrainType = tt_beach 
					end
		        end
			-- only run this check on non-beach tiles
			if (worldGetRandom() < terrainChance and isBeach == false) then
				terrainLayoutResult[row][col].terrainType = b
			elseif (worldGetRandom() < terrainChance and isBeach == false) then
			    terrainLayoutResult[row][col].terrainType = low_trees
			end
		end
	end
end

-- find settlement locations
settlement1pos = {}
settlement2pos = {}

if mapDir == 0 then
    --vertical higbridge
    settlement1pos[1] = lakeStartSquare[1]
    settlement1pos[2] = math.ceil(GetRandomInRange(lakeStartSquare[2] - 1, lakeStartSquare[2] + 1))
       
    settlement2pos[1] = lakeEndSquare[1]
    settlement2pos[2] = gridSize - settlement1pos[2] + 1

    terrainLayoutResult[settlement1pos[1]][settlement1pos[2]].terrainType = settlement
    terrainLayoutResult[settlement2pos[1]][settlement2pos[2]].terrainType = settlement
    

    
elseif mapDir == 1 then
   -- horizontal highbridge 
   
    settlement1pos[1] = math.ceil(GetRandomInRange(lakeStartSquare[1] - 1, lakeStartSquare[1] + 1))
    settlement1pos[2] = lakeStartSquare[2]
       
    settlement2pos[1] = gridSize - settlement1pos[1] + 1
    settlement2pos[2] = lakeEndSquare[2]

    terrainLayoutResult[settlement1pos[1]][settlement1pos[2]].terrainType = settlement
    terrainLayoutResult[settlement2pos[1]][settlement2pos[2]].terrainType = settlement
end


--Holy sites
-- directly in middle

holySite1Pos = {mapHalfSize, mapHalfSize}
holySite2Pos = {}
holySite3Pos = {}

if mapDir == 0 then
    --vertical higbridge
    holySite2Pos[1] = lakeStartSquare[1] - 1
    holySite2Pos[2] = gridSize - math.ceil(GetRandomInRange(lakeStartSquare[2] - 1, lakeStartSquare[2] + 1))
    
    holySite3Pos[1] = lakeEndSquare[1] + 1
    holySite3Pos[2] = gridSize - holySite2Pos[2] + 1
    

    
    terrainLayoutResult[holySite1Pos[1]][holySite1Pos[2]].terrainType = holysite
    terrainLayoutResult[holySite2Pos[1]][holySite2Pos[2]].terrainType = holysite_low
    terrainLayoutResult[holySite3Pos[1]][holySite3Pos[2]].terrainType = holysite_low
elseif mapDir == 1 then
   -- horizontal highbridge
    holySite2Pos[1] = gridSize - math.ceil(GetRandomInRange(lakeStartSquare[1] - 1, lakeStartSquare[1] + 1))
    holySite2Pos[2] = lakeStartSquare[2] - 1
    
    holySite3Pos[1] = math.ceil(GetRandomInRange(lakeStartSquare[1], lakeStartSquare[1] + 2))
    holySite3Pos[2] = lakeEndSquare[2] + 1
    
    terrainLayoutResult[holySite1Pos[1]][holySite1Pos[2]].terrainType = holysite
    terrainLayoutResult[holySite2Pos[1]][holySite2Pos[2]].terrainType = holysite_low
    terrainLayoutResult[holySite3Pos[1]][holySite3Pos[2]].terrainType = holysite_low
end



-- Resource Bounties
-- near middle

bountyGoldPos = {}
bountyStonePos = {}

if mapDir == 0 then
    --vertical higbridge
    bountyGoldPos[1] = math.ceil(GetRandomInRange(mapHalfSize - 2, mapHalfSize + 1))
    bountyGoldPos[2] = mapHalfSize - 1
    
    bountyStonePos[1] = math.ceil(GetRandomInRange(mapHalfSize - 2, mapHalfSize + 1))
    bountyStonePos[2] = mapHalfSize + 1
    
elseif mapDir == 1 then
   -- horizontal highbridge 
    bountyGoldPos[1] = mapHalfSize - 1
    bountyGoldPos[2] = math.ceil(GetRandomInRange(mapHalfSize - 2, mapHalfSize + 1))
    
    bountyStonePos[1] = mapHalfSize + 1
    bountyStonePos[2] = math.ceil(GetRandomInRange(mapHalfSize - 2, mapHalfSize + 1))
end

terrainLayoutResult[bountyGoldPos[1]][bountyGoldPos[2]].terrainType = bountyGold
terrainLayoutResult[bountyStonePos[1]][bountyStonePos[2]].terrainType = bountyStone
-------------------
-- PLACE PLAYERS --
-------------------
teamsList, playersPerTeam = SetUpTeams()
teamMappingTable = CreateTeamMappingTable()

innerExclusion = 0.4
minPlayerDistance = 3.5

minTeamDistance =  8
edgeBuffer = 1
cornerThreshold = 1
isVertical = false

impasseTypes = {}
table.insert(impasseTypes, settlement)
table.insert(impasseTypes, tt_beach)
table.insert(impasseTypes, hr)
table.insert(impasseTypes, highbridge)
table.insert(impasseTypes, c)
table.insert(impasseTypes, lake)
table.insert(impasseTypes, holysite_low)
table.insert(impasseTypes, tt_none)

impasseBuffer = 2.5
topSelectionThreshold = 0.4

startBufferRadius = 2
placeStartBuffer = true

if(#teamMappingTable == 2) then
    if mapDir == 0 then
        --vertical higbridge
        isVertical = false
	    terrainLayoutResult = PlacePlayerStartsDivided(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, isVertical, impasseTypes, 1, topSelectionThreshold, playerStartTerrain, startBufferTerrain, 1.5, true, terrainLayoutResult)
    elseif mapDir == 1 then
       -- horizontal highbridge 
        isVertical = true
	    terrainLayoutResult = PlacePlayerStartsDivided(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, isVertical, impasseTypes, 1, topSelectionThreshold, playerStartTerrain, startBufferTerrain, 1.5, true, terrainLayoutResult)
        
   end
else
	minPlayerDistance = 2
	terrainLayoutResult = PlacePlayerStartsRing(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, impasseTypes, 1, 0.05, playerStartTerrain, startBufferTerrain, 1.5, true, terrainLayoutResult)
end









































































