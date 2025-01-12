' @module BGE
' Collider with the shape of a rectangle with top left at (offset_x, offset_y), with given width and height
function __BGE_RectangleCollider_builder()
    instance = __BGE_Collider_builder()
    ' Create a new RectangleCollider
    '
    ' @param {string} colliderName - name of this collider
    ' @param {object} [args={}] - additional properties (e.g {width: 10, height: 20})
    instance.super0_new = instance.new
    instance.new = function(colliderName as string, args = {} as object) as void
        m.super0_new(colliderName, args)
        m.width = 0.0
        m.height = 0.0
        m.colliderType = "rectangle"
        m.append(args)
    end function
    ' Refreshes the collider
    '
    instance.super0_refreshColliderRegion = instance.refreshColliderRegion
    instance.refreshColliderRegion = function() as void
        region = m.compositorObject.GetRegion()
        region.SetCollisionType(1)
        region.SetCollisionRectangle(m.offset_x, m.offset_y, m.width, m.height)
    end function
    ' Draws the rectangle outline around the collider
    instance.super0_debugDraw = instance.debugDraw
    instance.debugDraw = function(draw2d as object, entityX as float, entityY as float, color = &hFF0000FF as integer)
        BGE_DrawRectangleOutline(draw2d, entityX + m.offset_x, entityY + m.offset_y, m.width, m.height, color)
    end function
    return instance
end function
function BGE_RectangleCollider(colliderName as string, args = {} as object)
    instance = __BGE_RectangleCollider_builder()
    instance.new(colliderName, args)
    return instance
end function'//# sourceMappingURL=./RectangleCollider.bs.map