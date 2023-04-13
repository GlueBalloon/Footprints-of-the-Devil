Invoker  = class()

function Invoker :init()
    self.history = {}
end

function Invoker:executeCommand(command)
    command:execute()
    table.insert(self.history, command)
end



Command = class()

function Command:init(receiver)
    self.receiver = receiver
end

function Command:execute()
    -- overridden in concrete command classes
end



MoveCommand = class(Command)

function MoveCommand:init(rowAndColumnConverter, unit, row, col)
    Command.init(self)
    self.rowAndColumnConverter = rowAndColumnConverter
    self.unit = unit
    self.row = row
    self.col = col
end

function MoveCommand:execute()
    local unitX, unitY = self.rowAndColumnConverter(self.row, self.col)
    self.unit.x = unitX
    self.unit.y = unitY
end



AttackCommand = class(Command)

function AttackCommand:init(attackFunction, attacker, target)
    Command.init(self)
    self.attackFunction = attackFunction
    self.attacker = attacker
    self.target = target
end

function AttackCommand:execute()
    print("AttackCommand:execute()")
    self.attackFunction(self.attacker, self.target)
end



NextTurnCommand = class(Command)

function NextTurnCommand:init(turnSystem, team)
    Command.init(self)
    self.turnSystem = turnSystem
    self.team = team
end

function NextTurnCommand:execute()
    self.turnSystem:nextTurn(self.team)
end



TouchInputCommand = class()

function TouchInputCommand:init(touch, touchedFunction)
    self.touchedFunction = touchedFunction
    self.touch = touch
end

function TouchInputCommand:execute()
    self.touchedFunction(self.touch)
end
