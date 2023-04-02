
Grid3D = class(GridIO)

function Grid3D:init(gridData, cellSize)
    GridIO.init(self, gridData, cellSize)
    self.selectedCellEntity = nil
    self.cellSelectionColor = color(164, 236, 67, 144)
end

function Grid3D:setupGrid()
    self.defaultCellImage = readImage(asset.builtin.Blocks.Trunk_White_Top)
    self.scene = craft.scene()
    self:makeGridEntities()
    self:setupCamera()
end

function Grid3D:makeGridEntities()
    self.tiles = {}
    for r = 1, self.gridData.rows do
        for c = 1, self.gridData.columns do
            
            local x = (c - self.gridData.columns) * -self.cellSize
            local z = (self.gridData.rows - r) * self.cellSize   
            
            local cellEntity = self.scene:entity()
            cellEntity.position = vec3(x, 0, z)
            
            if r == 1 then
               -- local plane = createFourPlanesModel(2, self.scene)
               -- plane.position = cellEntity.position
              --  local newCube = createTransparentCube(self.cellSize * 0.9, self.scene)
                -- newCube.position = cellEntity.position
                -- Position the cube on the grid
                local unitSize = self.cellSize * 0.87
             --   newCube.position = vec3(cellEntity.position.x * self.cellSize, cellEntity.position.y * self.cellSize - size * 1.15 / 2, cellEntity.position.z * self.cellSize)
                -- Create the transparent cube
                local parentOfCube = createTransparentCube(unitSize, cellEntity.position, self.scene)
                
                -- Position the cube in the cell
                local halfHeight = unitSize * 1.15 / 2
                parentOfCube.position = vec3(cellEntity.position.x, cellEntity.position.y + halfHeight, cellEntity.position.z)
                
            end
            if r == 2 then
                createOpenCube(2, cellEntity.position, self.scene)
            end
            
            local cellModel = craft.model.cube(vec3(self.cellSize, 0.1, self.cellSize))
            cellEntity:add(craft.renderer, cellModel)
            cellEntity.material = craft.material(asset.builtin.Materials.Specular)
            cellEntity.material.map = self.defaultCellImage
            
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

function Grid3D:draw(deltaTime)
    self.scene:draw()
    self.scene:update(deltaTime)
    self:update()
end

function Grid3D:update()
    local r, c = self:selectedCoords()
    if (r and c) then
        self:updateSelectionVisuals(r, c)
    end
end

function Grid3D:applySelectedCellEffect(r, c)
    local cell = self:getCellEntity(r, c)
    if cell == self.selectedCellEntity then
        return
    elseif self.selectedCellEntity ~= nil then
        self:clearSelectedCellEffect(self.selectedCellEntity)      
    end
    self.selectedCellEntity = cell
    local cellRenderer = cell:get(craft.renderer)
    cellRenderer.material.diffuse = self.cellSelectionColor
end

function Grid3D:clearSelectedCellEffect(entity)
    if not entity then
        return
    else
        entity.material = craft.material(asset.builtin.Materials.Specular)
        entity.material.map = self.defaultCellImage
        entity:get(craft.renderer).material.diffuse = color(255, 255, 255)
    end
end

function Grid3D:getCellEntity(r, c)
    local cellIndex = (r - 1) * self.gridData.columns + c
    return self.tiles[cellIndex]
end

function Grid3D:rowAndColumnFromPoint(point)
    local origin, direction = self.orbitViewer.camera:screenToRay(vec2(point.x, point.y))
    local hit = self.scene.physics:raycast(origin, direction, 2000)    
    if hit and hit.entity then
        local r = self.gridData.rows - math.floor((hit.point.z + self.cellSize / 2) / self.cellSize)
        local c = self.gridData.columns - math.floor((hit.point.x + self.cellSize / 2) / self.cellSize)
        
        self.gridData.selectedR = nil
        self.gridData.selectedC = nil
        
        if r and c then
            self.gridData.selectedR = r
            self.gridData.selectedC = c
        end
        
        if r >= 1 and r <= self.gridData.rows and c >= 1 and c <= self.gridData.columns then
            return r, c
        else
            return nil, nil
        end
    end
