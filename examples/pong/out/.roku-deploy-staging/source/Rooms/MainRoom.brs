function __ServiceLayerOne_builder()
    instance = {}
    instance.new = function() as void
        m.debug = invalid
        m.messagePort = invalid
        m.timer = invalid
        m.url = "https://api.restful-api.dev/objects"
        m.prices = []
        m.debug = CreateObject("roDeviceInfo")
        m.messagePort = CreateObject("roMessagePort")
        m.timer = CreateObject("roTimeSpan")
    end function
    instance.execute = function() as void
        m.log("Service Layer One Executing - Fetching Prices")
        ' Create URL transfer object
        request = CreateObject("roUrlTransfer")
        request.SetURL(m.url)
        request.SetMessagePort(m.messagePort)
        request.SetCertificatesFile("common:/certs/ca-bundle.crt")
        request.InitClientCertificates()
        ' Make the request
        if request.AsyncGetToString()
            ' Wait for response
            msg = wait(0, m.messagePort)
            if type(msg) = "roUrlEvent"
                ' Process response
                if msg.GetResponseCode() = 200
                    ' Parse JSON response
                    json = ParseJson(msg.GetString())
                    if json <> invalid
                        m.log("Service One - Prices found:")
                        m.prices.Clear()
                        for each item in json
                            if item.data <> invalid and item.data.price <> invalid
                                m.prices.Push(item.data.price)
                                m.log("$" + item.data.price.ToStr() + " - " + item.name)
                            end if
                        end for
                    end if
                else
                    m.log("Error: Response code " + msg.GetResponseCode().ToStr())
                end if
            end if
        end if
        m.log("Service Layer One Complete")
        m.messagePort.PostMessage("ServiceOneComplete")
    end function
    instance.getPrices = function() as object
        return m.prices
    end function
    instance.getMessagePort = function() as object
        return m.messagePort
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
        m.messagePort = invalid
        m.timer = invalid
        m.url = "https://api.restful-api.dev/objects"
        m.prices = []
        m.debug = CreateObject("roDeviceInfo")
        m.messagePort = CreateObject("roMessagePort")
        m.timer = CreateObject("roTimeSpan")
    end function
    instance.execute = function() as void
        m.log("Service Layer Two Executing - Fetching Prices")
        ' Create URL transfer object
        request = CreateObject("roUrlTransfer")
        request.SetURL(m.url)
        request.SetMessagePort(m.messagePort)
        request.SetCertificatesFile("common:/certs/ca-bundle.crt")
        request.InitClientCertificates()
        ' Make the request
        if request.AsyncGetToString()
            ' Wait for response
            msg = wait(0, m.messagePort)
            if type(msg) = "roUrlEvent"
                ' Process response
                if msg.GetResponseCode() = 200
                    ' Parse JSON response
                    json = ParseJson(msg.GetString())
                    if json <> invalid
                        m.log("Service Two - Prices found:")
                        m.prices.Clear()
                        for each item in json
                            if item.data <> invalid and item.data.price <> invalid
                                m.prices.Push(item.data.price)
                                m.log("$" + item.data.price.ToStr() + " - " + item.name)
                            end if
                        end for
                    end if
                else
                    m.log("Error: Response code " + msg.GetResponseCode().ToStr())
                end if
            end if
        end if
        m.log("Service Layer Two Complete")
        m.messagePort.PostMessage("ServiceTwoComplete")
    end function
    instance.getPrices = function() as object
        return m.prices
    end function
    instance.getMessagePort = function() as object
        return m.messagePort
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
        m.servicesCompleted = 0
        m.serviceOne = ServiceLayerOne()
        m.serviceTwo = ServiceLayerTwo()
    end function
    instance.super0_execute = instance.execute
    instance.execute = function() as void
        m.log("PHASE 1: Initialization Phase")
        m.servicesCompleted = 0
        ' Start both services
        m.serviceOne.execute()
        m.serviceTwo.execute()
        ' Wait for completion messages from both services
        while m.servicesCompleted < 2
            msg1 = m.serviceOne.getMessagePort().GetMessage()
            msg2 = m.serviceTwo.getMessagePort().GetMessage()
            if msg1 <> invalid
                m.servicesCompleted++
            end if
            if msg2 <> invalid
                m.servicesCompleted++
            end if
        end while
        m.log("All Services Completed")
        ' Create next phase with price arrays
        m.nextPhaseObj = SetupPhase(m.serviceOne.getPrices(), m.serviceTwo.getPrices())
    end function
    instance.super0_createNextPhase = instance.createNextPhase
    instance.createNextPhase = function() as void
        ' Overridden by execute() to pass price data
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
    instance.new = function(pricesArrayOne = [] as object, pricesArrayTwo = [] as object) as void
        m.super0_new()
        m.pricesOne = []
        m.pricesTwo = []
        m.centroids = []
        m.pricesOne = pricesArrayOne
        m.pricesTwo = pricesArrayTwo
        m.centroids = []
    end function
    instance.super0_execute = instance.execute
    instance.execute = function() as void
        m.log("PHASE 2: Setup Phase")
        ' Print price arrays
        m.log("Prices from Service One:")
        for each price in m.pricesOne
            m.log(price.ToStr())
        end for
        m.log("Prices from Service Two:")
        for each price in m.pricesTwo
            m.log(price.ToStr())
        end for
        ' Perform K-means clustering
        m.KMeansClustering()
        ' Create next phase with centroids
        m.nextPhaseObj = ExecutePhase(m.centroids)
    end function
    instance.KMeansClustering = function() as void
        ' Combine the data into an array of points with numeric conversion
        dataPoints = []
        for i = 0 to m.pricesOne.Count() - 1
            if i < m.pricesTwo.Count()
                ' Convert string prices to float
                price1 = Val(m.pricesOne[i].ToStr())
                price2 = Val(m.pricesTwo[i].ToStr())
                dataPoints.Push([
                    price1
                    price2
                ])
            end if
        end for
        ' K-means clustering parameters
        k = 2 ' Number of clusters
        maxIterations = 100
        m.centroids = []
        clusters = []
        ' Initialize centroids randomly
        for i = 0 to k - 1
            randomIndex = Int(Rnd(0) * dataPoints.Count())
            m.centroids.Push(dataPoints[randomIndex])
            clusters.Push([])
        end for
        converged = false
        iteration = 0
        while not converged and iteration < maxIterations
            ' Assign points to the nearest centroid
            for i = 0 to dataPoints.Count() - 1
                minDistance = 1.0e+300 ' High initial value for minimum distance
                closestCentroid = - 1
                for j = 0 to k - 1
                    distance = m.EuclideanDistance(dataPoints[i], m.centroids[j])
                    if distance < minDistance
                        minDistance = distance
                        closestCentroid = j
                    end if
                end for
                clusters[closestCentroid].Push(i)
            end for
            ' Recalculate centroids
            converged = true
            for i = 0 to k - 1
                if clusters[i].Count() > 0
                    newCentroid = [
                        0.0
                        0.0
                    ]
                    for each index in clusters[i]
                        newCentroid[0] += dataPoints[index][0]
                        newCentroid[1] += dataPoints[index][1]
                    end for
                    newCentroid[0] = newCentroid[0] / clusters[i].Count()
                    newCentroid[1] = newCentroid[1] / clusters[i].Count()
                    if newCentroid[0] <> m.centroids[i][0] or newCentroid[1] <> m.centroids[i][1]
                        converged = false
                        m.centroids[i] = newCentroid
                    end if
                end if
            end for
            ' Clear clusters for the next iteration
            for i = 0 to k - 1
                clusters[i] = []
            end for
            iteration = iteration + 1
        end while
        ' Output the cluster centroids
        m.log("K-means Clustering Results:")
        m.log("Number of iterations: " + iteration.ToStr())
        m.log("Cluster centroids:")
        for i = 0 to k - 1
            m.log("Centroid " + (i + 1).ToStr() + ": (" + m.centroids[i][0].ToStr() + ", " + m.centroids[i][1].ToStr() + ")")
        end for
    end function
    instance.EuclideanDistance = function(point1 as Object, point2 as Object) as Float
        sum = 0.0
        for i = 0 to point1.Count() - 1
            diff = point1[i] - point2[i]
            sum = sum + (diff * diff)
        end for
        return Sqr(sum)
    end function
    instance.super0_createNextPhase = instance.createNextPhase
    instance.createNextPhase = function() as void
        ' Overridden by execute() to pass centroid data
    end function
    return instance
