-- helper functions
function table_contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Game
Game = class()

function Game:init()
    font("ArialRoundedMTBold")
    self.gameState = "inGame"
    -- local buttonHeight = (math.min(WIDTH, HEIGHT)) * 0.07
    local buttonHeight = 0
    local cellsPerSide = 9
    local sideSize = (math.min(WIDTH, HEIGHT)) * 0.95
    local mapX, mapY = (WIDTH - sideSize) * 0.5, (HEIGHT - sideSize + buttonHeight) * 0.5
    self.map = Map(mapX, mapY, sideSize, sideSize, cellsPerSide)
    local player1 = Player(1, "sapiens", color(143, 236, 67, 226))
    local aiPlayer = AIPlayer(2, "neanderthal", color(73, 218, 234, 222))
    if false then
        aiPlayer.logicModule = SimpleLogicModule()
    end
    self.players = {player1, aiPlayer}
    self.invoker = Invoker()
    self.turnSystem = TurnSystem(self.players, 5, 6, self.invoker)
    self.unitManager = UnitManager(self.players)
    self.inGameUI = InGameUI(self.map)
    self.turnSystem.funcWhenTurnChanges = function() 
        self.inGameUI.selectedUnit = nil
        self.turnSystem.turnChangeAnimationInProgress = true
        self.turnSystem.timeRemaining = self.turnSystem.timePerTurn
        self.inGameUI:announceTurn(self.turnSystem:getCurrentTeam())
    end
    self.endTurnChangeFunction = function()
        self.turnSystem.turnChangeAnimationInProgress = false
        self.turnSystem.turnStartTime = os.clock()
    end
    self.inGameUI.nextTurnAction = function()
        local nextTurnCommand = NextTurnCommand(self.turnSystem)
        self.invoker:executeCommand(nextTurnCommand)
    end
    self.inGameUI.isActiveTeam = function(team)
        return self.turnSystem:getCurrentTeam() == team
    end
    self.inGameUI.isCellOccupied = function(row, col)
        return self:isCellOccupied(self.unitManager.units, row, col)
    end
    self.attackFunction = function(attacker, target)
        self:attack(attacker, target)
    end
    self.touchedFunction = function(touch)
        self:touched(touch)
    end
    self.saveManager = SaveManager()
    self.unitManager.units = self:generateRandomUnits(7, 7)  
    local buttonMargin = sideSize * 0.0091 
    local bottomButtonWidth = (sideSize - buttonMargin) / 2
    local bottomButtonY = mapY - buttonHeight - buttonMargin
    local topButtonY = mapY + sideSize + buttonMargin
    self.turnIndicatorRect = vec4(mapX, bottomButtonY, bottomButtonWidth, buttonHeight)
    self.endTurnRect = vec4(mapX + bottomButtonWidth + buttonMargin, bottomButtonY, bottomButtonWidth, buttonHeight)
    self.movesLeftRect = vec4(mapX + (sideSize * 0.65) + buttonMargin, topButtonY, sideSize * 0.35, buttonHeight)
    self.turnSystem:nextTurn(self.players[1].team)
    self:defineGameQueries()
    aiPlayer.queries = self.queries
    self.inGameUI.queries = self.queries
end

function Game:defineGameQueries()
    local game = self
    self.queries = GameQueries()
    self.queries.getUnits = function() 
        return game.unitManager.units 
    end
    self.queries.getRowAndColumnFor = function(self, unit)
        return game.map:pointToCellRowAndColumn(unit.x, unit.y)
    end
    self.queries.getUnitAt = function(self, row, col) 
        return game:isCellOccupied(game.unitManager.units, row, col) 
    end
    self.queries.getCurrentPlayer = function(self) return game.turnSystem:getCurrentPlayer() end
    self.queries.getTeams = function(self) return game.unitManager:getTeams(team) end 
    self.queries.moveUnit = function(self, unit, row, col)
        local moveCommand = MoveCommand(game.map.rowColToPointFunction, unit, row, col)
        game.invoker:executeCommand(moveCommand)
    end    
    self.queries.attack = function(self, attacker, target)
        local attackCommand = AttackCommand(game.attackFunction, attacker, target)
        game.invoker:executeCommand(attackCommand)
    end
    self.queries.orthogonalCellsFor = function(self, row, col)
        return game.map:orthogonalCellsFor(row, col)
    end
    self.queries.endTurn = function(self)
        local nextTurnCommand = NextTurnCommand(game.turnSystem)
        game.invoker:executeCommand(nextTurnCommand)
    end
    self.queries.isFlanked = function(self, unit)
        return game:isFlanked(unit)
    end
    self.queries.attackableUnits = function(self, selectedUnit, units)
        if not selectedUnit then
            return
        end
        local selectedUnitAttackable = {}
        local otherAttackable = {}
        
        for _, unit in ipairs(units) do
            if unit.team ~= selectedUnit.team then
                if game.map:isAttackable(selectedUnit, unit) then
                    table.insert(selectedUnitAttackable, unit)
                else
                    for _, otherUnit in ipairs(units) do
                        if otherUnit ~= selectedUnit and otherUnit.team == selectedUnit.team and game.map:isAttackable(otherUnit, unit) then
                            table.insert(otherAttackable, unit)
                            break
                        end
                    end
                end
            end
        end
        return selectedUnitAttackable, otherAttackable
    end   
end

