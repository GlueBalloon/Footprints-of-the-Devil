-- In-Game UI
InGameUI = class()

function InGameUI:init(map)
    self.map = map
    self.gridSize = map.gridSize
    self.cellSize = map.cellSize
    self.selectedUnit = nil
    self.isActiveTeam = function(team) end
    self.nextTurnButtonAction = function() end
    self.isCellOccupied = function(row, col) end
    self.fontSizingText = "abcdefghijklmnop"
    self.sapiensIcon = asset.Sapiens
    self.neanderthalIcon = asset.Neanderthal
    self.announcementStartTime = 0
    self.announcementTeam = nil
    self.crosshairTweens = {}
    self.damageAnimations = {}
    self.uiStroke = color(197, 189, 169)
    self.uiFill = color(61, 65, 81)
    self.alreadyCrosshaired = {}
    local countdownsW = self.map.cellSize * 5.25
    local largeText = "0.0"
    local smallText = "timer timer timer"
    local smallFont = self:fontSizeForWidth("timer timer", countdownsW)
    local largeFont = self:fontSizeForWidth("0.0", countdownsW)
    pushStyle()
    fontSize(smallFont)
    local _, smallH = textSize(smallText)
    fontSize(largeFont)
    local largeW, largeH = textSize("0.0") 
    self.countdownSpecs = {
        color = color(217, 211, 202, 121),
        leftX = self.map.offsetX + (self.map.width * 0.5),
        rightX = self.map.offsetX + (self.map.width * 0.5),
        smallY = self.map.offsetY + self.map.height - (smallH * 0.6),
        largeY = self.map.offsetY + self.map.height - ((largeH + smallH) * 0.55),
        smallFont = smallFont,
        largeFont = largeFont
    }
    popStyle()
end

function InGameUI:announceTurn(team)
    self.announcementStartTime = os.clock()
    self.announcementTeam = team
end

function InGameUI:drawAnnouncement(teamColor, fadeCompleteCallback)
    if self.announcementTeam then
        
        local elapsedTime = os.clock() - self.announcementStartTime
        local fadeInDuration = 0.01 -- Adjust this value to control the fade-in speed
        local timeBeforeFadeStarts = 0.64 -- Adjust this value to control the time before fade-out starts
        local fadeOutDuration = 0.05 -- Adjust this value to control the fade-out speed
        
        -- Add new control variables
        local startingScale = 0.25 -- Initial scale factor
        local scaleSpeed = 2.55 -- Scale speed factor
        
        local alpha = 255
        if elapsedTime < fadeInDuration then
            alpha = 255 * (elapsedTime / fadeInDuration)
        elseif elapsedTime > timeBeforeFadeStarts then
            local fadeOutTime = elapsedTime - timeBeforeFadeStarts
            alpha = math.max(0, 255 * (1 - fadeOutTime / fadeOutDuration))
        end
        
        -- Calculate scale factor based on elapsed time
        local aScale = startingScale + (scaleSpeed * elapsedTime)
        local currentTeamColorAlpha = math.min(alpha, 255 * (elapsedTime / timeBeforeFadeStarts))
        local currentGrayColorAlpha = math.max(0, alpha - currentTeamColorAlpha)
        
        pushMatrix()
        pushStyle()
        
        -- Apply the scaling transformation
        translate(WIDTH / 2, HEIGHT / 2)
        scale(aScale)
        translate(-WIDTH / 2, -HEIGHT / 2)
        
        -- frame with dark background
        rectMode(CENTER)
        local textStr = "Turn:\n" .. self.announcementTeam
        local rectSize = self.map.width * 0.69
        local sizedFont = self:fontSizeForWidth(textStr, rectSize * 0.9)
        fontSize(sizedFont * 0.8)
        noStroke()
        fill(teamColor.r, teamColor.g, teamColor.b, currentTeamColorAlpha)
        roundRect(WIDTH / 2, HEIGHT / 2, rectSize, rectSize, rectSize * 0.09)
        -- team announcement
        
        textAlign(CENTER)

        fill(0, 0, 0, math.min(110, alpha * 0.8))
      --  text(textStr, (WIDTH / 2) - 1, (HEIGHT / 2) - 1)
        fill(teamColor.r, teamColor.g, teamColor.b, alpha)
        text(textStr, WIDTH / 2, HEIGHT / 2)
        
        popStyle()
        popMatrix()
        if alpha <= 0 then
            self.announcementTeam = nil
            if fadeCompleteCallback then
                fadeCompleteCallback()
            end
        end
    end
