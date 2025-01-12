function __BGE_TagList_builder()
    instance = {}
    instance.new = function() as void
        m.tags = []
    end function
    instance.clear = function() as void
        m.tags.clear()
    end function
    instance.add = function(tagName as string) as void
        if not m.hasTag(tagName)
            m.tags.push(lcase(tagName))
        end if
    end function
    instance.remove = function(tagName as string) as void
        tagName = lcase(tagName)
        i = 0
        for each tag in m.tags
            if tag = tagName
                m.tags.delete(i)
                return
            end if
            i++
        end for
        return
    end function
    instance.contains = function(tagName as string) as boolean
        tagName = lcase(tagName)
        for each tag in m.tags
            if tag = tagName
                return true
            end if
        end for
        return false
    end function
    instance.count = function() as integer
        return m.tags.count()
    end function
    return instance
end function
function BGE_TagList()
    instance = __BGE_TagList_builder()
    instance.new()
    return instance
end function'//# sourceMappingURL=./TagList.bs.map