-- In-Game UI
InGameUI = class()

function InGameUI:init(map, queries)
    self.map = map
    self.queries = queries
    self.gridSize = map.gridSize
    self.cellSize = map.cellSize
    self.selectedUnit = nil
    self.isActiveTeam = function(team) end
    self.nextTurnAction = function() end
    self.isCellOccupied = function(row, col) end
    self.fontSizingText = "abcdefghijklmnop"
    self.sapiensIcon = asset.Sapiens
    self.neanderthalIcon = asset.Neanderthal
    self.announcementStartTime = 0
    self.announcementTeam = nil
  --  self.crosshairTweens = {}
    self.damageAnimations = {}
    self.uiStroke = color(197, 189, 169)
    self.uiFill = color(61, 65, 81)
    self.currentPlayerCombatColor = color(255, 0, 45)
    self.otherPlayerCombatColor = color(215)
    self.animation = Animation(map, self.currentPlayerCombatColor, self.otherPlayerCombatColor)
    local countdownsW = self.map.cellSize * 3.5
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
        color = color(229, 225, 211, 173),
        leftX = self.map.offsetX + (self.map.width * 0.16),
        rightX = self.map.offsetX + (self.map.width * 0.75),
        smallYUpper = self.map.offsetY + self.map.height - (smallH * 0.6),
        largeYUpper = self.map.offsetY + self.map.height - ((largeH + smallH) * 0.55),
        smallYLower = self.map.offsetY + (smallH * 0.6),
        largeYLower = self.map.offsetY + ((largeH + smallH) * 0.55),      
        smallFont = smallFont,
        largeFont = largeFont
    }
    popStyle()
end

function InGameUI:draw(units)
    self:updateAndDrawIndicators(units)
end

function InGameUI:updateAndDrawIndicators(units)
    self:updateCrosshairs(units)
    self:updateFlankingArrows(units)
    self.animation:drawFlankingArrows()
    self.animation:drawCrosshairs()
    self.animation:drawYellowDots()
end

function InGameUI:announceTurn(team)
    self.announcementStartTime = os.clock()
    self.announcementTeam = team
end

function InGameUI:drawAnnouncement(teamColor, fadeCompleteCallback)
    if self.announcementTeam then
        
        local elapsedTime = os.clock() - self.announcementStartTime
        local startSize = 0.05 -- Adjust this value to control the starting size of the rectangle
        local endSize = 1.9 -- Adjust this value to control the ending size of the rectangle
        local scaleSpeed = 1.5 -- Adjust this value to control the speed of the scaling
        local timeFadeoutBegins = 0.3 -- Adjust this value to control the time before fade-out starts
        local timeFadeoutEnds = 0.9 -- Adjust this value to control the time when fade-out ends
        
        local scaleFactor = startSize + scaleSpeed * elapsedTime
        scaleFactor = math.min(scaleFactor, endSize)
        
        local alpha = 255
        if elapsedTime >= timeFadeoutBegins and elapsedTime <= timeFadeoutEnds then
            local fadeOutTime = elapsedTime - timeFadeoutBegins
            alpha = math.max(0, 255 * (1 - fadeOutTime / (timeFadeoutEnds - timeFadeoutBegins)))
        elseif elapsedTime > timeFadeoutEnds then
            alpha = 0
        end
        
        local currentTeamColorAlpha = math.min(alpha, 255 * (elapsedTime / timeFadeoutBegins))
        local currentGrayColorAlpha = math.max(0, alpha - currentTeamColorAlpha * 0.15)
        
        pushStyle()
        
        -- frame with dark background
        rectMode(CENTER)
        local textStr = "Turn:\n" .. self.announcementTeam
        local rectSize = self.map.width * scaleFactor
        local sizedFont = self:fontSizeForWidth(textStr, rectSize * 0.9)
        fontSize(sizedFont)
        noStroke()
        fill(teamColor.r, teamColor.g, teamColor.b, currentTeamColorAlpha)
        roundRect(WIDTH / 2, HEIGHT / 2, rectSize, rectSize, rectSize * 0.09)
        fill(110, currentGrayColorAlpha)
        roundRect(WIDTH / 2, HEIGHT / 2, rectSize, rectSize, rectSize * 0.09)
        
        -- team announcement
        textAlign(CENTER)
        local textStr = "Turn:\n" .. self.announcementTeam
        fill(0, 0, 0, math.min(180, alpha * 0.8))
        --text(textStr, (WIDTH / 2) - 1, (HEIGHT / 2) - 1)
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

