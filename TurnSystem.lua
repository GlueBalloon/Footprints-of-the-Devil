TurnSystem = class()

function TurnSystem:init(players, movesPerTurn, timePerTurn)
    self.players = players
    self.movesPerTurn = movesPerTurn or 5
    self.currentPlayerIndex = 1
    self.moveCounter = 0
    self.timePerTurn = timePerTurn or 2
    self.timeRemaining = self.timePerTurn
    self.turnStartTime = os.clock()
    self.funcWhenTurnChanges = function() end
    self.turnChangeAnimationInProgress = false
end

function TurnSystem:update(deltaTime)
    if self.turnChangeAnimationInProgress then
        return
    end
    local timeElapsed = os.clock() - self.turnStartTime
    self.timeRemaining = self.timePerTurn - timeElapsed    
    if self.timeRemaining <= 0 then
        self:nextTurn()
    end
end

function TurnSystem:getCurrentPlayer()
    return self.players[self.currentPlayerIndex]
end

function TurnSystem:getCurrentTeam()
    return self.players[self.currentPlayerIndex].team
end

function TurnSystem:startTurn()
    local currentPlayer = self:getCurrentPlayer()
    print("Player " .. currentPlayer.id .. "'s turn")
end

-- Add a new function to reset the move counter
function TurnSystem:resetMoveCounter()
    self.moveCounter = 0
end

-- Modify the nextTurn function to reset the move counter
function TurnSystem:nextTurn()
    self.currentPlayerIndex = self.currentPlayerIndex % #self.players + 1
    self:resetMoveCounter()
    self.turnStartTime = os.clock()
    self.funcWhenTurnChanges()
    collectgarbage()
end

