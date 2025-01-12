' @module BGE
' Used to draw a bitmap image to the screen
function __BGE_Image_builder()
    instance = __BGE_Drawable_builder()
    ' -------------Never To Be Manually Changed-----------------
    ' These values should never need to be manually changed.
    instance.super0_new = instance.new
    instance.new = function(owner as object, canvasBitmap as object, region as object, args = {} as object) as void
        m.super0_new(owner, canvasBitmap, args)
        m.region = invalid
        m.region = region
        m.append(args)
    end function
    instance.super0_draw = instance.draw
    instance.draw = function(additionalRotation = 0 as float) as void
        m.width = m.region.getWidth()
        m.height = m.region.getHeight()
        if m.enabled
            m.drawRegionToCanvas(m.region, additionalRotation)
        end if
    end function
    return instance
end function
function BGE_Image(owner as object, canvasBitmap as object, region as object, args = {} as object)
    instance = __BGE_Image_builder()
    instance.new(owner, canvasBitmap, region, args)
    return instance
end function'//# sourceMappingURL=./Image.bs.map