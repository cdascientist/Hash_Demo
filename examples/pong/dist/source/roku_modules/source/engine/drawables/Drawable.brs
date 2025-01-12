' @module BGE
' Abstract drawable class - all drawables extend from this
function __BGE_Drawable_builder()
    instance = {}
    ' --------------Values That Can Be Changed------------
    ' The horizontal offset of the image from the owner's x position
    ' The vertical offset of the image from the owner's y position
    ' The image scale - horizontal
    ' The image scale - vertical
    ' Rotation of the image
    ' This can be used to tint the image with the provided color if desired. White makes no change to the original image.
    ' Change the image alpha (transparency).
    ' Whether or not the image will be drawn.
    ' Should the image be offset from teh owner, or from the canvas's origin?
    ' The canvas this will be drawn to (e.g. m.game.getCanvas())
    ' -------------Never To Be Manually Changed-----------------
    ' These values should never need to be manually changed.
    ' owner GameEntity
    instance.new = function(owner as object, canvasBitmap as object, args = {} as object) as void
        m.name = ""
        m.offset_x = 0
        m.offset_y = 0
        m.scale_x = 1.0
        m.scale_y = 1.0
        m.rotation = 0
        m.color = &hFFFFFF
        m.alpha = 255
        m.enabled = true
        m.offsetPositionFromOwner = true
        m.drawTo = invalid
        m.owner = invalid
        m.width = 0
        m.height = 0
        m.shouldRedraw = false
        m.owner = owner
        m.drawTo = canvasBitmap
        m.append(args)
    end function
    ' Sets the scale of the drawable
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
    ' Sets the canvas this will draw to
    '
    ' @param {object} [canvas] The canvas (roBitmap) this should draw to
    instance.setCanvas = sub(canvas as object)
        m.drawTo = canvas
    end sub
    instance.getDrawPosition = function() as object
        x = m.offset_x
        y = m.offset_y
        if invalid <> m.owner and m.offsetPositionFromOwner
            x += m.owner.x
            y += m.owner.y
        end if
        return {
            x: x
            y: y
        }
    end function
    instance.draw = function(additionalRotation = 0 as float) as void
    end function
    instance.onResume = function(pausedTimeMs as integer)
    end function
    ' Forces a redraw of this drawable on next frame
    ' By default, some drawables that need to do preprocessing (text, polygons, etc) will only redraw automatically
    ' if their dimensions or underlying values change --
    '
    instance.forceRedraw = function() as void
        m.shouldRedraw = true
    end function
    instance.getSize = function() as object
        return {
            width: m.width
            height: m.height
        }
    end function
    instance.getDrawnSize = function() as object
        return {
            width: m.width * m.scale_x
            height: m.height * m.scale_y
        }
    end function
    instance.getFillColorRGBA = function(ignoreColor = false as boolean) as integer
        rgba = (function(__bsCondition, BGE, int, m)
                if __bsCondition then
                    return BGE_Colors().White
                else
                    return (m.color << 8) + int(m.alpha)
                end if
            end function)(ignoreColor, BGE, int, m)
        return rgba
    end function
    instance.drawRegionToCanvas = function(draw2d as object, additionalRotation = 0 as float, ignoreColor = false as boolean) as void
        position = m.getDrawPosition()
        x = position.x
        y = position.y
        rgba = m.getFillColorRGBA(ignoreColor)
        totalRotation = additionalRotation + m.rotation
        if m.scale_x = 1 and m.scale_y = 1 and totalRotation = 0
            m.drawTo.DrawObject(x, y, draw2d, rgba)
        else if totalRotation = 0
            m.drawTo.DrawScaledObject(x, y, m.scale_x, m.scale_y, draw2d, rgba)
        else if m.scale_x = 1 and m.scale_y = 1
            m.drawTo.DrawRotatedObject(x, y, - totalRotation, draw2d, rgba)
        else
            BGE_DrawScaledAndRotatedObject(m.drawTo, x, y, m.scale_x, m.scale_y, - totalRotation, draw2d, rgba)
        end if
    end function
    return instance
end function
function BGE_Drawable(owner as object, canvasBitmap as object, args = {} as object)
    instance = __BGE_Drawable_builder()
    instance.new(owner, canvasBitmap, args)
    return instance
end function
function __BGE_DrawableWithOutline_builder()
    instance = __BGE_Drawable_builder()
    ' Draw an outline stroke of outlineRGBA color
    ' RGBA color for outline stroke
    instance.super0_new = instance.new
    instance.new = function(owner as object, canvasBitmap as object, args = {} as object) as void
        m.super0_new(owner, canvasBitmap, args)
        m.drawOutline = false
        m.outlineRGBA = BGE_Colors().White
    end function
    return instance
end function
function BGE_DrawableWithOutline(owner as object, canvasBitmap as object, args = {} as object)
    instance = __BGE_DrawableWithOutline_builder()
    instance.new(owner, canvasBitmap, args)
    return instance
end function'//# sourceMappingURL=./Drawable.bs.map