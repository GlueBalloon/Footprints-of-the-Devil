TurnSystem = class()

function TurnSystem:init(players)
    self.players = players
    self.currentPlayerIndex = 1
    self.moveCounter = 0
end

-- Add a new function to reset the move counter
function TurnSystem:resetMoveCounter()
    self.moveCounter = 0
end

function TurnSystem:getCurrentPlayer()
    return self.players[self.currentPlayerIndex]
end

function TurnSystem:startTurn()
    local currentPlayer = self:getCurrentPlayer()
    print("Player " .. currentPlayer.id .. "'s turn")
end

-- Add a new function to reset the move counter
function TurnSystem:resetMoveCounter()
    self.moveCounter = 0
end

-- Modify the endTurn function to reset the move counter
function TurnSystem:endTurn()
    self.currentPlayerIndex = self.currentPlayerIndex % #self.players + 1
    self:resetMoveCounter()
end