end function
function SetupPhase(pricesArrayOne = [] as object, pricesArrayTwo = [] as object)
    instance = __SetupPhase_builder()
    instance.new(pricesArrayOne, pricesArrayTwo)
    return instance
end function
function __ExecutePhase_builder()
    instance = __PhaseBase_builder()
    ' Limit recursion depth
    ' Minimum value to continue division
    instance.super0_new = instance.new
    instance.new = function(centroidData = [] as object) as void
        m.super0_new()
        m.centroids = []
        m.MAX_DEPTH = 5
        m.MIN_VALUE = 3
        m.centroids = centroidData
    end function
    instance.super0_execute = instance.execute
    instance.execute = function() as void
        m.log("PHASE 3: Execution Phase")
        ' Print original centroid values
        m.log("Original Centroid Values from Setup Phase:")
        for i = 0 to m.centroids.Count() - 1
            m.log("Centroid " + (i + 1).ToStr() + ": (" + m.centroids[i][0].ToStr() + ", " + m.centroids[i][1].ToStr() + ")")
        end for
        ' Process each coordinate of each centroid
        m.log("Processing Fractal Diffusion for each centroid coordinate:")
        for i = 0 to m.centroids.Count() - 1
            m.log("Centroid " + (i + 1).ToStr() + " Diffusion:")
            ' Process X coordinate with safety checks
            x_value = Int(m.centroids[i][0])
            if x_value > 0
                m.log("X-coordinate diffusion for value " + x_value.ToStr())
                x_diffused = m.safeFractalFragment(x_value)
                m.log("X-coordinate diffused array: " + m.arrayToString(x_diffused))
            else
                m.log("X-coordinate value too small for diffusion")
            end if
            ' Process Y coordinate with safety checks
            y_value = Int(m.centroids[i][1])
            if y_value > 0
                m.log("Y-coordinate diffusion for value " + y_value.ToStr())
                y_diffused = m.safeFractalFragment(y_value)
                m.log("Y-coordinate diffused array: " + m.arrayToString(y_diffused))
            else
                m.log("Y-coordinate value too small for diffusion")
            end if
        end for
        m.log("Fractal Diffusion Processing Complete")
    end function
    instance.safeFractalFragment = function(number as Integer) as Object
        result = []
        ' Initial sanity check
        if number <= 0
            return result
        end if
        ' Create a queue with depth tracking
        queue = CreateObject("roArray", 0, true)
        queue.push({
            value: number
            depth: 0
        })
        while queue.count() > 0
            current = queue.shift()
            currentValue = current.value
            currentDepth = current.depth
            ' Check if we've reached maximum depth or minimum value
            if currentDepth >= m.MAX_DEPTH or currentValue <= m.MIN_VALUE
                result.push(currentValue)
            else ' Calculate the division, ensuring we don't get stuck with small numbers
                part = Int(currentValue / 3)
                if part > 0
                    ' Add three parts with increased depth
                    for i = 0 to 2
                        queue.push({
                            value: part
                            depth: currentDepth + 1
                        })
                    end for
                else ' If division would result in 0, add current value
                    result.push(currentValue)
                end if
            end if
            ' Safety check to prevent excessive processing
            if result.Count() > 100
                m.log("Warning: Truncating results due to size limit")
                exit while
            end if
        end while
        return result
    end function
    instance.arrayToString = function(arr as Object) as String
        result = "["
        for i = 0 to arr.Count() - 1
            if i > 0
                result = result + ", "
            end if
            result = result + arr[i].ToStr()
        next
        result = result + "]"
        return result
    end function
    instance.super0_createNextPhase = instance.createNextPhase
    instance.createNextPhase = function() as void
        m.nextPhaseObj = CompletePhase()
    end function
    return instance
