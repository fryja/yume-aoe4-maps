-----------------------------
------- Safety Bay ----------
------- by Yume -------------
------- version 1.0 ---------
--[[
1.0
- Release

]]

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
	worldPlayerCount = 6
	playerTeams[1] = 1 --player 1 on team 1
	playerTeams[2] = 1 --player 2 on team 1
	playerTeams[3] = 1 --player 3 on team 2
	playerTeams[4] = 2 --player 4 on team 2
	playerTeams[5] = 2 --player 5 on team 3
	playerTeams[6] = 2 --player 6 on team 3
--	playerTeams[7] = 2 --player 7 on team 3
--	playerTeams[8] = 2 --player 8 on team 3
end


t_base =  tt_plains
t_p = tt_plains
t_n = tt_none
t_water = tt_ocean
t_m = tt_mountains
t_beach = tt_beach

playerStartTerrain = tt_player_start_classic_plains
startBufferTerrain = tt_plains
tradeTerrain = tt_settlement_naval
holySiteIslandTerrain = tt_holy_site
holySiteTerrain = tt_holy_site

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

--draws a circle that is filled
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

function searchForTerrain(startRow, startCol, rowIteration, colIteration, failRadius, terrainToFind1, terrainToFind2)
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

function trigIsHard(hypLength, ang)
  local rad = math.rad(ang)

  local side_a = hypLength * math.sin(rad)
  local side_b = hypLength * math.cos(rad)

  return {side_a, side_b}
end
-----------------
-- MAP VARS  --
-----------------
    mapRotate = false
if worldGetRandom() < 0.5 then
    mapRotate = true
end


edgeOceanWidth = 4
bayMouthWidth = 3

bayRadius = 4.5
mountainRadius = 1.5
smallMountainRadius = 1.5
bayCentreCoord = {gridHalf - 1, gridHalf}



holyIslandWidth = 2
holyIslandLength = 5

holySiteCornerBuffer = 2

playerEdgeBuffer = 2
playerOceanBuffer = 5  
    


if(worldTerrainWidth <= 417) then -- Micro
    
    playerEdgeBuffer = 2
    playerOceanBuffer = 5  
    
elseif(worldTerrainWidth <= 513) then -- Small

    bayRadius = 5.5

elseif(worldTerrainWidth <= 641) then -- Medium
    
    bayRadius = 7.5
    edgeOceanWidth = 5
    bayMouthWidth = 3
    mountainRadius = 2
    
    playerEdgeBuffer = 3

elseif(worldTerrainWidth <= 769) then -- Large
        
    bayRadius = 9.5
    bayCentreCoord = {gridHalf - 2, gridHalf}
    edgeOceanWidth = 6
    bayMouthWidth = 5
    mountainRadius = 2.5
    smallMountainRadius = 2.5
    playerEdgeBuffer = 3
    
    holyIslandWidth = 3
    holyIslandLength = 7
        
else -- Gigantic
    bayRadius = 11.5
    bayCentreCoord = {gridHalf - 3, gridHalf}
    edgeOceanWidth = 7
    bayMouthWidth = 5
    mountainRadius = 2.5
    smallMountainRadius = 2.5
    playerEdgeBuffer = 3
    
    holyIslandWidth = 3
    holyIslandLength = 7
end

-- calc variables
secondaryMountainsPos = trigIsHard(bayRadius + 1, 45)
holyIslandLengthHalf = math.floor(holyIslandLength / 2)
bayMouthWidthHalf = math.floor(bayMouthWidth / 2)
-----------------
-- BUILD MAP!! --
-----------------

-- bay  mountains
if mapRotate then
    bayCentreCoordTemp = bayCentreCoord
    bayCentreCoord[1] = bayCentreCoordTemp[2]
    bayCentreCoord[2] = bayCentreCoordTemp[1]
    
      -- primary mountains  
    drawCircle({gridHalf - bayMouthWidthHalf - math.floor(mountainRadius), edgeOceanWidth + math.floor(mountainRadius)}, mountainRadius, t_m)
    drawCircle({gridHalf + bayMouthWidthHalf + math.floor(mountainRadius), edgeOceanWidth + math.floor(mountainRadius)}, mountainRadius, t_m)
    --secondary mountains
    drawCircle({gridHalf - secondaryMountainsPos[1], gridHalf + secondaryMountainsPos[2]}, smallMountainRadius, t_m)
    drawCircle({gridHalf + secondaryMountainsPos[1], gridHalf + secondaryMountainsPos[2] }, smallMountainRadius, t_m)
    
    
    -- the bay
    drawCircle(bayCentreCoord, bayRadius, t_water)
    drawRect(1, 1, gridSize, edgeOceanWidth, t_water)
    drawRect(gridHalf - bayMouthWidthHalf, 1, gridHalf + bayMouthWidthHalf, gridHalf, t_water)
    
    --Holy site island
    drawRect(gridHalf - holyIslandLengthHalf, 1, gridHalf + holyIslandLengthHalf, holyIslandWidth, t_beach)
    
