' @module BGE
' Collider with the shape of a circle centered at (offset_x, offset_y), with given radius
function __BGE_CircleCollider_builder()
    instance = __BGE_Collider_builder()
    ' Radius of the collider
    ' Create a new CircleCollider
    '
    ' @param {string} colliderName - name of this collider
    ' @param {object} [args={}] - additional properties (e.g {radius: 10})
    instance.super0_new = instance.new
    instance.new = function(colliderName as string, args = {} as object) as void
        m.super0_new(colliderName, args)
        m.radius = 0
        m.colliderType = "circle"
        m.append(args)
    end function
    ' Refreshes the collider
    '
    instance.super0_refreshColliderRegion = instance.refreshColliderRegion
    instance.refreshColliderRegion = function() as void
        region = m.compositorObject.GetRegion()
        region.SetCollisionType(2)
        region.SetCollisionCircle(m.offset_x, m.offset_y, m.radius)
    end function
    ' Draws the circle outline around the collider
    instance.super0_debugDraw = instance.debugDraw
    instance.debugDraw = function(draw2d as object, entityX as float, entityY as float, color = &hFF0000FF as integer)
        ' This function is slow as I'm making draw calls for every section of the line.
        ' It's for debugging purposes only!
        BGE_DrawCircleOutline(draw2d, 16, entityX + m.offset_x, entityY + m.offset_y, m.radius, color)
    end function
    return instance
end function
function BGE_CircleCollider(colliderName as string, args = {} as object)
    instance = __BGE_CircleCollider_builder()
    instance.new(colliderName, args)
    return instance
end function'//# sourceMappingURL=./CircleCollider.bs.map