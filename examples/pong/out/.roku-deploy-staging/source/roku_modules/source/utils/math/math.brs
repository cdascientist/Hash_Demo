' @module BGE.Math
function BGE_Math_Min(a as dynamic, b as dynamic) as dynamic
    if a <= b
        return a
    end if
    return b
end function

function BGE_Math_Max(a as dynamic, b as dynamic) as dynamic
    if a >= b
        return a
    end if
    return b
end function

function BGE_Math_Clamp(number as dynamic, minVal as dynamic, maxVal as dynamic) as dynamic
    if number < minVal
        return minVal
    else if number > maxVal
        return maxVal
    else
        return number
    end if
end function

function BGE_Math_PI() as float
    return 3.1415926535897932384626433832795
end function

function BGE_Math_Atan2(y as float, x as float) as float
    piValue = BGE_Math_PI()
    if x > 0
        angle = Atn(y / x)
    else if y >= 0 and x < 0
        angle = Atn(y / x) + BGE_Math_pi
    else if y < 0 and x < 0
        angle = Atn(y / x) - BGE_Math_pi
    else if y > 0 and x = 0
        angle = piValue / 2
    else if y < 0 and x = 0
        angle = (piValue / 2) * - 1
    else
        angle = 0
    end if
    return angle
end function

function BGE_Math_IsIntegerEven(number as integer) as boolean
    return (number MOD 2 = 0)
end function

function BGE_Math_IsIntegerOdd(number as integer) as boolean
    return (number MOD 2 <> 0)
end function

function BGE_Math_Power(number as dynamic, pow as integer) as dynamic
    n = 1
    for i = 0 to pow - 1
        n *= number
    end for
    return n
end function

function BGE_Math_Round(number as float, decimals = 0 as integer) as float
    if 0 = decimals
        return cint(number)
    else
        magnitude = BGE_Math_Power(10, decimals)
        return cint(number * magnitude) / magnitude
    end if
end function

function BGE_Math_DegreesToRadians(degrees as float) as float
    return (degrees / 180) * BGE_Math_PI()
end function

function BGE_Math_RadiansToDegrees(radians as float) as float
    return (180 / BGE_Math_PI()) * radians
end function

function BGE_Math_RandomRange(lowest_int as integer, highest_int as integer) as integer
    return rnd(highest_int - (lowest_int - 1)) + (lowest_int - 1)
end function

function BGE_Math_RotateVectorAroundVector(vector1 as object, vector2 as object, radians as float) as object
    v = BGE_Math_Vector2d(vector1.x, vector1.y)
    s = sin(radians)
    c = cos(radians)
    v.x -= vector2.x
    v.y -= vector2.y
    new_x = v.x * c + v.y * s
    new_y = - v.x * s + v.y * c
    v.x = new_x + vector2.x
    v.y = new_y + vector2.y
    return v
end function

function BGE_Math_TotalDistance(vector1 as object, vector2 as object) as float
    x_distance = vector1.x - vector2.x
    y_distance = vector1.y - vector2.y
    total_distance = Sqr(x_distance * x_distance + y_distance * y_distance)
    return total_distance
end function

function BGE_Math_GetAngle(vector1 as object, vector2 as object) as float
    x_distance = vector1.x - vector2.x
    y_distance = vector1.y - vector2.y
    return BGE_Math_Atan2(y_distance, x_distance) + BGE_Math_PI()
end function
function __BGE_Math_Rectangle_builder()
    instance = {}
    instance.new = function(x as float, y as float, width as float, height as float) as void
        m.x = 0
        m.y = 0
        m.width = 0
        m.height = 0
        m.x = x
        m.y = y
        m.width = width
        m.height = height
    end function
    instance.right = function() as float
        return m.x + m.width
    end function
    instance.left = function() as float
        return m.x
    end function
    instance.top = function() as float
        return m.y
    end function
    instance.bottom = function() as float
        return m.y + m.height
    end function
    instance.center = function() as object
        return {
            x: m.x + m.width / 2
            y: m.y + m.height / 2
        }
    end function
    instance.copy = function() as object
        return BGE_Math_Rectangle(m.x, m.y, m.width, m.height)
    end function
    return instance
end function
function BGE_Math_Rectangle(x as float, y as float, width as float, height as float)
    instance = __BGE_Math_Rectangle_builder()
    instance.new(x, y, width, height)
    return instance
end function
function __BGE_Math_Circle_builder()
    instance = {}
    instance.new = function(x as float, y as float, radius as float) as void
        m.x = invalid
        m.y = invalid
        m.radius = invalid
        m.x = x
        m.y = y
        m.radius = radius
    end function
    return instance
end function
function BGE_Math_Circle(x as float, y as float, radius as float)
    instance = __BGE_Math_Circle_builder()
    instance.new(x, y, radius)
    return instance
end function
function __BGE_Math_Vector2d_builder()
    instance = {}
    instance.new = function(x = 0 as float, y = 0 as float) as void
        m.x = invalid
        m.y = invalid
        m.x = x
        m.y = y
    end function
    return instance
end function
function BGE_Math_Vector2d(x = 0 as float, y = 0 as float)
    instance = __BGE_Math_Vector2d_builder()
    instance.new(x, y)
    return instance
end function'//# sourceMappingURL=./math.bs.map