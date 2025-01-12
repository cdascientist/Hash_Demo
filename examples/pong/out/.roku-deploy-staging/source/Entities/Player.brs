function __Player_builder()
    instance = __Paddle_builder()
    instance.super1_new = instance.new
    instance.new = function(game) as void
        m.super1_new(game)
        m.name = "Player"
        m.x = 50
        m.y = invalid
    end function
    instance.super1_getFrontColliderXOffset = instance.getFrontColliderXOffset
    instance.getFrontColliderXOffset = function() as float
        return m.width / 2 - 1
    end function
    instance.super1_onUpdate = instance.onUpdate
    instance.onUpdate = function(dt)
        if m.y < m.bounds.top + m.height / 2
            m.y = m.bounds.top + m.height / 2
            m.yspeed = 0
        end if
        if m.y > m.bounds.bottom - m.height / 2
            m.y = m.bounds.bottom - m.height / 2
            m.yspeed = 0
        end if
    end function
    instance.super1_onInput = instance.onInput
    instance.onInput = function(input as object)
        m.yspeed = input.y * 3.5
    end function
    return instance
end function
function Player(game)
    instance = __Player_builder()
    instance.new(game)
    return instance
end function'//# sourceMappingURL=./Player.bs.map