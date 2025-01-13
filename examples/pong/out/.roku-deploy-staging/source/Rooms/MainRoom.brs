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
    instance.new = function(roomInstance as object) as void
        m.nextPhaseObj = invalid
        m.debug = invalid
        m.roomRef = invalid
        m.debug = CreateObject("roDeviceInfo")
        m.roomRef = roomInstance
    end function
    instance.log = function(message as string) as void
        ? message
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
function PhaseBase(roomInstance as object)
    instance = __PhaseBase_builder()
    instance.new(roomInstance)
    return instance
end function
function __InitPhase_builder()
    instance = __PhaseBase_builder()
    instance.super0_new = instance.new
    instance.new = function(roomInstance as object) as void
        m.super0_new(roomInstance)
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
        ' Update room with service prices
        if m.roomRef <> invalid
            m.roomRef.updateServicePrices(m.serviceOne.getPrices())
        end if
        ' Create next phase with price arrays
        m.nextPhaseObj = SetupPhase(m.roomRef, m.serviceOne.getPrices(), m.serviceTwo.getPrices())
    end function
    instance.super0_createNextPhase = instance.createNextPhase
    instance.createNextPhase = function() as void
        ' Overridden by execute() to pass price data
    end function
    return instance
end function
function InitPhase(roomInstance as object)
    instance = __InitPhase_builder()
    instance.new(roomInstance)
    return instance
end function
function __SetupPhase_builder()
    instance = __PhaseBase_builder()
    instance.super0_new = instance.new
    instance.new = function(roomInstance as object, pricesArrayOne = [] as object, pricesArrayTwo = [] as object) as void
        m.super0_new(roomInstance)
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
        ' Update room with centroids
        if m.roomRef <> invalid
            m.roomRef.updateCentroids(m.centroids)
        end if
        ' Create next phase with centroids
        m.nextPhaseObj = ExecutePhase(m.roomRef, m.centroids)
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
function SetupPhase(roomInstance as object, pricesArrayOne = [] as object, pricesArrayTwo = [] as object)
    instance = __SetupPhase_builder()
    instance.new(roomInstance, pricesArrayOne, pricesArrayTwo)
    return instance
end function
function __ExecutePhase_builder()
    instance = __PhaseBase_builder()
    instance.super0_new = instance.new
    instance.new = function(roomInstance as object, centroidData = [] as object) as void
        m.super0_new(roomInstance)
        m.centroids = []
        m.MAX_DEPTH = 5
        m.MIN_VALUE = 3
        m.centroids = centroidData
    end function
    instance.super0_execute = instance.execute
    instance.execute = function() as void
        m.log("PHASE 3: Execution Phase")
        ' Process each coordinate of each centroid
        for i = 0 to m.centroids.Count() - 1
            ' Initialize diffusion strings with empty values
            x_diffusion_str = "[]"
            y_diffusion_str = "[]"
            ' Process X coordinate
            x_value = Int(m.centroids[i][0])
            if x_value > 0
                x_diffused = m.safeFractalFragment(x_value)
                x_diffusion_str = m.arrayToString(x_diffused)
            end if
            ' Process Y coordinate
            y_value = Int(m.centroids[i][1])
            if y_value > 0
                y_diffused = m.safeFractalFragment(y_value)
                y_diffusion_str = m.arrayToString(y_diffused)
            end if
            ' Update room with diffusion results
            if m.roomRef <> invalid
                m.roomRef.updateDiffusion(x_diffusion_str, y_diffusion_str)
            end if
        end for
        m.nextPhaseObj = CompletePhase(m.roomRef)
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
        m.nextPhaseObj = CompletePhase(m.roomRef)
    end function
    return instance
end function
function ExecutePhase(roomInstance as object, centroidData = [] as object)
    instance = __ExecutePhase_builder()
    instance.new(roomInstance, centroidData)
    return instance
