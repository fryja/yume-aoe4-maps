-----------------------------
------- Drowned Forest  ----------
------- by Yume -------------
------- version 1.0 ---------
--[[
1.0
- Release

]]

terrainLayoutResult = {}
mapRes = 20
gridHeight, gridWidth, gridSize = SetCustomCoarseGrid(mapRes)

if (gridHeight % 2 == 0) then
	gridHeight = gridHeight -1
end

if (gridWidth % 2 == 0) then
	gridWidth = gridWidth -1
end

gridSize = gridWidth
gridHalf = math.ceil(gridSize / 2)
gridThird = math.ceil(gridSize / 3)
gridQuarter = math.ceil(gridSize/4)
mapHalfSize = math.ceil(gridSize/2)
mapQuarterSize = math.ceil(gridSize/4)
mapEighthSize = math.ceil(gridSize/8)
mapSizeSetting = 1

-- start map
debug = false
if debug then
	playerTeams = {}
	worldPlayerCount = 6
	playerTeams[1] = 1 --player 1 on team 1
	playerTeams[2] = 1 --player 2 on team 1
	playerTeams[3] = 1 --player 3 on team 2
	playerTeams[4] = 2 --player 4 on team 2
	playerTeams[5] = 2 --player 5 on team 3
	playerTeams[6] = 2 --player 6 on team 3
--	playerTeams[7] = 2 --player 7 on team 3
--	playerTeams[8] = 4 --player 8 on team 3
end


t_p =  tt_plateau_low
t_n = tt_none
t_h = tt_hills
t_m = tt_mountains
t_river = tt_flatland
t_forest = tt_none
t_flat = tt_flatland
t_water = tt_ocean
t_forest_edge = tt_forest_plateau_low_natural_small
t_forest_edge_stealth = tt_stealth_plateau_low_natural_small

t_plateau = tt_plateau_low
t_valley = tt_valley_shallow

t_trade = tt_settlement_hills_wveg
t_holySite_mid = tt_holy_site_valley_danger
t_holySite_outer = tt_holy_site_hill_danger_lite

playerStartTerrain = tt_player_start_classic_hills_gentle_no_tertiary_wood
startBufferTerrain = t_h

bonusStone = tt_tactical_region_stone_plateau_low_a
bonusGold = tt_tactical_region_gold_plateau_low_c


-- fill grid default
terrainLayoutResult = SetUpGrid(gridSize, t_p, terrainLayoutResult)

------------------
--- FUNCTIONS ----
------------------

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

--draws a circle that is filled
function drawCircle(centerCoord, radius, terrainType)
    local function circleFill(centerCoord, tileCoord, radius)
        dx = centerCoord.row - tileCoord.row
        dy = centerCoord.col - tileCoord.col
        distanceSquared = (dx*dx) + (dy*dy)
        return distanceSquared <= radius*radius
    end
    
    for row = 1, gridSize do
        for col = 1, gridSize do
            local tileCoord = { row = row, col = col }
            if (circleFill(centerCoord, tileCoord, radius)) then
                 terrainLayoutResult[row][col].terrainType = terrainType
        end
    end
end 
end

--draws random tiles at given rate in circle
function drawRandomInCircle(centerCoord, radius, terrainType, chance)
    local function circleFill(centerCoord, tileCoord, radius)
        dx = centerCoord.row - tileCoord.row
        dy = centerCoord.col - tileCoord.col
        distanceSquared = (dx*dx) + (dy*dy)
        return distanceSquared <= radius*radius
    end
    
    for row = 1, gridSize do
        for col = 1, gridSize do
            local tileCoord = { row = row, col = col }
            if (circleFill(centerCoord, tileCoord, radius)) and (worldGetRandom() < chance) then
                 terrainLayoutResult[row][col].terrainType = terrainType
        end
    end
end 
end


function mirrorTile(row, col, gridSize)
    local newRow = 0
    local newCol = 0

    
    newRow = gridSize - row + 1
    newCol = gridSize - col + 1
    
    terrainLayoutResult[newRow][newCol].terrainType = terrainLayoutResult[row][col].terrainType
end

