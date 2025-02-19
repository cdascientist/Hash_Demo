' @module BGE
' Main Game Engine class which runs everything
' The main game loop is as follows:
' 1. Update - For each GameEntity:
'   - Process Input from roku remote
'   - Process Audio Events (https://developer.roku.com/en-ca/docs/references/brightscript/events/roaudioplayerevent.md)
'   - Process ECP input (https://developer.roku.com/en-ca/docs/developer-program/debugging/external-control-api.md)
'   - Process URL events (https://developer.roku.com/en-ca/docs/references/brightscript/events/rourlevent.md)
'   - Runs the Entity's onUpdate() function
'   - Moves Entity based on velocity
' 2. Collisions - For each GameEntity:
'   - Run Entity's onPreCollision() function
'   - For any collisions, runs Entity's onCollision() function
'   - Runs entity's onPostCollision() function
' (At any time, the Entity in question may Delete() itself. Before every entity interaction, the entity is checked to make sure it is still valid
' in case it was deleted in the last interaction)
'
' 3. Draw - For each GameEntity, sorted by zIndex
'   - Runs the Entity onDrawBegin() function
'   - For each drawable in the Entity, run the draw() function
'   - Run the Entity onDrawEnd() function
'
' 4. Draw all debug items in game space (e.g. colliders, screen safe zones, etc).
'
' 5. UI - For the tree of widgets in the UI Container
'    - Run onUpdate()
'    - Run draw()
'
' 6. Debug UI - Draw all debug windows in the tree of the Debug UI
'
function __BGE_Game_builder()
    instance = {}
    ' ****BEGIN - For Internal Use, Do Not Manually Alter****
    ' ****END - For Internal Use, Do Not Manually Alter****
    ' Reference to the current room in play
    ' Any special arguments for the current room
    ' All of the GameEntities <entityName> => GameEntity[]
    ' All static variables for a given object type
    ' The room definitions by name (the room creation functions)
    ' The interface definitions by name
    ' The loaded bitmaps by name
    ' The loaded sounds by name
    ' The loaded fonts by name
    ' Container for all UI
    ' Container for Debug UI
    ' Constructor for GameEngine
    '
    ' @param {integer} canvas_width - Width of the canvas the game is drawn to
    ' @param {integer} canvas_height - Height of the canvas the game is drawn to
    ' @param {boolean} [canvas_as_screen_if_possible=false] - If true, the game will draw to the roScreen directly if the canvas dimensions are the same as the screen dimensions, this improves performance but makes it so you can't do various canvas manipulations (such as screen shake or taking screenshots)
    ' @return {void}
    instance.new = function(canvas_width as integer, canvas_height as integer, canvas_as_screen_if_possible = false as boolean) as void
        m.debugging = {
            draw_colliders: false
            draw_safe_zones: false
            colliders_color: BGE_RGBAtoRGBA(&hFF, 0, 0, 0.8)
            safe_action_zone_color: BGE_RGBAtoRGBA(0, &hFF, 0, 0.2)
            safe_title_zone_color: BGE_RGBAtoRGBA(0, 0, &hFF, 0.2)
            limit_frame_rate: 0
            show_debug_ui: false
            draw_debugUi_to_screen: false
        }
        m.canvas_is_screen = false
        m.background_color = BGE_RGBAtoRGBA(0, 0, 0, 0.8)
        m.running = true
        m.paused = false
        m.sortedEntities = []
        m.buttonHeld = - 1
        m.buttonHeldTime = 0
        m.inputEntityId = invalid
        m.currentInputEntityId = invalid
        m.dt = 0
        m.totalRunTime = 0
        m.FakeDT = invalid
        m.dtTimer = CreateObject("roTimespan")
        m.pauseTimer = CreateObject("roTimespan")
        m.buttonHeldTimer = CreateObject("roTimespan")
        m.garbageCollectionTimer = CreateObject("roTimespan")
        m.currentID = 0
        m.shouldUseIntegerMovement = false
        m.enableAudioGuideSuppression = true
        m.emptyBitmap = CreateObject("roBitmap", {
            width: 1
            height: 1
            AlphaEnable: false
        })
        m.device = CreateObject("roDeviceInfo")
        m.urlTransfers = {}
        m.url_port = CreateObject("roMessagePort")
        m.ecp_input_port = CreateObject("roMessagePort")
        m.ecp_input = CreateObject("roInput")
        m.compositor = CreateObject("roCompositor")
        m.filesystem = CreateObject("roFileSystem")
        m.screen_port = CreateObject("roMessagePort")
        m.audioPlayer = CreateObject("roAudioPlayer")
        m.music_port = CreateObject("roMessagePort")
        m.fontRegistry = CreateObject("roFontRegistry")
        m.screen = invalid
        m.canvas = invalid
        m.nextGameEntityId = 0
        m.secondsBetweenGarbageCollection = 1
        m.lastGarbageCollection = invalid
        m.roomChangedThisFrame = false
        m.roomChangeDetails = {}
        m.currentRoom = invalid
        m.currentRoomArgs = {}
        m.Entities = {}
        m.Statics = {}
        m.Rooms = {}
        m.Interfaces = {}
        m.Bitmaps = {}
        m.Sounds = {}
        m.Fonts = {}
        m.gameUi = invalid
        m.debugUi = invalid
        ' ############### Create Initial Object - Begin ###############
        ' Set up the screen
        m.canvas = BGE_Canvas(canvas_width, canvas_height)
        m.setUpScreen(canvas_width, canvas_height, canvas_as_screen_if_possible)
        ' Set up the audioPlayer
        m.audioPlayer.SetMessagePort(m.music_port)
        ' Set up the input port
        m.ecp_input.SetMessagePort(m.ecp_input_port)
        ' Register all fonts in package
        m.setUpFonts()
        m.lastGarbageCollection = RunGarbageCollector()
        ' ############### Create Initial Object - End ###############
    end function
    ' Sets up the screen based on canvas dimensions, and screen size
    '
    ' @param {integer} canvas_width
    ' @param {integer} canvas_height
    ' @param {boolean} [canvas_as_screen_if_possible=false]
    ' @return {void}
    instance.setUpScreen = function(canvas_width as integer, canvas_height as integer, canvas_as_screen_if_possible = false as boolean) as void
        UIResolution = m.device.getUIResolution()
        SupportedResolutions = m.device.GetSupportedGraphicsResolutions()
        FHD_Supported = false
        for i = 0 to SupportedResolutions.Count() - 1
            if SupportedResolutions[i].name = "FHD"
                FHD_Supported = true
            end if
        end for
        if UIResolution.name = "SD"
            m.screen = CreateObject("roScreen", true, 854, 626)
        else
            if canvas_width <= 854
                m.screen = CreateObject("roScreen", true, 854, 480)
            else if canvas_width <= 1280 or not FHD_Supported
                m.screen = CreateObject("roScreen", true, 1280, 720)
            else
                m.screen = CreateObject("roScreen", true, 1920, 1080)
            end if
        end if
        m.compositor.SetDrawTo(m.screen, &h00000000)
        m.screen.SetMessagePort(m.screen_port)
        m.screen.SetAlphaEnable(true)
        if canvas_as_screen_if_possible
            if m.screen.GetWidth() = m.canvas.bitmap.GetWidth() and m.screen.GetHeight() = m.canvas.bitmap.GetHeight()
                m.canvas.bitmap = m.screen
                m.canvas_is_screen = true
            end if
        end if
        m.setupUi()
    end function
    ' Sets up the Ui layer
    '
    ' @param {object} canvas
    instance.setupUi = function() as void
        canvas = m.getCanvas()
        m.gameUi = BGE_UI_UiContainer(m)
        m.gameUi.showBackground = false
        m.gameUi.width = canvas.getWidth()
        m.gameUi.height = canvas.getHeight()
        m.gameUi.padding.set(32)
        m.debugUi = BGE_UI_UiContainer(m)
        m.debugUi.showBackground = false
        m.debugUi.width = canvas.getWidth()
        m.debugUi.height = canvas.getHeight()
        m.debugUi.padding.set(32)
    end function
    ' Finds fonts and registers them
    '
    ' @return {void}
    instance.setUpFonts = function() as void
        ttfs_in_package = m.filesystem.FindRecurse("pkg:/fonts/", ".ttf")
        otfs_in_package = m.filesystem.FindRecurse("pkg:/fonts/", ".otf")
        for each font_path in ttfs_in_package
            m.fontRegistry.Register("pkg:/fonts/" + font_path)
        end for
        for each font_path in otfs_in_package
            m.fontRegistry.Register("pkg:/fonts/" + font_path)
        end for
        ' Create the default font
        m.fonts["default"] = m.fontRegistry.GetDefaultFont(28, false, false)
        m.fonts["debugUi"] = m.fontRegistry.GetDefaultFont(20, false, false)
    end function
    ' Gets the next valid id for a GameEntity
    '
    ' @return {string}
    instance.getNextGameEntityId = function() as string
        id = m.nextGameEntityId.ToStr()
        m.nextGameEntityId++
        return id
    end function
    ' Starts the game engine.
    ' Run this function after setting up the game.
    '
    ' @return {void}
    instance.Play = function() as void
        audio_guide_suppression_roURLTransfer = CreateObject("roURLTransfer")
        audio_guide_suppression_roURLTransfer.SetUrl("http://localhost:8060/keydown/Backspace")
        audio_guide_suppression_ticker = 0
        m.running = true
        while m.running
            m.roomChangedThisFrame = false
            if m.inputEntityId <> invalid and m.getEntityByID(m.inputEntityId) = invalid
                m.inputEntityId = invalid
            end if
            m.currentInputEntityId = m.inputEntityId
            m.compositor.draw() ' For some reason this has to be called or the colliders don't remove themselves from the compositor ¯\(°_°)/¯
            m.dt = m.dtTimer.TotalMilliseconds() / 1000
            m.totalRunTime += m.dt
            if m.FakeDT <> invalid
                m.dt = m.FakeDT
            end if
            m.dtTimer.Mark()
            url_msg = m.url_port.GetMessage()
            universalControlEvents = []
            screen_msg = m.screen_port.GetMessage()
            ecp_msg = m.ecp_input_port.GetMessage()
            while screen_msg <> invalid
                if type(screen_msg) = "roUniversalControlEvent" and screen_msg.GetInt() <> 11
                    universalControlEvents.Push(screen_msg)
                    if screen_msg.GetInt() < 100
                        m.buttonHeld = screen_msg.GetInt()
                        m.buttonHeldTimer.Mark()
                    else
                        m.buttonHeld = - 1
                        if m.enableAudioGuideSuppression
                            if screen_msg.GetInt() = 110
                                audio_guide_suppression_ticker++
                                if audio_guide_suppression_ticker = 3
                                    audio_guide_suppression_roURLTransfer.AsyncPostFromString("")
                                    audio_guide_suppression_ticker = 0
                                end if
                            else
                                audio_guide_suppression_ticker = 0
                            end if
                        end if
                    end if
                end if
                screen_msg = m.screen_port.GetMessage()
            end while
            m.buttonHeldTime = m.buttonHeldTimer.TotalMilliseconds()
            music_msg = m.music_port.GetMessage()
            ' ----------------------Handle entity interactions (collisions, etc)--------------------
            m.processEntitiesPreDraw(universalControlEvents, music_msg, ecp_msg, url_msg)
            ' ----------------------Clear the screen before drawing entities-------------------------
            if m.background_color <> invalid
                m.canvas.bitmap.Clear(m.background_color)
            end if
            ' ----------------------Then draw all of the entities and call onDrawBegin() and onDrawEnd()-------------------------
            m.drawEntities()
            ' ---------------------- Draw debug items in game space -------------------------
            m.drawDebugItems()
            ' ---------------------- Handle all UI updates and draws -------------------------
            m.processAndDrawUI(universalControlEvents, music_msg, ecp_msg, url_msg)
            ' -------------------Draw everything to the screen----------------------------
            if not m.canvas_is_screen
                m.screen.DrawScaledObject(m.canvas.offset_x, m.canvas.offset_y, m.canvas.scale_x, m.canvas.scale_y, m.canvas.bitmap)
            end if
            ' ---------------------- Handle all Debug UI updates and draws -------------------------
            m.processAndDrawDebugUI(universalControlEvents, music_msg, ecp_msg, url_msg)
            if m.debugging.draw_safe_zones
                m.drawSafeZones()
            end if
            m.screen.SwapBuffers()
            if m.debugging.limit_frame_rate > 0 and m.dtTimer.TotalMilliseconds() > 0
                while 1000 / m.dtTimer.TotalMilliseconds() > m.debugging.limit_frame_rate
                    sleep(1)
                end while
            end if
            ' ------------------Destroy the UrlTransfer object if it has returned an event------------------
            if type(url_msg) = "roUrlEvent"
                url_transfer_id_string = url_msg.GetSourceIdentity().ToStr()
                if invalid <> url_transfer_id_string and m.urlTransfers.DoesExist(url_transfer_id_string)
                    m.urlTransfers.Delete(url_transfer_id_string)
                end if
            end if
            if m.garbageCollectionTimer.totalMilliseconds() > (m.secondsBetweenGarbageCollection * 1000)
                m.lastGarbageCollection = runGarbageCollector()
                m.garbageCollectionTimer.mark()
            end if
            if m.roomChangedThisFrame
                m.handleRoomChange()
            end if
        end while
    end function
    ' Handles all the processing for the entities before drawing
    '
    ' @param {object} universalControlEvents - array of any control events that happened since last frame
    ' @param {object} music_msg - audio player event in last frame
    ' @param {object} ecp_msg  - input event in last frame
    ' @param {object} url_msg - url event in last frame
    ' @return {void}
    instance.processEntitiesPreDraw = function(universalControlEvents as object, music_msg as object, ecp_msg as object, url_msg as object) as void
        started_paused = m.paused
        ' Process all Entity Updates
        for i = m.sortedEntities.Count() to 0 step - 1
            entity = invalid
            if i = m.sortedEntities.Count()
                ' magic to process current room first
                entity = m.currentRoom
            else
                entity = m.sortedEntities[i]
            end if
            if not m.isValidEntity(entity) or not entity.enabled or (started_paused and entity.pauseable)
                ' no need to process this entity
            else ' --------------------First process the onInput() function--------------------
                if m.isValidEntity(entity)
                    m.processEntityOnInput(entity, universalControlEvents)
                end if
                ' -------------------Then send the audioPlayer event msg if applicable-------------------
                if m.isValidEntity(entity) and invalid <> entity.onAudioEvent and "roAudioPlayerEvent" = type(music_msg)
                    entity.onAudioEvent(music_msg)
                end if
                ' -------------------Then send the ecp input events if applicable-------------------
                if m.isValidEntity(entity) and invalid <> entity.onECPInput and "roInputEvent" = type(ecp_msg) and ecp_msg.isInput()
                    entity.onECPInput(ecp_msg.GetInfo())
                end if
                ' -------------------Then send the urltransfer event msg if applicable-------------------
                if m.isValidEntity(entity) and invalid <> entity.onUrlEvent and "roUrlEvent" = type(url_msg)
                    entity.onUrlEvent(url_msg)
                end if
                ' -------------------Then process the onUpdate() function----------------------
                if m.isValidEntity(entity) and invalid <> entity.onUpdate
                    entity.onUpdate(m.dt)
                end if
                ' -------------------- Then handle the object movement--------------------
                if m.isValidEntity(entity)
                    m.processEntityMovement(entity)
                end if
            end if
            m.deleteIfInvalidEntityByIndex(i)
        end for
        ' Process all Entity Collisions
        for i = m.sortedEntities.Count() - 1 to 0 step - 1
            entity = m.sortedEntities[i]
            if not m.isValidEntity(entity) or not entity.enabled or (started_paused and entity.pauseable)
                ' no need to process this entity
            else ' ---------------- Give a space for any processing to happen just before collision checking occurs ------------
                if m.isValidEntity(entity) and invalid <> entity.onPreCollision
                    entity.onPreCollision()
                end if
                ' -------------------Then handle collisions and call onCollision() for each collision---------------------------
                if m.isValidEntity(entity) and invalid <> entity.onCollision
                    m.processEntityOnCollision(entity)
                end if
                ' ---------------- Give a space for any processing to happen just after collision checking occurs ------------
                if m.isValidEntity(entity) and invalid <> entity.onPostCollision
                    entity.onPostCollision()
                end if
                ' --------------Adjust compositor collider at end of loop so collider is accurate for collision checking from other objects-------------
                if m.isValidEntity(entity)
                    m.adjustEntityCompositorObjectPostCollision(entity)
                end if
            end if
            m.deleteIfInvalidEntityByIndex(i)
        end for
    end function
    ' Checks if an entity is still valid
    '
    ' @param {GameEntity} entity
    ' @return {boolean}
    instance.isValidEntity = function(entity as object) as boolean
        return BGE_isValidEntity(entity)
    end function
    ' Deletes an entity from the sortedEntities list by the index if that entity is not valid.
    ' Does not call the onDestroy() method of the entity.
    '
    ' @param {integer} sortedEntitiesIndex
    instance.deleteIfInvalidEntityByIndex = function(sortedEntitiesIndex as integer) as void
        entity = m.sortedEntities[sortedEntitiesIndex]
        if not m.isValidEntity(entity)
            m.destroyEntity(entity, false)
            m.sortedEntities.Delete(sortedEntitiesIndex)
        end if
    end function
    ' Processes input events and calls the entity's onInput function
    '
    ' @param {GameEntity} entity - the entity to relay input to
    ' @param {object} universalControlEvents - array of control events since last frame
    ' @return {boolean} true if this entity is still valid
    instance.processEntityOnInput = function(entity as object, universalControlEvents as object) as boolean
        if not m.isValidEntity(entity)
            return false
        end if
        for each msg in universalControlEvents
            if entity.onInput <> invalid and (m.currentInputEntityId = invalid or m.currentInputEntityId = entity.id)
                entity.onInput(BGE_GameInput(msg.GetInt(), 0))
                if not m.isValidEntity(entity)
                    return false
                end if
            end if
            if entity.onECPKeyboard <> invalid and msg.GetChar() <> 0 and msg.GetChar() = msg.GetInt()
                entity.onECPKeyboard(Chr(msg.GetChar()).toStr())
                if not m.isValidEntity(entity)
                    return false
                end if
            end if
        end for
        if m.buttonHeld <> - 1
            ' Button release codes are 100 plus the button press code
            ' This shows a button held code as 1000 plus the button press code
            if entity.onInput <> invalid and (m.currentInputEntityId = invalid or m.currentInputEntityId = entity.id)
                entity.onInput(BGE_GameInput(1000 + m.buttonHeld, m.buttonHeldTime))
                if not m.isValidEntity(entity)
                    return false
                end if
            end if
        end if
        return true
    end function
    ' Moves an entity based on its velocity
    '
    ' @param {GameEntity} entity
    ' @return {boolean} true if this entity is still valid
    instance.processEntityMovement = function(entity as object) as boolean
        if not m.isValidEntity(entity)
            return false
        end if
        if m.shouldUseIntegerMovement
            entity.x = entity.x + cint(entity.xspeed * 60 * m.dt)
            entity.y = entity.y + cint(entity.yspeed * 60 * m.dt)
        else
            entity.x = entity.x + entity.xspeed * 60 * m.dt
            entity.y = entity.y + entity.yspeed * 60 * m.dt
        end if
        return true
    end function
    ' Checks all colliders in an entity with all other colliders and if
    ' there is a collision, will call the entity's onCollsion() function
    '
    ' @param {GameEntity} entity
    ' @return {boolean} true if this entity is still valid
    instance.processEntityOnCollision = function(entity as object) as boolean
        if not m.isValidEntity(entity)
            return false
        end if
        for each colliderKey in entity.colliders
            collider = entity.colliders[colliderKey]
            if collider <> invalid
                if collider.enabled
                    collider.compositorObject.SetMemberFlags(collider.memberFlags)
                    collider.compositorObject.SetCollidableFlags(collider.collidableFlags)
                    collider.refreshColliderRegion()
                    collider.compositorObject.MoveTo(entity.x, entity.y)
                    multipleCollisions = collider.compositorObject.CheckMultipleCollisions()
                    if multipleCollisions <> invalid
                        for each otherCollider in multipleCollisions
                            otherColliderData = otherCollider.GetData()
                            if invalid <> otherColliderData and invalid <> otherColliderData.entityId
                                if otherColliderData.entityId <> entity.id
                                    otherEntity = invalid
                                    if m.Entities[otherColliderData.objectName].DoesExist(otherColliderData.entityId)
                                        otherEntity = m.Entities[otherColliderData.objectName][otherColliderData.entityId]
                                    else if invalid <> m.currentRoom and otherColliderData.objectName = m.currentRoom.name
                                        ' Or is it the current room?
                                        otherEntity = m.currentRoom
                                    end if
                                    if invalid <> otherEntity and otherEntity.id <> entity.id
                                        entity.onCollision(colliderKey, otherColliderData.colliderName, otherEntity)
                                        if not m.isValidEntity(entity)
                                            return false
                                        end if
                                    end if
                                end if
                            end if
                        end for
                        if not m.isValidEntity(entity)
                            return false
                        end if
                    end if
                else
                    collider.compositorObject.SetMemberFlags(0)
                    collider.compositorObject.SetCollidableFlags(0)
                end if
            else
                if entity.colliders.DoesExist(colliderKey)
                    entity.colliders.Delete(colliderKey)
                end if
            end if
        end for
        return true
    end function
    ' Helper to adjust en entities colliders after movement
    '
    ' @param {GameEntity} entity
    ' @return {boolean} true if this entity is still valid
    instance.adjustEntityCompositorObjectPostCollision = function(entity as object) as boolean
        if not m.isValidEntity(entity)
            return false
        end if
        for each colliderKey in entity.colliders
            collider = entity.colliders[colliderKey]
            if collider <> invalid
                collider.adjustCompositorObject(entity.x, entity.y)
            else
                if entity.colliders.DoesExist(colliderKey)
                    entity.colliders.Delete(colliderKey)
                end if
            end if
        end for
        return true
    end function
    ' Draws all the entities, by zIndex (low zIndex is drawn before high zIndex)
    '
    ' @return {void}
    instance.drawEntities = function() as void
        if invalid <> m.currentRoom
            m.processEntityDraw(m.currentRoom)
        end if
        m.sortedEntities.sortBy("zIndex")
        for each entity in m.sortedEntities
            m.processEntityDraw(entity)
        end for
    end function
    ' Draws an entity, bookended by calling onDrawBegin/End functions
    '
    ' @param {GameEntity} entity
    ' @return {boolean} true if this entity is still valid
    instance.processEntityDraw = function(entity as object) as boolean
        if not m.isValidEntity(entity)
            return false
        end if
        if m.isValidEntity(entity) and invalid <> entity.onDrawBegin
            entity.onDrawBegin(m.canvas.bitmap)
        end if
        if m.isValidEntity(entity)
            for each image in entity.images
                image.Draw(entity.rotation)
            end for
            if m.isValidEntity(entity) and invalid <> entity.onDrawEnd
                entity.onDrawEnd(m.canvas.bitmap)
            end if
        end if
        return m.isValidEntity(entity)
    end function
    ' Ends the Game
    '
    ' @return {void}
    instance.End = function() as void
        m.running = false
    end function
    ' Pauses the game
    ' Only entities marked as pausable = false will be processed in game loop
    ' For each entity, the onPause() function will be called
    '
    ' @return {void}
    instance.Pause = function() as void
        if not m.paused
            m.paused = true
            for i = 0 to m.sortedEntities.Count() - 1
                entity = m.sortedEntities[i]
                if entity <> invalid and entity.id <> invalid and entity.onPause <> invalid
                    entity.onPause()
                end if
            end for
            m.pauseTimer.Mark()
        end if
    end function
    ' Resumes / unpauses the game
    ' For each entity, the onResume() function will be called, and any image in the entity will have its onResume() called
    '
    ' @return {void}
    instance.Resume = function() as dynamic
        if m.paused
            m.paused = false
            paused_time = m.pauseTimer.TotalMilliseconds()
            for i = 0 to m.sortedEntities.Count() - 1
                entity = m.sortedEntities[i]
                if entity <> invalid and entity.id <> invalid
                    if invalid <> entity.images
                        for each image in entity.images
                            if image.DoesExist("onResume") and image.onResume <> invalid
                                image.onResume(paused_time)
                            end if
                        end for
                    end if
                    if entity.onResume <> invalid
                        entity.onResume(paused_time)
                    end if
                end if
            end for
            return paused_time
        end if
        return invalid
    end function
    ' Is the game paused?
    '
    ' @return {boolean}
    instance.isPaused = function() as boolean
        return m.paused
    end function
    ' Sets the default background color for the game
    ' Before any entities are drawn, the screen is cleared to this color
    '
    ' @param {integer} color
    ' @return {void}
    instance.setBackgroundColor = function(color as integer) as void
        m.background_color = color
    end function
    ' What's the time in seconds since last frame?
    '
    ' @return {float}
    instance.getDeltaTime = function() as float
        return m.dt
    end function
    ' What's the total time in seconds since ths start
    '
    ' @return {float}
    instance.getTotalTime = function() as float
        return m.totalRunTime
    end function
    ' Gets the current Room/Level the game is using
    '
    ' @return {Room}
    instance.getRoom = function() as object
        return m.currentRoom
    end function
    ' Gets the bitmap the game is currently drawing to
    '
    ' @return {object}
    instance.getCanvas = function() as object
        return m.canvas.bitmap
    end function
    ' Gets the screen object
    '
    ' @return {object}
    instance.getScreen = function() as object
        return m.screen
    end function
    ' Resets the screen
    ' Note: _Important_ This function is here because of a bug with the Roku.
    ' If you ever try to use a component that displays something on the screen aside from roScreen,
    ' such as roKeyboardScreen, roMessageDialog, etc. the screen will flicker after you return to your game
    ' You should always call this method after using a screen that's outside of roScreen in order to prevent this bug.
    '
    ' @return {void}
    instance.resetScreen = function() as void
        m.setUpScreen(m.screen.GetWidth(), m.screen.GetHeight(), m.canvas_is_screen)
        if m.canvas_is_screen
            m.canvas.bitmap = m.screen
            ' This is so all entities that have images that draw to the screen get updated with the new screen.
            for each objectKey in m.Entities
                for each entityKey in m.Entities[objectKey]
                    entity = m.Entities[objectKey][entityKey]
                    if entity <> invalid and entity.id <> invalid and entity.DoesExist("images")
                        for each image in entity.images
                            if type(image.drawTo) = "roScreen"
                                image.drawTo = m.screen
                            end if
                        end for
                    end if
                end for
            end for
        end if
    end function
    ' Gets a 1x1 bitmap image (used for collider compositing)
    '
    ' @return {object} - a 1x1 empty roBitmap
    instance.getEmptyBitmap = function() as object
        return m.emptyBitmap
    end function
    ' --------------------------------Begin Ui Functions----------------------------------------
    ' Gets the UI Container to add new UI elements (which get drawn on top off Game Entities)
    '
    ' @return {BGE.Ui.UiContainer} - the container all other UI elements can be added to
    instance.getUI = function() as object
        return m.gameUi
    end function
    ' Function to handle all input and updates and draws for UI layer
    '
    ' @param {object} universalControlEvents - array of control events since last frame
    ' @param {object} music_msg - audio player event in last frame
    ' @param {object} ecp_msg  - input event in last frame
    ' @param {object} url_msg - url event in last frame
    instance.processAndDrawUI = function(universalControlEvents as object, music_msg as object, ecp_msg as object, url_msg as object) as void
        m.processUiUpdate(m.gameUi, universalControlEvents, music_msg, ecp_msg, url_msg)
        if m.isValidEntity(m.gameUi) and invalid <> m.gameUi.draw
            m.gameUi.draw()
        end if
    end function
    ' Function to handle all input and updates and draws for UI layer
    '
    ' @param {BGE.Ui.UiWidget} - widget to process
    ' @param {object} universalControlEvents - array of control events since last frame
    ' @param {object} music_msg - audio player event in last frame
    ' @param {object} ecp_msg  - input event in last frame
    ' @param {object} url_msg - url event in last frame
    instance.processUiUpdate = function(uiEntity as object, universalControlEvents as object, music_msg as object, ecp_msg as object, url_msg as object) as void
        ' --------------------First process the onInput() function--------------------
        if m.isValidEntity(uiEntity)
            m.processEntityOnInput(uiEntity, universalControlEvents)
        end if
        ' -------------------Then send the audioPlayer event msg if applicable-------------------
        if m.isValidEntity(uiEntity) and invalid <> uiEntity.onAudioEvent and "roAudioPlayerEvent" = type(music_msg)
            uiEntity.onAudioEvent(music_msg)
        end if
        ' -------------------Then send the ecp input events if applicable-------------------
        if m.isValidEntity(uiEntity) and invalid <> uiEntity.onECPInput and "roInputEvent" = type(ecp_msg) and ecp_msg.isInput()
            uiEntity.onECPInput(ecp_msg.GetInfo())
        end if
        ' -------------------Then send the urltransfer event msg if applicable-------------------
        if m.isValidEntity(uiEntity) and invalid <> uiEntity.onUrlEvent and "roUrlEvent" = type(url_msg)
            uiEntity.onUrlEvent(url_msg)
        end if
        ' -------------------Then process the onUpdate() function----------------------
        if m.isValidEntity(uiEntity) and invalid <> uiEntity.onUpdate
            uiEntity.onUpdate(m.dt)
        end if
    end function
    ' --------------------------------Begin Debug Functions----------------------------------------
    ' Gets the main debug window to add other debug widgets to
    '
    ' @return {BGE.Debug.DebugWindow} - the container all other Debug UI elements can be added to
    instance.getDebugUI = function() as object
        return m.debugUi
    end function
    ' Function to handle all input and updates and draws for Debug UI layer
    '
    ' @param {object} universalControlEvents - array of control events since last frame
    ' @param {object} music_msg - audio player event in last frame
    ' @param {object} ecp_msg  - input event in last frame
    ' @param {object} url_msg - url event in last frame
    instance.processAndDrawDebugUI = function(universalControlEvents as object, music_msg as object, ecp_msg as object, url_msg as object) as void
        m.processUiUpdate(m.debugUi, universalControlEvents, music_msg, ecp_msg, url_msg)
        if m.debugging.show_debug_ui and m.isValidEntity(m.debugUi) and invalid <> m.debugUi.draw
            if m.debugging.draw_debugUi_to_screen and m.debugUi.drawTo <> m.screen
                m.debugUi.setCanvas(m.screen)
            else if not m.debugging.draw_debugUi_to_screen and m.debugUi.drawTo <> m.getCanvas()
                m.debugUi.setCanvas(m.getCanvas())
            end if
            m.debugUi.draw()
        end if
    end function
    ' Draw Debug Related Items on the game Layer
    '
    ' @return {void}
    instance.drawDebugItems = function() as void
        if m.debugging.draw_colliders
            for i = m.sortedEntities.Count() - 1 to 0 step - 1
                entity = m.sortedEntities[i]
                if m.isValidEntity(entity)
                    m.drawColliders(entity)
                end if
            end for
        end if
    end function
    ' Set if colliders should be drawn
    '
    ' @param {boolean} enabled
    instance.debugDrawColliders = function(enabled as boolean) as void
        m.debugging.draw_colliders = enabled
    end function
    ' Set if Safe Zone should be drawn
    '
    ' @param {boolean} enabled
    instance.debugDrawSafeZones = function(enabled as boolean) as void
        m.debugging.draw_safe_zones = enabled
    end function
    ' Set if Debug UI/Windows should be drawn
    '
    ' @param {boolean} enabled
    ' @param {boolean} drawToScreen Draw the debug UI to the screen instead of the canvas
    instance.debugShowUi = function(enabled as boolean, drawToScreen = false as boolean) as void
        m.debugging.show_debug_ui = enabled
        m.debugging.draw_debugUi_to_screen = drawToScreen
        debugCanvas = m.canvas
        if drawToScreen
            debugCanvas = m.screen
        end if
        m.debugUi.width = debugCanvas.getWidth()
        m.debugUi.height = debugCanvas.getHeight()
    end function
    ' Sets the colors for the debug items to be drawn
    ' colors = {colliders: integer, safe_action_zone: integer, safe_title_zone: integer}
    '
    ' @param {object} colors
    instance.debugSetColors = function(colors as object) as void
        if invalid = BGE_colors
            return
        end if
        allowedColorNames = [
            "colliders"
            "safe_action_zone"
            "safe_title_zone"
        ]
        colorsToAppend = {}
        for each colorName in allowedColorNames
            if invalid <> BGE_colors[colorName]
                colorsToAppend[colorName + "_color"] = BGE_colors[colorName]
            end if
        end for
        m.debugging.append(colorsToAppend)
    end function
    ' Limit the frame rate to the given number of frames per second
    '
    ' @param {integer} limit_frame_rate
    ' @return {void}
    instance.debugLimitFrameRate = function(limit_frame_rate as integer) as void
        m.debugging.limit_frame_rate = limit_frame_rate
    end function
    ' Gets the latest stats from automatic garbage collection
    ' https://developer.roku.com/en-ca/docs/references/brightscript/language/global-utility-functions.md#rungarbagecollector-as-object
    '
    ' @return {object} Stats of garbage collection. Properties: count, orphaned, root
    instance.getGarbageCollectionStats = function() as object
        return m.lastGarbageCollection
    end function
    ' Draw the colliders for the given entity
    '
    ' @param {GameEntity} entity
    ' @param {integer} [color=0]
    ' @return {void}
    instance.drawColliders = function(entity as object, color = 0 as integer) as void
        if not m.isValidEntity(entity) or invalid = entity.colliders
            return
        end if
        if 0 = color
            color = m.debugging.colliders_color
        end if
        for each colliderKey in entity.colliders
            collider = entity.colliders[colliderKey]
            if collider.enabled
                collider.debugDraw(m.canvas.bitmap, entity.x, entity.y, color)
            end if
        end for
    end function
    ' Draws the safe zones
    '
    ' @return {void}
    instance.drawSafeZones = function() as void
        screen_width = m.screen.GetWidth()
        screen_height = m.screen.GetHeight()
        if m.device.GetDisplayAspectRatio() = "4x3"
            action_offset = {
                w: 0.033 * screen_width
                h: 0.035 * screen_height
            }
            title_offset = {
                w: 0.067 * screen_width
                h: 0.05 * screen_height
            }
        else
            action_offset = {
                w: 0.035 * screen_width
                h: 0.035 * screen_height
            }
            title_offset = {
                w: 0.1 * screen_width
                h: 0.05 * screen_height
            }
        end if
        action_safe_zone = {
            x1: action_offset.w
            y1: action_offset.h
            x2: screen_width - action_offset.w
            y2: screen_height - action_offset.h
        }
        title_safe_zone = {
            x1: title_offset.w
            y1: title_offset.h
            x2: screen_width - title_offset.w
            y2: screen_height - title_offset.h
        }
        m.screen.DrawRect(action_safe_zone.x1, action_safe_zone.y1, action_safe_zone.x2 - action_safe_zone.x1, action_safe_zone.y2 - action_safe_zone.y1, m.debugging.safe_action_zone_color)
        m.screen.DrawRect(title_safe_zone.x1, title_safe_zone.y1, title_safe_zone.x2 - title_safe_zone.x1, title_safe_zone.y2 - title_safe_zone.y1, m.debugging.safe_title_zone_color)
        m.screen.DrawText("Action Safe Zone", m.screen.GetWidth() / 2 - m.getFont("debugUI").GetOneLineWidth("Action Safe Zone", 1000) / 2, action_safe_zone.y1 + 10, &hFF0000FF, m.getFont("debugUI"))
        m.screen.DrawText("Title Safe Zone", m.screen.GetWidth() / 2 - m.getFont("debugUI").GetOneLineWidth("Title Safe Zone", 1000) / 2, action_safe_zone.y1 + 50, &hFF00FFFF, m.getFont("debugUI"))
    end function
    ' --------------------------------Begin Raycast Functions----------------------------------------
    ' Performs a raycast from a certain location along a vector to find any colliders on that line
    '
    ' @param {float} sourceX x position of ray start
    ' @param {float} sourceY y position of ray start
    ' @param {float} vectorX x value of vector
    ' @param {float} vectorY y value of vector
    ' @return {object} {collider: collider, entity: entity} of first collider along the vector, or invalid if no collisions
    instance.raycastVector = function(sourceX as float, sourceY as float, vectorX as float, vectorY as float) as object
        ' TODO Do Raycasts!
        return invalid
    end function
    ' Performs a raycast from a certain location along a n angle to find any colliders on that line
    '
    ' @param {float} sourceX x position of ray start
    ' @param {float} sourceY y position of ray start
    ' @param {float} angle angle of ray
    ' @return {object} {collider: collider, entity: entity} of first collider along the angle, or invalid if no collisions
    instance.raycastAngle = function(sourceX as float, sourceY as float, angle as float) as object
        ' TODO Do Raycasts!
        return invalid
    end function
    ' --------------------------------Begin Object Functions----------------------------------------
    ' Sets up the lookup table of entities for entities with this name
    '
    ' @param {string} entityName
    ' @return {void}
    instance.defineEntity = function(entityName as string) as void
        if invalid = m.Entities[entityName]
            m.Entities[entityName] = {}
            m.Statics[entityName] = {}
        end if
    end function
    ' TODO: work on interfaces
    '
    ' @param {string} interfaceName
    ' @param {callable} interfaceCreationFunction
    ' @return {void}
    instance.defineInterface = function(interfaceName as string, interfaceCreationFunction as Function) as void
        m.Interfaces[interfaceName] = interfaceCreationFunction
    end function
    ' Adds a game entity to be processed by the game engine
    ' Only entities that have been added will be part of the game
    ' Calls the entity's onCreate() function with the args provided
    '
    ' @param {GameEntity} entity - the entity to be added
    ' @param {object} [args={}] - arguments to the entity's onCreate() method
    ' @return {GameEntity} the entity that was added
    instance.addEntity = function(entity as object, args = {} as object) as object
        entity.onCreate(args)
        m.defineEntity(entity.name)
        m.Entities[entity.name][entity.id] = entity
        m.sortedEntities.Push(entity)
        return entity
    end function
    ' Gets an entity by its unique id
    '
    ' @param {string} entityId
    ' @return {GameEntity} the entity with the given id, if found, otherwise invalid
    instance.getEntityByID = function(entityId as string) as object
        for each entity in m.sortedEntities
            if m.isValidEntity(entity) and entityId = entity.id
                return entity
            end if
        end for
        return invalid
    end function
    ' Gets the first entity with the given name
    '
    ' @param {string} objectName
    ' @return {GameEntity} the entity with the given name, if found, otherwise invalid
    instance.getEntityByName = function(objectName as string) as object
        if invalid <> objectName and m.Entities.DoesExist(objectName)
            for each entityKey in m.Entities[objectName]
                return m.Entities[objectName][entityKey] ' Obviously only retrieves the first value
            end for
        end if
        return invalid
    end function
    ' Gets all the entities that match the given name
    '
    ' @param {string} objectName
    ' @return {object} an array with entities with the given name
    instance.getAllEntities = function(objectName as string) as object
        array = []
        if invalid <> objectName and m.Entities.DoesExist(objectName)
            for each entityKey in m.Entities[objectName]
                array.Push(m.Entities[objectName][entityKey])
            end for
        end if
        return []
    end function
    ' TODO: work on interfaces
    '
    ' @param {string} interfaceName
    ' @return {object}
    instance.getAllEntitiesWithInterface = function(interfaceName as string) as dynamic
        array = []
        if invalid <> interfaceName and m.Interfaces.DoesExist(interfaceName)
            for each entity in m.sortedEntities
                if entity <> invalid and entity.id <> invalid and entity.hasInterface(interfaceName)
                    array.Push(entity)
                end if
            end for
        end if
        return array
    end function
    ' Destroys an entity and all its colliders
    ' Clears its properties, so images, etc. won't get drawn anymore
    '
    ' @param {GameEntity} entity - the entity to destroy
    ' @param {boolean} [callOnDestroy=true]
    ' @return {void}
    instance.destroyEntity = function(entity as object, callOnDestroy = true as boolean) as void
        if invalid <> entity
            entityName = entity.name
            entityId = entity.id
            if invalid <> entity.clearAllColliders
                entity.clearAllColliders()
            end if
            if invalid <> entity.onDestroy and callOnDestroy
                entity.onDestroy()
            end if
            if invalid <> entity.name and invalid <> entityId and m.Entities[entityName].DoesExist(entityId) ' This redundancy is here because if somebody would try to change rooms within the onDestroy() method the game would break.
                m.Entities[entityName].Delete(entityId)
            end if
            if invalid <> entity.Clear
                entity.Clear()
            end if
            entity.id = invalid
        end if
    end function
    ' Destroys all entities with a given name
    '
    ' @param {string} objectName
    ' @param {boolean} [callOnDestroy=true]
    ' @return {void}
    instance.destroyAllEntities = function(objectName as string, callOnDestroy = true as boolean) as void
        if invalid <> m.Entities[objectName]
            for each entityKey in m.Entities[objectName]
                m.destroyEntity(m.Entities[objectName][entityKey], callOnDestroy)
            end for
        end if
    end function
    ' Gets the number of entities of a given name
    '
    ' @param {string} objectName
    ' @return {integer}
    instance.entityCount = function(objectName as string) as integer
        count = 0
        if invalid <> m.Entities[objectName]
            count = m.Entities[objectName].Count()
        end if
        return count
    end function
    ' --------------------------------Begin Room Functions----------------------------------------
    ' Defines a room (like a level) in the game
    ' TODO: work on rooms
    '
    ' @param {Room} room
    ' @return {void}
    instance.defineRoom = function(room as object) as void
        roomName = room.name
        m.Rooms[roomName] = room
        m.Entities[roomName] = {}
        m.Statics[roomName] = {}
    end function
    instance.isRoomChanging = function() as boolean
        return m.roomChangedThisFrame
    end function
    ' Changes the active room to the one with the given name
    ' Calls the room's onCreate() method with the args given
    ' TODO: work on rooms
    '
    ' @param {string} roomName
    ' @param {object} [args={}]
    ' @return {boolean} true if room change was successful
    instance.changeRoom = function(roomName as string, args = {} as object) as boolean
        if m.Rooms[roomName] <> invalid
            m.roomChangedThisFrame = true
            m.roomChangeDetails = {
                room: m.Rooms[roomName]
                args: args
            }
            if invalid = m.currentRoom or not m.running
                m.handleRoomChange()
            end if
            return true
        else
            print "changeRoom() - A room named " + roomName + " hasn't been defined"
            return false
        end if
    end function
    instance.handleRoomChange = sub()
        if m.roomChangedThisFrame and m.roomChangeDetails <> invalid and m.roomChangeDetails.room <> invalid
            room = m.roomChangeDetails.room
            args = {}
            if m.roomChangeDetails.args <> invalid
                args = m.roomChangeDetails.args
            end if
            for i = 0 to m.sortedEntities.Count() - 1
                entity = m.sortedEntities[i]
                if m.isValidEntity(entity) and entity.onChangeRoom <> invalid
                    entity.onChangeRoom(room)
                end if
            end for
            for i = 0 to m.sortedEntities.Count() - 1
                entity = m.sortedEntities[i]
                if m.isValidEntity(entity) and not entity.persistent and entity.name <> m.currentRoom.name
                    m.destroyEntity(entity, false)
                end if
            end for
            if m.isValidEntity(m.currentRoom) and m.currentRoom.onChangeRoom <> invalid
                m.currentRoom.onChangeRoom(room)
            end if
            m.currentRoom = room
            m.currentRoomArgs = args
            m.currentRoom.onCreate(args)
            m.roomChangedThisFrame = false
        end if
    end sub
    ' Resets the current room to its state at when it was first created
    '
    ' @return {void}
    instance.resetRoom = function() as void
        m.changeRoom(m.currentRoom.name, m.currentRoomArgs)
    end function
    ' --------------------------------Begin Bitmap Functions----------------------------------------
    ' Loads an image file (png/jpg) to be used as an image in the game
    '
    ' @param {string} bitmapName - the name this bitmap will be referenced by later
    ' @param {dynamic} path - The path to the bitmap, or an associative array {width: integer, height: integer, alphaEnable:boolean}
    ' @return {boolean} true if image was loaded
    instance.loadBitmap = function(bitmapName as string, path as dynamic) as boolean
        if type(path) = "roAssociativeArray"
            if path.width <> invalid and path.height <> invalid and path.AlphaEnable <> invalid
                m.Bitmaps[bitmapName] = CreateObject("roBitmap", path)
                return true
            else
                print "loadBitmap() - Width as Integer, Height as Integer, and AlphaEnabled as Boolean must be provided in order to create an empty bitmap"
                return false
            end if
        else if m.filesystem.Exists(path)
            path_object = CreateObject("roPath", path)
            parts = path_object.Split()
            if parts.extension = ".png" or parts.extension = ".jpg"
                m.Bitmaps[bitmapName] = CreateObject("roBitmap", path)
                return true
            else
                print "loadBitmap() - Bitmap " + path + " not loaded, file must be of type .png or .jpg"
                return false
            end if
        else
            print "loadBitmap() - Bitmap not created, invalid path or object properties provided"
            return false
        end if
    end function
    ' Gets a bitmap image (roBitmap) by the name given to it when loadBitmap() was called
    '
    ' @param {string} bitmapName
    ' @return {object}
    instance.getBitmap = function(bitmapName as string) as object
        return m.Bitmaps[bitmapName]
    end function
    ' Invalidates a bitmap name, so it can't be loaded again
    '
    ' @param {string} bitmapName
    ' @return {void}
    instance.unloadBitmap = function(bitmapName as string) as void
        m.Bitmaps[bitmapName] = invalid
    end function
    ' --------------------------------Begin Font Functions----------------------------------------
    ' Registers a font by its path
    '
    ' @param {string} path
    ' @return {boolean} true if font was registered
    instance.registerFont = function(path as string) as boolean
        if m.filesystem.Exists(path)
            path_object = CreateObject("roPath", path)
            parts = path_object.Split()
            if parts.extension = ".ttf" or parts.extension = ".otf"
                m.fontRegistry.register(path)
                return true
            else
                print "Font must be of type .ttf or .otf"
                return false
            end if
        else
            print "File at path "; path; " doesn't exist"
            return false
        end if
    end function
    ' Loads a font from the registry, and assigns it the given name
    '
    ' @param {string} fontName - the lookup name to assign to this font
    ' @param {string} font - the font to load
    ' @param {integer} size
    ' @param {boolean} italic
    ' @param {boolean} bold
    ' @return {void}
    instance.loadFont = function(fontName as string, font as string, size as integer, italic as boolean, bold as boolean) as void
        m.fonts[fontName] = m.fontRegistry.GetFont(font, size, italic, bold)
    end function
    ' Unloads a font so it can't be used again
    '
    ' @param {string} fontName
    ' @return {void}
    instance.unloadFont = function(fontName as string) as void
        m.fonts[fontName] = invalid
    end function
    ' Gets a font object, to be used for writing text to the screen
    ' For example, in BGE.DrawText()
    '
    ' @param {string} fontName
    ' @return {object}
    instance.getFont = function(fontName as string) as object
        return m.fonts[fontName]
    end function
    ' --------------------------------Begin Canvas Functions----------------------------------------
    ' Scales and positions the current canvas to fit the screen
    '
    ' @return {void}
    instance.fitCanvasToScreen = function() as void
        canvas_width = m.canvas.bitmap.GetWidth()
        canvas_height = m.canvas.bitmap.GetHeight()
        screen_width = m.screen.GetWidth()
        screen_height = m.screen.GetHeight()
        if screen_width / screen_height < canvas_width / canvas_height
            m.canvas.scale_x = screen_width / canvas_width
            m.canvas.scale_y = m.canvas.scale_x
            m.canvas.offset_x = 0
            m.canvas.offset_y = (screen_height - (screen_width / (canvas_width / canvas_height))) / 2
        else if screen_width / screen_height > canvas_width / canvas_height
            m.canvas.scale_x = screen_height / canvas_height
            m.canvas.scale_y = m.canvas.scale_x
            m.canvas.offset_x = (screen_width - (screen_height * (canvas_width / canvas_height))) / 2
            m.canvas.offset_y = 0
        else
            m.canvas.offset_x = 0
            m.canvas.offset_y = 0
            scale_difference = screen_width / canvas_width
            m.canvas.scale_x = 1 * scale_difference
            m.canvas.scale_y = 1 * scale_difference
        end if
    end function
    ' Centers the canvas on the screen
    '
    ' @return {void}
    instance.centerCanvasToScreen = function() as void
        m.canvas.offset_x = m.screen.GetWidth() / 2 - (m.canvas.scale_x * m.canvas.bitmap.GetWidth()) / 2
        m.canvas.offset_y = m.screen.GetHeight() / 2 - (m.canvas.scale_y * m.canvas.bitmap.GetHeight()) / 2
    end function
    ' --------------------------------Begin Audio Functions----------------------------------------
    ' Plays an audio file at the given path
    ' This is designed for music, where only one file can play at a time.
    '
    ' @param {string} path - the path of the music file
    ' @param {boolean} [loop=false]
    ' @return {boolean} - true if started
    instance.musicPlay = function(path as string, loop = false as boolean) as boolean
        if m.filesystem.Exists(path)
            m.audioPlayer.stop()
            m.audioPlayer.ClearContent()
            song = {}
            song.url = path
            m.audioPlayer.AddContent(song)
            m.audioPlayer.SetLoop(loop)
            m.audioPlayer.play()
            return true
        else
            print "musicPlay() - No file exists at path: "; path
            return false
        end if
    end function
    ' Stops the currently playing music file
    '
    ' @return {void}
    instance.musicStop = function() as void
        m.audioPlayer.stop()
    end function
    ' Pauses the currently playing music
    '
    ' @return {void}
    instance.musicPause = function() as void
        m.audioPlayer.pause()
    end function
    ' Resumes / unpauses the current music
    '
    ' @return {void}
    instance.musicResume = function() as void
        m.audioPlayer.resume()
    end function
    ' Loads a sound file from the given path to be played later
    '
    ' @param {string} soundName - the name to assign this sound to, to be referenced later
    ' @param {string} path - the path to load
    ' @return {void}
    instance.loadSound = function(soundName as string, path as string) as void
        m.Sounds[soundName] = CreateObject("roAudioResource", path)
    end function
    ' Plays the given sound
    '
    ' @param {string} soundName - the name of the sound to play
    ' @param {integer} [volume=100] - volume (0-100) to play the sound at
    ' @return {boolean}
    instance.playSound = function(soundName as string, volume = 100 as integer) as boolean
        if invalid <> soundName and m.Sounds.DoesExist(soundName)
            volume = cint(BGE_Math_Clamp(volume, 0, 100))
            m.Sounds[soundName].trigger(volume)
            return true
        else
            print "playSound() - No sound has been loaded under the name: "; soundName
            return false
        end if
    end function
    ' --------------------------------Begin Url Functions----------------------------------------
    ' Creates a new URL Async Transfer object, which is handled by the game loop
    ' Events from this URL transfer will be set to entities via the onUrlEvent() method
    '
    ' @return {object}
    instance.newAsyncUrlTransfer = function() as object
        UrlTransfer = CreateObject("roUrlTransfer")
        UrlTransfer.SetMessagePort(m.url_port)
        m.urlTransfers[UrlTransfer.GetIdentity().ToStr()] = UrlTransfer
        return UrlTransfer
    end function
    ' --------------------------------Begin Input Entity Functions----------------------------------------
    ' Set only one entity to receive onInput() calls
    ' Useful for when a menu/pause screen should handle all input
    '
    ' @param {GameEntity} entity
    ' @return {void}
    instance.setInputEntity = function(entity as object) as void
        m.inputEntityId = entity.id
    end function
    ' Unset that only one entity will receive onInputCalls()
    '
    ' @return {void}
    instance.unsetInputEntity = function() as void
        m.inputEntityId = invalid
    end function
    ' --------------------------------Begin Game Event Functions----------------------------------------
    ' General purpose event dispatch method
    ' Game entities can listen for events via the onGameEvent() method
    '
    ' @param {string} eventName - identifier for the event, eg. "hit", "win", etc.
    ' @param {object} [data={}] - any data that needs to be be passed with the event
    ' @return {void}
    instance.postGameEvent = function(eventName as string, data = {} as object) as void
        for i = 0 to m.sortedEntities.Count() - 1
            entity = m.sortedEntities[i]
            if m.isValidEntity(entity) and entity.onGameEvent <> invalid
                entity.onGameEvent(eventName, data)
            end if
        end for
        if invalid <> m.currentRoom
            m.currentRoom.onGameEvent(eventName, data)
        end if
        if invalid <> m.ui
        end if
    end function
    return instance
end function
function BGE_Game(canvas_width as integer, canvas_height as integer, canvas_as_screen_if_possible = false as boolean)
    instance = __BGE_Game_builder()
    instance.new(canvas_width, canvas_height, canvas_as_screen_if_possible)
    return instance
end function'//# sourceMappingURL=./Game.bs.map