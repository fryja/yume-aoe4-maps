-----------------------------
------- Cache  ----------
------- by Yume -------------
------- version 1.0 ---------
--[[
1.0
- Release

]]

terrainLayoutResult = {}


if(worldTerrainWidth <= 417) then
    -- Micro
mapRes = 10    
elseif(worldTerrainWidth <= 513) then
    -- Small
mapRes = 10   
elseif(worldTerrainWidth <= 641) then
    -- Medium
mapRes = 10  
elseif(worldTerrainWidth <= 769) then
    -- Large
mapRes = 15
else
    -- giagantic
mapRes = 15
end









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


t_base =  tt_plains
t_n = tt_none
t_h = tt_hills
t_m = tt_mountains --tt_impasse_mountains
t_impasse = tt_impasse_mountains
t_forest = tt_none --tt_hidden_valley_forest_impasse



t_plateau = tt_plateau_low
t_valley = tt_valley_shallow

t_trade = tt_settlement_hills_wveg
t_holySite = tt_holy_site


playerStartTerrain = tt_player_start_classic_plains
startBufferTerrain = tt_plains

bonusStone = tt_tactical_region_stone_plains_a
bonusGold = tt_tactical_region_gold_plains_a
bonusRelic = tt_relic_spawner

cacheTerrainList = {bonusStone, bonusGold, bonusRelic, t_holySite}
cacheMidTerrainList = {bonusStone, bonusGold, bonusStone, bonusGold}




-- fill grid default
terrainLayoutResult = SetUpGrid(gridSize, t_base, terrainLayoutResult)

------------------
--- FUNCTIONS ----
------------------



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

function shuffleTable(tbl)
  for i = #tbl, 2, -1 do
    local j = math.floor(GetRandomInRange(1,i))
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
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


function drawRect(startRow, startCol, endRow, endCol, pickedTerrain)
    local function sign(number)
        return number > 0 and 1 or (number == 0 and 0 or -1)
    end
    
    
    local incRow = sign(endRow - startRow)
    local incCol = sign(endCol - startCol)

    for row = startRow, endRow, incRow do
        for col = startCol, endCol, incCol do
            terrainLayoutResult[row][col].terrainType = pickedTerrain
        end
    end
end

function drawHollowRect(startRow, startCol, endRow, endCol, pickedTerrain, thickness)
    local function sign(number)
        return number > 0 and 1 or (number == 0 and 0 or -1)
    end
    
    
    local incRow = sign(endRow - startRow)
    local incCol = sign(endCol - startCol)

    for row = startRow, endRow, incRow do
        for col = startCol, endCol, incCol do
            if (math.abs(row - startRow) < thickness) or (math.abs(row - endRow) < thickness) or (math.abs(col - endCol) < thickness) or (math.abs(col - startCol) < thickness) then
                terrainLayoutResult[row][col].terrainType = pickedTerrain
            end
        end
    end
end





function drawCache(startRow, startCol, endRow, endCol, pickedTerrain, doorTerrain, thickness, direction)
    local function sign(number)
        return number > 0 and 1 or (number == 0 and 0 or -1)
    end

    local incRow = sign(endRow - startRow)
    local incCol = sign(endCol - startCol)

    for row = startRow, endRow, incRow do
        for col = startCol, endCol, incCol do

            local sizes = {row - startRow, col - endCol, row - endRow, col - startCol}
            local directions = {"up", "right", "down", "left"}


            for i = 1, 4, 1 do
                if(math.abs(sizes[i]) >= thickness) then goto continue end

                local rowOffset = (i % 2)+1
                local isNotCorner = (math.abs(sizes[rowOffset]) >= thickness and math.abs(sizes[rowOffset+2]) >= thickness)

                if((direction == directions[i]) and isNotCorner) then
                    terrainLayoutResult[row][col].terrainType = doorTerrain
                else
                    terrainLayoutResult[row][col].terrainType = pickedTerrain
                end

                ::continue::
            end
        end
    end
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

sideCaches = 4

borderSize = 8

cacheSize = 4
cacheThickness = 1

middleCacheWidth = 6
middleCacheThickness = 1


--Set up Variables for MapSize
if(worldTerrainWidth <= 417) then
    -- Micro


elseif(worldTerrainWidth <= 513) then
    -- Small
    borderSize = 9
    cacheSize = 5
    cacheThickness = 1
    
    middleCacheWidth = 8
    middleCacheThickness = 1


	
elseif(worldTerrainWidth <= 641) then
    -- Medium
    cacheTerrainList = {bonusStone, bonusGold, bonusRelic, t_holySite, bonusGold}


    sideCaches = 5
    borderSize = 8
    cacheSize = 4
    cacheThickness = 1
    
    middleCacheWidth = 7
    middleCacheThickness = 1
    
