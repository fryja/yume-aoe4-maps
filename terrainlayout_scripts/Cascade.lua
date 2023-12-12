-----------------------------
------- Cascade  ----------
------- by Yume -------------
------- version 1.0 ---------
--[[
1.0
- Release

]]
--Set up Variables for MapSize
mapRes = 20


terrainLayoutResult = {}
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

-- start map
debug = false
if debug then
	playerTeams = {}
	worldPlayerCount = 7
	playerTeams[1] = 1 --player 1 on team 1
	playerTeams[2] = 1 --player 2 on team 1
	playerTeams[3] = 1 --player 3 on team 2
	playerTeams[4] = 2 --player 4 on team 2
	playerTeams[5] = 2 --player 5 on team 3
	playerTeams[6] = 2 --player 6 on team 3
	playerTeams[7] = 2 --player 7 on team 3
--	playerTeams[8] = 2 --player 8 on team 3
end


t_base =  tt_plains
t_p = tt_plains
t_n = tt_none
t_water = tt_ocean
t_river = tt_river
t_m = tt_mountains
t_beach = tt_beach
t_forest = tt_forest_natural_medium

t_plateau_high = tt_plateau_standard
t_plateau_med = tt_plateau_low
t_h = tt_hills_low_rolling

playerStartTerrain = tt_player_start_classic_plains
startBufferTerrain = tt_plains

t_trade = tt_settlement_hills
t_holySiteDelta = tt_holy_site
t_holySite = tt_holy_site

bonusGold = tt_tactical_region_gold_plains_a

-- fill grid default
terrainLayoutResult = SetUpGrid(gridSize, t_base, terrainLayoutResult)

------------------
--- FUNCTIONS ----
------------------
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

function drawCircle(centerCoord, radius, terrainType)
    local function circleFill(centerCoord, tileCoord, radius)
        dx = centerCoord[1] - tileCoord.row
        dy = centerCoord[2] - tileCoord.col
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

function drawCircleOnTerrain(centerCoord, radius, terrainType, terrainToReplace)
    local function circleFill(centerCoord, tileCoord, radius)
        dx = centerCoord[1] - tileCoord.row
        dy = centerCoord[2] - tileCoord.col
        distanceSquared = (dx*dx) + (dy*dy)
        return distanceSquared <= radius*radius
    end
    
    for row = 1, gridSize do
        for col = 1, gridSize do
            local tileCoord = { row = row, col = col }
            if (circleFill(centerCoord, tileCoord, radius)) and (terrainLayoutResult[row][col].terrainType == terrainToReplace) then
                 terrainLayoutResult[row][col].terrainType = terrainType
            end
        end
    end 
end


function drawHill(centreCoordRow, centreCoordCol, width, height, pickedTerrain, rampTerrain, direction)
    local startRow = centreCoordRow - Round(height / 2 - 0.1)
    local startCol = centreCoordCol - Round(width / 2 - 0.1)
    local endRow = centreCoordRow + Round(height / 2 - 0.1)
    local endCol = centreCoordCol + Round(width / 2 - 0.1)
    
    
    local function sign(number)
        return number > 0 and 1 or (number == 0 and 0 or -1)
    end

    local incRow = sign(endRow - startRow)
    local incCol = sign(endCol - startCol)

    for row = startRow, endRow, incRow do
        for col = startCol, endCol, incCol do
            if IsInMap(row, col, gridSize, gridSize) then
              terrainLayoutResult[row][col].terrainType = pickedTerrain
              -- If the direction is up, set the top edge to pickedValue2
              if direction == "up" and row == startRow then
                terrainLayoutResult[row][col].terrainType = rampTerrain
              end
              -- If the direction is down, set the bottom edge to pickedValue2
              if direction == "down" and row == endRow then
                terrainLayoutResult[row][col].terrainType = rampTerrain
              end
              -- If the direction is left, set the left edge to pickedValue2
              if direction == "left" and col == startCol then
                terrainLayoutResult[row][col].terrainType = rampTerrain
              end
              -- If the direction is right, set the right edge to pickedValue2
              if direction == "right" and col == endCol then
                terrainLayoutResult[row][col].terrainType = rampTerrain
              end
            end
        end
    end
