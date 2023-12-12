
-- Gets all the squares in a triangle between 3 points
-- point1, point2, point3 are tables defined as {row, col} of the point 
function getSquaresInTriangle(point1, point2, point3)
    
    tiles = {}
    
    local function sign(p1, p2, p3)
        return (p1[2] - p3[2]) * (p2[1] - p3[1]) - (p2[2] - p3[2]) * (p1[1] - p3[1])
    end



    local function pointInTriangle(point, v1, v2, v3)
    
        local d1 = 0
        local d2 = 0
        local d3 = 0
        
        local hasNeg = false
        local hasPos = false

    
        d1 = sign(point, v1, v2)
        d2 = sign(point, v2, v3)
        d3 = sign(point, v3, v1)
    
        hasNeg = (d1 < 0) or (d2 < 0) or (d3 < 0)
        hasPos = (d1 > 0) or (d2 > 0) or (d3 > 0)
    
        return not (hasNeg and hasPos)
    end   

    for row = 1, gridSize do
    	for col = 1, gridSize do
    		
    		local currentTile = {row, col}
    		
            if pointInTriangle(currentTile, point1, point2, point3) then
                table.insert(tiles, currentTile)
            end
    		    
		end
	end
    return tiles
end


-- Draws a terrain type on all the squares in a triangle between 3 points
-- point1, point2, point3 are tables defined as {row, col} of the point 
-- terrainToDraw is the terrain to draw 
function drawTriangle(point1, point2, point3, terrainToDraw)
  
    local function sign(p1, p2, p3)
        return (p1[2] - p3[2]) * (p2[1] - p3[1]) - (p2[2] - p3[2]) * (p1[1] - p3[1])
    end


    local function pointInTriangle(point, v1, v2, v3)
    
        local d1 = 0
        local d2 = 0
        local d3 = 0
        
        local hasNeg = false
        local hasPos = false

    
        d1 = sign(point, v1, v2)
        d2 = sign(point, v2, v3)
        d3 = sign(point, v3, v1)
    
        hasNeg = (d1 < 0) or (d2 < 0) or (d3 < 0)
        hasPos = (d1 > 0) or (d2 > 0) or (d3 > 0)
    
        return not (hasNeg and hasPos)
    end   

    for row = 1, gridSize do
    	for col = 1, gridSize do
    		
    		local currentTile = {row, col}
    		
            if pointInTriangle(currentTile, point1, point2, point3) then
                terrainLayoutResult[currentTile[1]][currentTile[2]].terrainType = terrainToDraw  
            end
    		    
		end
	end

end