end function
function ExecutePhase(centroidData = [] as object)
    instance = __ExecutePhase_builder()
    instance.new(centroidData)
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
    ' Slow rotation speed
    ' Arrays for sphere points and lines
    ' Store 3D points
    ' Store line connections
    ' Reduced segments for better performance
    ' Panel properties
    ' Height of bottom panel
    ' Width of left panel
    ' Height of left panel
    ' Width of bottom panel
    ' Corner radius (removed rounded corners)
    ' Base panel color
    ' Current alpha for fade
    ' Reduced speed for slower fade in
    ' Text properties
    ' Grey color
    ' Factory instance
    instance.super1_new = instance.new
    instance.new = function(game) as void
        m.super1_new(game)
        m.center_x = 640
        m.center_y = 360
        m.radius = 156
        m.rotation = 0
        m.rotation_speed = 1
        m.points = []
        m.lines = []
        m.num_segments = 12
        m.bottom_panel_height = 287
        m.left_panel_width = 250
        m.left_panel_height = 468
        m.panel_width_reduced = 960
        m.corner_radius = 0
        m.panel_color = &h4169E1FF
        m.panel_alpha = 0
        m.fade_speed = 2
        m.text_message = "Press OK to execute machine learning functions"
        m.text_color = &h808080FF
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
    instance.drawRoundedPanel = function(canvas, x, y, width, height) as void
        ' Calculate current panel color with fade
        alpha = Int(m.panel_alpha)
        fadeColor = (m.panel_color and &hFFFFFF00) or alpha
        ' Draw inner rectangles
        canvas.DrawRect(x + m.corner_radius, y, width - (2 * m.corner_radius), height, fadeColor)
        canvas.DrawRect(x, y + m.corner_radius, width, height - (2 * m.corner_radius), fadeColor)
        ' Draw corner areas
        for radius = 0 to m.corner_radius
            cornerWidth = Int(Sqr((m.corner_radius * m.corner_radius) - (radius * radius)))
            ' Top corners if not at screen top
            if y > 0
                if x = 0 ' Left panel top-left
                    canvas.DrawRect(x, y + radius, cornerWidth, 1, fadeColor)
                end if
                canvas.DrawRect(x + width - cornerWidth, y + radius, cornerWidth, 1, fadeColor)
            end if
            ' Bottom corners
            if x = 0 ' Left panel bottom-left
                canvas.DrawRect(x, y + height - radius - 1, cornerWidth, 1, fadeColor)
            end if
            canvas.DrawRect(x + width - cornerWidth, y + height - radius - 1, cornerWidth, 1, fadeColor)
        next
    end function
    instance.super1_onDrawBegin = instance.onDrawBegin
    instance.onDrawBegin = function(canvas) as void
        ' Clear background
        canvas.DrawRect(0, 0, 1280, 720, &h000000FF)
        ' Update fade
        if m.panel_alpha < 255
            m.panel_alpha = m.panel_alpha + m.fade_speed
            if m.panel_alpha > 255
                m.panel_alpha = 255
            end if
        end if
        ' Draw panels
        ' Bottom panel (centered)
        bottom_x = (1280 - m.panel_width_reduced) / 2
        m.drawRoundedPanel(canvas, bottom_x, 720 - m.bottom_panel_height, m.panel_width_reduced, m.bottom_panel_height)
        ' Left panel
        m.drawRoundedPanel(canvas, 0, 0, m.left_panel_width, m.left_panel_height)
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
            canvas.DrawLine(p1.x, p1.y, p2.x, p2.y, m.panel_color)
        next
        ' Update rotation for next frame
        m.rotation = (m.rotation + m.rotation_speed) mod 360
        ' Draw text message
        canvas.DrawString(m.text_message, m.center_x - 200, m.center_y + 100, m.text_color)
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