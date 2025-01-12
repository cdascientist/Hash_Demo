function __ScoreHandler_builder()
    instance = __BGE_GameEntity_builder()
    instance.super0_new = instance.new
    instance.new = function(game) as void
        m.super0_new(game)
        m.scores = {
            player: 0
            computer: 0
        }
        m.name = "ScoreHandler"
    end function
    instance.super0_onGameEvent = instance.onGameEvent
    instance.onGameEvent = function(event as string, data as object)
        if event = "score"
            if data.team = 0
                m.scores.player++
            else
                m.scores.computer++
            end if
        end if
    end function
    instance.super0_onDrawEnd = instance.onDrawEnd
    instance.onDrawEnd = function(canvas as object)
        font = m.game.getFont("default")
        BGE_DrawText(canvas, m.scores.player.ToStr(), 1280 / 2 - 200, 100, font, "center")
        BGE_DrawText(canvas, m.scores.computer.ToStr(), 1280 / 2 + 200, 100, font, "center")
    end function
    return instance
end function
function ScoreHandler(game)
    instance = __ScoreHandler_builder()
    instance.new(game)
    return instance
end function'//# sourceMappingURL=./ScoreHandler.bs.map