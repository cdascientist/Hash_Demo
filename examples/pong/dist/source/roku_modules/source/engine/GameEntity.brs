' @module BGE
' Every thing (character, player, object, etc) in the game should extend this class.
' This class has a number of empty methods that are designed to be overridden in subclasses.
' For example, override `onInput()` to handle input event, and `onUpdate()` to handle updating each frame
function __BGE_GameEntity_builder()
    instance = {}
    '-----Constants-----
    ' Constant - name of this Entity
    ' Constant - Unique Id
    ' -----Variables-----
    ' Is this GameEntity enabled
    ' Does this entity persist across room changes?
    ' When the game is paused, does this entity pause too?
    ' zIndex is used when handling draw order in the game loop - lower zIndex is drawn first
    ' x position of where this entity is in game world
    ' y position of where this entity is in game world
    ' Speed in x/horizontal direction
    ' Speed in y/vertical direction
    ' Rotation of entity - applies to all images
    ' The colliders for this entity by name
    ' The array of images to draw for this entity
    ' Associative array of images by name
    ' Game Entities can be tagged with any number of tags so they can be easily identified (e.g. "enemy", "wall", etc.)
    ' Creates a new GameEntity
    '
    ' @param {Game} game - The game engine that this entity is going to be assigned to
    ' @param {object} [args={}] Any extra properties to be added to this entity
    instance.new = function(game as object, args = {} as object)
        m.name = invalid
        m.id = invalid
        m.game = invalid
        m.enabled = true
        m.persistent = false
        m.pauseable = true
        m.zIndex = 0
        m.x = 0.0
        m.y = 0.0
        m.xspeed = 0.0
        m.yspeed = 0.0
        m.rotation = 0
        m.colliders = {}
        m.images = []
        m.imagesByName = {}
        m.tagsList = BGE_TagList()
        m.game = game
        m.id = m.game.getNextGameEntityId()
        m.append(args)
    end function
    ' Is this still a valid entity?
    '
    ' @return {boolean} - true if still valid
    instance.isValid = function() as boolean
        return m.id <> invalid
    end function
    ' Marks this entity as invalid, so it will be cleared/destroyed at the end of the frame
    instance.invalidate = function() as void
        m.id = invalid
    end function
    ' Method to be called when this entity is added to a Game.
    ' Override in subclass
    '
    ' @param {object} args
    instance.onCreate = function(args as object) as void
    end function
    ' Method for handling any updates based on time since previous frame
    '
    ' @param {float} deltaTime - milliseconds since last frame
    instance.onUpdate = function(deltaTime as float) as void
    end function
    ' Method for processing all collisions
    '
    ' @param {Collider} collider - the collider of this entity that collided
    ' @param {Collider} otherCollider - the collider of the other entity in the collision
    ' @param {GameEntity} otherEntity - the entity that owns the other collider
    instance.onCollision = function(collider as object, otherCollider as object, otherEntity as object) as void
    end function
    ' Method called each frame before drawing any images of this entity
    '
    ' @param {object} canvas - the canvas images will be drawn to
    instance.onDrawBegin = function(canvas as object) as void
    end function
    ' Method called each frame after drawing all images of this entity
    '
    ' @param {object} canvas - the canvas images were drawn to
    instance.onDrawEnd = function(canvas as object) as void
    end function
    ' Method to process input per frame
    '
    ' @param {GameInput} input - GameInput object for the last frame
    instance.onInput = function(input as object) as void
    end function
    ' Method to process an ECP keyboard event
    ' @see  https://developer.roku.com/en-ca/docs/developer-program/debugging/external-control-api.md
    '
    ' @param {integer} char
    instance.onECPKeyboard = function(char as integer) as void
    end function
    ' Method to process an External Control Protocol event
    ' @see  https://developer.roku.com/en-ca/docs/references/brightscript/events/roinputevent.md
    '
    ' @param {object} data
    instance.onECPInput = function(data as object) as void
    end function
    ' Method to handle audio events
    ' @see  https://developer.roku.com/en-ca/docs/references/brightscript/events/roaudioplayerevent.md
    '
    ' @param {object} msg - roAudioPlayerEvent
    instance.onAudioEvent = function(msg as object) as void
    end function
    ' Called when the game pauses
    '
    instance.onPause = function() as void
    end function
    ' Called when the game unpauses
    '
    ' @param {integer} pauseTimeMs - The number of milliseconds the game was paused
    instance.onResume = function(pauseTimeMs as integer) as void
    end function
    ' Called on url event
    ' @see  https://developer.roku.com/en-ca/docs/references/brightscript/events/rourlevent.md
    '
    ' @param {object} msg - roUrlEvent
    instance.onUrlEvent = function(msg as object) as void
    end function
    ' General purpose event handler for in-game events.
    '
    ' @param {string} eventName - Event name that describes the event type
    ' @param {object} data - Any extra data to go along with the event
    instance.onGameEvent = function(eventName as string, data as object) as void
    end function
    ' Method called when the current room changes.
    ' This method is only called when the entity is marked as `persistant`,
    ' otherwise entities are destroyed on room changes.
    '
    ' @param {Room} newRoom - The next room
    instance.onChangeRoom = function(newRoom as object) as void
    end function
    ' Method called when this entity is destroyed
    '
    instance.onDestroy = function() as void
    end function
    ' Adds a circle collider to this entity
    '
    ' @param {string} colliderName - Name of the collider (only one collider with the same name can be added)
    ' @param {float} radius - radius of the circle
    ' @param {float} [offset_x=0] - horizontal offset from entity position of centre of the circle
    ' @param {float} [offset_y=0] - vertical offset from entity position of centre of the circle
    ' @param {boolean} [enabled=true] - is this collider enabled?
    ' @return {object}  - the collider that was added, or `invalid` if it could not be added
    instance.addCircleCollider = function(colliderName as string, radius as float, offset_x = 0 as float, offset_y = 0 as float, enabled = true as boolean) as object
        collider = BGE_CircleCollider(colliderName, {
            enabled: enabled
            radius: radius
            offset_x: offset_x
            offset_y: offset_y
        })
        return m.addCollider(collider)
    end function
    ' Adds a rectangle collider to this entity
    '
    ' @param {string} colliderName - Name of the collider (only one collider with the same name can be added)
    ' @param {float} width - Width of rectangle
    ' @param {float} height - Height of rectangle
    ' @param {float} [offset_x=0] - horizontal offset from entity position of top left point of rectangle
    ' @param {float} [offset_y=0] - vertical offset from entity position of top left point of rectangle
    ' @param {boolean} [enabled=true] - is this collider enabled?
    ' @return {object}  - the collider that was added, or `invalid` if it could not be added
    instance.addRectangleCollider = function(colliderName as string, width as float, height as float, offset_x = 0 as float, offset_y = 0 as float, enabled = true as boolean) as object
        collider = BGE_RectangleCollider(colliderName, {
            enabled: enabled
            offset_x: offset_x
            offset_y: offset_y
            width: width
            height: height
        })
        return m.addCollider(collider)
    end function
    ' Adds a collider that has already been constructed
    '
    ' @param {Collider} collider - the collider to add  (only one collider with the same name can be added)
    ' @return {Collider}  - the collider that was added, or `invalid` if it could not be added
    instance.addCollider = function(collider as object) as object
        colliderName = collider.name
        collider.setupCompositor(m.game, m.name, m.id, m.x, m.y)
        if m.colliders[colliderName] = invalid
            m.colliders[colliderName] = collider
        else
            print "addCollider() - Collider Name Already Exists: " + colliderName
            return invalid
        end if
        return collider
    end function
    ' Gets a collider based on its name
    '
    ' @param {string} colliderName - The name of the collider to find
    ' @return {Collider} - the collider (if found) otherwise `invalid`
    instance.getCollider = function(colliderName as string) as object
        if m.colliders.DoesExist(colliderName)
            return m.colliders[colliderName]
        else
            return invalid
        end if
    end function
    ' Removes a collider by its name
    '
    ' @param {string} colliderName - the name of the collider to remove
    instance.removeCollider = function(colliderName as string) as void
        if m.colliders[colliderName] <> invalid
            if type(m.colliders[colliderName].compositorObject) = "roSprite"
                m.colliders[colliderName].compositorObject.Remove()
            end if
            m.colliders.Delete(colliderName)
        end if
    end function
    ' Remove all colliders from this entity
    '
    instance.clearAllColliders = function() as void
        if invalid <> m.colliders
            for each colliderKey in m.colliders
                m.removeCollider(colliderKey)
            end for
        end if
    end function
    ' Adds a basic image (non-animated) to be drawn for this entity
    '
    ' @param {string} imageName - Name of the image
    ' @param {object} region - an `roRegion` of a bitmap to draw
    ' @param {object} [args={}] - any extra properties to set (e.g. offset_x, offset_y, rotation, scale_x, scale_y, etc.)
    ' @param {integer} [insertPosition=-1] - the position/order in the images array where the image should be added (defaults to being added at the end)
    ' @return {Image} - The image object that was added, or `invalid` if there was an error
    instance.addImage = function(imageName as string, region as object, args = {} as object, insertPosition = - 1 as integer) as object
        imageObject = BGE_Image(m, m.game.getCanvas(), region, args) 'm as first arg
        return m.addImageObject(imageName, imageObject, insertPosition)
    end function
    ' Adds a animated image to be drawn for this entity. Animated images cycle through regions of a bitmap (e.g. spritesheet)
    '
    ' @param {string} imageName - Name of the image
    ' @param {object} regions - an array of `roRegion` of a bitmap to draw
    ' @param {object} [args={}] - any extra properties to set (e.g. offset_x, offset_y, rotation, scale_x, scale_y, etc.)
    ' @param {integer} [insertPosition=-1] - the position/order in the images array where the image should be added (defaults to being added at the end)
    ' @return {AnimatedImage} - The image object that was added, or `invalid` if there was an error
    instance.addAnimatedImage = function(imageName as string, regions as object, args = {} as object, insertPosition = - 1 as integer) as object
        imageObject = BGE_AnimatedImage(m, m.game.getCanvas(), regions, args)
        return m.addImageObject(imageName, imageObject, insertPosition)
    end function
    '
    ' @param {object} regions - an array of `roRegion` of a bitmap to draw
    ' Adds a Sprite to be drawn for this entity. Sprites can have specific animations configured buy choosing series of cells from a sprite sheet
    '
    ' @param {string} imageName - Name of the image
    ' @param {object} bitmap - the bitmap object to use for teh SpriteSheet (e.g response from game.getBitmap("bitmap_name"))
    ' @param {integer} cellWidth - the height in pixels of a dingle cell in the sprite
    ' @param {integer} cellHeight - the height in pixels of a dingle cell in the sprite
    ' @param {object} [args={}] - any extra properties to set (e.g. offset_x, offset_y, rotation, scale_x, scale_y, etc.)
    ' @param {integer} [insertPosition=-1] - the position/order in the images array where the image should be added (defaults to being added at the end)
    ' @return {Sprite} - The image object that was added, or `invalid` if there was an error
    instance.addSprite = function(imageName as string, spriteSheet as object, cellWidth as integer, cellHeight as integer, args = {} as object, insertPosition = - 1 as integer) as object
        imageObject = BGE_Sprite(m, m.game.getCanvas(), spriteSheet, cellWidth, cellHeight, args)
        return m.addImageObject(imageName, imageObject, insertPosition)
    end function
    ' Adds any Image object to this entity
    '
    ' @param {string} imageName - Name of the image
    ' @param {Drawable} imageObject - The image to be added
    ' @param {integer} [insertPosition=-1] - the position/order in the images array where the image should be added (defaults to being added at the end)
    ' @return {Drawable} - The image object that was added, or `invalid` if there was an error
    instance.addImageObject = function(imageName as string, imageObject as object, insertPosition = - 1 as integer) as object
        imageObject.name = imageName
        if m.getImage(imageObject.name) <> invalid
            print "addImageObject() - An image named - " + imageObject.name + " - already exists"
            return invalid
        end if
        m.imagesByName[imageObject.name] = imageObject
        if insertPosition = - 1
            m.images.Push(imageObject)
        else if insertPosition = 0
            m.images.Unshift(imageObject)
        else if insertPosition < m.images.Count()
            BGE_ArrayInsert(m.images, insertPosition, imageObject)
        else
            m.images.Push(imageObject)
        end if
        return imageObject
    end function
    ' Gets an image by its name from the lookup table
    '
    ' @param {string} imageName - Name of image to get
    ' @return {Drawable}
    instance.getImage = function(imageName as string) as object
        return m.imagesByName[imageName]
    end function
    ' Removes an image from the entity
    '
    ' @param {string} imageName - Name of image to remove
    instance.removeImage = function(imageName as string) as void
        m.imagesByName.Delete(imageName)
        if m.images.Count() > 0
            for i = 0 to m.images.Count() - 1
                if m.images[i].name = imageName
                    m.images.Delete(i)
                    exit for
                end if
            end for
        end if
    end function
    ' TODO: work on statics
    '
    ' @param {string} staticVariableName
    ' @return {dynamic}
    instance.getStaticVariable = function(staticVariableName as string) as dynamic
        if m.game.Statics.DoesExist(m.name) and m.game.Statics[m.name].DoesExist(staticVariableName)
            return m.game.Statics[m.name][staticVariableName]
        else
            return invalid
        end if
    end function
    ' TODO: work on statics
    '
    ' @param {string} staticVariableName
    ' @param {dynamic} staticVariableValue
    instance.setStaticVariable = function(staticVariableName as string, staticVariableValue as dynamic) as void
        if m.game.Statics.doesExist(m.name)
            m.game.Statics[m.name][staticVariableName] = staticVariableValue
        end if
    end function
    ' TODO: work on Interfaces
    '
    ' @param {string} interfaceName
    instance.addInterface = function(interfaceName as string) as void
        interfaceObj = {
            owner: m
        }
        m.game.Interfaces[interfaceName](interfaceObj)
        m[interfaceName] = interfaceObj
    end function
    ' TODO: work on Interfaces
    '
    ' @param {string} interfaceName
    ' @return {boolean}
    instance.hasInterface = function(interfaceName as string) as boolean
        return (m.doesExist(interfaceName) and m[interfaceName] <> invalid)
    end function
    return instance
end function
function BGE_GameEntity(game as object, args = {} as object)
    instance = __BGE_GameEntity_builder()
    instance.new(game, args)
    return instance
end function'//# sourceMappingURL=./GameEntity.bs.map