
-- Game
Game = class()

function Game:init()
    font("ArialRoundedMTBold")
    self.gameState = "inGame"
    local buttonHeight = (math.min(WIDTH, HEIGHT)) * 0.07
    local cellsPerSide = 9
    local sideSize = (math.min(WIDTH, HEIGHT)) - buttonHeight * 2.5
    local mapX, mapY = (WIDTH - sideSize) * 0.5, (HEIGHT - sideSize) * 0.5
    self.map = Map(mapX, mapY, sideSize, sideSize, cellsPerSide)
    local player1 = Player(1, "sapiens", color(143, 236, 67, 226))
    local aiPlayer = AIPlayer(2, "neanderthal", color(73, 218, 234, 222))
    self.players = {player1, aiPlayer}
    self.invoker = Invoker()
    self.turnSystem = TurnSystem(self.players, 5, 6, self.invoker)
    self.unitManager = UnitManager(self.players)
    self.inGameUI = InGameUI(self.map)
    self.turnSystem.funcWhenTurnChanges = function() 
        self.inGameUI.selectedUnit = nil
        self.turnSystem.turnChangeAnimationInProgress = true
        self.turnSystem.timeRemaining = 0.0
        self.inGameUI:announceTurn(self.turnSystem:getCurrentTeam())
    end
    self.endTurnChangeAnimation = function()
        self.turnSystem.turnChangeAnimationInProgress = false
    end
    self.inGameUI.nextTurnButtonAction = function()
        local nextTurnCommand = NextTurnCommand(self.turnSystem)
        self.invoker:executeCommand(nextTurnCommand)
    end
    self.inGameUI.isActiveTeam = function(team)
        return self.turnSystem:getCurrentTeam() == team
    end
    self.attackFunction = function(attacker, target)
        self:attack(attacker, target)
    end
    self.touchedFunction = function(touch)
        self:touched(touch)
    end
    self.saveManager = SaveManager()
    self.unitManager.units = self:generateRandomUnits(9, 5)  
    local buttonMargin = sideSize * 0.0091 
    local bottomButtonWidth = (sideSize - buttonMargin) / 2
    local bottomButtonY = mapY - buttonHeight - buttonMargin
    local topButtonY = mapY + sideSize + buttonMargin
    self.turnIndicatorRect = vec4(mapX, bottomButtonY, bottomButtonWidth, buttonHeight)
    self.endTurnRect = vec4(mapX + bottomButtonWidth + buttonMargin, bottomButtonY, bottomButtonWidth, buttonHeight)
    self.timeLeftRect = vec4(mapX, topButtonY, sideSize * 0.65, buttonHeight)
    self.movesLeftRect = vec4(mapX + (sideSize * 0.65) + buttonMargin, topButtonY, sideSize * 0.35, buttonHeight)
    self.turnSystem:nextTurn(self.players[1].team)
end

function Game:draw(deltaTime)
    if self.gameState == "inGame" then
        self.map:draw()
    end
    local turnPlayer = self.players[self.turnSystem.currentPlayerIndex]
    local tiRec, eRec, tlRec = self.turnIndicatorRect, self.endTurnRect, self.timeLeftRect
    local mRec = self.movesLeftRect
    local movesLeft = self.turnSystem.movesPerTurn - self.turnSystem.moveCounter
    self.inGameUI:drawTurnIndicator(tiRec.x, tiRec.y, tiRec.z, tiRec.w, turnPlayer.team, turnPlayer.teamColor)
    self.inGameUI:drawEndTurnButton(eRec.x, eRec.y, eRec.z, eRec.w)
    self.inGameUI:drawTimeLeft(tlRec.x, tlRec.y, tlRec.z, tlRec.w, self.turnSystem.timeRemaining)
    self.inGameUI:drawMovesLeft(mRec.x, mRec.y, mRec.z, mRec.w, movesLeft)
    self.inGameUI:drawUnitStatsPanel(10, 130, 200, 100, self.inGameUI.selectedUnit)
    self.inGameUI:drawAllUnits(self.unitManager.units)
    self.inGameUI:drawAttackableTargets(self.unitManager.units)
    self.inGameUI:drawAnnouncement(turnPlayer.teamColor, self.endTurnChangeAnimation)
    self.turnSystem:update(deltaTime)
end

function Game:touchInput(touch)
    local touchInputCommand = TouchInputCommand(touch, self.touchedFunction)
    self.invoker:executeCommand(touchInputCommand)
end

function Game:serialize()
    -- Convert the game state to a string
    -- You can use a simple format, such as comma-separated values, or use a library to encode the data in JSON or another format
    local serializedData = "gameState=" .. self.gameState
    return serializedData
end

function Game:deserialize(gameData)
    -- Load the game state from a string
    -- You will need to parse the data and update the game state accordingly
    for key, value in string.gmatch(gameData, "(%w+)=(%w+)") do
        if key == "gameState" then
            self.gameState = value
        end
    end
end


function Game:unitContainsPoint(unit, x, y)
    local pointRow, pointCol = self.map:pointToCellRowAndColumn(x, y)
    local unitRow, unitCol = self.map:pointToCellRowAndColumn(unit.x, unit.y)
    return pointRow == unitRow and pointCol == unitCol
end

function Game:attack(attacker, target)
    print("attack(attacker, defender): ", attacker, ", ", target)
    
    if attacker.team == "sapiens" and target.team == "neanderthal" and self:isFlanked(target) then
        target.strength = 0 -- Kill a flanked Neanderthal in one hit
    else
        target.strength = target.strength - attacker.strength
    end
    
    self.inGameUI:createDamageAnimation(target, attacker.strength)
    
    if target.strength <= 0 then
        self:removeUnit(target)
    end
