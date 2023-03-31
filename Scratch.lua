--[[
 Grid3D = class()

function Grid3D:init(gridData, cellSize)
    -- Capture parameters
    self.gridData = gridData
    self.cellSize = cellSize
    
    -- Set up the grid and camera
    self:setupGrid()
    
    -- Initialize other variables
    self.selectedCell = nil
    self.draggingUnit = nil
    self.originalUnitPosition = nil
end

-- Set up the grid and camera
function Grid3D:setupGrid()
    -- Set up the scene
    self.scene = craft.scene()
    
    -- Create the grid
    self:createGrid()
    
    -- Set up the camera
    self:setupCamera()
end

function Grid3D:createGrid()
    self.tiles = {}
    for r = 1, self.gridData.rows do
        for c = 1, self.gridData.columns do
            
            local x = (c - self.gridData.columns) * -self.cellSize
            local z = (self.gridData.rows - r) * self.cellSize   
            
            local cellEntity = self.scene:entity()
            cellEntity.position = vec3(x, 0, z)
            
            local cellModel = craft.model.cube(vec3(self.cellSize, 0.1, self.cellSize))
            cellEntity:add(craft.renderer, cellModel)
            cellEntity.material = craft.material(asset.builtin.Materials.Specular)
            cellEntity.material.map = readImage(asset.builtin.Blocks.Glass)
            
            -- Add a physics body to the cell entity
            cellEntity:add(craft.rigidbody, STATIC)
            cellEntity:add(craft.shape.box, vec3(self.cellSize, 0.1, self.cellSize))
            cellEntity.collisionMask = 1
            
            table.insert(self.tiles, cellEntity)
        end
    end
end

-- Set up camera
function Grid3D:setupCamera()
    local width, height = self.gridData.columns * self.cellSize, self.gridData.rows * self.cellSize
    self.orbitViewer = self.scene.camera:add(OrbitViewer, vec3(width / 2, height * 1.5, width / 1.5), 45, 0, 1000)
    self.orbitViewer.target = vec3(width / 2, 0, height / 2)
    self.orbitViewer.rx, self.orbitViewer.ry = 45, 0
end

-- The draw function
function Grid3D:draw(deltaTime)
    self.scene:draw()
    self.scene:update(deltaTime)
end

-- The touched function
function Grid3D:touched(touch)
    grid3D.orbitViewer:touched(touch)
end
]]