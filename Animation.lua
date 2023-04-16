-- Animation.lua
Animation = class()

function Animation:init(map, currentPlayerCombatColor, otherPlayerCombatColor)
    self.map = map
    self.currentPlayerCombatColor = currentPlayerCombatColor
    self.otherPlayerCombatColor = otherPlayerCombatColor
    self.tweens = {}
    self.arrowMeshes = {}
    self.crosshairsData = {}
    self.crosshairTweens = {} 
end

function Animation:update(dt)
    for i, tween in ipairs(self.tweens) do
     --   tween:update(dt)
    end
end

function Animation:drawCrosshairs()
    for unit, crosshairTweenData in pairs(self.crosshairTweens) do
        self:drawCrosshairsOn(unit, crosshairTweenData.attackable, self.currentPlayerCombatColor, self.otherPlayerCombatColor, self.map, self.crosshairTweens)
    end
end

function Animation:addCrosshairAnimation(unit, attackable)
    local scaleLarge = 0.75
    local duration = 0.55  -- Adjust this value to control the overall animation duration
    local scaleSmall = 0.1  -- Adjust this value to control the initial scale
    local bounceFactor = 1.5  -- Adjust this value to control the bounce size
    
    if not self.crosshairTweens[unit] then
        self.crosshairTweens[unit] = {scale = scaleSmall, attackable = attackable}
        -- Start the animation sequence for this unit's crosshair
        tween(duration * 0.4, self.crosshairTweens[unit], {scale = scaleLarge}, {easing = tween.easing.backOut, callback = function()
                tween(duration * 0.3, self.crosshairTweens[unit], {scale = scaleLarge * bounceFactor}, {easing = tween.easing.quadIn, callback = function()
                        tween(duration * 0.3, self.crosshairTweens[unit], {scale = scaleLarge}, {easing = tween.easing.quadOut})
                    end})
            end})
    else
        self.crosshairTweens[unit].attackable = attackable
    end
end

function Animation:drawCrosshairsOn(unit, attackable, currentPlayerCombatColor, otherPlayerCombatColor, map, crosshairTweens)
    local function drawScaledCrosshairs(aScale)
        pushStyle()
        pushMatrix()
        
        noFill()
        strokeWidth(map.cellSize * 0.15)
        translate(unit.x, unit.y)
        scale(aScale)
        if attackable then
            scale(aScale)
            stroke(currentPlayerCombatColor) -- Red crosshairs
        else
            scale(aScale * 0.75)
            stroke(otherPlayerCombatColor) -- Gray crosshairs
        end
        
        local circleRadius = map.cellSize * 0.4
        
        ellipse(0, 0, circleRadius * 2, circleRadius * 2)
        
        local lineLength = map.cellSize * 0.1
        
        line(-circleRadius - lineLength, 0, -circleRadius + lineLength + strokeWidth(), 0) -- West line
        line(circleRadius + lineLength, 0, circleRadius - lineLength - strokeWidth(), 0) -- East line
        line(0, -circleRadius - lineLength, 0, -circleRadius + lineLength + strokeWidth()) -- South line
        line(0, circleRadius + lineLength, 0, circleRadius - lineLength - strokeWidth()) -- North line
        
        popStyle()
        popMatrix()
    end
    
    if not crosshairTweens[unit] then
        local duration = 0.55  -- Adjust this value to control the overall animation duration
        local scaleSmall = 0.1  -- Adjust this value to control the initial scale
        local scaleLarge = 0.75
        local bounceFactor = 1.5  -- Adjust this value to control the bounce size
        crosshairTweens[unit] = {scale = scaleSmall}
        -- Start the animation sequence for this unit's crosshair
        tween(duration * 0.4, crosshairTweens[unit], {scale = scaleLarge}, {easing = tween.easing.backOut, callback = function()
                tween(duration * 0.3, crosshairTweens[unit], {scale = scaleLarge * bounceFactor}, {easing = tween.easing.quadIn, callback = function()
                        tween(duration * 0.3, crosshairTweens[unit], {scale = scaleLarge}, {easing = tween.easing.quadOut})
                    end})
            end})
    end
    
    if crosshairTweens[unit].scale then
        drawScaledCrosshairs(crosshairTweens[unit].scale)
    else
        drawScaledCrosshairs(scaleLarge)
    end
end

function Animation:updateCrosshair(unit, crosshairImage, crosshairColor)
    self.crosshairData = {
        unit = unit,
        image = crosshairImage,
        color = crosshairColor
    }
end

