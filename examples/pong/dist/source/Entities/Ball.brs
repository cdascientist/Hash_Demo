function __Ball_builder()
    instance = __BGE_GameEntity_builder()
    instance.super0_new = instance.new
    instance.new = function(game as object) as void
        m.super0_new(game)
        m.direction = invalid
        m.hit_frequency_timer = CreateObject("roTimeSpan")
        m.dead = false
        m.bounds = {
            top: 50
            bottom: 720 - 50
        }
        m.name = "Ball"
    end function
    instance.super0_onCreate = instance.onCreate
    instance.onCreate = function(args as object)
        m.direction = args.direction
        m.x = 1280 / 2
        m.y = 720 / 2
        m.xspeed = 5.5 * m.direction
        m.yspeed = 5
        if rnd(2) = 1
            m.yspeed *= - 1
        end if
        bm_ball = m.game.getBitmap("ball")
        ' bs:disable-next-line
        region = CreateObject("roRegion", bm_ball, 0, 0, bm_ball.GetWidth(), bm_ball.GetHeight())
        region.SetPreTranslation(- bm_ball.GetWidth() / 2, - bm_ball.GetHeight() / 2)
        m.addImage("main", region, {
            color: &hffffff
            alpha: 0
        })
        m.addRectangleCollider("ball_collider", bm_ball.GetWidth(), bm_ball.GetHeight(), - bm_ball.GetWidth() / 2, - bm_ball.GetHeight() / 2)
    end function
    instance.super0_onCollision = instance.onCollision
    instance.onCollision = function(colliderName as string, other_colliderName as string, other_entity as object)
        need_to_play_hit_sound = false
        ' If colliding with the front of the player paddle
        if not m.dead and other_entity.name = "Player" and other_colliderName = "front"
            m.xspeed = Abs(m.xspeed)
            need_to_play_hit_sound = true
        end if
        ' If colliding with the front of the computer paddle
        if not m.dead and other_entity.name = "Computer" and other_colliderName = "front"
            m.xspeed = Abs(m.xspeed) * - 1
            need_to_play_hit_sound = true
        end if
        ' If colliding with the front or bottom of the either paddle
        if other_entity.name = "Player" or other_entity.name = "Computer"
            if other_colliderName = "top"
                m.yspeed = Abs(m.yspeed) * - 1
                need_to_play_hit_sound = true
            end if
            if other_colliderName = "bottom"
                m.yspeed = Abs(m.yspeed)
                need_to_play_hit_sound = true
            end if
        end if
        if need_to_play_hit_sound
            m.PlayHitSound()
        end if
    end function
    instance.super0_onUpdate = instance.onUpdate
    instance.onUpdate = function(dt as float) as void
        image = m.getImage("main")
        collider = m.getCollider("ball_collider")
        ' Increase alpha until full if not at full
        if image.alpha < 255
            image.alpha += 3
        end if
        ' If the left side of the ball is past the center of the player paddle position
        if m.x - collider.width / 2 <= m.game.getEntityByName("Player").x
            m.dead = true
            if m.x <= - 100
                m.game.postGameEvent("score", {
                    team: 1
                })
                m.game.destroyEntity(m)
                return ' If an entity destroys itself it must return immediately as all internal variables are now invalid
            end if
        end if
        ' If the right side of the ball is past the center of the computer paddle
        if m.x + collider.width / 2 >= m.game.getEntityByName("Computer").x
            m.dead = true
            if m.x >= 1280 + 100
                m.game.postGameEvent("score", {
                    team: 0
                })
                m.game.destroyEntity(m)
                return ' If an entity destroys itself it must return immediately as all internal variables are now invalid
            end if
        end if
        ' If the ball is hitting the top bounds
        if m.y - collider.height / 2 <= m.bounds.top
            m.yspeed = abs(m.yspeed)
            m.PlayHitSound()
        end if
        ' If the ball is hitting the bottom bounds
        if m.y + collider.height / 2 >= m.bounds.bottom
            m.yspeed = abs(m.yspeed) * - 1
            m.PlayHitSound()
        end if
    end function
    instance.super0_PlayHitSound = instance.PlayHitSound
    instance.PlayHitSound = function()
        ' Play the hit sound if ball is on screen and didn't already play within the last 100ms
        if m.x > 0 and m.x < m.game.getCanvas().GetWidth() and m.hit_frequency_timer.TotalMilliseconds() > 100
            m.game.playSound("hit", 50)
            m.hit_frequency_timer.Mark()
        end if
    end function
    instance.super0_onDestroy = instance.onDestroy
    instance.onDestroy = function()
        m.game.playSound("score", 50)
    end function
    return instance
end function
function Ball(game as object)
    instance = __Ball_builder()
    instance.new(game)
    return instance
end function'//# sourceMappingURL=./Ball.bs.map