end

function pointsAlongLine(startRow, startCol, endRow, endCol, numPoints, randomRow, randomCol, addStartPoint, addEndPoint, shift)
    
    local spacedPoints = {}   
    local points = DrawStraightLineReturn(startRow, startCol, endRow, endCol, debug, tt_flatland, gridSize, terrainLayoutResult)
    local division = math.floor(#points / (numPoints + 1) + shift)

    
    for i = 1, numPoints do
       local row = points[i * division][1] + Round(GetRandomInRange(0 - randomRow, randomRow))
       local col = points[i * division][2] + Round(GetRandomInRange(0 - randomCol, randomCol))
       table.insert(spacedPoints, {row, col})
    end
    if addStartPoint then
        table.insert(spacedPoints, points[1])
    end
    if addEndPoint then
        table.insert(spacedPoints, points[#points])
    end

    
    return spacedPoints
end
-----------------
-- MAP VARS  --
-----------------
   mapRotate = false
if worldGetRandom() < 0.5 then
   mapRotate = true
end

--defaults
if mapRotate then
    crossMapLineStart = {gridHalf, 1}
    crossMapLineEnd = {gridHalf, gridSize}
else
    crossMapLineStart = {1, gridHalf}
    crossMapLineEnd = {gridSize, gridHalf}    
end

forestCentreOffset = 3
forestRadius = 1.5


hillsRiverBuffer = 4
hillsWidth = 4
hillsHeight = 3
hillsLineEndShift = -3


hillLineEndEdgeBuffer = 4
numHills = 3
numPasses = 2
tradeHillsRadius = 5

holySiteEdgeBuffer =  1
holySiteHillsOffset = 2
holySiteEdgeBuffer =  1

riverSplitEndDistanceFromMid = 5
riverSplitPointDivision = 4

---------
if(worldTerrainWidth <= 417) then
    -- Micro


elseif(worldTerrainWidth <= 513) then
    -- Small
 
hillsLineEndShift = -2
tradeHillsRadius = 7	

elseif(worldTerrainWidth <= 641) then
    -- Medium
numHills = 4
numPasses = 3    
hillsRiverBuffer = 6
hillsWidth = 5
hillsHeight = 4 
hillsLineEndShift = -1
tradeHillsRadius = 8
riverSplitEndDistanceFromMid = 7
forestCentreOffset = 5
forestRadius = 3
    
elseif(worldTerrainWidth <= 769) then
    -- Large
    
numHills = 4
numPasses = 3    
hillsRiverBuffer = 6
hillsWidth = 5
hillsHeight = 4 
hillsLineEndShift = -1
tradeHillsRadius = 11
riverSplitEndDistanceFromMid = 7
forestCentreOffset = 5
forestRadius = 3
else
    -- giagantic
numHills = 4
numPasses = 3    
hillsRiverBuffer = 6
hillsWidth = 5
hillsHeight = 6 
hillsLineEndShift = -1
tradeHillsRadius = 14
riverSplitEndDistanceFromMid = 8
riverSplitPointDivision = 3
forestCentreOffset = 5
forestRadius = 3

end

--Calculation Variables (based on previous stuff)
hillsAreaWidth = gridSize - gridThird + hillsLineEndShift


-----------------
-- BUILD MAP!! --
-----------------

if worldGetRandom() < 0.5 then
    holySiteHillsOffset = 0 - holySiteHillsOffset
end


if mapRotate then
    tradeLoc1 = {1 + holySiteEdgeBuffer, 1+ holySiteEdgeBuffer}
    tradeLoc2 = {gridSize - holySiteEdgeBuffer, 1+holySiteEdgeBuffer}
    
    holySiteDeltaLoc = {crossMapLineEnd[1], crossMapLineEnd[2]  - holySiteEdgeBuffer}
    holySiteHillsLoc = {crossMapLineStart[1]  + holySiteHillsOffset, crossMapLineStart[2]  + holySiteEdgeBuffer,}
else
    tradeLoc2 = {1 + holySiteEdgeBuffer, 1+ holySiteEdgeBuffer}
    tradeLoc1 = {1 + holySiteEdgeBuffer, gridSize - holySiteEdgeBuffer}  

    holySiteDeltaLoc = {crossMapLineEnd[1] - holySiteEdgeBuffer, crossMapLineEnd[2]}
    holySiteHillsLoc = {crossMapLineStart[1] + holySiteEdgeBuffer, crossMapLineStart[2] + holySiteHillsOffset}    
end












-- RIVERS --

riverResult = {}
fordResults = {}
riverPointsMain = {}
riverPoints2 = {}
riverPoints3 = {}

crossMapLinePoints = {}





crossMapLinePoints = DrawLineOfTerrainNoNeighbors(crossMapLineStart[1], crossMapLineStart[2], crossMapLineEnd[1], crossMapLineEnd[2], false, t_river, gridSize, terrainLayoutResult)
riverSplitPoint = math.floor(#crossMapLinePoints / riverSplitPointDivision) * (riverSplitPointDivision - 1)



riverPointsMain = DrawLineOfTerrainReturn(crossMapLineStart[1], crossMapLineStart[2], crossMapLinePoints[riverSplitPoint][1], crossMapLinePoints[riverSplitPoint][2], t_river, true, gridSize)

if mapRotate then
    riverPoints2 = DrawLineOfTerrainReturn(crossMapLinePoints[riverSplitPoint][1], crossMapLinePoints[riverSplitPoint][2], gridHalf - riverSplitEndDistanceFromMid, gridSize, t_river, true, gridSize)
    riverPoints3 = DrawLineOfTerrainReturn(crossMapLinePoints[riverSplitPoint][1], crossMapLinePoints[riverSplitPoint][2], gridHalf + riverSplitEndDistanceFromMid, gridSize, t_river, true, gridSize)
else
    riverPoints2 = DrawLineOfTerrainReturn(crossMapLinePoints[riverSplitPoint][1], crossMapLinePoints[riverSplitPoint][2], gridSize, gridHalf - riverSplitEndDistanceFromMid, t_river, true, gridSize)
    riverPoints3 = DrawLineOfTerrainReturn(crossMapLinePoints[riverSplitPoint][1], crossMapLinePoints[riverSplitPoint][2], gridSize, gridHalf + riverSplitEndDistanceFromMid, t_river, true, gridSize)
    
end
--DrawLineOfTerrainReturn(riverStartPoint[1], riverStartPoint[2], riverEndPoint[1], riverEndPoint[2], t_river, false, gridSize)
table.insert(riverResult, 1, riverPointsMain)


-- FORESTS
if mapRotate then
    --delta forests
    drawCircleOnTerrain({crossMapLineEnd[1] - forestCentreOffset, crossMapLineEnd[2]}, forestRadius, t_forest, t_base)
    drawCircleOnTerrain({crossMapLineEnd[1] + forestCentreOffset, crossMapLineEnd[2]}, forestRadius, t_forest, t_base)
    --corner forests
    drawCircleOnTerrain({1, gridSize}, forestRadius, t_forest, t_base)
    drawCircleOnTerrain({gridSize, gridSize}, forestRadius, t_forest, t_base)
else
    drawCircleOnTerrain({crossMapLineEnd[1], crossMapLineEnd[2]  - forestCentreOffset}, forestRadius, t_forest, t_base)
    drawCircleOnTerrain({crossMapLineEnd[1], crossMapLineEnd[2] + forestCentreOffset}, forestRadius, t_forest, t_base)
    --corner forests
    drawCircleOnTerrain({gridSize, 1}, forestRadius, t_forest, t_base)
    drawCircleOnTerrain({gridSize, gridSize}, forestRadius, t_forest, t_base)   
end


-- HILLS

if mapRotate then
    hillLine1Start = {crossMapLineStart[1] - hillsRiverBuffer, 1}
    hillLine1End = {hillLineEndEdgeBuffer, hillsAreaWidth}
    hillLine2Start = {crossMapLineStart[1] + hillsRiverBuffer, 1}
    hillLine2End = {gridSize - hillLineEndEdgeBuffer, hillsAreaWidth}
    hillLineRandomRow = 1
    hillLineRandomCol = 0
    passRandomRow = 0
    passRandomCol = 1
else
    hillLine1Start = {1, crossMapLineStart[2] + hillsRiverBuffer + 1}
    hillLine1End = {hillsAreaWidth, gridSize - hillLineEndEdgeBuffer}
    hillLine2Start = {1, crossMapLineStart[2] - hillsRiverBuffer - 1}
    hillLine2End = {hillsAreaWidth, hillLineEndEdgeBuffer}
    hillLineRandomRow = 0
    hillLineRandomCol = 1
    passRandomRow = 1
    passRandomCol = 0
    
    hillsWidth, hillsHeight = hillsHeight, hillsWidth
end

--pointsAlongLine(startRow, startCol, endRow, endCol, numPoints, randomRow, randomCol, addStartPoint, addEndPoint, shift)
hillSpawns1 = pointsAlongLine(hillLine1Start[1], hillLine1Start[2], hillLine1End[1], hillLine1End[2], numHills, hillLineRandomRow, hillLineRandomCol, true, false, 1)
for i, currentTile in ipairs(hillSpawns1) do
	local row = currentTile[1]
	local col = currentTile[2]
	--local heightChange = worldGetRandom() < 0.5 
	if (i % 2 == 1) then
	    terrainToUse = t_plateau_high
	else
	    terrainToUse = t_plateau_med
	end
	
    if mapRotate then
        drawHill(row, col, Round(GetRandomInRange(hillsWidth, hillsWidth + 2)), Round(GetRandomInRange(hillsHeight, hillsHeight)), terrainToUse, t_h, "up")
    else
        drawHill(row, col, Round(GetRandomInRange(hillsWidth, hillsWidth + 2)), Round(GetRandomInRange(hillsHeight, hillsHeight)), terrainToUse, t_h, "right")  
    end
end

hillSpawns2 = pointsAlongLine(hillLine2Start[1], hillLine2Start[2], hillLine2End[1], hillLine2End[2], numHills, hillLineRandomRow, hillLineRandomCol, true, false, 1)
for i, currentTile in ipairs(hillSpawns2) do
	local row = currentTile[1]
	local col = currentTile[2]
	if (i % 2 == 1) then
	    terrainToUse = t_plateau_high
	else
	    terrainToUse = t_plateau_med
	end
   --terrainLayoutResult[row][col].terrainType = tt_none
    if mapRotate then
        drawHill(row, col, Round(GetRandomInRange(hillsWidth, hillsWidth + 2)), Round(GetRandomInRange(hillsHeight, hillsHeight)), terrainToUse, t_h, "down")
    else
        drawHill(row, col, Round(GetRandomInRange(hillsWidth, hillsWidth + 2)), Round(GetRandomInRange(hillsHeight, hillsHeight)), terrainToUse, t_h, "left")
    end
end


-- DRAW THE PASSES BETWEEN HILLS
    hillPassesPoints1 = pointsAlongLine(hillLine1Start[1], hillLine1Start[2], hillLine1End[1], hillLine1End[2], numPasses, passRandomRow, passRandomCol, false, true, -1)
    for i, currentTile in ipairs(hillPassesPoints1) do
    	local row = currentTile[1]
    	local col = currentTile[2]

    	    terrainToUse = t_base

    
        if mapRotate then
            DrawStraightLine(row - 2, col, row + 2, col, true, terrainToUse, gridSize, terrainLayoutResult)
        else
            DrawStraightLine(row, col - 2, row, col + 2, true, terrainToUse, gridSize, terrainLayoutResult)    
        end
    end
    
    hillPassesPoints2 = pointsAlongLine(hillLine2Start[1], hillLine2Start[2], hillLine2End[1], hillLine2End[2], numPasses, passRandomRow, passRandomCol, false, true, -1)
    for i, currentTile in ipairs(hillPassesPoints2) do
    	local row = currentTile[1]
    	local col = currentTile[2]

    	    terrainToUse = t_base

       --terrainLayoutResult[row][col].terrainType = tt_none
        if mapRotate then
            DrawStraightLine(row - 2, col, row + 2, col, true, terrainToUse, gridSize, terrainLayoutResult)
        else
            DrawStraightLine(row, col - 2, row, col + 2, true, terrainToUse, gridSize, terrainLayoutResult)    
        end
    end



--Finally, fill in the corners where tradeposts are with hills

drawCircleOnTerrain(tradeLoc1, tradeHillsRadius, t_h, t_base)
drawCircleOnTerrain(tradeLoc2, tradeHillsRadius, t_h, t_base)


-------------------
-- PLACE MAP FEATURES --
-------------------







terrainLayoutResult[holySiteDeltaLoc[1]][holySiteDeltaLoc[2]].terrainType = t_holySiteDelta
terrainLayoutResult[holySiteHillsLoc[1]][holySiteHillsLoc[2]].terrainType = t_holySite

terrainLayoutResult[tradeLoc1[1]][tradeLoc1[2]].terrainType = t_trade
terrainLayoutResult[tradeLoc2[1]][tradeLoc2[2]].terrainType = t_trade


-- Place River Fords
fordTable = {}

ford1Min = (#riverPointsMain / 2) - 1
ford1Max = (#riverPointsMain / 2) + 1


ford1Index = math.ceil(#riverPointsMain / 2)
table.insert(fordTable, riverResult[1][ford1Index])
table.insert(fordTable, riverResult[1][holySiteEdgeBuffer + 1])
table.insert(fordResults, 1, fordTable)

--Finish Rivers

table.insert(riverResult, 1, riverPoints2)
table.insert(riverResult, 3, riverPoints3)



-------------------
-- PLAYER SPAWNING -----
-------------------
teamsList, playersPerTeam = SetUpTeams()
teamMappingTable = CreateTeamMappingTable()

innerExclusion = 0.3
minTeamDistance =  8
minPlayerDistance = 8
impasseDistance = 3
edgeBuffer = 2

cornerThreshold = 1

startBufferRadius = 1.5
placeStartBuffer = true
topSelectionThreshold = 0.2

impasseTypes = {}
table.insert(impasseTypes, tt_river)
table.insert(impasseTypes, t_plateau_high)
table.insert(impasseTypes, t_plateau_low)
table.insert(impasseTypes, t_h)
table.insert(impasseTypes, t_trade)
table.insert(impasseTypes, t_holySiteDelta)
table.insert(impasseTypes, t_holySite)


if(worldPlayerCount == 2) then -- Micro
    playerEdgeBuffer = 4
    
    if mapRotate then
        player1Loc = {playerEdgeBuffer, gridSize - playerEdgeBuffer}
        player2Loc = {gridSize - playerEdgeBuffer + 1, gridSize - playerEdgeBuffer}   
    else
        player1Loc = {gridSize - playerEdgeBuffer, playerEdgeBuffer}
        player2Loc = {gridSize - playerEdgeBuffer, gridSize - playerEdgeBuffer}          
    end

    terrainLayoutResult[player1Loc[1]][player1Loc[2]].terrainType = playerStartTerrain
    terrainLayoutResult[player2Loc[1]][player2Loc[2]].terrainType = playerStartTerrain
    terrainLayoutResult[player1Loc[1]][player1Loc[2]].playerIndex = 0
    terrainLayoutResult[player2Loc[1]][player2Loc[2]].playerIndex = 1
elseif (#teamMappingTable == 2) then


        if(worldTerrainWidth <= 417) then -- Micro
            playerSpawnLineStartShift = -1
            playerSpawnLineStartRowShift = 1
            playerSpawnLineCornerBuffer = 1   
        elseif(worldTerrainWidth <= 513) then -- Small
            playerSpawnLineStartShift = -2
            playerSpawnLineStartRowShift = 1
            playerSpawnLineCornerBuffer = 1   
        
        elseif(worldTerrainWidth <= 641) then -- Medium
            playerSpawnLineStartShift = -4
            playerSpawnLineStartRowShift = 1
            playerSpawnLineCornerBuffer = 1           

        elseif(worldTerrainWidth <= 769) then -- Large
            playerSpawnLineStartShift = -5
            playerSpawnLineStartRowShift = 2
            playerSpawnLineCornerBuffer = 3                
                
        else -- Gigantic
            playerSpawnLineStartShift = -5
            playerSpawnLineStartRowShift = 2
            playerSpawnLineCornerBuffer = 3
        end

    if mapRotate then
        teamLine1Start = {gridHalf - playerSpawnLineStartRowShift, gridHalf + playerSpawnLineStartShift}
        teamLine1End = {1 + playerSpawnLineCornerBuffer, gridSize - playerSpawnLineCornerBuffer}
        
        teamLine2Start = {gridHalf + playerSpawnLineStartRowShift, gridHalf + playerSpawnLineStartShift}
        teamLine2End = {gridSize - playerSpawnLineCornerBuffer, gridSize - playerSpawnLineCornerBuffer}
    else
        teamLine1Start = {gridHalf + playerSpawnLineStartShift, gridHalf + playerSpawnLineStartRowShift}
        teamLine1End = {gridSize - playerSpawnLineCornerBuffer, gridSize - playerSpawnLineCornerBuffer}
        
        teamLine2Start = {gridHalf + playerSpawnLineStartShift, gridHalf - playerSpawnLineStartRowShift}
        teamLine2End = {gridSize - playerSpawnLineCornerBuffer, 1 + playerSpawnLineCornerBuffer}       
    end

    playerSpawnsTeam1 = pointsAlongLine(teamLine1Start[1], teamLine1Start[2], teamLine1End[1], teamLine1End[2], playersPerTeam[1], 1, 0, false, false, 1)
    for i, currentSpawn in ipairs(playerSpawnsTeam1) do
    	local row = currentSpawn[1]
    	local col = currentSpawn[2]

        drawCircle(currentSpawn, startBufferRadius, startBufferTerrain)
        terrainLayoutResult[row][col].terrainType = playerStartTerrain
        terrainLayoutResult[row][col].playerIndex = i - 1
    end
    
    playerSpawnsTeam2 = pointsAlongLine(teamLine2Start[1], teamLine2Start[2], teamLine2End[1], teamLine2End[2], playersPerTeam[2], 1, 0, false, false, 1)
    for i, currentSpawn in ipairs(playerSpawnsTeam2) do
    	local row = currentSpawn[1]
    	local col = currentSpawn[2]

        terrainLayoutResult[row][col].terrainType = playerStartTerrain
        terrainLayoutResult[row][col].playerIndex = i + playersPerTeam[1] - 1
    end

else
	terrainLayoutResult = PlacePlayerStartsRing(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, impasseTypes, impasseDistance, topSelectionThreshold, playerStartTerrain, startBufferTerrain, startBufferRadius, true, terrainLayoutResult)
end  




