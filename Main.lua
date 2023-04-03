-- Footprints Of The Devil

function setup()
    viewer.mode = OVERLAY
    parameter.boolean("show3D", true)
    parameter.watch("selected")
     
    rows = 10
    columns = 10
    cellSize = 50
    
    gridData = GridData(rows, columns)
    gridData:placeUnitData(Unit(), 2,7)
    
    grid2D = Grid2D(gridData, cellSize)
    grid3D = Grid3D(gridData, 4)
    
    gridData:placeUnitData(Unit(), 5, 5)
    scene = grid3D.scene    

    -- Run the test
    -- testGridData()
    
    -- Load the texture and create the material
    local customTexture = readImage(asset.builtin.SpaceCute.Beetle_Ship)
    local customMaterial = craft.material(asset.builtin.Materials.Standard)
    customMaterial.map = customTexture
    customMaterial.blendMode = NORMAL
    customMaterial.opacity = 1.0
    
    -- Create two overlapping transparent planes that resemble box sides
    plane1 = createTransparentPlane(vec3(0, 0, -0.5), customMaterial, scene, quat.eulerAngles(90, 0, 0))
    plane2 = createTransparentPlane(vec3(-0.5, 0, 0), customMaterial, scene, quat.eulerAngles(90, 90, 0))
end




function createTransparentPlane(position, material, scene, rotation)
    local planeEntity = scene:entity()
    local model = craft.model.plane(vec2(1, 1))
    local renderer = planeEntity:add(craft.renderer, model)
    renderer.material = material
    planeEntity.position = position
    planeEntity.rotation = rotation
    return planeEntity
end

function update(dt)
    -- Calculate the distance to the camera for each plane
    local cameraPosition = scene.camera:get(craft.camera).entity.position
    local distance1 = (plane1.position - cameraPosition):len()
    local distance2 = (plane2.position - cameraPosition):len()
    
    -- Set the render order based on the distance
    if distance1 > distance2 then
        plane1:get(craft.renderer).renderOrder = 1
        plane2:get(craft.renderer).renderOrder = 0
    else
        plane1:get(craft.renderer).renderOrder = 0
        plane2:get(craft.renderer).renderOrder = 1
    end
end


function createTransparentPlane(position, material, scene)
    local planeEntity = scene:entity()
    local model = craft.model.plane(vec2(1, 1))
    local renderer = planeEntity:add(craft.renderer, model)
    renderer.material = material
    planeEntity.position = position
    return planeEntity
end

function draw()
    background(40, 40, 50)
    if not show3D then
        grid2D:draw()
        grid2D:touched(CurrentTouch)
    else
        grid3D:draw(DeltaTime)
    end
    selected = tostring(gridData.selectedR).." "..tostring(gridData.selectedC)
    -- Calculate the distance to the camera for each plane
    local cameraPosition = scene.camera:get(craft.camera).entity.position
    local distance1 = (plane1.position - cameraPosition):len()
    local distance2 = (plane2.position - cameraPosition):len()
    
    -- Set the render order based on the distance
    if distance1 > distance2 then
        plane1:get(craft.renderer).renderOrder = 1
        plane2:get(craft.renderer).renderOrder = 0
    else
        plane1:get(craft.renderer).renderOrder = 0
        plane2:get(craft.renderer).renderOrder = 1
    end
end

function touched(touch)
    if not show3D then
        grid2D:touched(touch)
    else
        grid3D:touched(touch)
    end 
end
