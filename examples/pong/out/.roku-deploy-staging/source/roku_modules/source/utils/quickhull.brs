' Gets a series of triangles for the convex space defined by an array of {x,y} points
'
' @param {object} pointsArray - array of {x,y} objects
' @param {boolean} hull - perform a quick hull operation
' @return {object} array of triangles, each is array of 3 {x,y} points
function BGE_QuickHull_getTrianglesFromPoints(pointsArray = [] as object, hull = true as boolean) as object
    triangles = []
    if pointsArray.count() < 3
        return []
    end if
    if hull
        pointsArray = BGE_QuickHull_QuickHull(pointsArray)
    end if
    apex = pointsArray[0]
    for i = 1 to pointsArray.count() - 2
        tri = []
        tri.push(apex)
        tri.push(pointsArray[i])
        tri.push(pointsArray[i + 1])
        triangles.push(tri)
    end for
    return triangles
end function

' Implementation of the QuickHull algorithm for finding convex hull of a set of points
' Modified from: https://github.com/claytongulick/quickhull
' Original author Clay Gulick
' @param {object} pointsArray - array of {x,y} objects
' @return {object} the minimal set of points for a convex hull
function BGE_QuickHull_QuickHull(pointsArray = [] as object) as object
    hull = []
    'if there are only three points, this is a triangle, which by definition is already a hull
    if pointsArray.count() = 3
        return pointsArray
    end if
    baseline = BGE_QuickHull_getMinMaxPoints(pointsArray)
    BGE_QuickHull_addSegments(hull, baseline, pointsArray)
    BGE_QuickHull_addSegments(hull, [
        baseline[1]
        baseline[0]
    ], pointsArray) ' reverse line direction to get points on other side
    return hull
end function

' Gets the min and max points in the set along the X axis
' modified from https:'github.com/claytongulick/quickhull
' @param {Array} pointsArray - An array of {x,y} objects
' @return {object} array [ {x,y}, {x,y} ]
function BGE_QuickHull_getMinMaxPoints(pointsArray = [] as object, vertical = false as boolean) as object
    minPoint = pointsArray[0]
    maxPoint = pointsArray[0]
    for i = 1 to pointsArray.count() - 1
        if not vertical
            if pointsArray[i].x < minPoint.x
                minPoint = pointsArray[i]
            end if
            if pointsArray[i].x > maxPoint.x
                maxPoint = pointsArray[i]
            end if
        else
            if pointsArray[i].y < minPoint.y
                minPoint = pointsArray[i]
            end if
            if pointsArray[i].y > maxPoint.y
                maxPoint = pointsArray[i]
            end if
        end if
    end for
    return [
        minPoint
        maxPoint
    ]
end function

'
' Gets the total width from first point to last point horizontally, and the offset of the first point
'
' @param {object} [pointsArray=[]] array of {x,y} objects
' @return {object}
function BGE_QuickHull_getMaxWidthAndHorizontalOffset(pointsArray = [] as object) as object
    if pointsArray.count() < 1
        return invalid
    end if
    minMax = BGE_QuickHull_getMinMaxPoints(pointsArray)
    return {
        width: minMax[1].x - minMax[0].x
        offset: minMax[0].x
    }
end function

' Gets the total height from first point to last point vertically, and the offset of the first point
'
' @param {object} [pointsArray=[]] array of {x,y} objects
' @return {object} object with {height as float, offset as float}
function BGE_QuickHull_getMaxHeightAndVerticalOffset(pointsArray = [] as object) as object
    if pointsArray.count() < 1
        return invalid
    end if
    minMax = BGE_QuickHull_getMinMaxPoints(pointsArray, true)
    return {
        height: minMax[1].y - minMax[0].y
        offset: minMax[0].y
    }
end function

' Calculates the distance of a point from a line
' modified from https:'github.com/claytongulick/quickhull
' @param {Array} point - Array [x,y]
' @param {Array} line - Array of two points [ [x1,y1], [x2,y2] ]
' return {float}
function BGE_QuickHull_distanceFromLine(point as object, line as object) as float
    vY = line[1].y - line[0].y
    vX = line[0].x - line[1].x
    return (vX * (point.y - line[0].y) + vY * (point.x - line[0].x))
end function

' Determines the set of points that lay outside the line (positive), and the most distal point
' Returns: {points: [ [x1, y1], ... ], max: [x,y] ]
' @param points
' @param line
function BGE_QuickHull_distalPoints(line as object, points as object) as object
    outerPoints = []
    point = points[0]
    distalPoint = invalid
    distance = 0
    maxDistance = 0
    for each point in points
        distance = BGE_QuickHull_distanceFromLine(point, line)
        if distance > 0
            outerPoints.push(point)
            if distance > maxDistance
                distalPoint = point
                maxDistance = distance
            end if
        end if
    end for
    return {
        points: outerPoints
        max: distalPoint
    }
end function

' Recursively adds hull segments
' @param line
' @param points
'
function BGE_QuickHull_addSegments(hull as object, line as object, points as object) as void
    distal = BGE_QuickHull_distalPoints(line, points)
    if invalid = distal.max
        hull.push(line[0])
        return
    end if
    BGE_QuickHull_addSegments(hull, [
        line[0]
        distal.max
    ], distal.points)
    BGE_QuickHull_addSegments(hull, [
        distal.max
        line[1]
    ], distal.points)
end function'//# sourceMappingURL=./quickhull.bs.map