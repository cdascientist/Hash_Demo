' @module BGE
' Wrapper for Roku's roTimeSpan that allows time adjustment
function __BGE_GameTimer_builder()
    instance = {}
    instance.new = function()
        m.internal_roku_timer = invalid
        m.total_milliseconds_modifier = 0
        m.internal_roku_timer = CreateObject("roTimespan")
    end function
    instance.mark = function() as void
        m.internal_roku_timer.Mark()
        m.total_milliseconds_modifier = 0
    end function
    instance.totalMilliseconds = function() as integer
        return m.internal_roku_timer.TotalMilliseconds() + m.total_milliseconds_modifier
    end function
    instance.totalSeconds = function() as integer
        return m.internal_roku_timer.TotalSeconds() + cint(m.total_milliseconds_modifier / 1000)
    end function
    instance.getSecondsToISO8601Date = function(date as string) as integer
        return m.internal_roku_timer.GetSecondsToISO8601Date(date)
    end function
    instance.addTime = function(milliseconds as integer) as void
        m.total_milliseconds_modifier += milliseconds
    end function
    instance.removeTime = function(milliseconds as integer) as void
        m.total_milliseconds_modifier -= milliseconds
    end function
    return instance
end function
function BGE_GameTimer()
    instance = __BGE_GameTimer_builder()
    instance.new()
    return instance
end function'//# sourceMappingURL=./GameTimer.bs.map