end

function InGameUI:createDamageAnimation(unit, damage)
    local anim = {
        unit = unit,
        badgeSize = 1,
        floatingHP = nil,
        active = true
    }
    
    -- Add the animation to damageAnimations table
    table.insert(self.damageAnimations, anim)
    
    anim.badgeSize = 1.5 -- Start by increasing the badge size
    
    -- Tween badge size back to normal
    tween(0.3, anim, { badgeSize = 1 }, tween.easing.expoOut)
    
    -- Create floating hit points text
    anim.floatingHP = {
        value = -damage,
        y = 0,
        opacity = 255
    }
    
    -- Tween floating hit points text
    local animationDuration = 1.5 -- Change this value to control the time until the text vanishes
    local floatingDistance = 25 -- Change this value to control the distance the floating number floats
    tween(animationDuration, anim.floatingHP, { y = floatingDistance, opacity = 0 }, tween.easing.cubicOut, function()
        anim.floatingHP = nil
        anim.active = false
    end)

end

function InGameUI:drawStrengthBadge(unit, anim)
    
    local badgeSize = 18
    if not unit then
        unit = anim.unit
        badgeSize = 28 * anim.badgeSize
    end
    
    local badgeX = unit.x - (self.map.cellSize / 2 * 0.8)
    local badgeY = unit.y + (self.map.cellSize / 2 * 0.8)
    
    pushStyle()
    fontSize(badgeSize * 0.65)
    
    -- Draw strength badge
    if unit.strength ~= 0 then
        noStroke()
        fill(236, 66, 66)
        ellipse(badgeX, badgeY, badgeSize)
        
        -- Draw strength value
        fill(255)
        text(tostring(unit.strength), badgeX, badgeY)
    end
    
    -- Draw floating hit points text if available
    if anim and anim.floatingHP then
        fill(255, 255, 255, anim.floatingHP.opacity)
        fontSize(fontSize() * 1.5)
        text(tostring(anim.floatingHP.value), badgeX, badgeY + (badgeSize / 2) - 5 + anim.floatingHP.y)
    end
    
    popStyle()
    
end

function InGameUI:drawAllUnits(units)
    if self.selectedUnit then
        self:drawSelectedUnitInfo(self.selectedUnit)
        self:highlightAvailableMoves(self.selectedUnit)
    end
    
    for _, unit in ipairs(units) do
        if unit ~= self.selectedUnit then
            self:drawUnit(unit)
        end
    end
    
    -- Draw selected unit last
    if self.selectedUnit then
        self:drawUnit(self.selectedUnit)
    end
    
    -- Draw badges for active animations
    for i, anim in ipairs(self.damageAnimations) do
        if anim.active then
            self:drawStrengthBadge(nil, anim)
        else
            table.remove(self.damageAnimations, i)
        end
    end
end


function InGameUI:drawUnit(unit)
    
    local row, column = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    
    if (not row) or (not column) then
        print("not row or column ", row, column, unit.x, unit.y)
        return
    end
    
    -- Calculate the x and y position of the cell
    local x = self.map.offsetX + (column - 1) * self.map.cellSize
    local y = self.map.offsetY + (row - 1) * self.map.cellSize
    
    -- Draw the background rectangle
    pushStyle()
    strokeWidth(self.map.cellSize * 0.06)
    local rectInset = self.map.cellSize * 0.05
    local rectSize = self.map.cellSize - rectInset
    local rectX = x + (rectInset / 2)
    local rectY = y + (rectInset / 2)
    -- Draw a colored rectangle based on unit type
    fill(unit.color)
    stroke(unit.color.r, unit.color.g, unit.color.b, 80)
    if self.isActiveTeam(unit.team) then
        stroke(unit.color.r, unit.color.g, unit.color.b, 180)
    end
    roundRect(rectX + (rectSize * 0.5), rectY + (rectSize * 0.5), rectSize, rectSize, rectSize * 0.25)
    
    -- Draw the unit sprite

    spriteMode(CENTER)
    rectMode(CENTER)
    local unitSize = self.map.cellSize
    if unit == self.selectedUnit then
        unitSize = unitSize * 1.2
        noStroke()
        fill(236, 208, 67)
        roundRect(unit.x, unit.y, rectSize - strokeWidth(), rectSize - strokeWidth(), rectSize * 0.25)
    end
    sprite(unit.icon, unit.x, unit.y, unitSize)

    self:drawStrengthBadge(unit)
    
    popStyle()
