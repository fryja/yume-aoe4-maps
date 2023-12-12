
-- Draws a rectangle between two defined points of a certain terrain. Works with the two points in any corners of the rectangle.
-- startRow, startCol is the start row and col of the rectangle
-- endRow, endCol is the end point of the rectangle 
-- pickedTerrain is the terrain you wish to draw
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