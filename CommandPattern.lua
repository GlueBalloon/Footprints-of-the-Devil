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

function MoveCommand:init(game, unit, row, col)
    Command.init(self)
    self.game = game
    self.unit = unit
    self.row = row
    self.col = col
end

function MoveCommand:execute()
    local unitX, unitY = self.game.map:cellRowAndColumnToPoint(self.row, self.col)
    self.unit.x = unitX
    self.unit.y = unitY
end


AttackCommand = class(Command)

function AttackCommand:init(game, attacker, target)
    Command.init(self)
    self.game = game
    self.attacker = attacker
    self.target = target
end

function AttackCommand:execute()
    print("AttackCommand:execute()")
    self.game:attack(self.attacker, self.target)
end