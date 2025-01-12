' Base Abstract class for all UI Elements
function __BGE_UI_UiWidget_builder()
    instance = __BGE_GameEntity_builder()
    ' If position = "custom", then m.customX is horizontal position of this element from the parent position
    ' and m.customY is the vertical position of this element from the parent position (positive is down)
    ' If customPosition is false, this dictates where horizontally in the container this element should go. Can be: "left", "center" or "right"
    ' If customPosition is false, this dictates where vertically in the container this element should go. Can be: "top", "center" or "bottom"
    ' Width of the element
    ' Height of the element
    instance.super0_new = instance.new
    instance.new = function(game as object) as void
        m.super0_new(game)
        m.customPosition = false
        m.customX = 0
        m.customY = 0
        m.horizAlign = "left"
        m.vertAlign = "top"
        m.width = 0
        m.height = 0
        m.canvas = invalid
        m.padding = BGE_UI_Offset()
        m.margin = BGE_UI_Offset()
        m.setCanvas(game.getCanvas())
    end function
    ' Function to get the value of the UI element
    '
    ' @return {dynamic} - the value of this element
    instance.getValue = function() as dynamic
        return invalid
    end function
    ' Method called each frame to draw any images of this entity
    '
    ' @param {object} [parent=invalid] - the parent of this Ui Element - will be an object with {x, y, width, height}
    instance.draw = function(parent = invalid as object) as void
    end function
    ' Set the canvas this UIWidgetDraws to
    '
    ' @param {object} [canvas=invalid] The canvas this should draw to - if invalid, then will draw to the game canvas
    instance.setCanvas = sub(canvas = invalid as object)
        if canvas <> invalid
            m.canvas = canvas
        else
            m.canvas = m.game.getCanvas()
        end if
    end sub
    ' Method called each frame to reposition
    '
    ' @param {object} [parent=invalid] - the parent of this Ui Element - will be an object with {x, y, width, height}
    instance.repositionBasedOnParent = function(parent = invalid as object) as void
        drawPosition = m.getDrawPosition(parent)
        m.x = drawPosition.x
        m.y = drawPosition.y
    end function
    ' Method called each frame to draw any images of this entity
    '
    ' @param {object} [parent=invalid] - the parent of this Ui Element - will be an object with {x, y, width, height}
    ' @return {object} - x,y coordinates of where this widget should be positioned
    instance.getDrawPosition = function(parent = invalid as object) as object
        drawPosition = {
            x: 0
            y: 0
        }
        parentPadding = BGE_UI_Offset()
        if invalid <> parent
            drawPosition.x += parent.x
            drawPosition.y += parent.y
            if invalid <> parent.padding
                parentPadding = parent.padding
            end if
        else
            parent = {
                x: 0
                y: 0
            }
        end if
        if m.customPosition or invalid = parent.width or invalid = parent.height
            drawPosition.x += m.customX
            drawPosition.y += m.customY
        else
            hAlign = lcase(m.horizAlign).trim()
            vAlign = lcase(m.vertAlign).trim()
            if "left" = hAlign
                drawPosition.x += m.margin.left + parentPadding.left
            else if "center" = hAlign
                drawPosition.x += parent.width / 2 - m.width / 2
            else if "right" = hAlign
                drawPosition.x += parent.width - m.width - parentPadding.right - m.margin.right
            end if
            if "top" = vAlign
                drawPosition.y += m.margin.top + parentPadding.top
            else if "center" = vAlign
                drawPosition.y += parent.height / 2 - m.height / 2
            else if "bottom" = vAlign
                drawPosition.y += parent.height - m.height - m.margin.bottom - parentPadding.bottom
            end if
        end if
        return drawPosition
    end function
    return instance
end function
function BGE_UI_UiWidget(game as object)
    instance = __BGE_UI_UiWidget_builder()
    instance.new(game)
    return instance
end function'//# sourceMappingURL=./UiWidget.bs.map