else
    -- primary mountains
    drawCircle({gridSize - edgeOceanWidth - math.floor(mountainRadius), gridHalf - bayMouthWidthHalf - math.floor(mountainRadius)}, mountainRadius, t_m)
    drawCircle({gridSize - edgeOceanWidth - math.floor(mountainRadius), gridHalf + bayMouthWidthHalf + math.floor(mountainRadius)}, mountainRadius, t_m)
    --secondary mountains
    drawCircle({gridHalf - secondaryMountainsPos[1], gridHalf - secondaryMountainsPos[2]}, smallMountainRadius, t_m)
    drawCircle({gridHalf - secondaryMountainsPos[1], gridHalf + secondaryMountainsPos[2] }, smallMountainRadius, t_m)
    
    
    -- the bay
    drawCircle(bayCentreCoord, bayRadius, t_water)
    drawRect(gridSize - edgeOceanWidth, 1, gridSize, gridSize, t_water)
    drawRect(gridHalf, gridHalf - bayMouthWidthHalf, gridSize, gridHalf + bayMouthWidthHalf, t_water)
    
    --Holy site island
    drawRect(gridSize - holyIslandWidth + 1, gridHalf - holyIslandLengthHalf, gridSize, gridHalf + holyIslandLengthHalf, t_beach)

end






-- set all edge of land tiles to beach
landSquares = GetSquaresOfType(t_base, gridSize, terrainLayoutResult)
for i, landTile in ipairs(landSquares) do
	local row = landTile[1]
	local col = landTile[2]
   
    if Check4Neighbours(row, col, gridSize, t_water) then
        terrainLayoutResult[row][col].terrainType = t_beach
    end
end



-------------------
-- PLACE MAP FEATURES --
-------------------
if mapRotate then
    tradePostLoc1 = searchForTerrain(gridHalf, gridHalf, 0, 1, gridHalf, t_beach, t_beach)
    
    holySiteLocIslandLoc = {gridHalf, 1}
    holySiteLoc2 = {holySiteCornerBuffer, gridSize - holySiteCornerBuffer}
    holySiteLoc3 = {gridSize - holySiteCornerBuffer + 1, gridSize - holySiteCornerBuffer}
else
    tradePostLoc1 = searchForTerrain(gridHalf, gridHalf, -1, 0, gridHalf, t_beach, t_beach)   
    
    holySiteLocIslandLoc = {gridSize, gridHalf}
    holySiteLoc2 = {holySiteCornerBuffer, holySiteCornerBuffer}
    holySiteLoc3 = {holySiteCornerBuffer, gridSize - holySiteCornerBuffer + 1}
end

if(worldTerrainWidth >= 768) then
    if mapRotate then
        tradePostLoc2 = searchForTerrain(gridHalf, gridHalf, 0, -1, gridHalf, t_beach, t_beach)        
    else
        tradePostLoc2 = searchForTerrain(gridHalf, gridHalf, 1, 0, gridHalf, t_beach, t_beach)       
    end

    terrainLayoutResult[tradePostLoc2[1]][tradePostLoc2[2]].terrainType = tradeTerrain
    
end



if mapRotate then
    goldBountyLoc1 = {gridHalf - bayMouthWidthHalf - math.floor(mountainRadius) - 3, edgeOceanWidth + math.floor(mountainRadius) + 1}
    goldBountyLoc2 = {gridHalf + bayMouthWidthHalf + math.floor(mountainRadius) + 3, edgeOceanWidth + math.floor(mountainRadius) + 1}
else
    goldBountyLoc1 = {gridSize - edgeOceanWidth - math.floor(mountainRadius) -1, gridHalf - bayMouthWidthHalf - math.floor(mountainRadius) - 3}
    goldBountyLoc2 = {gridSize - edgeOceanWidth - math.floor(mountainRadius) -1, gridHalf + bayMouthWidthHalf + math.floor(mountainRadius) + 3}
   