end

function InGameUI:drawAttackableTargets(units)
    self.alreadyCrosshaired = {}
    for _, attacker in ipairs(units) do
        if self.isActiveTeam(attacker.team) then
            for _, target in ipairs(units) do
                if attacker ~= target and attacker.team ~= target.team and self:isAttackable(attacker, target) then
                    if self.selectedUnit and self:isAttackable(self.selectedUnit, target) then
                        if attacker == self.selectedUnit then
                            self:drawCrosshairsOn(target, true)
                            self.alreadyCrosshaired[target] = true
                        end
                    elseif not self.alreadyCrosshaired[target] then
                        self:drawCrosshairsOn(target, false)
                        self.alreadyCrosshaired[target] = true
                    end
                end
            end 
        end
    end
end

function InGameUI:drawCrosshairsOn(unit, attackable)
    local function drawScaledCrosshairs(aScale)
        pushStyle()
        pushMatrix()
        
        noFill()
        strokeWidth(self.map.cellSize * 0.15)
        translate(unit.x, unit.y)
        scale(aScale)
        if attackable then
            scale(aScale)
            stroke(255, 0, 0, 194) -- Red crosshairs
        else
            scale(aScale * 0.75)
            stroke(186, 221) -- Gray crosshairs
        end
        
        local circleRadius = self.map.cellSize * 0.4
        
        ellipse(0, 0, circleRadius * 2, circleRadius * 2)
        
        local lineLength = self.map.cellSize * 0.1
        
        line(-circleRadius - lineLength, 0, -circleRadius + lineLength + strokeWidth(), 0) -- West line
        line(circleRadius + lineLength, 0, circleRadius - lineLength - strokeWidth(), 0) -- East line
        line(0, -circleRadius - lineLength, 0, -circleRadius + lineLength + strokeWidth()) -- South line
        line(0, circleRadius + lineLength, 0, circleRadius - lineLength - strokeWidth()) -- North line
        
        popStyle()
        popMatrix()
    end
    
    if not self.crosshairTweens[unit] then
        local duration = 0.55  -- Adjust this value to control the overall animation duration
        local scaleSmall = 0.1  -- Adjust this value to control the initial scale
        local scaleLarge = 1
        local bounceFactor = 1.5  -- Adjust this value to control the bounce size
        self.crosshairTweens[unit] = {scale = scaleSmall}
        -- Start the animation sequence for this unit's crosshair
        tween(duration * 0.4, self.crosshairTweens[unit], {scale = scaleLarge}, {easing = tween.easing.backOut, callback = function()
                tween(duration * 0.3, self.crosshairTweens[unit], {scale = scaleLarge * bounceFactor}, {easing = tween.easing.quadIn, callback = function()
                        tween(duration * 0.3, self.crosshairTweens[unit], {scale = scaleLarge}, {easing = tween.easing.quadOut})
                    end})
            end})
    end
    
    if self.crosshairTweens[unit].scale then
        drawScaledCrosshairs(self.crosshairTweens[unit].scale)
    else
        drawScaledCrosshairs(scaleLarge)
    end
    
    -- Draw flanking indicators if the unit is a Neanderthal unit
    
    if unit.team == "neanderthal" and self.isActiveTeam("sapiens") then
        local row, col = self.map:pointToCellRowAndColumn(unit.x, unit.y)
        local iconOffset = self.map.cellSize * 0.85
        local offsets = {
            {x = 0, y = iconOffset},
            {x = 0, y = -iconOffset},
            {x = iconOffset, y = 0},
            {x = -iconOffset, y = 0},
        }
        
        for _, offset in ipairs(offsets) do
            local newRow, newCol = self.map:pointToCellRowAndColumn(unit.x + offset.x, unit.y + offset.y)
            if not self.isCellOccupied(newRow, newCol) then
                self:drawFlankingIndicator(unit, offset.x, offset.y)
            end
        end
    end
