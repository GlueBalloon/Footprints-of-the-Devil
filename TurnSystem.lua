TurnSystem = class()

function TurnSystem:init(players)
    self.players = players
    self.currentPlayerIndex = 1
end

function TurnSystem:getCurrentPlayer()
    return self.players[self.currentPlayerIndex]
end

function TurnSystem:endTurn()
    self.currentPlayerIndex = self.currentPlayerIndex + 1
    if self.currentPlayerIndex > #self.players then
        self.currentPlayerIndex = 1
    end
    self:startTurn()
end

function TurnSystem:startTurn()
    local currentPlayer = self:getCurrentPlayer()
    print("Player " .. currentPlayer.id .. "'s turn")
    if currentPlayer.takeTurn then
        currentPlayer:takeTurn(map.units, map)
        self:endTurn()
    end
end
