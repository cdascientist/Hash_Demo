function __ServiceLayerOne_builder()
    instance = {}
    instance.new = function() as void
        m.debug = invalid
        m.debug = CreateObject("roDeviceInfo")
    end function
    instance.execute = function() as void
        m.log("Service Layer One Executing")
    end function
    instance.log = function(message as string) as void
        ? message
    end function
    return instance
end function
function ServiceLayerOne()
    instance = __ServiceLayerOne_builder()
    instance.new()
    return instance
end function
function __ServiceLayerTwo_builder()
    instance = {}
    instance.new = function() as void
        m.debug = invalid
        m.debug = CreateObject("roDeviceInfo")
    end function
    instance.execute = function() as void
        m.log("Service Layer Two Executing")
    end function
    instance.log = function(message as string) as void
        ? message
    end function
    return instance
end function
function ServiceLayerTwo()
    instance = __ServiceLayerTwo_builder()
    instance.new()
    return instance
end function
function __PhaseBase_builder()
    instance = {}
    instance.new = function() as void
        m.nextPhaseObj = invalid
        m.debug = invalid
        m.debug = CreateObject("roDeviceInfo")
    end function
    instance.log = function(message as string) as void
        ? message ' Using print statement for debug output
    end function
    instance.getNextPhase = function() as object
        if m.nextPhaseObj = invalid
            m.createNextPhase()
        end if
        return m.nextPhaseObj
    end function
    instance.createNextPhase = function() as void
        ' To be implemented by child classes
    end function
    instance.execute = function() as void
        ' To be implemented by child classes
    end function
    return instance
end function
function PhaseBase()
    instance = __PhaseBase_builder()
    instance.new()
    return instance
end function
function __InitPhase_builder()
    instance = __PhaseBase_builder()
    instance.super0_new = instance.new
    instance.new = function() as void
        m.super0_new()
        m.serviceOne = invalid
        m.serviceTwo = invalid
        m.serviceOne = ServiceLayerOne()
        m.serviceTwo = ServiceLayerTwo()
    end function
    instance.super0_execute = instance.execute
    instance.execute = function() as void
        m.log("PHASE 1: Initialization Phase")
        ' Execute services in parallel using Tasks
        taskOne = CreateObject("roSGNode", "Task")
        taskOne.observeField("state", "onTaskOneComplete")
        taskOne.control = "RUN"
        m.serviceOne.execute()
        taskTwo = CreateObject("roSGNode", "Task")
        taskTwo.observeField("state", "onTaskTwoComplete")
        taskTwo.control = "RUN"
        m.serviceTwo.execute()
    end function
    instance.onTaskOneComplete = function(event as object) as void
        m.log("Service Layer One Task Complete")
    end function
    instance.onTaskTwoComplete = function(event as object) as void
        m.log("Service Layer Two Task Complete")
    end function
    instance.super0_createNextPhase = instance.createNextPhase
    instance.createNextPhase = function() as void
        m.nextPhaseObj = SetupPhase()
    end function
    return instance
end function
function InitPhase()
    instance = __InitPhase_builder()
    instance.new()
    return instance
end function
function __SetupPhase_builder()
    instance = __PhaseBase_builder()
    instance.super0_new = instance.new
    instance.new = function() as void
        m.super0_new()
    end function
    instance.super0_execute = instance.execute
    instance.execute = function() as void
        m.log("PHASE 2: Setup Phase")
    end function
    instance.super0_createNextPhase = instance.createNextPhase
    instance.createNextPhase = function() as void
        m.nextPhaseObj = ExecutePhase()
    end function
    return instance
end function
function SetupPhase()
    instance = __SetupPhase_builder()
    instance.new()
    return instance
end function
function __ExecutePhase_builder()
    instance = __PhaseBase_builder()
    instance.super0_new = instance.new
    instance.new = function() as void
        m.super0_new()
    end function
    instance.super0_execute = instance.execute
    instance.execute = function() as void
        m.log("PHASE 3: Execution Phase")
    end function
    instance.super0_createNextPhase = instance.createNextPhase
    instance.createNextPhase = function() as void
        m.nextPhaseObj = CompletePhase()
    end function
    return instance
end function
function ExecutePhase()
    instance = __ExecutePhase_builder()
    instance.new()
    return instance
end function
function __CompletePhase_builder()
    instance = __PhaseBase_builder()
    instance.super0_new = instance.new
    instance.new = function() as void
        m.super0_new()
    end function
    instance.super0_execute = instance.execute
    instance.execute = function() as void
        m.log("PHASE 4: Completion Phase")
    end function
    instance.super0_createNextPhase = instance.createNextPhase
    instance.createNextPhase = function() as void
        m.nextPhaseObj = InitPhase()
    end function
    return instance
