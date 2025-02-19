' @module BGE
' Draws text to the screen
'
' @param {object} draw2d The iDraw2d instance to use
' @param {string} text the test to display
' @param {integer} x
' @param {integer} y
' @param {object} font Font object to use
' @param {string} [alignment="left"] Alignment - "left", "right" or "center"
' @param {integer} [color=-1] RGBA color to use
sub BGE_drawText(draw2d as object, text as string, x as integer, y as integer, font as object, alignment = "left" as string, color = - 1 as integer) as void
    if draw2d = invalid
        return
    end if
    if alignment = "left"
        draw2d.DrawText(text, x, y, color, font)
    else if alignment = "right"
        draw2d.DrawText(text, x - font.GetOneLineWidth(text, 10000), y, color, font)
    else if alignment = "center"
        draw2d.DrawText(text, x - font.GetOneLineWidth(text, 10000) / 2, y, color, font)
    end if
end sub

' NOTE: This function is unsafe! It creates an roBitmap of the required size to be able to both scale and rotate the drawing, this action requires free video memory of the appropriate amount.
function BGE_DrawScaledAndRotatedObject(draw2d as object, x as float, y as float, scale_x as float, scale_y as float, theta as float, drawable as object, color = - 1 as integer) as void
    new_width = Abs(int(drawable.GetWidth() * scale_x))
    new_height = Abs(int(drawable.GetHeight() * scale_y))
    if new_width <> 0 and new_height <> 0
        scaledBitmap = CreateObject("roBitmap", {
            width: new_width
            height: new_height
            AlphaEnable: true
        })
        scaledRegion = CreateObject("roRegion", scaledBitmap, 0, 0, new_width, new_height)
        pretranslation_x = drawable.GetPretranslationX()
        pretranslation_y = drawable.GetPretranslationY()
        newPreX = pretranslation_x * scale_x
        if scale_x < 0
            newPreX = - newPreX
        end if
        newPreY = pretranslation_y * scale_y
        if scale_y < 0
            newPreY = - newPreY
        end if
        scaledRegion.setPretranslation(- Abs(newPreX), - Abs(newPreY))
        scaled_draw_x = Abs(newPreX)
        scaled_draw_y = Abs(newPreY)
        scaledRegion.DrawScaledObject(scaled_draw_x, scaled_draw_y, scale_x, scale_y, drawable)
        draw2d.ifDraw2D.DrawRotatedObject(x, y, theta, scaledRegion, color)
    end if
end function

function BGE_TexturePacker_GetRegions(atlas as dynamic, bitmap as object) as object
    if type(atlas) = "String" or type(atlas) = "roString"
        atlas = ParseJson(atlas)
    end if
    regions = {}
    for each key in atlas.frames
        item = atlas.frames[key]
        region = CreateObject("roRegion", bitmap, item.frame.x, item.frame.y, item.frame.w, item.frame.h)
        if item.DoesExist("pivot")
            translation_x = item.spriteSourceSize.x - item.sourceSize.w * item.pivot.x
            translation_y = item.spriteSourceSize.y - item.sourceSize.h * item.pivot.y
            region.SetPretranslation(translation_x, translation_y)
        end if
        regions[key] = region
    end for
    return regions
end function

' -----------------------Utilities Used By Game Engine---------------------------
function BGE_ArrayInsert(array as object, index as integer, value as dynamic) as object
    for i = array.Count() to index + 1 step - 1
        array[i] = array[i - 1]
    end for
    array[index] = value
    return array
end function

sub BGE_DrawCircleOutline(draw2d as object, line_count as integer, x as float, y as float, radius as float, rgba as integer)
    if draw2d = invalid
        return
    end if
    previous_x = radius
    previous_y = 0
    for i = 0 to line_count
        degrees = 360 * (i / line_count)
        current_x = cos(degrees * .01745329) * radius
        current_y = sin(degrees * .01745329) * radius
        draw2d.DrawLine(x + previous_x, y + previous_y, x + current_x, y + current_y, rgba)
        previous_x = current_x
        previous_y = current_y
    end for
end sub

sub BGE_DrawRectangleOutline(draw2d as object, x as float, y as float, width as float, height as float, rgba as integer)
    if draw2d = invalid
        return
    end if
    draw2d.DrawLine(x, y, x + width, y, rgba)
    draw2d.DrawLine(x, y, x, y + height, rgba)
    draw2d.DrawLine(x + width, y, x + width, y + height, rgba)
    draw2d.DrawLine(x, y + height, x + width, y + height, rgba)
end sub

function BGE_isValidEntity(entity as object) as boolean
    return invalid <> entity and entity.id <> invalid
end function

' 	' -------Button Code Reference--------
' 	' Button  Pressed Released  Held
'   ' ------------------------------
' 	' Back         0      100   1000
' 	' Up           2      102   1002
' 	' Down         3      103   1003
' 	' Left         4      104   1004
' 	' Right        5      105   1005
' 	' OK           6      106   1006
' 	' Replay       7      107   1007
' 	' Rewind       8      108   1008
' 	' FastForward  9      109   1009
' 	' Options     10      110   1010
' 	' Play        13      113   1013
function BGE_buttonNameFromCode(buttonCode as integer) as string
    buttonId = buttonCode mod 100
    possibleButtonNames = [
        "back"
        "unknown"
        "up"
        "down"
        "left"
        "right"
        "OK"
        "replay"
        "rewind"
        "fastforward"
        "options"
        "audioguide"
        "unknown"
        "play"
    ]
    if buttonId < possibleButtonNames.count()
        return possibleButtonNames[buttonId]
    end if
    return invalid
end function

' Clone an array (shallow)
'
' @param {object} [original=[]] the original array to be clones
' @return {object} A shallow copy of the original array
function BGE_cloneArray(original = [] as object) as object
    retVal = []
    for each item in original
        retVal.push(item)
    end for
    return retVal
end function

' Check if two arrays of points are teh same - that is, if each point, in order has same x and y values
'
' @param {object} [a=[]] the first array
' @param {object} [b=[]] the second array
' @return {boolean} true if both arrays have same number of points and x and y values are the same for each point
function BGE_pointArraysEqual(a = [] as object, b = [] as object) as boolean
    if a.count() <> b.count()
        return false
    end if
    same = true
    for i = 0 to a.count() - 1
        same = a[i].x = b[i].x and a[i].y = b[i].y
        if not same
            exit for
        end if
    end for
    return same
end function'//# sourceMappingURL=./utils.bs.map