end

terrainLayoutResult[tradePostLoc1[1]][tradePostLoc1[2]].terrainType = tradeTerrain

terrainLayoutResult[holySiteLocIslandLoc[1]][holySiteLocIslandLoc[2]].terrainType = holySiteIslandTerrain
terrainLayoutResult[holySiteLoc2[1]][holySiteLoc2[2]].terrainType = holySiteTerrain
terrainLayoutResult[holySiteLoc3[1]][holySiteLoc3[2]].terrainType = holySiteTerrain

terrainLayoutResult[goldBountyLoc1[1]][goldBountyLoc1[2]].terrainType = bonusGold
terrainLayoutResult[goldBountyLoc2[1]][goldBountyLoc2[2]].terrainType = bonusGold



-------------------
-- PLAYER SPAWNING -----
-------------------
teamsList, playersPerTeam = SetUpTeams()
teamMappingTable = CreateTeamMappingTable()
 
 
    minTeamDistance =  8
    minPlayerDistance = 4
    impasseDistance = 2
    edgeBuffer = 2
    innerExclusion = 0.5

    cornerThreshold = 1
    startBufferRadius = 1.5
    placeStartBuffer = true
    isVertical = true
    
    topSelectionThreshold = 0.2
    
    impasseTypes = {}
    table.insert(impasseTypes, t_m)
    table.insert(impasseTypes, t_water)
    table.insert(impasseTypes, t_beach)



--Set up Variables for MapSize
if(worldTerrainWidth <= 417) then
    -- Micro
    
elseif(worldTerrainWidth <= 513) then
    -- Small

    
elseif(worldTerrainWidth <= 641) then
    -- Medium


    
elseif(worldTerrainWidth <= 769) then
    -- Large

else
    -- giagantic

end



--Place players
if(worldPlayerCount == 2) then -- Micro

    if mapRotate then
        player1Loc = {1 + playerEdgeBuffer, edgeOceanWidth + playerOceanBuffer}
        player2Loc = {gridSize - playerEdgeBuffer, edgeOceanWidth + playerOceanBuffer}        
    else
        player1Loc = {gridSize - edgeOceanWidth - playerOceanBuffer, 1 + playerEdgeBuffer}
        player2Loc = {gridSize - edgeOceanWidth - playerOceanBuffer, gridSize - playerEdgeBuffer}
    end
    
    terrainLayoutResult[player1Loc[1]][player1Loc[2]].terrainType = playerStartTerrain
    terrainLayoutResult[player2Loc[1]][player2Loc[2]].terrainType = playerStartTerrain
    terrainLayoutResult[player1Loc[1]][player1Loc[2]].playerIndex = 0
    terrainLayoutResult[player2Loc[1]][player2Loc[2]].playerIndex = 1
    
elseif (#teamMappingTable == 2) then
    
    if mapRotate then
        team1Loc = {1 + playerEdgeBuffer, edgeOceanWidth + playerOceanBuffer}
        team2Loc = {gridSize - playerEdgeBuffer, edgeOceanWidth + playerOceanBuffer} 
    else
        team1Loc = {gridSize - edgeOceanWidth - playerOceanBuffer, 1 + playerEdgeBuffer}
        team2Loc = {gridSize - edgeOceanWidth - playerOceanBuffer, gridSize - playerEdgeBuffer}        
    end
    openTypes = {}
    table.insert(openTypes, tt_flatland)

    
   -- here we draw two bubbles of "flatland" terrain to place the players on. I'm not smart enough to figure out another way
    drawCircleOnTerrain(team1Loc, 8, tt_flatland, t_base)
    drawCircleOnTerrain(team2Loc, 8, tt_flatland, t_base)
    
    PlacePlayerStarts(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, impasseTypes, openTypes, playerStartTerrain, terrainLayoutResult)

  -- go over all the "flatland" terrain and replace it with plains again

    for row = 1, gridSize do
    	for col = 1, gridSize do
    		if (terrainLayoutResult[row][col].terrainType == tt_flatland) then
    		    terrainLayoutResult[row][col].terrainType = t_base  
    		end
    	end
    end
  
  
else
	terrainLayoutResult = PlacePlayerStartsRing(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, impasseTypes, impasseDistance, topSelectionThreshold, playerStartTerrain, startBufferTerrain, startBufferRadius, true, terrainLayoutResult)
end  




