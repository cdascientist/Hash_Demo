function __BGE_UI_Offset_builder()
    instance = {}
    instance.new = function(tOffset = 0 as float, rOffset = invalid as dynamic, bOffset = invalid as dynamic, lOffset = invalid as dynamic) as void
        m.top = 0
        m.right = 0
        m.bottom = 0
        m.left = 0
        m.set(tOffset, rOffset, bOffset, lOffset)
    end function
    instance.set = function(offset = 0 as float, rOffset = invalid as dynamic, bOffset = invalid as dynamic, lOffset = invalid as dynamic) as void
        m.top = offset
        m.right = bslib_coalesce(rOffset, offset)
        m.bottom = bslib_coalesce(bOffset, offset)
        m.left = bslib_coalesce(lOffset, offset)
    end function
    return instance
end function
function BGE_UI_Offset(tOffset = 0 as float, rOffset = invalid as dynamic, bOffset = invalid as dynamic, lOffset = invalid as dynamic)
    instance = __BGE_UI_Offset_builder()
    instance.new(tOffset, rOffset, bOffset, lOffset)
    return instance
end function'//# sourceMappingURL=./Style.bs.map