end

function Grid3D:touched(touch)
    self.orbitViewer:touched(touch)
    GridIO.touched(self, touch)
end
--[[
Grid3D = class()

function Grid3D:init(gridData, cellSize)
    -- Capture parameters
    self.gridData = gridData
    self.cellSize = cellSize
    
    -- Set up the scene and the camera
    self.scene = craft.scene()
    
    -- Create the grid
    self.tiles = self:createGrid()
    
    -- set up entities
    self.entities = {}
    self:updateEntities()
    
    -- Prepare piece moving
    self.selectedCell = nil
    
    -- Calculate grid dimensions
    self.width = gridData.columns * cellSize
    self.height = gridData.rows * cellSize
    
    -- Set up camera
    local camX = self.width / 2
    local camY = self.height * 1.5 -- Position the camera above the grid
    local camZ = self.width / 1.5
    
    local targetX = self.width / 2
    local targetY = 0
    local targetZ = self.height / 2
    
    self.orbitViewer = self.scene.camera:add(OrbitViewer, vec3(camX, camY, camZ), 90, 0, 1000)
    self.orbitViewer.target = vec3(targetX, targetY, targetZ)
    
    -- Set camera direction
    self.orbitViewer.rx = 45 -- Point the camera downwards
    self.orbitViewer.ry = 0
    
    self.draggingUnit = nil
    self.originalUnitPosition = nil
end

function Grid3D:createGrid()
    local tiles = {}
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
            
            table.insert(tiles, cellEntity)
        end
    end
    return tiles
end

function Grid3D:entityForUnit(unit)
    local cube = self.scene:entity()
    local unitSize = self.cellSize * 0.6
    cube:add(craft.renderer, craft.model.cube(vec3(unitSize, unitSize, unitSize)))
    cube:get(craft.renderer).material = craft.material(asset.builtin.Materials.Standard)
    cube:get(craft.renderer).material.map = unit.icon
    cube.collisionMask = 1
    return cube
end

function Grid3D:updateEntities()
    for r = 1, self.gridData.rows do
        for c = 1, self.gridData.columns do
            local cell = self.gridData:getCell(r, c)
            local unit = cell:getContent(Content.UNIT)
            local cellEntity = self:getCellEntity(r, c)
            
            if unit and not cellEntity.unitEntity then
                print(unit)
                local unitEntity = self:entityForUnit(unit)
                unitEntity.position = cellEntity.position + vec3(0, self.cellSize * 0.35, 0)
                -- Add the unitEntity to the cellEntity
                cellEntity.unitEntity = unitEntity
                self.entities[unit.id] = unitEntity
            elseif not unit and cellEntity.unitEntity then
                -- Remove the unitEntity from the cellEntity
                cellEntity.unitEntity:destroy()
                cellEntity.unitEntity = nil
            end
        end
    end
end


function Grid3D:draw()
    if self.gridData.selectedR and self.gridData.selectedC then
        local cellCheck = self:getCellEntity(self.gridData.selectedR, self.gridData.selectedC)
        if cellCheck then
            if cellCheck ~= self.selectedCell then
                self:resetSelectedCell()
                self.selectedCell = cellCheck
                self:highlightSelectedCell()
            end
        end
    else
        self:resetSelectedCell()
        self.selectedCell = nil
    end
    self:updateEntities()
    self.scene:draw()
end

function Grid3D:update(dt)
    self.scene:update(dt)
    for _, entity in pairs(self.entities) do
        local currentEulerAngles = entity.eulerAngles
        entity.eulerAngles = currentEulerAngles + vec3(0, 1, 0) -- Rotate the cubes for a dynamic look
    end
end

function Grid3D:touched(touch)
    if not self.draggingUnit then
        grid3D.orbitViewer:touched(touch)
    end
    if CurrentTouch.state == BEGAN then
        grid3D:touchPressed(CurrentTouch)
    elseif CurrentTouch.state == CHANGED then
        self:touchMoved(touch)
    elseif CurrentTouch.state == ENDED or CurrentTouch.state == CANCELLED then
        grid3D:touchReleased(CurrentTouch)
    end
end

function Grid3D:touchPressed(touch)
    local origin, direction = self.orbitViewer.camera:screenToRay(vec2(touch.x, touch.y))
    local hit = self.scene.physics:raycast(origin, direction, 2000)    
    if hit and hit.entity then
        local r, c = self:worldToGrid(hit.point)
        if r and c then
            self.gridData.selectedR = r
            self.gridData.selectedC = c
        else
            -- Deselect the cell when tapping outside the grid
            self.gridData.selectedR = nil
            self.gridData.selectedC = nil
        end
    else 
        -- Deselect the cell when tapping outside the grid
        self.gridData.selectedR = nil
        self.gridData.selectedC = nil
    end
    print("pressed: ", self.gridData.selectedR, self.gridData.selectedC)
    
    local cell = self.gridData:getCell(self.gridData.selectedR, self.gridData.selectedC)
    if not cell then
        return
    end
    local unit = cell:getContent(Content.UNIT)
    if unit then
        self.draggingUnit = self.entities[unit.id]
        self.originalUnitPosition = self.draggingUnit.position
        -- Change the unit's elevation when picked up
        self.draggingUnit.position = self.draggingUnit.position + vec3(0, self.cellSize * 0.5, 0)
    end
end


function Grid3D:touchMoved(touch)
if self.draggingUnit then
local origin, direction = self.orbitViewer.camera:screenToRay(vec2(touch.x, touch.y))
local planeNormal = vec3(0, 1, 0) -- Upwards direction
local planePoint = vec3(0, 0.6 * self.cellSize, 0) -- A point on the invisible plane
local denom = direction:dot(planeNormal)
local t = (planePoint - origin):dot(planeNormal) / denom
local newPos = origin + t * direction
self.draggingUnit.position = newPos
end
end

function Grid3D:touchReleased(touch)
    if self.draggingUnit then
        local origin, direction = self.orbitViewer.camera:screenToRay(vec2(touch.x, touch.y))
        local hit = self.scene.physics:raycast(origin, direction, 2000)
        local releasedOnValidCell = false
        if hit and hit.entity then
            local r, c = self:worldToGrid(hit.point)
            if r and c then
                local movedSuccessfully = self.gridData:moveUnit(self.gridData.selectedR, self.gridData.selectedC, r, c)
                if movedSuccessfully then
                    releasedOnValidCell = true
                end
            end
        end
        if not releasedOnValidCell then
            self.draggingUnit.position = self.originalUnitPosition
        end
        self.draggingUnit = nil
        self.originalUnitPosition = nil
    end
end

function Grid3D:highlightSelectedCell()
    if self.selectedCell then     
        print(self.selectedCell)   
        self.selectedCell:get(craft.renderer).material.diffuse = color(0, 255, 0)
    end
end

function Grid3D:resetSelectedCell()
    if self.selectedCell then        
        self.selectedCell.material = craft.material(asset.builtin.Materials.Specular)
        self.selectedCell.material.map = readImage(asset.builtin.Blocks.Glass)
        self.selectedCell:get(craft.renderer).material.diffuse = color(255, 255, 255)
    end
end

function Grid3D:worldToGrid(worldPos)
    if worldPos then
        local r = self.gridData.rows - math.floor((worldPos.z + self.cellSize / 2) / self.cellSize)
        local c = self.gridData.columns - math.floor((worldPos.x + self.cellSize / 2) / self.cellSize)
        
        if r >= 1 and r <= self.gridData.rows and c >= 1 and c <= self.gridData.columns then
            return r, c
        else
            return nil, nil
        end
    else
        return nil, nil
    end
end

function Grid3D:getCellEntity(r, c)
    local cellIndex = (r - 1) * self.gridData.columns + c
    return self.tiles[cellIndex]
end
]]