function InGameUI:updateCrosshairs(units)
    local currentPlayerTeam = self.queries:getCurrentPlayer().team
    local attackableUnits = {}
    
    --go through units
    for _, unit in ipairs(units) do
        --if enemy found
        if unit.team ~= currentPlayerTeam then
            --go through units again
            for _, otherUnit in ipairs(units) do
                --if enemy is near player's unit
                if otherUnit.team == currentPlayerTeam and self.map:isAttackable(otherUnit, unit) then
                    --use enemy unit as key for player unit
                    attackableUnits[unit] = otherUnit
                    break
                end
            end
        end
    end
    
    --go through units
    for _, unit in ipairs(units) do
        --if current player unit
        if unit.team == currentPlayerTeam then
            --nil out any crosshair tween
            self.animation.crosshairTweens[unit] = nil
        else
            --else if enemy unit is a key in attackables
            if attackableUnits[unit] then
                --determine if crosshair should be red
                local isRedCrosshair = self.selectedUnit and attackableUnits[unit] == self.selectedUnit
                --add animation for crosshair
                self.animation:addCrosshairAnimation(unit, isRedCrosshair)
            else
                --if not a key in attackables nil any tween for it
                self.animation.crosshairTweens[unit] = nil
            end
        end
    end
    
    --nil crosshairs with keys that are not in units table
    for key, _ in pairs(self.animation.crosshairTweens) do
        if table_contains(units, key) == false then
            self.animation.crosshairTweens[key] = nil
        end
    end
end

function InGameUI:updateFlankingArrows(units)
    local currentPlayerTeam = self.queries:getCurrentPlayer().team
    local teamsTable = self.queries:getTeams()
    for k, v in pairs(teamsTable) do
    end
    local sapiensUnits = teamsTable.sapiens
    local neanderthalUnits = teamsTable.neanderthal
    
    self.animation.arrowData = {} -- Reset the arrow data table
    
    for _, neanderthal in ipairs(neanderthalUnits) do
        local flankingSapiens = {}
        local isFlanked = self.queries:isFlanked(neanderthal)
        local nRow, nCol = self.map:pointToCellRowAndColumn(neanderthal.x, neanderthal.y)
        local adjacentCells = self.map:orthogonalCellsFor(nRow, nCol)
        
        if isFlanked then
            for _, sapiens in ipairs(sapiensUnits) do
                local sRow, sCol = self.map:pointToCellRowAndColumn(sapiens.x, sapiens.y)
                if self.map:isAdjacent(sRow, sCol, nRow, nCol) then
                    table.insert(flankingSapiens, sapiens)
                end
            end
            
            if #flankingSapiens > 0 then
                local arrowColor = neanderthal == self.selectedUnit and self.currentPlayerCombatColor or self.otherPlayerCombatColor
                table.insert(self.animation.arrowData, {neanderthal = neanderthal, flankingSapiens = flankingSapiens, color = arrowColor})
            end
        end
        
        for _, sapiens in ipairs(sapiensUnits) do
            local sRow, sCol = self.map:pointToCellRowAndColumn(sapiens.x, sapiens.y)
            if self.map:isAdjacent(sRow, sCol, nRow, nCol) then
                for _, cell in ipairs(adjacentCells) do
                    local row, col = cell.row, cell.col
                    local unitAtCell = self.queries:getUnitAt(row, col)
                    -- Check if it's the Sapiens' turn
                    if self.queries:getCurrentPlayer().team ~= "sapiens" then
                        -- Empty the dotData if it's not the Sapiens' turn
                        if #self.animation.dotData > 0 then
                            self.animation.dotData = {}
                        end
                    else
                        -- Add/update the yellow dots during the Sapiens' turn
                        if not unitAtCell then
                            -- No unit at the cell, draw a yellow dot
                            local x, y = self.map:cellRowAndColumnToPoint(row, col)
                            local dotRadius = self.map.cellSize * 0.1
                            local dotColor = color(236, 197, 67) -- Yellow color
                            
                            -- Store the dot data for drawing later
                            if not self.animation.dotData then
                                self.animation.dotData = {}
                            end
                            table.insert(self.animation.dotData, {x = x, y = y, radius = dotRadius, color = dotColor})
                        end
                    end
                end
            end
        end
    end
