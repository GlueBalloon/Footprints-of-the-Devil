TurnSystem = class()

function TurnSystem:init(players, movesPerTurn, timePerTurn, invoker)
    self.players = players
    self.movesPerTurn = movesPerTurn or 8
    self.currentPlayerIndex = 1
    self.moveCounter = 0
    self.timePerTurn = timePerTurn or 2
    self.timeRemaining = self.timePerTurn
    self.turnStartTime = os.clock()
    self.funcWhenTurnChanges = function() end
    self.turnChangeAnimationInProgress = false
    self.invoker = invoker
end

function TurnSystem:update(deltaTime)
    if self.turnChangeAnimationInProgress then
        return
    end
    local timeElapsed = os.clock() - self.turnStartTime
    self.timeRemaining = self.timePerTurn - timeElapsed    
    if self.timeRemaining <= 0 then
        local nextTurnCommand = NextTurnCommand(self)
        self.invoker:executeCommand(nextTurnCommand)
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

-- Modify the nextTurn function to reset the move counter
function TurnSystem:nextTurn(team)
    if team then
        for i, player in ipairs(self.players) do
            if player.team == team then
                self.currentPlayerIndex = i
                break
            end
        end
    else
        self.currentPlayerIndex = self.currentPlayerIndex % #self.players + 1
    end
    self.moveCounter = 0
    self.funcWhenTurnChanges()
    collectgarbage()
end