end

function InGameUI:drawFlankingIndicator(unit, offsetX, offsetY)
    local iconSize = self.map.cellSize * 0.75
    local iconX = unit.x + offsetX
    local iconY = unit.y + offsetY
    
    pushStyle()
    spriteMode(CENTER)
    rectMode(CENTER)
    tint(255, 79)
    sprite(self.sapiensIcon, iconX, iconY, iconSize)
    popStyle()
end

function InGameUI:resetCrosshairTweens()
    self.crosshairTweens = {}
end

function InGameUI:isAttackable(attacker, target)
    local attackerRow, attackerCol = self.map:pointToCellRowAndColumn(attacker.x, attacker.y)
    local targetRow, targetCol = self.map:pointToCellRowAndColumn(target.x, target.y)
    
    local rowDelta = math.abs(targetRow - attackerRow)
    local colDelta = math.abs(targetCol - attackerCol)
    
    return (rowDelta == 1 and colDelta == 0) or (rowDelta == 0 and colDelta == 1)
end

function InGameUI:highlightAvailableMoves(unit)
    local row, column = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    local adjacentCells = {
        {row = row - 1, col = column},
        {row = row + 1, col = column},
        {row = row, col = column - 1},
        {row = row, col = column + 1}
    }
    
    local inset = self.map.cellSize * 0.1
    for _, cell in ipairs(adjacentCells) do
        -- Check if the cell coordinates are within the map grid bounds
        if cell.row >= 1 and cell.row <= self.map.gridSize and cell.col >= 1 and cell.col <= self.map.gridSize then
            local x = self.map.offsetX + (cell.col - 1) * self.map.cellSize + inset
            local y = self.map.offsetY + (cell.row - 1) * self.map.cellSize + inset
            pushStyle()
            fill(unit.color.r, unit.color.g, unit.color.b, 96)
            rect(x, y, self.map.cellSize - (inset * 2), self.map.cellSize - (inset * 2))
            popStyle()
        end
    end
end

function InGameUI:drawSelectedUnitInfo(unit)
    -- Draw the background square for the unit info
    pushStyle()
    fill(64, 64, 64, 200)
    rectMode(CORNER)
    local infoBoxWidth = 150
    local infoBoxHeight = 100
    rect(WIDTH - infoBoxWidth, HEIGHT - infoBoxHeight, infoBoxWidth, infoBoxHeight)
    popStyle()
    
    -- Draw the selected unit's info (health, attack, etc.) inside the square
    local textX, textY = WIDTH - infoBoxWidth + 10, HEIGHT - 20
    fill(255)
    text("Unit Team: " .. unit.team, textX, textY)
    text("Strength: " .. unit.strength, textX, textY - 20)
end

function InGameUI:isValidMove(unit, row, col, units)
    local currentRow, currentCol = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    if (not currentRow) or (not currentCol) then
        return false
    end
    local rowDelta = math.abs(row - currentRow)
    local colDelta = math.abs(col - currentCol)
    
    local isAdjacent = (rowDelta == 1 and colDelta == 0) or (rowDelta == 0 and colDelta == 1)
    
    if not isAdjacent then
        return false
    end
    
    for _, otherUnit in ipairs(units) do
        local otherUnitRow, otherUnitCol = self.map:pointToCellRowAndColumn(otherUnit.x, otherUnit.y)
        if row == otherUnitRow and col == otherUnitCol then
            return false
        end
    end
    
    return true
end


function InGameUI:selectUnit(units, x, y)
    if not units then
        return
    end
    for _, unit in ipairs(units) do
        local unitX, unitY = unit.x, unit.y
        if x >= unitX and x <= unitX + 32 and y >= unitY and y <= unitY + 32 then
            self.selectedUnit = unit
            return
        end
    end
    self.selectedUnit = nil
end

function InGameUI:moveSelectedUnit(x, y)
    if self.selectedUnit then
        self.selectedUnit.x = x
        self.selectedUnit.y = y
    end
end