end

function InGameUI:updateFlankingArrows(units)
    local currentPlayerTeam = self.queries:getCurrentPlayer().team
    local teamsTable = self.queries:getTeams()
    for k, v in pairs(teamsTable) do
    end
    local sapiensUnits = teamsTable.sapiens
    local neanderthalUnits = teamsTable.neanderthal
    
    self.animation.arrowData = {} -- Reset the arrow data table
    self.animation.dotData = {}
    
    for _, neanderthal in ipairs(neanderthalUnits) do
        local adjacentUnits = self:findAdjacentUnits(neanderthal)
        local flankingSapiens = adjacentUnits.sapiens or {}
        local isFlanked = self.queries:isFlanked(neanderthal)
        local nRow, nCol = self.map:pointToCellRowAndColumn(neanderthal.x, neanderthal.y)
        local adjacentCells = self.map:orthogonalCellsFor(nRow, nCol)
        
        if isFlanked and #flankingSapiens > 0 then
            local arrowColor = neanderthal == self.selectedUnit and self.currentPlayerCombatColor or self.otherPlayerCombatColor
            table.insert(self.animation.arrowData, {neanderthal = neanderthal, flankingSapiens = flankingSapiens, color = arrowColor})
        end
        
        for _, sapiens in ipairs(sapiensUnits) do
            local sRow, sCol = self.map:pointToCellRowAndColumn(sapiens.x, sapiens.y)
            if self.map:isAdjacent(sRow, sCol, nRow, nCol) then
                for _, cell in ipairs(adjacentCells) do
                    local row, col = cell.row, cell.col
                    local unitAtCell = self.queries:getUnitAt(row, col)
                    -- Check if it's the Sapiens' turn
                    if self.queries:getCurrentPlayer().team ~= "sapiens" then
                        -- Empty the dotData if it's not the Sapiens' turn
                        if #self.animation.dotData > 0 then
                            self.animation.dotData = {}
                        end
                    else
                        -- Add/update the yellow dots during the Sapiens' turn
                        if not unitAtCell then
                            -- No unit at the cell, draw a yellow dot
                            local x, y = self.map:cellRowAndColumnToPoint(row, col)
                            local dotRadius = self.map.cellSize * 0.1
                            local dotColor = color(236, 197, 67) -- Yellow color
                            
                            -- Store the dot data for drawing later
                            if not self.animation.dotData then
                                self.animation.dotData = {}
                            end
                            table.insert(self.animation.dotData, {x = x, y = y, radius = dotRadius, color = dotColor})
                        end
                    end
                end
            end
        end
    end
end

function InGameUI:updateFlankingArrows(units)
    local currentPlayerTeam = self.queries:getCurrentPlayer().team
    local teamsTable = self.queries:getTeams()
    for k, v in pairs(teamsTable) do
    end
    local sapiensUnits = teamsTable.sapiens
    local neanderthalUnits = teamsTable.neanderthal
    
    self.animation.arrowData = {} -- Reset the arrow data table
    self.animation.dotData = {} -- Reset the dot data table
    
    for _, neanderthal in ipairs(neanderthalUnits) do
        local adjacentUnits = self:findAdjacentUnits(neanderthal)
        local flankingSapiens = adjacentUnits.sapiens or {}
        local isFlanked = self.queries:isFlanked(neanderthal)
        local nRow, nCol = self.map:pointToCellRowAndColumn(neanderthal.x, neanderthal.y)
        local adjacentCells = self.map:orthogonalCellsFor(nRow, nCol)
        
        if isFlanked and #flankingSapiens > 0 then
            local arrowColor = neanderthal == self.selectedUnit and self.currentPlayerCombatColor or self.otherPlayerCombatColor
            table.insert(self.animation.arrowData, {neanderthal = neanderthal, flankingSapiens = flankingSapiens, color = arrowColor})
        end
        
        if currentPlayerTeam == "sapiens" and #flankingSapiens > 0 then
            for _, cell in ipairs(adjacentCells) do
                local row, col = cell.row, cell.col
                local unitAtCell = self.queries:getUnitAt(row, col)
                
                if not unitAtCell then
                    -- No unit at the cell, draw a yellow dot
                    local x, y = self.map:cellRowAndColumnToPoint(row, col)
                    local dotRadius = self.map.cellSize * 0.1
                    local dotColor = color(236, 197, 67) -- Yellow color
                    
                    -- Store the dot data for drawing later
                    table.insert(self.animation.dotData, {x = x, y = y, radius = dotRadius, color = dotColor})
                end
            end
        end
    end
