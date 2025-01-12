function __Computer_builder()
    instance = __Paddle_builder()
    instance.super1_new = instance.new
    instance.new = function(game) as void
        m.super1_new(game)
        m.name = "Computer"
        m.x = 1280 - 50
        m.y = invalid
    end function
    instance.super1_getFrontColliderXOffset = instance.getFrontColliderXOffset
    instance.getFrontColliderXOffset = function() as float
        return - m.width / 2
    end function
    instance.super1_onUpdate = instance.onUpdate
    instance.onUpdate = function(dt)
        ballEntity = m.game.getEntityByName("Ball")
        ' If there is a ball and the ball is moving to the right and hasn't gotten to the computer paddle yet move paddle towards ball
        if ballEntity <> invalid and ballEntity.xspeed > 0 and ballEntity.x < m.x
            if ballEntity.y < m.y - 20
                if m.y > m.bounds.top + m.height / 2
                    m.y -= 3.5 * 60 * dt
                else
                    m.y = m.bounds.top + m.height / 2
                end if
            else if ballEntity.y > m.y + 20
                if m.y < m.bounds.bottom - m.height / 2
                    m.y += 3.5 * 60 * dt
                else
                    m.y = m.bounds.bottom - m.height / 2
                end if
            end if
        end if
    end function
    return instance
end function
function Computer(game)
    instance = __Computer_builder()
    instance.new(game)
    return instance
end function'//# sourceMappingURL=./Computer.bs.map