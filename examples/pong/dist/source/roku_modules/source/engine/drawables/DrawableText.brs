' @module BGE
' Class to draw text
function __BGE_DrawableText_builder()
    instance = __BGE_Drawable_builder()
    ' The text to write on the screen
    ' The Font object to use ( get this from the font registry)
    ' The Horizontal alignment for the text: "left", "center", "right"
    instance.super0_new = instance.new
    instance.new = function(owner as object, canvasBitmap as object, text = "" as string, font = invalid as object, args = {} as object) as void
        m.super0_new(owner, canvasBitmap, args)
        m.text = ""
        m.font = invalid
        m.alignment = "left"
        m.lastTextValue = ""
        m.tempCanvas = invalid
        m.text = text
        m.font = font
        if invalid <> m.owner and invalid <> m.owner.game and invalid = m.font
            m.font = m.owner.game.getFont("default")
        end if
        m.append(args)
    end function
    instance.super0_draw = instance.draw
    instance.draw = function(additionalRotation = 0 as float) as void
        if not m.enabled
            return
        end if
        if m.text = m.lastTextValue and invalid <> m.tempCanvas and not m.shouldRedraw
            m.drawRegionToCanvas(m.tempCanvas, additionalRotation, true)
            return
        end if
        m.lastTextValue = m.text
        m.width = m.font.GetOneLineWidth(m.text, 10000)
        m.height = m.font.GetOneLineHeight() * BGE_getNumberOfLinesInAString(m.text)
        m.tempCanvas = CreateObject("roBitmap", {
            width: m.width
            height: m.height
            AlphaEnable: true
        })
        BGE_DrawText(m.tempCanvas, m.text, 0, 0, m.font, "left", BGE_Colors().White)
        m.drawRegionToCanvas(m.tempCanvas, additionalRotation, true)
        m.shouldRedraw = false
    end function
    instance.super0_getDrawPosition = instance.getDrawPosition
    instance.getDrawPosition = function() as object
        position = m.super0_getDrawPosition()
        alignment = lcase(m.alignment)
        if alignment = "center"
            position.x -= m.width / 2
        else if alignment = "right"
            position.x -= m.height
        end if
        return position
    end function
    return instance
end function
function BGE_DrawableText(owner as object, canvasBitmap as object, text = "" as string, font = invalid as object, args = {} as object)
    instance = __BGE_DrawableText_builder()
    instance.new(owner, canvasBitmap, text, font, args)
    return instance
end function'//# sourceMappingURL=./DrawableText.bs.map