end




function InGameUI:createFlankingTables(units)
    local flankingTables = {}
    for _, unit in ipairs(units) do
        local adjacentData = {
            emptyCells = self:findEmptyAdjacentCells(unit),
            adjacentUnits = self:findAdjacentUnits(unit)
        }
        
        flankingTables[unit] = adjacentData
    end
    return flankingTables
end

function InGameUI:findEmptyAdjacentCells(unit)
    local emptyCells = {}
    local uRow, uCol = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    local adjacentCells = self.map:orthogonalCellsFor(uRow, uCol)
    
    for _, cell in ipairs(adjacentCells) do
        local unitAtCell = self.queries:getUnitAt(cell.row, cell.col)
        if not unitAtCell then
            table.insert(emptyCells, cell)
        end
    end
    
    return emptyCells
end

function InGameUI:findAdjacentUnits(unit)
    local adjacentUnits = {
        sapiens = {},
       neanderthals = {}
    }
    local uRow, uCol = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    local adjacentCells = self.map:orthogonalCellsFor(uRow, uCol)
    
    for _, cell in ipairs(adjacentCells) do
        local unitAtCell = self.queries:getUnitAt(cell.row, cell.col)
        if unitAtCell then
            if unitAtCell.team == "sapiens" then
                table.insert(adjacentUnits.sapiens, unitAtCell)
            elseif unitAtCell.team == "neanderthal" then
                table.insert(adjacentUnits.neanderthals, unitAtCell)
            end
        end
    end
    
    return adjacentUnits
end

function InGameUI:updateFlankingArrowData(flankingTables, currentPlayerTeam, selectedUnit)
    for neanderthal, adjacentData in pairs(flankingTables) do
        local arrowColor = neanderthal == selectedUnit and self.currentPlayerCombatColor or self.otherPlayerCombatColor
        table.insert(self.animation.arrowData, {neanderthal = neanderthal, flankingSapiens = adjacentData.adjacentUnits.sapiens, color = arrowColor})
    end
end

function InGameUI:updateYellowDotData(flankingTables, currentPlayerTeam)
    if currentPlayerTeam == "sapiens" then
        self.animation.dotData = {} -- Reset the dot data table
        for neanderthal, adjacentData in pairs(flankingTables) do
            for _, cell in ipairs(adjacentData.emptyCells) do
                local x, y = self.map:cellRowAndColumnToPoint(cell.row, cell.col)
                local dotRadius = self.map.cellSize * 0.1
                local dotColor = color(236, 197, 67) -- Yellow color
                
                -- Store the dot data for drawing later
                table.insert(self.animation.dotData, {x = x, y = y, radius = dotRadius, color = dotColor})
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
    
    anim.badgeSize = 1.75 -- Start by increasing the badge size
    
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
    local badgeSize = self.map.cellSize * 0.45
    
    if anim and anim.unit then
        unit = anim.unit
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
        fontSize(fontSize() * 2.5)
        text(tostring(anim.floatingHP.value), badgeX, badgeY + (badgeSize / 2) - 5 + anim.floatingHP.y)
    end
    
    popStyle()
    
end

function InGameUI:drawUnitBackground(unit)
    local row, column = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    
    -- Calculate the x and y position of the cell
    local x = self.map.offsetX + (column - 1) * self.map.cellSize
    local y = self.map.offsetY + (row - 1) * self.map.cellSize
    
    -- Draw the background rectangle
    pushStyle()
    strokeWidth(self.map.cellSize * 0.25)
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
    if unit == self.selectedUnit then
        noStroke()
        fill(236, 208, 67)
        roundRect(unit.x, unit.y, rectSize - strokeWidth(), rectSize - strokeWidth(), rectSize * 0.25)
    end
    roundRect(rectX + (rectSize * 0.5), rectY + (rectSize * 0.5), rectSize, rectSize, rectSize * 0.25)
    popStyle()