function Game:draw(deltaTime)
    if self.gameState == "inGame" then
        self.map:draw()
    end
    local turnPlayer = self.players[self.turnSystem.currentPlayerIndex]
    local tiRec, eRec = self.turnIndicatorRect, self.endTurnRect
    local mRec = self.movesLeftRect
    local movesLeft = self.turnSystem.movesPerTurn - self.turnSystem.moveCounter
    self.inGameUI:drawEndTurnButton(eRec.x, eRec.y, eRec.z, eRec.w)

    self.inGameUI:drawAllUnits(self.unitManager.units)
    self.inGameUI:drawBadgesAndAnimations()
    self.inGameUI:drawAnnouncement(turnPlayer.teamColor, self.endTurnChangeFunction)
    -- AI turn handling
    local aiPlayer = self.players[2]
    if self.queries:getCurrentPlayer().team == aiPlayer.team and
        aiPlayer.logicModule and not 
        self.turnSystem.turnChangeAnimationInProgress then
        local actNow = math.random(400) == 1
        if not aiPlayer.aiActionTime or 
        os.clock() - aiPlayer.aiActionTime > 0.6 or -- Wait
        actNow then 
            aiPlayer.aiActionTime = os.clock()
            
            local actionTaken = aiPlayer.logicModule:decideAction(aiPlayer.queries)
            
            if not actionTaken then
                aiPlayer.queries:endTurn()
            else
                self:advanceMoveCounter()
            end 
        end
    end
    self.inGameUI.animation:update(DeltaTime)
   -- self.inGameUI.animation:drawArrows()
    self.inGameUI:draw(self.unitManager.units)
    self.turnSystem:update(deltaTime)
    self.inGameUI:drawTimeLeft(self.turnSystem.timeRemaining)
    self.inGameUI:drawMovesLeft(movesLeft)
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
        target.strength = math.max(0, target.strength - attacker.strength)
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
                print("found flanked unit: ", flankedStatus)
                flankingSapiens = flankingSapiens + 1
            end
        end
    end
    
    local flankedStatus = flankingSapiens >= 2
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
            row = math.random(2, self.map.gridSize - 1)
            col = math.random(2, math.floor(self.map.gridSize / 2))
            if not self:isCellOccupied(units, row, col) then
                break
            end
        end
        unitX, unitY = self.map:cellRowAndColumnToPoint(row, col)
        local tColor = self.players[1].teamColor
        local uColor = color(tColor.r, tColor.g, tColor.b, 24)
        table.insert(units, Unit(self.players[1].team, 3, unitX, unitY, uColor, self.inGameUI.sapiensIcon))
    end
    
    for i = 1, neanderthalCount do
        while true do
            row = math.random(2, self.map.gridSize - 1)
            col = math.random(math.ceil(self.map.gridSize / 2) + 1, self.map.gridSize - 1)
            if not self:isCellOccupied(units, row, col) then
                break
            end
        end
        unitX, unitY = self.map:cellRowAndColumnToPoint(row, col)
        local tColor = self.players[2].teamColor
        local uColor = color(tColor.r, tColor.g, tColor.b, 24)
        table.insert(units, Unit(self.players[2].team, 7, unitX, unitY, uColor, self.inGameUI.neanderthalIcon))
    end
    
    return units
end

function Game:isCellOccupied(units, row, col)
    for _, unit in ipairs(units) do
        local unitRow, unitCol = self.map:pointToCellRowAndColumn(unit.x, unit.y)
        if row == unitRow and col == unitCol then
            return unit
        end
    end
    return false
end

function Game:advanceMoveCounter()
    self.turnSystem.moveCounter = self.turnSystem.moveCounter + 1
    if self.turnSystem.moveCounter >= self.turnSystem.movesPerTurn then
        local nextTurnCommand = NextTurnCommand(self.turnSystem)
        self.invoker:executeCommand(nextTurnCommand)
    end
end

--[[
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
                        self.inGameUI:drawCrosshairsOn(unit, true)
                    else
                        self.inGameUI.animation.crosshairTweens[unit] = nil
                    end 
                end
                
                self:advanceMoveCounter()
            else
                -- Check if another unit of the same team is touched
                for _, unit in ipairs(units) do
                    if game:unitContainsPoint(unit, touch.x, touch.y) then
                        if unit.team == self.turnSystem:getCurrentPlayer().team then
                            self.inGameUI.selectedUnit = unit
                        elseif self.inGameUI:isAttackable(self.inGameUI.selectedUnit, unit) then
                            local attackCommand = AttackCommand(self.attackFunction, self.inGameUI.selectedUnit, unit)
                            self.invoker:executeCommand(attackCommand)
                            self:advanceMoveCounter()
                        end
                        break
                    end
                end
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
]]

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
                    if self.map:isAttackable(self.inGameUI.selectedUnit, unit) then
                        self.inGameUI.animation:addCrosshairAnimation(unit, true)
                    else
                        self.inGameUI.animation.crosshairTweens[unit] = nil
                    end 
                end
                
                self:advanceMoveCounter()
            else
                -- Check if another unit of the same team is touched
                for _, unit in ipairs(units) do
                    if game:unitContainsPoint(unit, touch.x, touch.y) then
                        if unit.team == self.turnSystem:getCurrentPlayer().team then
                            self.inGameUI.selectedUnit = unit
                        elseif self.map:isAttackable(self.inGameUI.selectedUnit, unit) then
                            local attackCommand = AttackCommand(self.attackFunction, self.inGameUI.selectedUnit, unit)
                            self.invoker:executeCommand(attackCommand)
                            self:advanceMoveCounter()
                        end
                        break
                    end
                end
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

