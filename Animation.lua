-- Animation.lua
Animation = class()

function Animation:init(map, currentPlayerCombatColor, otherPlayerCombatColor)
    self.map = map
    self.currentPlayerCombatColor = currentPlayerCombatColor
    self.otherPlayerCombatColor = otherPlayerCombatColor
    self.tweens = {}
    self.arrowData = {}
    self.arrowMeshes = {}
    self.arrowTweens = {}
    self.crosshairsData = {}
    self.crosshairTweens = {} 
    self.arrowTweenValue = 0
end

function Animation:update(dt)
    for i, tween in ipairs(self.tweens) do
     --   tween:update(dt)
    end
end

function Animation:clearCrosshairs()
    self.crosshairTweens = {}
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

function Animation:drawYellowDots()
    if not self.dotData then
        return
    end
    for _, dotData in ipairs(self.dotData) do
        fill(dotData.color)
        ellipse(dotData.x, dotData.y, dotData.radius)
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

function Animation:drawFlankingArrows()
    if not self.valueTween then
        self.valueTween = tween(1, self, {arrowTweenValue = 10}, {loop = tween.loop.pingpong, easing = tween.easing.linear})
    end
    for _, arrowData in ipairs(self.arrowData) do
        local neanderthal = arrowData.neanderthal
        local flankingSapiens = arrowData.flankingSapiens
        local arrowColor = arrowData.color
        local cSize = self.map.cellSize
        
        for _, sapiens in ipairs(flankingSapiens) do
            local arrowOffset = cSize * 0.4
            local arrowLength = cSize * 0.2
            
            local direction = (vec2(neanderthal.x, neanderthal.y) - vec2(sapiens.x, sapiens.y)):normalize()
            local startPoint = vec2(sapiens.x, sapiens.y) + direction * arrowOffset
            local endPoint = startPoint + direction * arrowLength
            
            if not self.arrowMeshes[sapiens] then
                local width = cSize * 0.6
                local arrowHeadLength = arrowLength
                
                local arrowMesh = self:createArrowMesh(arrowColor, startPoint, endPoint, width, arrowHeadLength)
                self.arrowMeshes[sapiens] = {mesh = arrowMesh, startPoint = startPoint, endPoint = endPoint, direction = direction}
            else
                -- Update the arrow color if it already exists
                self.arrowMeshes[sapiens].mesh:setColors(arrowColor)
            end
            
            local arrowMesh = self.arrowMeshes[sapiens].mesh
            local arrowDirection = self.arrowMeshes[sapiens].direction
            
            pushMatrix()
            translate(self.arrowTweenValue * arrowDirection.x, self.arrowTweenValue * arrowDirection.y)
            arrowMesh:draw()
            popMatrix()
        end
    end
end

function Animation:createArrowMesh(aColor, startPoint, endPoint, width, arrowHeadLength, speed, distance)
    aColor = aColor or color(236, 67, 93)
    startPoint = startPoint or vec2(WIDTH * 0.4, HEIGHT/2)
    endPoint = endPoint or vec2(WIDTH * 0.6, HEIGHT/2)
    width = width or HEIGHT * 0.25
    arrowHeadLength = arrowHeadLength or WIDTH * 0.1
    speed = speed or 1.25
    distance = distance or 90
    
    local direction = (endPoint - startPoint):normalize()
    local perpDirection = vec2(-direction.y, direction.x)
    
    local arrowHeadPoint1 = endPoint + direction
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
    
    local arrowMesh = mesh()
    arrowMesh.vertices = arrowHeadTriangulation
    arrowMesh:setColors(aColor)
    return arrowMesh
end
