-- In-Game UI
InGameUI = class()

function InGameUI:init(map)
    self.map = map
    self.gridSize = map.gridSize
    self.cellSize = map.cellSize
    self.selectedUnit = nil
    self.isActiveTeam = function(team) end
    self.nextTurnButtonAction = function() end
    self.fontSizingText = "abcdefghijklmnop"
    self.announcementStartTime = 0
    self.announcementTeam = nil
    self.crosshairTweens = {}
    self.uiStroke = color(197, 189, 169)
    self.uiFill = color(61, 65, 81)
end

function InGameUI:announceTurn(team)
    self.announcementStartTime = os.clock()
    self.announcementTeam = team
end

function InGameUI:drawAnnouncement(teamColor, fadeCompleteCallback)
    if self.announcementTeam then
        
        local elapsedTime = os.clock() - self.announcementStartTime
        local fadeInDuration = 0.2 -- Adjust this value to control the fade-in speed
        local timeBeforeFadeStarts = 0.75 -- Adjust this value to control the time before fade-out starts
        local fadeOutDuration = 0.25 -- Adjust this value to control the fade-out speed
        
        local alpha = 255
        if elapsedTime < fadeInDuration then
            alpha = 255 * (elapsedTime / fadeInDuration)
        elseif elapsedTime > timeBeforeFadeStarts then
            local fadeOutTime = elapsedTime - timeBeforeFadeStarts
            alpha = math.max(0, 255 * (1 - fadeOutTime / fadeOutDuration))
        end
        
        pushStyle()
        
        -- frame with dark background
        rectMode(CENTER)
        local rectSize = self.map.width * 0.69
        local sizedFont = self:fontSizeForWidth(self.fontSizingText, rectSize)
        fontSize(sizedFont * 0.8)
        noStroke()
        fill(self.uiStroke.r, self.uiStroke.g, self.uiStroke.b, alpha)
        roundRect(WIDTH / 2, HEIGHT / 2, rectSize, rectSize, rectSize * 0.09)
        -- team announcement

        textAlign(CENTER)
        local textStr = "Turn:\n" .. self.announcementTeam
        fill(0, 0, 0, math.min(110, alpha * 0.8))
        text(textStr, (WIDTH / 2) - 1, (HEIGHT / 2) - 1)
        fill(teamColor.r, teamColor.g, teamColor.b, alpha)
        text(textStr, WIDTH / 2, HEIGHT / 2)
        
        popStyle()
        
        if alpha <= 0 then
            self.announcementTeam = nil
            if fadeCompleteCallback then
                fadeCompleteCallback()
            end
        end
        
    end
end


function InGameUI:drawAllUnits(units)
    if self.selectedUnit then
        self:drawSelectedUnitInfo(self.selectedUnit)
        self:highlightAvailableMoves(self.selectedUnit)
    end
    
    for _, unit in ipairs(units) do
        self:drawUnit(unit)
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
    local spriteInset = self.map.cellSize * 0.15
    spriteMode(CORNER)
    local spriteSizeX = self.map.cellSize - spriteInset
    local spriteSizeY = spriteSizeX
    local spriteX = x + (spriteInset / 2)
    local spriteY = y + (spriteInset / 2)
    sprite(unit.icon, x, y, self.map.cellSize)
    
    -- Display strength number
    local radius = 13
    local textX = x + (self.map.cellSize * 0.1)
    local textY = y + (self.map.cellSize * 0.90)
    noStroke()
    fill(236, 66, 66) -- Red dot
    ellipse(textX, textY, radius * 2)
    --ellipse(unit.x, unit.y, radius * 2) -- show unit x, y
    fill(255) -- White text
    fontSize(radius * 1.2)
    textAlign(CENTER, CENTER)
    text(unit.strength, textX, textY)
    
    popStyle()
end

function InGameUI:drawAttackableTargets(units)
    pushStyle()
    strokeWidth(3)
    stroke(255, 0, 0, 136) -- Red crosshairs
    
    for _, attacker in ipairs(units) do
        if self.isActiveTeam(attacker.team) then
            for _, target in ipairs(units) do
                if attacker ~= target and attacker.team ~= target.team and self:isAttackable(attacker, target) then
                    self:drawCrosshairsOn(target)
                end
            end 
        end
    end
    
    popStyle()
end

function InGameUI:drawCrosshairsOn(unit)
    local function drawScaledCrosshairs(aScale)
        pushMatrix()
        translate(unit.x, unit.y)
        scale(aScale)
        
        pushStyle()
        noFill()
        strokeWidth(self.map.cellSize * 0.15)
        stroke(255, 0, 0, 194) -- Red crosshairs
        
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

function InGameUI:drawTimeLeft(x, y, width, height, timeLeft)
    pushStyle()
    fontSize(self:fontSizeForWidth(self.fontSizingText, width))
    textAlign(CENTER, CENTER)
    strokeWidth(4)
    stroke(self.uiStroke)
    fill(self.uiFill)
    rectMode(CORNER)
    roundRect(x + (width / 2), y + (height / 2), width, height)
    fill(0, 237)
    text("Turn Timer: " .. string.format("%.1f", math.max(0.0, timeLeft)), (x + width / 2) -1, (y + height / 2) - 1)
    fill(217, 213, 202)
    text("Turn Timer: " .. string.format("%.1f", math.max(0.0, timeLeft)), x + width / 2, y + height / 2)
    popStyle()
end

function InGameUI:drawMovesLeft(x, y, width, height, movesLeft)
    pushStyle()
    fontSize(self:fontSizeForWidth("Moves Left: 100", width))
    textAlign(CENTER, CENTER)
    
    stroke(self.uiStroke)
    fill(self.uiFill)
    strokeWidth(3)
    rectMode(CORNER)
    roundRect(x + (width / 2), y + (height / 2), width, height)
    
    fill(217, 213, 202)
    text("Moves Left: " .. movesLeft, x + width / 2, y + height / 2)
    popStyle()
end

function InGameUI:drawEndTurnButton(x, y, width, height)
    self.endTurnButtonBounds = {x = x, y = y, width = width, height = height}
    
    pushStyle()
    stroke(self.uiStroke)
    fill(self.uiFill)
    strokeWidth(3)
    roundRect(x + (width / 2), y + (height / 2), width, height)
    fill(223, 158, 158)
    local newFontSize = self:fontSizeForWidth(self.fontSizingText, width * 0.8)
    fontSize(newFontSize)
    textMode(CENTER)
    text("end turn", x + width / 2, y + height / 2)
    popStyle()
end


function InGameUI:drawUnitStatsPanel(x, y, width, height, unit)
    pushStyle()
    fill(255, 255, 255, 200)
    rect(x, y, width, height)
    
    if unit then
        local statsText = "Unit: " .. unit.team .. "\nStrength: " .. unit.strength
        fill(0)
        fontSize(height * 0.15)
        textMode(CORNER)
        text(statsText, x + width * 0.1, y + height * 0.8)
    end
    
    popStyle()
end

function InGameUI:touched(touch)
    if touch.state == ENDED then
        if self:isTouchWithinEndTurnButton(touch) then
            self.nextTurnButtonAction()
        end
    end
end

function InGameUI:isTouchWithinEndTurnButton(touch)
    local bounds = self.endTurnButtonBounds
    return touch.x >= bounds.x and touch.x <= bounds.x + bounds.width
    and touch.y >= bounds.y and touch.y <= bounds.y + bounds.height
end

