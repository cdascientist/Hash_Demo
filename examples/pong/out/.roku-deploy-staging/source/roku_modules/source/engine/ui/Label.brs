function __BGE_UI_Label_builder()
    instance = __BGE_UI_UiWidget_builder()
    instance.super1_new = instance.new
    instance.new = function(game as object) as void
        m.super1_new(game)
        m.drawableText = invalid
        m.drawableText = BGE_DrawableText(m, m.canvas)
    end function
    instance.setText = function(text = "" as string) as void
        m.drawableText.text = text
    end function
    ' Set the canvas this UIWidget Draws to
    '
    ' @param {object} [canvas=invalid] The canvas this should draw to - if invalid, then will draw to the game canvas
    instance.super1_setCanvas = instance.setCanvas
    instance.setCanvas = sub(canvas = invalid as object)
        m.super1_setCanvas(canvas)
        if invalid <> m.drawableText
            m.drawableText.setCanvas(m.canvas)
        end if
    end sub
    instance.super1_draw = instance.draw
    instance.draw = function(parent = invalid as object) as void
        ' drawPosition = m.getDrawPosition(parent)
        if invalid <> m.drawableText
            m.drawableText.draw()
            size = m.drawableText.getDrawnSize()
            m.width = size.width
            m.height = size.height
        end if
    end function
    return instance
end function
function BGE_UI_Label(game as object)
    instance = __BGE_UI_Label_builder()
    instance.new(game)
    return instance
end function'//# sourceMappingURL=./Label.bs.map