elseif(worldTerrainWidth <= 769) then
    -- Large
    bonusStone = tt_tactical_region_stone_plains_c
    bonusGold = tt_tactical_region_gold_plains_d
    bonusRelic = tt_relic_spawner  
   
    cacheTerrainList = {bonusStone, bonusGold, bonusRelic, t_holySite, bonusGold, bonusRelic}
    cacheMidTerrainList = {bonusStone, bonusGold, bonusStone, bonusGold}


    sideCaches = 5
    borderSize = 10
    cacheSize = 6
    cacheThickness = 2
    
    middleCacheWidth = 8
    middleCacheThickness = 1

    t_forest = tt_impasse_trees_plains
    t_m = t_impasse
else
    -- giagantic
    bonusStone = tt_tactical_region_stone_plains_c
    bonusGold = tt_tactical_region_gold_plains_d
    bonusRelic = tt_relic_spawner   
    
    cacheTerrainList = {bonusStone, bonusGold, bonusRelic, t_holySite, bonusGold, bonusRelic, bonusStone}
    cacheMidTerrainList = {bonusStone, bonusGold, bonusStone, bonusGold}

 
    sideCaches = 5
    borderSize = 11
    cacheSize = 7
    cacheThickness = 2
    
    middleCacheWidth = 8
    middleCacheThickness = 1
    
    t_forest = tt_impasse_trees_plains
    t_m = t_impasse
end

--Calc Variables
sideCacheDivisions = Round(gridSize / (sideCaches + 1))
middleCacheWidthHalf = Round(middleCacheWidth / 2)
cacheTerrainList = shuffleTable(cacheTerrainList)

---- DRAW MAP ------


--border
drawRect(1, 1, gridSize, borderSize, t_m)
drawRect(1, gridSize, gridSize, gridSize - borderSize + 1, t_m)



-- caches
--left
for i = 1, sideCaches do
    
    local startRow = (i * sideCacheDivisions) - (math.floor(cacheSize / 2))
    local startCol = 1
    local endRow = startRow + cacheSize
    local endCol = startCol + cacheSize + 3
    
    drawRect(startRow, startCol, endRow, endCol, t_base, cacheThickness)    
    
    DrawLineOfTerrain(endRow  - cacheSize, endCol - 1, endRow, endCol - 1, t_forest, false, gridSize)
    
    if(worldTerrainWidth ~= 769 and worldTerrainWidth ~= 896) then   
        DrawLineOfTerrain(endRow  - cacheSize, endCol, endRow, endCol, t_forest, false, gridSize)
    end   

    terrainLayoutResult[startRow + Round(cacheSize / 2)][startCol + Round(cacheSize / 2)].terrainType = cacheTerrainList[i]

end


--right
for i = 1, sideCaches do
    
    local startRow = (i * sideCacheDivisions) - (math.floor(cacheSize / 2))
    local startCol = gridSize
    local endRow = startRow + cacheSize
    local endCol = gridSize - cacheSize - 3
    
    drawRect(startRow, startCol, endRow, endCol, t_base, cacheThickness)  
    DrawLineOfTerrain(endRow  - cacheSize, endCol + 1, endRow, endCol + 1, t_forest, false, gridSize)
    if(worldTerrainWidth ~= 769 and worldTerrainWidth ~= 896) then   
        DrawLineOfTerrain(endRow  - cacheSize, endCol, endRow, endCol, t_forest, false, gridSize)
    end
    terrainLayoutResult[startRow + Round(cacheSize / 2)][startCol - Round(cacheSize / 2)].terrainType = cacheTerrainList[sideCaches + 1 - i]

end

--drawHollowRect(1, 1, gridSize, gridSize, t_m, 1)

--edge borders
DrawLineOfTerrain(1, 1, gridSize, 1, t_m, false, gridSize)
DrawLineOfTerrain(1, gridSize, gridSize, gridSize, t_m, false, gridSize)

-- middle cache

--bottom row of cache
if(worldTerrainWidth ~= 769 and worldTerrainWidth ~= 896) then   
    DrawLineOfTerrain(gridHalf + middleCacheWidth, gridHalf - middleCacheWidth, gridHalf + middleCacheWidth, gridHalf + middleCacheWidth, t_forest, false, gridSize)
    DrawLineOfTerrain(gridHalf - middleCacheWidth, gridHalf - middleCacheWidth, gridHalf - middleCacheWidth, gridHalf + middleCacheWidth, t_forest, false, gridSize)
end