function searchDiagonally(startRow, startCol, rowIteration, colIteration, failRadius, terrainToFind1, terrainToFind2)
    local foundBank = false
    local currentRow = startRow
    local currentCol = startCol
    local iterations = 0
    local locationFound = {}
    repeat
    	if (terrainLayoutResult[currentRow][currentCol].terrainType == terrainToFind1 or terrainLayoutResult[currentRow][currentCol].terrainType == terrainToFind2) then
            foundBank = true
    	else
    		currentRow = currentRow + rowIteration
    		currentCol = currentCol + colIteration
    	end
    	iterations = iterations + 1
    until(foundBank == true or currentRow >= gridSize or currentCol >= gridSize or currentRow <= 1 or currentCol <= 1 or iterations == math.ceil(failRadius))
    
    locationFound = {currentRow, currentCol}
    return locationFound
end

-----------------
-- BUILD MAP!! --
-----------------

if worldGetRandom() < 0.5 then
    mapRotate = true
else
    mapRotate = false  
end



-- Map Vars
minPlayerDistance = 3
minTeamDistance =  20

drownedForestRadius = 5
nonForestChance = 0.1
thickForestRadius = 1
thickForestChance = 0.45


--Set up Variables for MapSize
if(worldTerrainWidth <= 417) then
    -- Micro


elseif(worldTerrainWidth <= 513) then
    -- Small

	
elseif(worldTerrainWidth <= 641) then
    -- Medium
    drownedForestRadius = 6.5
    
    bonusStone = tt_tactical_region_stone_plateau_low_a
    bonusGold = tt_tactical_region_gold_plateau_low_c


    
elseif(worldTerrainWidth <= 769) then
    -- Large
    drownedForestRadius = 7.5 
    thickForestRadius = 2
    thickForestChance = 0.5
    
    bonusStone = tt_tactical_region_stone_plateau_low_c
    bonusGold = tt_tactical_region_gold_plateau_low_c
else
    -- giagantic
    drownedForestRadius = 9 
    thickForestRadius = 2
    thickForestChance = 0.5
    
    
    bonusStone = tt_tactical_region_stone_plateau_low_c
    bonusGold = tt_tactical_region_gold_plateau_low_e
end







-- RIVERS --

--drawCircle({row = gridHalf, col = gridHalf}, forestRadius, t_flat)

--drawBox(1, gridHalf - 1, gridSize, 3, t_flat)
--drawRandomInCircle({row = gridHalf, col = gridHalf}, forestRadius, t_forest, 0.5)


riverResult = {}
fordResults = {}

riverPoints = {}



riverStartPoint = math.floor(GetRandomInRange(gridThird, gridSize - gridThird))
riverEndPoint = gridSize - riverStartPoint

if(worldTerrainWidth <= 417) then
    riverStartPoint = math.floor(GetRandomInRange(gridHalf - 1, gridHalf + 1))
    riverEndPoint = gridSize - riverStartPoint
end


if mapRotate then
    --riverPoints = DrawLineOfTerrainReturn(startRow, startColumn, endRow, endColumn, terrainForSquare, meander, gridSize)
    riverPoints = DrawLineOfTerrainReturn(1, riverStartPoint, gridSize, riverEndPoint, t_water, false, gridSize)
    isVertical = true
else
    riverPoints = DrawLineOfTerrainReturn(riverStartPoint, 1, riverEndPoint, gridSize, t_water, false, gridSize)   
    isVertical = false
end
-- table.insert(riverResult, 1, riverPoints)