function Animation:drawArrows()
    for _, arrowData in ipairs(self.arrowMeshes) do
        local direction = (arrowData.endPoint - arrowData.startPoint):normalize()
        local animationOffset = math.sin(os.clock() * arrowData.speed) * arrowData.distance * direction
        local transformedEndPoint = arrowData.endPoint + animationOffset
        
        local transformedMesh = self:createArrowMesh(arrowData.color, arrowData.startPoint, transformedEndPoint, arrowData.width, arrowData.arrowHeadLength, arrowData.speed, arrowData.distance)
        transformedMesh:draw()
    end
end


--[[
function Animation:drawArrows()
    for _, arrowData in ipairs(self.arrowMeshes) do
        local animationOffset = math.sin(os.clock() * arrowData.speed) * arrowData.distance
        local aColor = arrowData.mesh.color
        local startPoint = arrowData.startPoint
        local endPoint = arrowData.endPoint + animationOffset
        local width = arrowData.width
        local arrowHeadLength = arrowData.arrowHeadLength
        local transformedMesh = self:createArrowMesh(arrowData.mesh.color, arrowData.startPoint, arrowData.endPoint + animationOffset, arrowData.width, arrowData.arrowHeadLength)
        transformedMesh:draw()
    end
end
]]

function Animation:createArrowMesh(aColor, startPoint, endPoint, width, arrowHeadLength, speed, distance)
    aColor = aColor or color(236, 67, 93)
    startPoint = startPoint or vec2(WIDTH * 0.4, HEIGHT/2)
    endPoint = endPoint or vec2(WIDTH * 0.6, HEIGHT/2)
    width = width or HEIGHT * 0.25
    arrowHeadLength = arrowHeadLength or WIDTH * 0.1
    
    local direction = (endPoint - startPoint):normalize()
    local perpDirection = vec2(-direction.y, direction.x)
    
    local animationOffset = math.sin(os.clock() * speed) * distance
    
    local arrowHeadPoint1 = endPoint + direction * animationOffset
    local arrowHeadPoint2 = arrowHeadPoint1 - direction * arrowHeadLength + perpDirection * (width / 2)
    local arrowHeadPoint3 = arrowHeadPoint1 - direction * arrowHeadLength - perpDirection * (width / 2)
    
    local arrowBasePoint1 = startPoint + perpDirection * (width * 0.8 / 2)
    local arrowBasePoint2 = startPoint - perpDirection * (width * 0.8 / 2)
    local arrowBasePoint3 = arrowHeadPoint3 + perpDirection * (width * 0.1)
    local arrowBasePoint4 = arrowHeadPoint2 - perpDirection * (width * 0.1)
    
    local arrowHead = {arrowHeadPoint1, arrowHeadPoint2, arrowHeadPoint3}
    local arrowBase = {arrowBasePoint1, arrowBasePoint2, arrowBasePoint3, arrowBasePoint4}
    
    local arrowHeadTriangulation = triangulate(arrowHead)
    local arrowBaseTriangulation = triangulate(arrowBase)
    
    for _, v in ipairs(arrowBaseTriangulation) do
        table.insert(arrowHeadTriangulation, v)
    end
    
    --[[
    Animation:75: bad argument #1 to 'setColors' (color)
    stack traceback:
    	[C]: in method 'setColors'
    	Animation:75: in method 'createArrowMesh'
    	Animation:21: in method 'drawArrows'
    	Game:141: in method 'draw'
    	Main:16: in function 'draw'
]]
    
    local arrowMesh = mesh()
    arrowMesh.vertices = arrowHeadTriangulation
    arrowMesh:setColors(aColor)
    return arrowMesh
end

function Animation:addArrowAnimation(aColor, startPoint, endPoint, width, arrowHeadLength, speed, distance)
    local arrowMesh = self:createArrowMesh(aColor, startPoint, endPoint, width, arrowHeadLength, speed, distance)
    local arrowData = {
        color = aColor,
        mesh = arrowMesh,
        startPoint = startPoint,
        endPoint = endPoint,
        width = width,
        arrowHeadLength = arrowHeadLength,
        speed = speed,
        distance = distance
    }
    table.insert(self.arrowMeshes, arrowData)
    
    local duration = 1 / speed
    local arrowTween = tween(duration, arrowData, {}, 'linear', function() self:removeArrowAnimation(arrowData) end)
    table.insert(self.tweens, arrowTween)
end

function Animation:removeArrowAnimation(arrowData)
    for i, data in ipairs(self.arrowMeshes) do
        if data == arrowData then
            table.remove(self.arrowMeshes, i)
            break
        end
    end
end