end function
function CompletePhase()
    instance = __CompletePhase_builder()
    instance.new()
    return instance
end function
function __PhaseFactory_builder()
    instance = {}
    instance.new = function() as void
        m.current_phase = invalid
        m.current_phase = InitPhase()
    end function
    instance.nextPhase = function() as void
        if m.current_phase <> invalid
            m.current_phase.execute()
            m.current_phase = m.current_phase.getNextPhase()
        end if
    end function
    return instance
end function
function PhaseFactory()
    instance = __PhaseFactory_builder()
    instance.new()
    return instance
end function
function __MainRoom_builder()
    instance = __BGE_Room_builder()
    ' Sphere properties
    ' Center of screen X
    ' Center of screen Y
    ' Sphere radius
    ' Current rotation angle
    ' Increased rotation speed
    ' Arrays for sphere points and lines
    ' Store 3D points
    ' Store line connections
    ' Reduced segments for better performance
    ' Factory instance
    instance.super1_new = instance.new
    instance.new = function(game) as void
        m.super1_new(game)
        m.center_x = 640
        m.center_y = 360
        m.radius = 100
        m.rotation = 0
        m.rotation_speed = 4
        m.points = []
        m.lines = []
        m.num_segments = 12
        m.factory = invalid
        m.name = "MainRoom"
        m.generateSpherePoints()
        m.generateLines()
        m.factory = PhaseFactory()
    end function
    instance.generateSpherePoints = function() as void
        m.points.clear()
        step_phi = 180 / m.num_segments
        step_theta = 360 / m.num_segments
        for phi = 0 to 180 step step_phi
            rad_phi = phi * 0.0174533
            sin_phi = Sin(rad_phi)
            cos_phi = Cos(rad_phi)
            for theta = 0 to 360 step step_theta
                rad_theta = theta * 0.0174533
                point = {}
                point.x = m.radius * Cos(rad_theta) * sin_phi
                point.y = m.radius * Sin(rad_theta) * sin_phi
                point.z = m.radius * cos_phi
                m.points.push(point)
            next
        next
    end function
    instance.generateLines = function() as void
        m.lines.clear()
        threshold = m.radius * 0.75 ' Increased threshold for more connections
        for i = 0 to m.points.count() - 1
            p1 = m.points[i]
            for j = i + 1 to m.points.count() - 1
                p2 = m.points[j]
                dx = p1.x - p2.x
                dy = p1.y - p2.y
                dz = p1.z - p2.z
                distance = Sqr(dx * dx + dy * dy + dz * dz)
                if distance < threshold
                    line = {}
                    line.i1 = i
                    line.i2 = j
                    m.lines.push(line)
                end if
            next
        next
    end function
    instance.rotatePoint = function(point, cos_a, sin_a) as object
        rotated = {}
        rotated.x = point.x * cos_a + point.z * sin_a
        rotated.y = point.y
        rotated.z = - point.x * sin_a + point.z * cos_a
        return rotated
    end function
    instance.project = function(point) as object
        projected = {}
        scale = 300 / (300 + point.z)
        projected.x = m.center_x + point.x * scale
        projected.y = m.center_y + point.y * scale
        return projected
    end function
    instance.super1_onDrawBegin = instance.onDrawBegin
    instance.onDrawBegin = function(canvas) as void
        ' Clear background
        canvas.DrawRect(0, 0, 1280, 720, &h000000FF)
        ' Pre-calculate rotation values
        rad_rotation = m.rotation * 0.0174533
        cos_a = Cos(rad_rotation)
        sin_a = Sin(rad_rotation)
        ' Create array for rotated points
        rotated_points = []
        for each point in m.points
            rotated = m.rotatePoint(point, cos_a, sin_a)
            projected = m.project(rotated)
            rotated_points.push(projected)
        next
        ' Draw lines using pre-calculated connections
        for each line in m.lines
            p1 = rotated_points[line.i1]
            p2 = rotated_points[line.i2]
            canvas.DrawLine(p1.x, p1.y, p2.x, p2.y, &h4169E1FF)
        next
        ' Update rotation for next frame
        m.rotation = (m.rotation + m.rotation_speed) mod 360
    end function
    instance.super1_onInput = instance.onInput
    instance.onInput = function(input) as void
        if input.isButton("back")
            m.game.End()
        else if input.isButton("OK")
            if m.factory <> invalid
                m.factory.nextPhase()
            end if
        end if
    end function
    return instance
end function
function MainRoom(game)
    instance = __MainRoom_builder()
    instance.new(game)
    return instance
end function'//# sourceMappingURL=./MainRoom.bs.map