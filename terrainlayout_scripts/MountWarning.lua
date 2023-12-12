-----------------------------
------- Mount Warning ----------
------- by Yume -------------
------- version 1.2 ---------
--[[
1.0
- Release

1.1
- Decreased mountain size on Medium and Large maps 
- increased resource bounties in corners on large maps. 
- Reworked sacred site and tradepost generation to hopefully ensure they spawn.

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
mapHalfSize = math.ceil(gridSize/2)
mapQuarterSize = math.ceil(gridSize/4)
mapEighthSize = math.ceil(gridSize/8)
mapSize = 1

-- start map
debug = false
if debug then
	playerTeams = {}
	worldPlayerCount = 4
	playerTeams[1] = 1 --player 1 on team 1
	playerTeams[2] = 1 --player 2 on team 1
	playerTeams[3] = 2 --player 3 on team 2
	playerTeams[4] = 2 --player 4 on team 2
--	playerTeams[5] = 2 --player 5 on team 3
--	playerTeams[6] = 2 --player 6 on team 3
--	playerTeams[7] = 2 --player 7 on team 3
--	playerTeams[8] = 2 --player 8 on team 3
end


p = tt_plains
n = tt_none
h = tt_hills
s = tt_mountains_small
m = tt_mountains
spire = tt_rock_pillar
lowhills = tt_hills_low_rolling

plateau = tt_plateau_standard

forest = tt_impasse_trees_hills

lake = tt_swamp_shallow
trees = tt_forest_natural_small

tradeTerrain = tt_settlement_hills_wveg
holySite = tt_holy_site_hill_danger_lite

playerStartTerrain = tt_player_start_classic_plains
startBufferTerrain = tt_plains

bonusStone = tt_tactical_region_stone_plateau_med_a
bonusGold = tt_tactical_region_gold_plateau_med_a



-- fill grid default
terrainLayoutResult = SetUpGrid(gridSize, plateau, terrainLayoutResult)

------------------
--- FUNCTIONS ----
------------------

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

function moveOut(currentRow, currentCol, gridSize, distance)
    local newCoord = { }
    local halfSize = math.ceil(gridSize / 2)
    
    if currentRow < halfSize then
        newCoord[1] = currentRow - distance
    elseif currentRow == halfSize then
        newCoord[1] = currentRow
    else
        newCoord[1] = currentRow + distance
    end
    if currentCol < halfSize then
        newCoord[2] = currentCol - distance
    elseif currentCol == halfSize then
        newCoord[2] = currentCol
    else
        newCoord[2] = currentCol + distance
    end
    
    return newCoord     
end


-----------------
-- BUILD MAP!! --
-----------------

-- Map Vars
mtRadius = 2
calderaRadius = mapHalfSize - 2.5
lakesRadius = math.floor(calderaRadius) - 1
forestsRadius = math.floor(calderaRadius) 
rampChance = 0.35
lakeChance = 0.06
forestChance = 0.04

--Player place variables
minPlayerDistance = 3
minTeamDistance =  10
innerExclusion = 0.4
edgeBuffer = 1
cornerThreshold = 1

--Set up Variables for MapSize
if(worldTerrainWidth <= 417) then
    -- Micro
    mapSize = 1
    
    minTeamDistance =  10

elseif(worldTerrainWidth <= 513) then
    -- Small
    mapSize = 2
    
    mtRadius = 3
    minTeamDistance =  12
    minPlayerDistance = 6
    edgeBuffer = 3
	
elseif(worldTerrainWidth <= 641) then
    -- Medium
    mapSize = 3
    
    mtRadius = 3
	minPlayerDistance = 7
    minTeamDistance =  15
	
    bonusGold = tt_tactical_region_gold_plateau_med_d

    
elseif(worldTerrainWidth <= 769) then
    -- Large
    mapSize = 4
    
    mtRadius = 4
    calderaRadius = mapHalfSize - 3
    minPlayerDistance = 6
  
    bonusGold = tt_tactical_region_gold_plateau_med_d
	
else
    -- giagantic
    mapSize = 5
    
    mtRadius = 4
    calderaRadius = mapHalfSize - 3.5
	minPlayerDistance = 7
	innerExclusion = 0.5


    bonusGold = tt_tactical_region_gold_plateau_med_e

end




-- Draw caldera




drawCircle({ row = mapHalfSize, col = mapHalfSize }, calderaRadius + 1, n) -- draw a border around caldera of TT NONE to find it later
drawCircle({ row = mapHalfSize, col = mapHalfSize }, calderaRadius, p)

--place lakes and forests

drawRandomInCircle({ row = mapHalfSize, col = mapHalfSize }, lakesRadius, lake, lakeChance)
drawRandomInCircle({ row = mapHalfSize, col = mapHalfSize }, forestsRadius, trees, forestChance)

-- Draw mountain
if (worldTerrainWidth >= 896) then
    drawCircle({ row = mapHalfSize, col = mapHalfSize }, mtRadius +2, forest)
else 
    drawCircle({ row = mapHalfSize, col = mapHalfSize }, mtRadius +1, forest)
end
drawCircle({ row = mapHalfSize, col = mapHalfSize }, mtRadius, spire)



--drawNumberOfTilesInRingRandom(mapHalfSize, mapHalfSize, numRampTiles, h, math.floor(calderaRadius), 1, { tt_none, tt_plains, plateau }, terrainLayoutResult)


--grab a list of all caldera edge squares, exclusing the ones near where the player starts

calderaEdgeSquares = {}
for row = 1, gridSize do
	for col = 1, gridSize do
		
		if(terrainLayoutResult[row][col].terrainType == n) then -- if its a ring square
			calderaNeighbors = {}
			calderaNeighbors = GetNeighbors(row, col, terrainLayoutResult)
			for calderaCheckIndex, calderaCheckNeighbor in ipairs(calderaNeighbors) do	
				currentCalderaCheckNeighborRow = calderaCheckNeighbor.x
				currentCalderaCheckNeighborCol = calderaCheckNeighbor.y
				
				hasNearbyStartArea = false
				startCheckSquares = {}
				startCheckSquares = Get20Neighbors(currentCalderaCheckNeighborRow, currentCalderaCheckNeighborCol, terrainLayoutResult)
				
				for startCheckIndex, startCheckNeighbor in ipairs(startCheckSquares) do	
					currentStartCheckNeighborRow = startCheckNeighbor.x
					currentStartCheckNeighborCol = startCheckNeighbor.y
					
					if(terrainLayoutResult[currentStartCheckNeighborRow][currentStartCheckNeighborCol].terrainType == playerStartTerrain) then
						hasNearbyStartArea = true
					end
				end
				
				currentCalderaCheckTT = terrainLayoutResult[currentCalderaCheckNeighborRow][currentCalderaCheckNeighborCol].terrainType
				if(currentCalderaCheckTT == p) then
					if(Table_ContainsCoordinate(calderaEdgeSquares, calderaCheckNeighbor) == false) then
						if(hasNearbyStartArea == false) then
							newInfo = {}
							newInfo = {currentCalderaCheckNeighborRow, currentCalderaCheckNeighborCol}
							table.insert(calderaEdgeSquares, newInfo)
						end
					end
				end
			end
		end
	end
end


-- Randomly add hills around the edge of the caldera to transition up to the plateu
for edgeIndex = 1, #calderaEdgeSquares do
	currentEdgeRow = calderaEdgeSquares[edgeIndex][1]
	currentEdgeCol = calderaEdgeSquares[edgeIndex][2]
	if (worldGetRandom() < rampChance) then
	    terrainLayoutResult[currentEdgeRow][currentEdgeCol].terrainType = lowhills
	end

end


for row = 1, gridSize do
	for col = 1, gridSize do
		if(terrainLayoutResult[row][col].terrainType == n) then
			terrainLayoutResult[row][col].terrainType = plateau
		end
	end
end



-------------------
-- PLACE PLAYERS --
-------------------
teamsList, playersPerTeam = SetUpTeams()
teamMappingTable = CreateTeamMappingTable()



startBufferRadius = 2
placeStartBuffer = true

impasseTypes = {}
table.insert(impasseTypes, settlement)
table.insert(impasseTypes, tt_beach)
table.insert(impasseTypes, plateau)

impasseDistance = 1.5
topSelectionThreshold = 0.02
--Place players
terrainLayoutResult = PlacePlayerStartsRing(teamMappingTable, minTeamDistance, minPlayerDistance, edgeBuffer, innerExclusion, cornerThreshold, impasseTypes, impasseDistance, topSelectionThreshold, playerStartTerrain, startBufferTerrain, startBufferRadius, placeStartBuffer, terrainLayoutResult)


-------------------
-- PLACE MAP FEATURES --
-------------------
valleyTiles = GetSquaresOfType(p, gridSize, terrainLayoutResult)
forestTiles = GetSquaresOfType(forest, gridSize, terrainLayoutResult)
avoidTiles = GetSquaresOfType(playerStartTerrain, gridSize, terrainLayoutResult)


-- place settlements
--returns the square from openSquares that is furthest away from the closedSquares
settlementLoc = GetFurthestSquareFromSquares(calderaEdgeSquares, avoidTiles)
holySiteLoc = GetFurthestSquareFromSquares(forestTiles, avoidTiles)
table.insert(avoidTiles, settlementLoc)
table.insert(avoidTiles, holySiteLoc)

-- second settlement location avoids the first, theoretically the opposite side of the map...

newSettlementLoc = moveOut(settlementLoc[1],settlementLoc[2], gridSize, -1)
terrainLayoutResult[newSettlementLoc[1]][newSettlementLoc[2]].terrainType = tradeTerrain

newHolySiteLoc = moveOut(holySiteLoc[1],holySiteLoc[2], gridSize, 2)
terrainLayoutResult[newHolySiteLoc[1]][newHolySiteLoc[2]].terrainType = holySite

mirrorTile(newSettlementLoc[1], newSettlementLoc[2], gridSize)
mirrorTile(newHolySiteLoc[1], newHolySiteLoc[2], gridSize)

terrainLayoutResult[1][1].terrainType = bonusGold
terrainLayoutResult[gridSize][gridSize].terrainType = bonusGold
terrainLayoutResult[1][gridSize].terrainType = bonusGold
terrainLayoutResult[gridSize][1].terrainType = bonusGold





