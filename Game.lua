
-- Game
Game = class()

function Game:init()
    font("ArialRoundedMTBold")
    self.gameState = "inGame"
    local cellsPerSide = 10
    local sideSize = (math.min(WIDTH, HEIGHT)) * 0.74
    local mapX, mapY = (WIDTH - sideSize) * 0.5, (HEIGHT - sideSize) * 0.5
    self.map = Map(mapX, mapY, sideSize, sideSize, cellsPerSide)
    local player1 = Player(1, "sapiens", color(143, 236, 67, 226))
    local aiPlayer = AIPlayer(2, "neanderthal", color(233, 77, 224, 222))
    self.players = {player1, aiPlayer}
    self.turnSystem = TurnSystem(self.players, 6)
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
        self.turnSystem:nextTurn()
    end
    self.inGameUI.isActiveTeam = function(team)
        return self.turnSystem:getCurrentTeam() == team
    end
    self.saveManager = SaveManager()
    self.unitManager.units = self:generateRandomUnits(5, 5)   
    self.turnIndicatorRect = vec4(mapX, mapY * 0.45, sideSize * 0.49, mapY * 0.45)
    self.endTurnRect = vec4(mapX + sideSize - (sideSize * 0.49), mapY * 0.45, sideSize * 0.49, mapY * 0.45)
    self.timeLeftRect = vec4(mapX, (mapY * 1.1) + sideSize, sideSize * 0.65, mapY * 0.65)
end

function Game:draw(deltaTime)
    if self.gameState == "inGame" then
        self.map:draw()
    end
    local turnPlayer = self.players[self.turnSystem.currentPlayerIndex]
    local tiRec, eRec, tlRec = self.turnIndicatorRect, self.endTurnRect, self.timeLeftRect
    self.inGameUI:drawTurnIndicator(tiRec.x, tiRec.y, tiRec.z, tiRec.w, turnPlayer.team, turnPlayer.teamColor)
    self.inGameUI:drawEndTurnButton(eRec.x, eRec.y, eRec.z, eRec.w)
    self.inGameUI:drawTimeLeft(tlRec.x, tlRec.y, tlRec.z, tlRec.w, self.turnSystem.timeRemaining)
    self.inGameUI:drawUnitStatsPanel(10, 130, 200, 100, self.inGameUI.selectedUnit)
    self.inGameUI:drawAllUnits(self.unitManager.units)
    self.inGameUI:drawAnnouncement(turnPlayer.teamColor, self.endTurnChangeAnimation)
    self.turnSystem:update(deltaTime)
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
            col = math.random(2, math.floor(self.map.gridSize / 2) - 1)
            if not self:isCellOccupied(units, row, col) then
                break
            end
        end
        unitX, unitY = self.map:cellRowAndColumnToPoint(row, col)
        local tColor = self.players[1].teamColor
        local uColor = color(tColor.r, tColor.g, tColor.b, 24)
        table.insert(units, Unit(self.players[1].team, 5, unitX, unitY, uColor, asset.Sapiens))
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


