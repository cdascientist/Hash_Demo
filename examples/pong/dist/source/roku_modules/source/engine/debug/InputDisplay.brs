' @module BGE
function __BGE_Debug_InputDisplay_builder()
    instance = __BGE_Debug_DebugWindow_builder()
    instance.super3_new = instance.new
    instance.new = function(game as object) as void
        m.super3_new(game)
        m.lastInputButton = ""
        m.heldTimeSeconds = 0
        m.inputLabel = invalid
        m.width = 240
        m.height = 40
        m.vertAlign = "bottom"
        m.inputLabel = BGE_UI_Label(game)
        m.inputLabel.drawableText.font = m.game.getFont("debugUI")
        m.addChild(m.inputLabel)
    end function
    instance.super3_onInput = instance.onInput
    instance.onInput = function(input as object)
        m.lastInputButton = input.button
        m.heldTimeSeconds = input.heldTimeMs / 1000
    end function
    instance.super3_onUpdate = instance.onUpdate
    instance.onUpdate = function(dt as float) as void
        buttonName = "none"
        heldTimeStr = "0"
        if invalid <> m.lastInputButton
            buttonName = m.lastInputButton
            heldTimeStr = BGE_NumberToFixed(m.heldTimeSeconds, 2)
        end if
        m.inputLabel.setText("Input: " + bslib_toString(buttonName) + " (" + bslib_toString(heldTimeStr) + "s)")
        m.lastInputButton = invalid
        m.width = m.inputLabel.width + 20
    end function
    return instance
end function
function BGE_Debug_InputDisplay(game as object)
    instance = __BGE_Debug_InputDisplay_builder()
    instance.new(game)
    return instance
end function'//# sourceMappingURL=./InputDisplay.bs.map