end

function InGameUI:drawAllUnits(units)
    if self.selectedUnit then
        self:drawSelectedUnitInfo(self.selectedUnit)
        self:highlightAvailableMoves(self.selectedUnit)
    end
    
    -- Sort units by their y-coordinate (row) in descending order
    table.sort(units, function(a, b)
        return a.y > b.y
    end)
    
    for _, unit in ipairs(units) do
        self:drawUnitBackground(unit)
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
    
    for _, unit in ipairs(units) do
      --  self:drawFlankingArrows(unit, color(255, 0, 0))
    end
end

function InGameUI:drawBadgesAndAnimations()
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
    
    -- Draw the unit sprite
    pushStyle()
    spriteMode(CENTER)
    rectMode(CENTER)
    local unitX = unit.x + (self.map.cellSize * 0.1)
    local unitY = unit.y
    local unitSizeX = self.map.cellSize * 1.15
    local unitSizeY = self.map.cellSize * 1.1
    if unit.team == "sapiens" then
        unitSizeX = unitSizeX * 1.1
        unitSizeY = unitSizeY * 1.1
        unitX = unit.x
        unitY = unitY + (self.map.cellSize * 0.07) 
    end
    if unit == self.selectedUnit then
        unitSizeX = unitSizeX * 1.2
        unitSizeY = unitSizeY * 1.2
    end
    sprite(unit.icon, unitX, unitY, 
    unitSizeX, unitSizeY)
    
    self:drawStrengthBadge(unit)
    
    popStyle()
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
    
    fill(190, 100, 96, 140)
    
    fontSize(spec.smallFont)
    text("timer", spec.rightX - 1, spec.smallYLower)
    
    fontSize(spec.largeFont)
    text(string.format("%.1f", math.max(0.0, timeLeft)), spec.rightX - 1, spec.largeYLower)
    
    fill(spec.color)
    
    fontSize(spec.smallFont)
    text("timer", spec.rightX, spec.smallYLower)
    
    fontSize(spec.largeFont)
    text(string.format("%.1f", math.max(0.0, timeLeft)), spec.rightX, spec.largeYLower)
    
    popStyle()
end

function InGameUI:drawMovesLeft(movesLeft)
    local spec = self.countdownSpecs
    pushStyle()
    textAlign(CENTER)
    
    fill(190, 100, 96, 140)
    
    fontSize(spec.smallFont)
    text("moves", spec.leftX - 1,  spec.smallYUpper - 1)
    
    fontSize(spec.largeFont)
    text(movesLeft, spec.leftX - 1, spec.largeYUpper - 1)
    
    fill(spec.color)
    
    fontSize(spec.smallFont)
    text("moves", spec.leftX, spec.smallYUpper)
    
    fontSize(spec.largeFont)
    text(movesLeft, spec.leftX, spec.largeYUpper)
    
    popStyle()
end

function InGameUI:touched(touch)
    if touch.state == ENDED then
        if self:isTouchWithinEndTurnButton(touch) then
            self.nextTurnAction()
        end
    end
end

function InGameUI:drawEndTurnButton()
    pushStyle()
    rectMode(CENTER)
    local gapSize = (math.max(WIDTH, HEIGHT) - self.map.width) / 2
    local gapMargin = gapSize * 0.05
    local buttonSide = math.min(gapSize - (gapMargin * 2), self.map.height * 0.2)
    if CurrentOrientation == LANDSCAPE_LEFT or 
    CurrentOrientation == LANDSCAPE_RIGHT then       
        self.endTurnButtonBounds = {
            x = self.map.offsetX + self.map.width + ((buttonSide + gapMargin) / 2), 
            y = self.map.offsetY + self.map.height - (buttonSide / 2), 
            width = buttonSide, 
        height = buttonSide}
    else
        gapSize = (math.max(WIDTH, HEIGHT) - self.map.height) / 2
        self.endTurnButtonBounds = {
            x = self.map.offsetX + self.map.width - (buttonSide / 2), 
            y = self.map.offsetY - ((buttonSide + gapMargin) / 2),
            width = buttonSide, 
        height = buttonSide}
    end
    local spec = self.endTurnButtonBounds
    --self.endTurnButtonBounds = {x = x, y = y, width = width, height = height}
    stroke(self.uiStroke)
    fill(self.uiFill)
    strokeWidth(0.5)
    roundRect(spec.x, spec.y, spec.width, spec.height, spec.width * 0.18)
    fill(223, 158, 158, 158)
    local newFontSize = self:fontSizeForWidth("end\nturn", spec.width * 0.6)
    fontSize(newFontSize)
    textMode(CENTER)
    text("end\nturn", spec.x, spec.y)
    popStyle()