--- PLACE FORDS ---
--[[
numFords = 3
fordTable = {}
fordPoint1 = math.ceil(#riverResult[1] / numFords) 
fordPoint2 = math.ceil(#riverResult[1] / 2)
fordPoint3 = math.ceil(#riverResult[1] -  #riverResult[1] / numFords) 

table.insert(fordTable, riverResult[1][fordPoint1])
table.insert(fordTable, riverResult[1][fordPoint2])
table.insert(fordTable, riverResult[1][fordPoint3])
table.insert(fordResults, fordTable)
]]

-- FOREST --
riverThird = math.floor(#riverPoints / 3)
riverTwoThirds = riverThird * 2

riverFifth = math.floor(#riverPoints / 5)
riverFourFifths = riverFifth * 4

-- thicken the river
for i, currentRiverPoint in ipairs(riverPoints) do
	local row = currentRiverPoint[1]
	local col = currentRiverPoint[2]
	
	radius = 1
        
    if i > riverFifth and i <= riverFourFifths then
         terrainLayoutResult[currentRiverPoint[1]][currentRiverPoint[2]].terrainType = t_flat
    else
    	local tilesInRadius = GetAllSquaresInRadius(row, col, radius, terrainLayoutResult)
        
        for k, currentTile in ipairs(tilesInRadius) do
            terrainLayoutResult[currentTile[1]][currentTile[2]].terrainType = t_water
        end  
    end
	
	-- terrainLayoutResult[row][col].terrainType = tt_river
	
end

-- paint a big forest around the middle part of the river
for i, currentRiverPoint in ipairs(riverPoints) do
	local row = currentRiverPoint[1]
	local col = currentRiverPoint[2]
	
	radius = GetRandomInRange(drownedForestRadius - 1, drownedForestRadius+ 1)
	
	if i > riverThird and i <= riverTwoThirds then
        
        tilesInRadius = GetAllSquaresInRadius(row, col, radius, terrainLayoutResult)
        for k, currentTile in ipairs(tilesInRadius) do
            if terrainLayoutResult[currentTile[1]][currentTile[2]].terrainType ~= t_water then
                terrainLayoutResult[currentTile[1]][currentTile[2]].terrainType = t_forest
            end
        end        

	end
	
end

-- find the edges of the drowned forest and add a border of regular trees
drownedForestTiles = GetSquaresOfTypes({t_forest}, gridSize, terrainLayoutResult)
for i, forestTile in ipairs(drownedForestTiles) do
	local row = forestTile[1]
	local col = forestTile[2]
	  

	    
        local tilesInRadius = GetAllSquaresInRadius(row, col, thickForestRadius, terrainLayoutResult)
        for k, currentTile in ipairs(tilesInRadius) do
            -- if that terrain type is the regular terrain
            if terrainLayoutResult[currentTile[1]][currentTile[2]].terrainType == t_p then
                -- set it to thick forest
                if worldGetRandom () < thickForestChance then
                    terrainLayoutResult[currentTile[1]][currentTile[2]].terrainType = t_forest_edge
                else
                    terrainLayoutResult[currentTile[1]][currentTile[2]].terrainType = t_forest_edge_stealth
                end
            end
        end 
	
end


-- randomly populate the drowned forest with a few non-forest tiles
for row = 1, gridSize do
	for col = 1, gridSize do
		if (terrainLayoutResult[row][col].terrainType == t_forest) then
		    if (worldGetRandom() < nonForestChance) then
		      terrainLayoutResult[row][col].terrainType = t_river  
		    end
		    
		end
	end
end




-------------------
-- PLACE MAP FEATURES --
-------------------

-- Holy Site Mid
holySiteLoc1 = {riverPoints[math.ceil(#riverPoints/2)][1], riverPoints[math.ceil(#riverPoints/2)][2]}



holySiteBufferRadius = 1
tradePostCornerBuffer = 0
bonusGoldCornerBuffer = 2

bonusGoldLoc1 = {}
bonusGoldLoc2 = {}

drawCircle({row = holySiteLoc1[1], col = holySiteLoc1[2]}, holySiteBufferRadius, t_p)
terrainLayoutResult[holySiteLoc1[1]][holySiteLoc1[2]].terrainType = t_holySite_mid

if worldPlayerCount == 2 then
    --draw line from centre holySite diagonally out until it hits the edge of the lake
    holySiteLoc2 = searchDiagonally(holySiteLoc1[1], holySiteLoc1[2], -1, 1, drownedForestRadius, t_forest_edge, t_forest_edge_stealth)
    --draw line from centre holySite diagonally out until it hits the edge of the lake
    holySiteLoc3 = searchDiagonally(holySiteLoc1[1], holySiteLoc1[2], 1, -1, drownedForestRadius, t_forest_edge, t_forest_edge_stealth)

    tradePostLoc1 = {gridSize - tradePostCornerBuffer, 1 + tradePostCornerBuffer}
    tradePostLoc2 = {1 + tradePostCornerBuffer, gridSize - tradePostCornerBuffer}
    
    bonusGoldLoc1 = {gridSize - bonusGoldCornerBuffer, 1 + bonusGoldCornerBuffer}
    bonusGoldLoc2 = {1 + bonusGoldCornerBuffer, gridSize - bonusGoldCornerBuffer}


else


    --draw line from centre holySite diagonally out until it hits the edge of the lake
    holySiteLoc2 = searchDiagonally(holySiteLoc1[1], holySiteLoc1[2], 1, 1, drownedForestRadius, t_forest_edge, t_forest_edge_stealth)
    --draw line from centre holySite diagonally out until it hits the edge of the lake
    holySiteLoc3 = searchDiagonally(holySiteLoc1[1], holySiteLoc1[2], -1, -1, drownedForestRadius, t_forest_edge, t_forest_edge_stealth)

    tradePostLoc1 = {1 + tradePostCornerBuffer, 1 + tradePostCornerBuffer}
    tradePostLoc2 = {gridSize - tradePostCornerBuffer, gridSize - tradePostCornerBuffer}
    
    bonusGoldLoc1 = {1 + bonusGoldCornerBuffer, 1 + bonusGoldCornerBuffer}
    bonusGoldLoc2 = {gridSize - bonusGoldCornerBuffer, gridSize - bonusGoldCornerBuffer}



end  

--Holy Site Outer 2

--holySiteLoc2 = {holySiteOuterCornerBuffer, gridSize - holySiteOuterCornerBuffer}
--holySiteLoc3 = {gridSize - holySiteOuterCornerBuffer, holySiteOuterCornerBuffer)



   
terrainLayoutResult[holySiteLoc2[1]][holySiteLoc2[2]].terrainType = t_holySite_outer
terrainLayoutResult[holySiteLoc3[1]][holySiteLoc3[2]].terrainType = t_holySite_outer


hillsRadius = 3.5
drawCircle({row = tradePostLoc1[1], col = tradePostLoc1[2]}, hillsRadius, t_h) 
drawCircle({row = tradePostLoc2[1], col = tradePostLoc2[2]}, hillsRadius, t_h) 

terrainLayoutResult[tradePostLoc1[1]][tradePostLoc1[2]].terrainType = t_trade
terrainLayoutResult[tradePostLoc2[1]][tradePostLoc2[2]].terrainType = t_trade

terrainLayoutResult[bonusGoldLoc1[1]][bonusGoldLoc1[2]].terrainType = bonusGold
terrainLayoutResult[bonusGoldLoc2[1]][bonusGoldLoc2[2]].terrainType = bonusGold
-------------------
-- PLACE PLAYERS --
-------------------
teamsList, playersPerTeam = SetUpTeams()
teamMappingTable = CreateTeamMappingTable()

innerExclusion = 0.5
minTeamDistance =  8
minPlayerDistance = 8

cornerThreshold = 1

startBufferRadius = 1.5
placeStartBuffer = true

impasseTypes = {}
table.insert(impasseTypes, t_forest)
table.insert(impasseTypes, t_water)
table.insert(impasseTypes, t_holySite_outer)

topSelectionThreshold = 0.2

--Set up Variables for MapSize
if(worldTerrainWidth <= 417) then
    -- Micro
    minTeamDistance =  15
    minPlayerDistance = 8
    impasseDistance = 2
    edgeBuffer = 2

    
elseif(worldTerrainWidth <= 513) then
    -- Small
    minTeamDistance =  15
    minPlayerDistance = 18
    impasseDistance = 4
    edgeBuffer = 2

    
elseif(worldTerrainWidth <= 641) then
    -- Medium
    minPlayerDistance = 6
    minTeamDistance =  15
    impasseDistance = 4
    edgeBuffer = 4


    
elseif(worldTerrainWidth <= 769) then
    -- Large

    minPlayerDistance = 8 
    minTeamDistance =  15
    impasseDistance = 4
    edgeBuffer = 4
    
else
    -- giagantic

    minPlayerDistance = 8
    minTeamDistance =  15
    impasseDistance = 4
    edgeBuffer = 6
end



--Place players
if(#teamMappingTable == 2) then
    terrainLayoutResult = PlacePlayerStartsDivided(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, isVertical, impasseTypes, impasseDistance, topSelectionThreshold, playerStartTerrain, startBufferTerrain, startBufferRadius, true, terrainLayoutResult)
else
	terrainLayoutResult = PlacePlayerStartsRing(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, impasseTypes, impasseDistance, topSelectionThreshold, playerStartTerrain, startBufferTerrain, startBufferRadius, true, terrainLayoutResult)
end  