end

function Game:isFlanked(neanderthal)
    local flankingSapiens = 0
    
    -- Check orthogonally adjacent cells
    local directions = {
        {-self.map.cellSize, 0}, -- left
        {self.map.cellSize, 0}, -- right
        {0, -self.map.cellSize}, -- up
        {0, self.map.cellSize} -- down
    }
    
    for _, dir in ipairs(directions) do
        local newX = neanderthal.x + dir[1]
        local newY = neanderthal.y + dir[2]
        
        -- Check if newRow and newCol are within map bounds
        for _, unit in ipairs(self.unitManager.units) do
            if unit.team == "sapiens" and self:unitContainsPoint(unit, newX, newY) then
                flankingSapiens = flankingSapiens + 1
            end
        end
    end
    
    local flankedStatus = flankingSapiens >= 2
    print("Game:isFlanked(neanderthal): ", flankedStatus)
    return flankedStatus
end

function Game:removeUnit(unit)
    print("removeUnit(unit): ", unit)
    for i, u in ipairs(self.unitManager.units) do
        if u == unit then
            table.remove(self.unitManager.units, i)
            break
        end
    end
end


function Game:saveGame(slot)
    local saveData = {
        map = self.map:serialize(),
        units = self.unitManager:serializeUnits(),
    }
    self.saveManager:save(slot, saveData)
end

function Game:loadGame(slot)
    local saveData = self.saveManager:load(slot)
    if saveData then
        self.map:deserialize(saveData.map)
        self.unitManager:deserializeUnits(saveData.units)
    end
end

function Game:generateRandomUnits(sapiensCount, neanderthalCount)
    local units = {}
    local row, col, unitX, unitY
    
    for i = 1, sapiensCount do
        while true do
            row = math.random(2, self.map.gridSize)
            col = math.random(2, math.floor(self.map.gridSize / 2))
            if not self:isCellOccupied(units, row, col) then
                break
            end
        end
        unitX, unitY = self.map:cellRowAndColumnToPoint(row, col)
        local tColor = self.players[1].teamColor
        local uColor = color(tColor.r, tColor.g, tColor.b, 24)
        table.insert(units, Unit(self.players[1].team, 3, unitX, unitY, uColor, asset.Sapiens))
    end
    
    for i = 1, neanderthalCount do
        while true do
            row = math.random(2, self.map.gridSize - 1)
            col = math.random(math.ceil(self.map.gridSize / 2) + 2, self.map.gridSize - 1)
            if not self:isCellOccupied(units, row, col) then
                break
            end
        end
        unitX, unitY = self.map:cellRowAndColumnToPoint(row, col)
        local tColor = self.players[2].teamColor
        local uColor = color(tColor.r, tColor.g, tColor.b, 24)
        table.insert(units, Unit(self.players[2].team, 7, unitX, unitY, uColor, asset.Neanderthal))
    end
    
    return units
end

function Game:isCellOccupied(units, row, col)
    for _, unit in ipairs(units) do
        local unitRow, unitCol = self.map:pointToCellRowAndColumn(unit.x, unit.y)
        if row == unitRow and col == unitCol then
            return true
        end
    end
    return false
end

function Game:touched(touch)
    if self.turnSystem.turnChangeAnimationInProgress then
        self.inGameUI.selectedUnit = nil
        return
    end
    self.inGameUI:touched(touch)
    local units = self.unitManager.units
    if touch.state == BEGAN then
        local row, col = self.map:pointToCellRowAndColumn(touch.x, touch.y)
        if self.inGameUI.selectedUnit and row and col then
            local validMove = self.inGameUI:isValidMove(self.inGameUI.selectedUnit, row, col, units)
            if validMove then
                local moveCommand = MoveCommand(self.map.rowColToPointFunction, self.inGameUI.selectedUnit, row, col)
                self.invoker:executeCommand(moveCommand)
                
                -- Check for attackable units after a unit has moved
                for _, unit in ipairs(units) do
                    if self.inGameUI:isAttackable(self.inGameUI.selectedUnit, unit) then
                        self.inGameUI:drawCrosshairsOn(unit)
                    else
                        self.inGameUI.crosshairTweens[unit] = nil
                    end 
                end
                
                self.turnSystem.moveCounter = self.turnSystem.moveCounter + 1
                
                local teamUnits = 0
                for _, unit in ipairs(units) do
                    if unit.team == self.turnSystem:getCurrentPlayer().team then
                        teamUnits = teamUnits + 1
                    end
                end
            else
                -- Check if another unit of the same team is touched
                for _, unit in ipairs(units) do
                    if game:unitContainsPoint(unit, touch.x, touch.y) then
                        if unit.team == self.turnSystem:getCurrentPlayer().team then
                            self.inGameUI.selectedUnit = unit
                        elseif self.inGameUI:isAttackable(self.inGameUI.selectedUnit, unit) then
                            local attackCommand = AttackCommand(self.attackFunction, self.inGameUI.selectedUnit, unit)
                            self.invoker:executeCommand(attackCommand)
                            self.turnSystem.moveCounter = self.turnSystem.moveCounter + 1
                        end
                        break
                    end
                end
            end
            if self.turnSystem.moveCounter >= self.turnSystem.movesPerTurn then
                local nextTurnCommand = NextTurnCommand(self.turnSystem)
                self.invoker:executeCommand(nextTurnCommand)
            end
        else
            for _, unit in ipairs(units) do
                if game:unitContainsPoint(unit, touch.x, touch.y) and unit.team == self.turnSystem:getCurrentPlayer().team then
                    self.inGameUI.selectedUnit = unit
                    break
                end
            end
        end
    end
end