end

function InGameUI:isTouchWithinEndTurnButton(touch)
    local bounds = self.endTurnButtonBounds
    local halfW, halfH = bounds.width / 2, bounds.height / 2
    local leftX, rightX = bounds.x - halfW, bounds.x + halfW
    local topY, bottomY = bounds.y + halfH, bounds.y - halfH
    fill(236, 67, 218)
    rect(bounds.x, bounds.y, bounds.width, bounds.height)
    return touch.x >= leftX and touch.x <= rightX
    and touch.y >= bottomY and touch.y <= topY
end


--[[
true mesh rounded rectangle. Original by @LoopSpace
with anti-aliasing, optional fill and stroke components, optional texture that preserves aspect ratio of original image, automatic mesh caching
usage: RoundedRectangle{key = arg, key2 = arg2}
required: x;y;w;h:  dimensions of the rectangle
optional: radius:   corner rounding radius, defaults to 6;
corners:  bitwise flag indicating which corners to round, defaults to 15 (all corners).
Corners are numbered 1,2,4,8 starting in lower-left corner proceeding clockwise
eg to round the two bottom corners use: 1 | 8
to round all the corners except the top-left use: ~ 2
tex:      texture image
texCoord: vec4 specifying x,y,width,and height to use as texture coordinates
scale:    size of rect (using scale)
use standard fill(), stroke(), strokeWidth() to set body fill color, outline stroke color and stroke width
]]
function roundRect(x, y, w, h, radius)
roundedRectangle({
x=x, y=y, w=w, h=h, radius=radius
})
end
local __RRects = {}
function roundedRectangle(t) 
local s = t.radius or 8
local c = t.corners or 15
local w = math.max(t.w+1,2*s)+1
local h = math.max(t.h,2*s)+2
local hasTexture = 0
local texCoord = t.texCoord or vec4(0,0,1,1) --default to bottom-left-most corner, full with and height
if t.tex then hasTexture = 1 end
local label = table.concat({w,h,s,c,hasTexture,texCoord.x,texCoord.y},",")
if not __RRects[label] then
local rr = mesh()
rr.shader = shader(rrectshad.vert, rrectshad.frag)

local v = {}
local no = {}