function InGameUI:drawTurnIndicator(x, y, width, height, teamName, teamColor)    
    pushStyle()
    strokeWidth(3)
    stroke(self.uiStroke)
    fill(self.uiFill)
    roundRect(x + (width / 2), y + (height / 2), width, height)
    local newFontSize = self:fontSizeForWidth(self.fontSizingText, width * 0.8)
    fontSize(newFontSize)
    textMode(CENTER)
    fill(0, 104)
    text("turn: "..teamName, x - 1 + width / 2, y - 1 + height / 2)
    fill(255)
    text("turn: "..teamName, x + width / 2, y + height / 2)
    fill(teamColor.r, teamColor.g, teamColor.b, 90)
    text("turn: "..teamName, x + width / 2, y + height / 2)
    stroke(fill())
    fill(0, 0)
    roundRect(x + (width / 2), y + (height / 2), width, height)
    popStyle()
end

function InGameUI:fontSizeForWidth(aText, desiredWidth)
    local currentFontSize = fontSize()
    local textW, textH = textSize(aText)
    local scaleFactor = desiredWidth / textW   
    return currentFontSize * scaleFactor
end

function InGameUI:drawTimeLeft(timeLeft)
    local spec = self.countdownSpecs
    pushStyle()
    textAlign(CENTER)
    fill(spec.color)

    fontSize(spec.smallFont)
    text("timer", spec.leftX, spec.smallY)
    
    fontSize(spec.largeFont)
    text(string.format("%.1f", math.max(0.0, timeLeft)), spec.leftX, spec.largeY)
    
    popStyle()
end

function InGameUI:drawMovesLeft(movesLeft)
    local spec = self.countdownSpecs
    pushStyle()
    textAlign(CENTER)
    fill(spec.color)
    
    fontSize(spec.smallFont)
    text("moves", spec.rightX, spec.smallY - (self.map.height / 2))
    
    fontSize(spec.largeFont)
    text(movesLeft, spec.rightX, spec.largeY - (self.map.height / 2))
    
    popStyle()
end



function InGameUI:touched(touch)
    if touch.state == ENDED then
        if self:isTouchWithinEndTurnButton(touch) then
            self.nextTurnButtonAction()
        end
    end
end

function InGameUI:drawEndTurnButton()
    pushStyle()
    rectMode(CENTER)
    local gapSize = (math.max(WIDTH, HEIGHT) - self.map.width) / 2
    local gapMargin = gapSize * 0.1
    local buttonSide = math.min(gapSize - (gapMargin * 2), self.map.height * 0.25)
    if CurrentOrientation == LANDSCAPE_LEFT or 
    CurrentOrientation == LANDSCAPE_RIGHT then       
        self.endTurnButtonBounds = {
            x = self.map.offsetX + self.map.width + ((buttonSide + gapMargin) / 2), 
            y = self.map.offsetY + (self.map.width * 0.7), 
            width = buttonSide, 
            height = buttonSide}
    else
        gapSize = (math.max(WIDTH, HEIGHT) - self.map.height) / 2
        self.endTurnButtonBounds = {
            x = WIDTH - (self.map.width * 0.3), 
            y = self.map.offsetY - ((buttonSide + gapMargin) / 2),
            width = buttonSide, 
        height = buttonSide}
    end
    local spec = self.endTurnButtonBounds
    --self.endTurnButtonBounds = {x = x, y = y, width = width, height = height}
    print(spec.x, spec.y, spec.width, spec.height, gapSize / 8)
    stroke(self.uiStroke)
    fill(self.uiFill)
    strokeWidth(3)
    roundRect(spec.x, spec.y, spec.width, spec.height, gapSize / 8)
    fill(223, 158, 158)
    local newFontSize = self:fontSizeForWidth("end\nturn", spec.width * 0.4)
    fontSize(newFontSize)
    textMode(CENTER)
    text("end\nturn", spec.x, spec.y)
    popStyle()
end

function InGameUI:isTouchWithinEndTurnButton(touch)
    local bounds = self.endTurnButtonBounds
    print(bounds.x, "-", bounds.y, "-", bounds.width, "-", bounds.height)
    local halfW, halfH = bounds.width / 2, bounds.height / 2
    local leftX, rightX = bounds.x - halfW, bounds.x + halfW
    local topY, bottomY = bounds.y + halfH, bounds.y - halfH
    fill(236, 67, 218)
    rect(bounds.x, bounds.y, bounds.width, bounds.height)
    return touch.x >= leftX and touch.x <= rightX
    and touch.y >= bottomY and touch.y <= topY
end
