' @module BGE
' Colliders are attached to GameEntities and when two colliders intersect, it triggers the onCollision() method in
' the GameEntity
function __BGE_Collider_builder()
    instance = {}
    ' The type of this collider - should be defined in sub classes (eg. "circle", "rectangle")
    ' Name this collider will be identified by
    ' Does this collider trigger onCollision() ?
    ' Horizontal offset from the GameEntity it is attached to
    ' Vertical offset from the GameEntity it is attached to
    ' Bitflag for collision detection: this collider is in this group - https://developer.roku.com/en-ca/docs/references/brightscript/interfaces/ifsprite.md#setmemberflagsflags-as-integer-as-void
    ' Bitflag for collision detection: this collider will only collider with colliders in this group - https://developer.roku.com/en-ca/docs/references/brightscript/interfaces/ifsprite.md#setcollidableflagsflags-as-integer-as-void
    ' Used internal to Game - should not be modified manually
    ' Colliders can be tagged with any number of tags so they can be easily identified (e.g. "enemy", "wall", etc.)
    ' Creates a new Collider
    '
    ' @param {string} colliderName - the name this collider will be identified by
    ' @param {object} [args={}] - additional properties to be added to this collider
    instance.new = function(colliderName as string, args = {} as object) as void
        m.colliderType = invalid
        m.name = ""
        m.enabled = true
        m.offset_x = 0
        m.offset_y = 0
        m.memberFlags = 1
        m.collidableFlags = 1
        m.compositorObject = invalid
        m.tagsList = BGE_TagList()
        m.name = colliderName
        m.append(args)
    end function
    ' Sets up this collider to be associated with a given game and entity
    '
    ' @param {object} game - the game this collider is used by
    ' @param {string} entityName - name of the entity that owns this collider
    ' @param {string} entityId - id of the entity that owns this collider
    ' @param {float} entityX - entity's x position
    ' @param {float} entityY - entity's y position
    instance.setupCompositor = function(game as object, entityName as string, entityId as string, entityX as float, entityY as float) as void
        region = CreateObject("roRegion", game.getEmptyBitmap(), 0, 0, 1, 1)
        m.compositorObject = game.compositor.NewSprite(entityX, entityY, region)
        m.compositorObject.SetDrawableFlag(false)
        m.compositorObject.SetData({
            colliderName: m.name
            objectName: entityName
            entityId: entityId
        })
        m.refreshColliderRegion()
    end function
    ' Refreshes the collider.
    ' Called every frame by the GameEngine.
    ' Should be overrided by sub classes if they have specialized collision set ups (e.g. circle, rectangle).
    '
    instance.refreshColliderRegion = function() as void
        region = m.compositorObject.GetRegion()
        region.SetCollisionType(0)
    end function
    ' Moves the compositor to the new x,y position - called from Game when the entity it is attached to moves
    '
    ' @param {float} x
    ' @param {float} y
    instance.adjustCompositorObject = function(x as float, y as float) as void
        if m.enabled
            m.compositorObject.SetMemberFlags(m.memberFlags)
            m.compositorObject.SetCollidableFlags(m.collidableFlags)
            m.refreshColliderRegion()
            m.compositorObject.MoveTo(x, y)
        else
            m.compositorObject.SetMemberFlags(0)
            m.compositorObject.SetCollidableFlags(0)
        end if
    end function
    ' Helper function to draw an outline around the collider
    '
    ' @param {object} draw2d
    ' @param {float} entityX
    ' @param {float} entityY
    ' @param {integer} [color=&hFF0000FF]
    instance.debugDraw = function(draw2d as object, entityX as float, entityY as float, color = &hFF0000FF as integer) as void
    end function
    return instance
end function
function BGE_Collider(colliderName as string, args = {} as object)
    instance = __BGE_Collider_builder()
    instance.new(colliderName, args)
    return instance
end function'//# sourceMappingURL=./Collider.bs.map