local n = math.max(3, s//2)
local o,dx,dy
local edge, cent = vec3(0,0,1), vec3(0,0,0)
for j = 1,4 do
    dx = 1 - 2*(((j+1)//2)%2)
    dy = -1 + 2*((j//2)%2)
    o = vec2(dx * (w * 0.5 - s), dy * (h * 0.5 - s))
    --  if math.floor(c/2^(j-1))%2 == 0 then
    local bit = 2^(j-1)
    if c & bit == bit then
        for i = 1,n do
            
            v[#v+1] = o
            v[#v+1] = o + vec2(dx * s * math.cos((i-1) * math.pi/(2*n)), dy * s * math.sin((i-1) * math.pi/(2*n)))
            v[#v+1] = o + vec2(dx * s * math.cos(i * math.pi/(2*n)), dy * s * math.sin(i * math.pi/(2*n)))
            no[#no+1] = cent
            no[#no+1] = edge
            no[#no+1] = edge
        end
    else
        v[#v+1] = o
        v[#v+1] = o + vec2(dx * s,0)
        v[#v+1] = o + vec2(dx * s,dy * s)
        v[#v+1] = o
        v[#v+1] = o + vec2(0,dy * s)
        v[#v+1] = o + vec2(dx * s,dy * s)
        local new = {cent, edge, edge, cent, edge, edge}
        for i=1,#new do
            no[#no+1] = new[i]
        end
    end
end
-- print("vertices", #v)
--  r = (#v/6)+1
rr.vertices = v

rr:addRect(0,0,w-2*s,h-2*s)
rr:addRect(0,(h-s)/2,w-2*s,s)
rr:addRect(0,-(h-s)/2,w-2*s,s)
rr:addRect(-(w-s)/2, 0, s, h - 2*s)
rr:addRect((w-s)/2, 0, s, h - 2*s)
--mark edges
local new = {cent,cent,cent, cent,cent,cent,
    edge,cent,cent, edge,cent,edge,
    cent,edge,edge, cent,edge,cent,
    edge,edge,cent, edge,cent,cent,
cent,cent,edge, cent,edge,edge}
for i=1,#new do
    no[#no+1] = new[i]
end
rr.normals = no
--texture
if t.tex then
    rr.shader.fragmentProgram = rrectshad.fragTex
    rr.texture = t.tex
    
    local w,h = t.tex.width,t.tex.height
    local textureOffsetX,textureOffsetY = texCoord.x,texCoord.y
    
    local coordTable = {}
    for i,v in ipairs(rr.vertices) do
        coordTable[i] = vec2((v.x + textureOffsetX)/w, (v.y + textureOffsetY)/h)
    end
    rr.texCoords = coordTable
end
local sc = 1/math.max(2, s)
rr.shader.scale = sc --set the scale, so that we get consistent one pixel anti-aliasing, regardless of size of corners
__RRects[label] = rr
end
__RRects[label].shader.fillColor = color(fill())
if strokeWidth() == 0 then
__RRects[label].shader.strokeColor = color(fill())
else
__RRects[label].shader.strokeColor = color(stroke())
end

if t.resetTex then
__RRects[label].texture = t.resetTex
t.resetTex = nil
end
local sc = 0.25/math.max(2, s)
__RRects[label].shader.strokeWidth =  strokeWidth() * 0.1
pushMatrix()
translate(t.x,t.y)
scale(t.scale or 1)
__RRects[label]:draw()
popMatrix()
end

rrectshad ={
vert=[[
uniform mat4 modelViewProjection;

attribute vec4 position;

//attribute vec4 color;
attribute vec2 texCoord;
attribute vec3 normal;

//varying lowp vec4 vColor;
varying highp vec2 vTexCoord;
varying vec3 vNormal;

void main()
{
//  vColor = color;
vTexCoord = texCoord;
vNormal = normal;
gl_Position = modelViewProjection * position;
}
]],
frag=[[
precision highp float;

uniform lowp vec4 fillColor;
uniform lowp vec4 strokeColor;
uniform float scale;
uniform float strokeWidth;

//varying lowp vec4 vColor;
varying highp vec2 vTexCoord;
varying vec3 vNormal;

void main()
{
lowp vec4 col = mix(strokeColor, fillColor, smoothstep((1. - strokeWidth) - scale * 0.5, (1. - strokeWidth) - scale * 1.5 , vNormal.z)); //0.95, 0.92,
col = mix(vec4(col.rgb, 0.), col, smoothstep(1., 1.-scale, vNormal.z) );
// col *= smoothstep(1., 1.-scale, vNormal.z);
gl_FragColor = col;
}
]],
fragTex=[[
precision highp float;

uniform lowp sampler2D texture;
uniform lowp vec4 fillColor;
uniform lowp vec4 strokeColor;
uniform float scale;
uniform float strokeWidth;

//varying lowp vec4 vColor;
varying highp vec2 vTexCoord;
varying vec3 vNormal;

void main()
{
vec4 pixel = texture2D(texture, vTexCoord) * fillColor;
lowp vec4 col = mix(strokeColor, pixel, smoothstep(1. - strokeWidth - scale * 0.5, 1. - strokeWidth - scale * 1.5, vNormal.z)); //0.95, 0.92,
// col = mix(vec4(0.), col, smoothstep(1., 1.-scale, vNormal.z) );
col *= smoothstep(1., 1.-scale, vNormal.z);
gl_FragColor = col;
}
]]
}