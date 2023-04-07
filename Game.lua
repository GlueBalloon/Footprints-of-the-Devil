
-- Game
Game = class()

function Game:init()
    self.gameState = "inGame"
    local cellsPerSide = 10
    local sideSize = (math.min(WIDTH, HEIGHT)) * 0.87
    local mapX, mapY = (WIDTH - sideSize) * 0.5, (HEIGHT - sideSize) * 0.5
    self.map = Map(mapX, mapY, sideSize, sideSize, cellsPerSide)
    local player1 = Player(1, "sapiens")
    local aiPlayer = AIPlayer(2, "neanderthal")
    self.players = {player1, aiPlayer}
    self.turnSystem = TurnSystem(self.players)
    self.unitManager = UnitManager(self.players)
    self.inGameUI = InGameUI(self.map)
    self.saveManager = SaveManager()
    self.unitManager.units = self:generateRandomUnits(5, 5)   
end

function Game:update()
    if self.gameState == "inGame" then
        self.map:update()
    end
end

function Game:draw()
    if self.gameState == "inGame" then
        self.map:draw()
    end
    self.inGameUI:draw(self.unitManager:getUnits())
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
        _ = color(143, 236, 67, 226)
        table.insert(units, Unit("sapiens", 5, unitX, unitY, color(143, 236, 67, 24)))
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
        _ = color(236, 67, 143, 222)
        table.insert(units, Unit("neanderthal", 7, unitX, unitY, color(236, 67, 117, 29)))
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