end function
function __CompletePhase_builder()
    instance = __PhaseBase_builder()
    instance.super0_new = instance.new
    instance.new = function(roomInstance as object) as void
        m.super0_new(roomInstance)
    end function
    instance.super0_execute = instance.execute
    instance.execute = function() as void
        m.log("PHASE 4: Completion Phase")
    end function
    instance.super0_createNextPhase = instance.createNextPhase
    instance.createNextPhase = function() as void
        m.nextPhaseObj = InitPhase(m.roomRef)
    end function
    return instance
end function
function CompletePhase(roomInstance as object)
    instance = __CompletePhase_builder()
    instance.new(roomInstance)
    return instance
end function
function __PhaseFactory_builder()
    instance = {}
    instance.new = function(roomInstance as object) as void
        m.current_phase = invalid
        m.roomRef = invalid
        m.roomRef = roomInstance
        m.current_phase = InitPhase(m.roomRef)
    end function
    instance.nextPhase = function() as void
        if m.current_phase <> invalid
            m.current_phase.execute()
            m.current_phase = m.current_phase.getNextPhase()
        end if
    end function
    return instance
end function
function PhaseFactory(roomInstance as object)
    instance = __PhaseFactory_builder()
    instance.new(roomInstance)
    return instance
end function
function __MainRoom_builder()
    instance = __BGE_Room_builder()
    ' Sphere properties
    ' Arrays for sphere points and lines
    ' Orbiting points
    ' Panel properties
    ' Text fade properties
    ' Data display properties
    ' Text properties
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
        m.x_orbit_points = []
        m.y_orbit_points = []
        m.orbit_radius_x = 200
        m.orbit_radius_y = 250
        m.orbit_rotation_x = 0
        m.orbit_rotation_y = 0
        m.orbit_speed_x = 0.5
        m.orbit_speed_y = 0.3
        m.diffusion_rotation_x = 0
        m.diffusion_rotation_y = 0
        m.diffusion_speed_x = 1.2
        m.diffusion_speed_y = 0.8
        m.bottom_panel_height = 161
        m.left_panel_width = 325
        m.left_panel_height = 468
        m.panel_width_expanded = 1280
        m.corner_radius = 0
        m.panel_color = &h4169E180
        m.panel_alpha = 0
        m.fade_speed = 2
        m.panel_width_current = 1280
        m.left_panel_width_current = 0
        m.expansion_speed = 8
        m.animation_delay = 60
        m.current_delay = 0
        m.text_alpha = 0
        m.text_fade_speed = 5
        m.text_fade_delay = 120
        m.text_color = &h000000FF
        m.text_alpha_color = &h000000FF
        m.main_text_color = &h696969FF
        m.service_prices = []
        m.centroids = []
        m.x_diffusion = ""
        m.y_diffusion = ""
        m.text_message = "Press OK to Run Client ML"
        m.factory = invalid
        m.name = "MainRoom"
        m.factory = PhaseFactory(m)
        ' Initialize sphere points
        step_phi = 180 / m.num_segments
        step_theta = 360 / m.num_segments
        ' Generate sphere points
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
                m.points.Push(point)
            end for
        end for
        ' Generate line connections
        threshold = m.radius * 0.75
        for i = 0 to m.points.Count() - 1
            p1 = m.points[i]
            for j = i + 1 to m.points.Count() - 1
                p2 = m.points[j]
                dx = p1.x - p2.x
                dy = p1.y - p2.y
                dz = p1.z - p2.z
                distance = Sqr(dx * dx + dy * dy + dz * dz)
                if distance < threshold
                    line = {}
                    line.i1 = i
                    line.i2 = j
                    m.lines.Push(line)
                end if
            end for
        end for
    end function
    instance.parseArrayString = function(arrayStr as string) as object
        result = []
        if arrayStr = "" or arrayStr = "[]"
            return result
        end if
        cleaned = arrayStr.Replace("[", "").Replace("]", "")
        parts = cleaned.Split(",")
        for each part in parts
            trimmed = part.Trim()
            if trimmed <> ""
                result.Push(Val(trimmed))
            end if
        end for
        return result
    end function
    instance.rotatePointX = function(point as object, angle as float) as object
        ' Rotate point around X-axis
        rotated = {}
        cos_a = Cos(angle * 0.0174533)
        sin_a = Sin(angle * 0.0174533)
        rotated.x = point.x
        rotated.y = point.y * cos_a - point.z * sin_a
        rotated.z = point.y * sin_a + point.z * cos_a
        return rotated
    end function
    instance.rotatePointY = function(point as object, angle as float) as object
        ' Rotate point around Y-axis
        rotated = {}
        cos_a = Cos(angle * 0.0174533)
        sin_a = Sin(angle * 0.0174533)
        rotated.x = point.x * cos_a + point.z * sin_a
        rotated.y = point.y
        rotated.z = - point.x * sin_a + point.z * cos_a
        return rotated
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
    instance.getOrbitPosition = function(angle as float, radius as float) as object
        point = {}
        point.x = radius * Cos(angle * 0.0174533)
        point.y = radius * Sin(angle * 0.0174533)
        point.z = 0
        return point
    end function
    instance.super1_onDrawBegin = instance.onDrawBegin
    instance.onDrawBegin = function(canvas) as void
        ' Clear background
        canvas.DrawRect(0, 0, 1280, 720, &h000000FF)
        ' Handle animation delay and panel fade
        if m.current_delay < m.animation_delay
            m.current_delay = m.current_delay + 1
        else ' Panel fade
            if m.panel_alpha < 255
                m.panel_alpha = m.panel_alpha + m.fade_speed
                if m.panel_alpha > 255
                    m.panel_alpha = 255
                end if
                if m.left_panel_width_current < m.left_panel_width
                    m.left_panel_width_current = m.left_panel_width_current + m.expansion_speed
                    if m.left_panel_width_current > m.left_panel_width
                        m.left_panel_width_current = m.left_panel_width
                    end if
                end if
            end if
            ' Text fade - starts after panel fade completion
            if m.panel_alpha >= 240
                if m.text_alpha < 255
                    m.text_alpha = m.text_alpha + m.text_fade_speed
                    if m.text_alpha > 255
                        m.text_alpha = 255
                    end if
                end if
            end if
        end if
        ' Calculate panel color with current alpha
        fadeColor = (m.panel_color and &hFFFFFF00) or Int(m.panel_alpha)
        ' Draw panels
        canvas.DrawRect(0, 720 - m.bottom_panel_height, m.panel_width_expanded, m.bottom_panel_height, fadeColor)
        canvas.DrawRect(0, 0, m.left_panel_width_current, m.left_panel_height, fadeColor)
        ' Handle sphere rotation and rendering
        rad_rotation = m.rotation * 0.0174533
        cos_a = Cos(rad_rotation)
        sin_a = Sin(rad_rotation)
        ' Rotate and project sphere points
        rotated_points = []
        for each point in m.points
            rotated = m.rotatePoint(point, cos_a, sin_a)
            projected = m.project(rotated)
            rotated_points.Push(projected)
        end for
        ' Draw sphere lines
        for each line in m.lines
            p1 = rotated_points[line.i1]
            p2 = rotated_points[line.i2]
            canvas.DrawLine(p1.x, p1.y, p2.x, p2.y, m.panel_color)
        end for
        ' Update diffusion ring rotations
        m.diffusion_rotation_x = (m.diffusion_rotation_x + m.diffusion_speed_x) mod 360
        m.diffusion_rotation_y = (m.diffusion_rotation_y + m.diffusion_speed_y) mod 360
        ' Draw X diffusion points (green) - rotating around X-axis
        x_values = m.parseArrayString(m.x_diffusion)
        angle_step_x = 360 / (x_values.Count() + 1)
        for i = 0 to x_values.Count() - 1
            angle = m.diffusion_rotation_x + (i * angle_step_x)
            orbit_point = m.getOrbitPosition(angle, m.orbit_radius_x)
            ' Rotate around X-axis
            rotated_x = m.rotatePointX(orbit_point, m.diffusion_rotation_x)
            ' Apply main sphere's rotation
            rotated = m.rotatePoint(rotated_x, cos_a, sin_a)
            projected = m.project(rotated)
            canvas.DrawRect(projected.x - 3, projected.y - 3, 6, 6, &h00FF00FF)
        end for
        ' Draw Y diffusion points (red) - rotating around Y-axis
        y_values = m.parseArrayString(m.y_diffusion)
        angle_step_y = 360 / (y_values.Count() + 1)
        for i = 0 to y_values.Count() - 1
            angle = m.diffusion_rotation_y + (i * angle_step_y)
            orbit_point = m.getOrbitPosition(angle, m.orbit_radius_y)
            ' Rotate around Y-axis
            rotated_y = m.rotatePointY(orbit_point, m.diffusion_rotation_y)
            ' Apply main sphere's rotation
            rotated = m.rotatePoint(rotated_y, cos_a, sin_a)
            projected = m.project(rotated)
            canvas.DrawRect(projected.x - 3, projected.y - 3, 6, 6, &hFF0000FF)
        end for
        m.rotation = (m.rotation + m.rotation_speed) mod 360
        ' Draw text only if panel alpha is high enough
        if m.panel_alpha > 200
            ' Calculate text color with current text alpha
            text_color_with_alpha = (m.text_color and &hFFFFFF00) or Int(m.text_alpha)
            ' Draw data in left panel
            BGE_drawText(canvas, "Data Retrieved from API:", 20, 20, m.game.fonts.default, "left", text_color_with_alpha)
            y_pos = 50
            for each price in m.service_prices
                if price <> invalid
                    BGE_drawText(canvas, "$" + price.ToStr(), 20, y_pos, m.game.fonts.default, "left", text_color_with_alpha)
                    y_pos += 25
                end if
            end for
            ' Draw centroids in bottom panel (left side)
            BGE_drawText(canvas, "MLearning Cumulative Clustering Centroids:", 20, 580, m.game.fonts.default, "left", text_color_with_alpha)
            y_pos = 610
            for each centroid in m.centroids
                if centroid <> invalid and centroid.Count() >= 2
                    BGE_drawText(canvas, "(" + centroid[0].ToStr() + ", " + centroid[1].ToStr() + ")", 20, y_pos, m.game.fonts.default, "left", text_color_with_alpha)
                    y_pos += 25
                end if
            end for
            ' Draw diffusion arrays in bottom panel (right side)
            BGE_drawText(canvas, "Fractal Fragmentation Diffusion of Centroids:", 640, 580, m.game.fonts.default, "left", text_color_with_alpha)
            if m.x_diffusion <> ""
                BGE_drawText(canvas, "X: " + m.x_diffusion, 640, 610, m.game.fonts.default, "left", text_color_with_alpha)
            end if
            if m.y_diffusion <> ""
                BGE_drawText(canvas, "Y: " + m.y_diffusion, 640, 635, m.game.fonts.default, "left", text_color_with_alpha)
            end if
            ' Draw main text message in dark grey
            BGE_drawText(canvas, m.text_message, 640, 460, m.game.fonts.default, "center", m.main_text_color)
        end if
    end function
    instance.super1_onInput = instance.onInput
    instance.onInput = function(input) as void
        if input.isButton("back")
            m.game.End()
        end if
        if input.isButton("OK")
            if m.factory <> invalid
                m.factory.nextPhase()
            end if
        end if
    end function
    instance.updateServicePrices = function(prices as object) as void
        m.service_prices = prices
    end function
    instance.updateCentroids = function(centroidData as object) as void
        m.centroids = centroidData
    end function
    instance.updateDiffusion = function(x_array as string, y_array as string) as void
        m.x_diffusion = x_array
        m.y_diffusion = y_array
    end function
    instance.setText = function(message as string) as void
        m.text_message = message
    end function
    return instance
end function
function MainRoom(game)
    instance = __MainRoom_builder()
    instance.new(game)
    return instance
end function'//# sourceMappingURL=./MainRoom.bs.map