--top row of cache
drawCache(gridHalf + 1, gridHalf, gridHalf + middleCacheWidth + 1, gridHalf + middleCacheWidth, t_impasse, t_forest, middleCacheThickness, "down")
drawCache(gridHalf - 1, gridHalf, gridHalf - middleCacheWidth - 1, gridHalf + middleCacheWidth, t_impasse, t_forest, middleCacheThickness, "down")

--mid line
DrawLineOfTerrain(gridHalf, gridHalf - middleCacheWidth, gridHalf, gridHalf + middleCacheWidth, t_m, false, gridSize)


drawCache(gridHalf + 1, gridHalf, gridHalf + middleCacheWidth + 1, gridHalf - middleCacheWidth, t_impasse, t_forest, middleCacheThickness, "down")
drawCache(gridHalf - 1, gridHalf, gridHalf - middleCacheWidth - 1, gridHalf - middleCacheWidth, t_impasse, t_forest, middleCacheThickness, "down")

middleCacheResourceLoc1 = {gridHalf - middleCacheWidthHalf, gridHalf - middleCacheWidthHalf}
middleCacheResourceLoc2 = {gridHalf - middleCacheWidthHalf, gridHalf + middleCacheWidthHalf}
middleCacheResourceLoc3 = {gridHalf + middleCacheWidthHalf, gridHalf - middleCacheWidthHalf}
middleCacheResourceLoc4 = {gridHalf + middleCacheWidthHalf, gridHalf + middleCacheWidthHalf}




terrainLayoutResult[middleCacheResourceLoc1[1]][middleCacheResourceLoc1[2]].terrainType = cacheMidTerrainList[1]
terrainLayoutResult[middleCacheResourceLoc2[1]][middleCacheResourceLoc2[2]].terrainType = cacheMidTerrainList[2]
terrainLayoutResult[middleCacheResourceLoc3[1]][middleCacheResourceLoc3[2]].terrainType = cacheMidTerrainList[3]
terrainLayoutResult[middleCacheResourceLoc4[1]][middleCacheResourceLoc4[2]].terrainType = cacheMidTerrainList[4]


-------------------
-- PLACE MAP FEATURES --
-------------------

tradePostLoc1 = {2, gridSize  - borderSize - 1}
tradePostLoc2 = {gridSize - 2, 1 + borderSize + 2}

terrainLayoutResult[tradePostLoc1[1]][tradePostLoc1[2]].terrainType = t_trade
terrainLayoutResult[tradePostLoc2[1]][tradePostLoc2[2]].terrainType = t_trade

relicLoc1 = {gridHalf, gridHalf - middleCacheWidth - 3}
relicLoc2 = {gridHalf, gridHalf + middleCacheWidth + 3}

terrainLayoutResult[relicLoc1[1]][relicLoc1[2]].terrainType = bonusRelic
terrainLayoutResult[relicLoc2[1]][relicLoc2[2]].terrainType = bonusRelic
-- PLACE PLAYERS --
-------------------
teamsList, playersPerTeam = SetUpTeams()
teamMappingTable = CreateTeamMappingTable()

innerExclusion = 0.5
minTeamDistance =  8
minPlayerDistance = 8
isVertical = false

cornerThreshold = 9

startBufferRadius = 1.5
placeStartBuffer = true

impasseTypes = {}
table.insert(impasseTypes, t_forest)
table.insert(impasseTypes, t_impasse)
table.insert(impasseTypes, t_m)

topSelectionThreshold = 0.2


    minTeamDistance =  15
    minPlayerDistance = 8
    impasseDistance = 2
    edgeBuffer = 5


--Set up Variables for MapSize
if(worldTerrainWidth <= 417) then
    -- Micro
    minTeamDistance =  15
    minPlayerDistance = 8
    impasseDistance = 2
    edgeBuffer = 5

     
elseif(worldTerrainWidth <= 513) then
    -- Small

cornerThreshold = 7
    
elseif(worldTerrainWidth <= 641) then
    -- Medium

cornerThreshold = 7
    
elseif(worldTerrainWidth <= 769) then
    -- Large

    cornerThreshold = 8
    impasseDistance = 3
else
    -- giagantic
    cornerThreshold = 15
    impasseDistance = 3
end



--Place players
if(#teamMappingTable == 2) then
    terrainLayoutResult = PlacePlayerStartsDivided(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, isVertical, impasseTypes, impasseDistance, topSelectionThreshold, playerStartTerrain, startBufferTerrain, startBufferRadius, true, terrainLayoutResult)
else
	terrainLayoutResult = PlacePlayerStartsRing(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, impasseTypes, impasseDistance, topSelectionThreshold, playerStartTerrain, startBufferTerrain, startBufferRadius, true, terrainLayoutResult)
end  









