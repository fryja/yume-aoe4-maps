-- Takes a start point and end point and returns specified number of points (in a table) that are evenly spaced along that line
-- startRow, startCol is the start point of the line
-- endRow, endCol is the end point of the line 
-- numPoints is the number of points you want to grab along that line, eg. 2 will return a point at 1/3, 2/3 along the line.
-- randomRow, randomCol shifts the points a random amount in the row and col axis before returning them
-- addStartPoint, andEndPoint are booleans that if set to true, will add the start point or end point of the line respectivly into the returned table, independant of the numPoints 
-- shift allows you to shift up/down the line the returned points. Accepts negative values to shift towards the start point and positive towards the end point.
-- terrainGridSize is your gridSize variable
-- terrainLayoutTable is your terrainLayoutResult variable 
function pointsAlongLine(startRow, startCol, endRow, endCol, numPoints, randomRow, randomCol, addStartPoint, addEndPoint, shiftAmount, terrainGridSize, terrainLayoutTable)
    
    local spacedPoints = {}   
    local points = DrawStraightLineReturn(startRow, startCol, endRow, endCol, false, tt_none, terrainGridSize, terrainLayoutTable)
    local division = math.floor(#points / (numPoints + 1) + shiftAmount)

    
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