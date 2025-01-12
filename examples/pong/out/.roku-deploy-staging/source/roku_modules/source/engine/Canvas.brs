' @module BGE
' Contains a roku roBitmap which all game objects get drawn to.
function __BGE_Canvas_builder()
    instance = {}
    ' bitmap GameEntity images get drawn to
    'horizontal position offset from screen coordinates
    ' vertical position offset from screen coordinates
    ' horizontal scale
    'vertical scale
    ' Creates a Canvas object and bitmap
    '
    ' @param {integer} canvasWidth - width of canvas
    ' @param {integer} canvasHeight - height of canvas
    instance.new = function(canvasWidth as integer, canvasHeight as integer) as void
        m.bitmap = invalid
        m.offset_x = 0.0
        m.offset_y = 0.0
        m.scale_x = 1.0
        m.scale_y = 1.0
        m.setSize(canvasWidth, canvasHeight)
    end function
    ' Changes the size of the canvas
    '
    ' @param {integer} canvasWidth - width of canvas
    ' @param {integer} canvasHeight - height of canvas
    instance.setSize = function(canvasWidth as integer, canvasHeight as integer) as void
        m.bitmap = CreateObject("roBitmap", {
            width: canvasWidth
            height: canvasHeight
            AlphaEnable: true
        })
    end function
    ' Gets the offset of the canvas from the screen
    '
    ' @return {object} - Position as object: {x, y}
    instance.getOffset = function() as object
        return {
            x: m.offset_x
            y: m.offset_y
        }
    end function
    ' Gets the scale of the canvas
    '
    ' @return {object} - Scale as object: {x, y}
    instance.getScale = function() as object
        return {
            x: m.scale_x
            y: m.scale_y
        }
    end function
    ' Sets the offset of the canvase.
    ' This is as Float to allow incrementing by less than 1 pixel, it is converted to integer internally
    '
    '
    ' @param {float} x - x offset
    ' @param {float} y - y offset
    instance.setOffset = function(x as float, y as float) as void
        m.offset_x = x
        m.offset_y = y
    end function
    ' Sets the scale of the canvas
    '
    ' @param {float} scale_x - horizontal scale
    ' @param {dynamic} [scale_y=invalid] - vertical scale, or if invalid, use the horizontal scale as vertical scale
    instance.setScale = function(scale_x as float, scale_y = invalid as dynamic) as void
        if scale_y = invalid
            scale_y = scale_x
        end if
        m.scale_x = scale_x
        m.scale_y = scale_y
    end function
    ' Gets the width of the underlying bitmap
    '
    ' @return {integer}
    instance.getWidth = function() as integer
        if invalid <> m.bitmap
            return m.bitmap.getWidth()
        end if
        return - 1
    end function
    ' Gets the height of the underlying bitmap
    '
    ' @return {integer}
    instance.getHeight = function() as integer
        if invalid <> m.bitmap
            return m.bitmap.getHeight()
        end if
        return - 1
    end function
    return instance
end function
function BGE_Canvas(canvasWidth as integer, canvasHeight as integer)
    instance = __BGE_Canvas_builder()
    instance.new(canvasWidth, canvasHeight)
    return instance
end function'//# sourceMappingURL=./Canvas.bs.map