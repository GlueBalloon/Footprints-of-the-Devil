



    
function createOpenCube(size, position, scene)
--[[
    local cube = scene:entity()
    cube.position = position
    local mesh = createDoubleSidedOpenCubeMesh(size)
    cube.model = craft.model(mesh)
    cube.material = craft.material(asset.builtin.Materials.Standard)
    return cube
]]
    local cube = scene:entity()
    cube.position = position
    cube.model = createBoxSides(size)
    cube.material = craft.material(asset.builtin.Materials.Standard)
    return cube
end
--[[
function createDoubleSidedPlane(size)
    local m = craft.model()
    
    local positions = {
        vec3(-size / 2, -size / 2, 0),
        vec3(-size / 2, size / 2, 0),
        vec3(size / 2, size / 2, 0),
        vec3(size / 2, -size / 2, 0),
        
        vec3(size / 2, -size / 2, 0),
        vec3(size / 2, size / 2, 0),
        vec3(-size / 2, size / 2, 0),
        vec3(-size / 2, -size / 2, 0)
    }
    
    local normals = {
        vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1),
        vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1)
    }
    
    local uvs = {
        vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0),
        vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0)
    }
    
    local colors = {}
    local c = color(255, 255, 255, 255)
    for i = 1, 8 do
        table.insert(colors, c)
    end
    
    local indices = {1, 2, 3, 1, 3, 4, 5, 6, 7, 5, 7, 8}
    
    m.positions = positions
    m.normals = normals
    m.uvs = uvs
    m.colors = colors
    m.indices = indices
    
    return m
end

    
function createPlane(scene)
    local planeEntity = scene:entity()
    planeEntity.position = vec3(0, 0, 0)
    
    local planeModel = craft.model.plane(vec2(1, 1))
    planeEntity:add(craft.renderer, planeModel)
    planeEntity.material = craft.material(asset.builtin.Materials.Specular)
    planeEntity.material.diffuse = color(255, 255, 255)
    return planeEntity
end
    
function createFourPlanesModel(cellSize, scene)
    
    local cellEntity = scene:entity()
    cellEntity.position = vec3(1, 0, 1)
    
    local planeModel = craft.model.plane(vec2(cellSize, cellSize))
    
    -- Create four planes
    local planes = {}
    for i = 1, 4 do
        local plane = scene:entity()
        plane:add(craft.renderer, planeModel)
        plane.material = craft.material(asset.builtin.Materials.Specular)
        plane.material.diffuse = color(255, 255, 255)
        plane.parent = cellEntity
        planes[i] = plane
    end
    
    -- Rotate and position planes to create vertical faces
    planes[1].rotation = quat.eulerAngles(0, 90, 0) -- Right
    planes[2].rotation = quat.eulerAngles(0, -90, 0) -- Left
    planes[3].rotation = quat.eulerAngles(0, 0, 0) -- Front
    planes[4].rotation = quat.eulerAngles(0, 180, 0) -- Back
    
    return cellEntity
end




-- Custom transparent cube
function createTransparentCube(position, scene)
    local cube = scene:entity()
    cube.position = position
    
    local model = craft.model.cube(vec3(1, 1, 1))
    -- local model = createVerticalFacesModel()
    local renderer = cube:add(craft.renderer, model)
    
    -- Load custom texture (replace with your own texture asset)
    local customTexture = readImage(asset.builtin.SpaceCute.Background)
    
    -- Create a custom material
    local customMaterial = craft.material(asset.builtin.Materials.Standard)
    customMaterial.map = customTexture
    customMaterial.blendMode = NORMAL
    customMaterial.opacity = 1.0
    
    -- Apply the custom material to the cube
    renderer.material = customMaterial
    
    -- Create a custom shader to handle transparency
    local customShader = shader(asset.builtin.Materials.Basic)
    customShader.blendMode = NORMAL
    renderer.shader = customShader
    
    -- Add a rigid body for physics simulation
    cube:add(craft.rigidbody, STATIC)
    cube:add(craft.shape.box, vec3(1, 1, 1))
end

]]
-- Custom transparent cube
function createTransparentCube(size, position, scene)
    
    -- Create a custom material
    local customTexture = readImage(asset.builtin.SpaceCute.Beetle_Ship)
    local customMaterial = craft.material(asset.builtin.Materials.Standard)
    customMaterial.map = customTexture
    customMaterial.blendMode = NORMAL
    customMaterial.opacity = 1.0

    -- Create a custom shader to handle transparency
    local customShader = shader(asset.builtin.Materials.Basic)
    customShader.blendMode = NORMAL
    
    local planes = {}
    local parentOfCube = scene:entity()
    local halfSize = 0.5 -- half the size of the cube's side length
    for i = 1, 4 do
        local planeEntity = scene:entity()
        local model = craft.model.plane(vec2(1, 1.15))
        local renderer = planeEntity:add(craft.renderer, model)
        renderer.shader = customShader
        renderer.material = customMaterial
        planeEntity.parent = parentOfCube
        planes[i] = planeEntity
    end
    
    parentOfCube.position = position
    
    -- Position and rotation adjustments
    planes[1].position = vec3(0, 0, -halfSize) -- Back
    planes[1].rotation = quat.eulerAngles(-90, 0, 0)
    
    planes[2].position = vec3(-halfSize, 0, 0) -- Right
    planes[2].rotation = quat.eulerAngles(-90, 90, 0)
    
    planes[3].position = vec3(0, 0, halfSize) -- Front
    planes[3].rotation = quat.eulerAngles(-90, 180, 0)
    
    planes[4].position = vec3(halfSize, 0, 0) -- Left
    planes[4].rotation = quat.eulerAngles(-90, 270, 0)
      
end



--[[
-- Custom transparent cube
function createTransparentCube(position, scene)
    local cube = scene:entity()
    cube.position = position
    
    local model = createVerticalFacesModel()
    local renderer = cube:add(craft.renderer, model)
    
    -- Load custom texture (replace with your own texture asset)
    local customTexture = readImage(asset.builtin.SpaceCute.Background)
    
    -- Create a custom material
    local customMaterial = craft.material(asset.builtin.Materials.Standard)
    customMaterial.map = customTexture
    customMaterial.blendMode = NORMAL
    customMaterial.opacity = 1.0
    
    -- Apply the custom material to the cube
   -- renderer.material = customMaterial
    
    -- Add a rigid body for physics simulation
    cube:add(craft.rigidbody, STATIC)
    cube:add(craft.shape.box, vec3(1, 1, 1))
end
]]

function planeModelWithTextureRightSideUp(size)
    local vertices = {
        vec3(-0.5 * size.x, 0, -0.5 * size.y),
        vec3(0.5 * size.x, 0, -0.5 * size.y),
        vec3(-0.5 * size.x, 0, 0.5 * size.y),
        vec3(0.5 * size.x, 0, 0.5 * size.y)
    }
    
    local texCoords = {
        vec2(0, 1),
        vec2(1, 1),
        vec2(0, 0),
        vec2(1, 0)
    }
    
    local indices = {1, 2, 3, 3, 2, 4}
    
    local m = craft.model()
    m.positions = vertices
    m.texCoords = texCoords
    m.indices = indices
    
    return m
end


-- Custom craft model with only vertical faces
function createVerticalFacesModel()
    local vertices = {
        vec3(-0.5, -0.5, 0.5), vec3(0.5, -0.5, 0.5), vec3(0.5, 0.5, 0.5), vec3(-0.5, 0.5, 0.5),
        vec3(-0.5, -0.5, -0.5), vec3(0.5, -0.5, -0.5), vec3(0.5, 0.5, -0.5), vec3(-0.5, 0.5, -0.5)
    }
    local texCoords = {
        vec2(0, 1), vec2(1, 1), vec2(1, 0), vec2(0, 0)
    }
    local indices = {
        1, 2, 3, 1, 3, 4, -- Front face
        5, 6, 7, 5, 7, 8, -- Back face
        1, 5, 8, 1, 8, 4, -- Left face
        2, 6, 7, 2, 7, 3  -- Right face
    }
    
    local m = craft.model()
    m.positions = vertices
    m.uvs = texCoords
    m.indices = indices
    
    return m
end

function createTransparentCube(size, scene)
    
    -- Create a custom material
    local customTexture = readImage(asset.builtin.SpaceCute.Beetle_Ship)
    local customMaterial = craft.material(asset.builtin.Materials.Standard)
    customMaterial.map = customTexture
    customMaterial.blendMode = NORMAL
    customMaterial.opacity = 1.0
    
    -- Create a custom shader to handle transparency
    local customShader = shader(asset.builtin.Materials.Basic)
    customShader.blendMode = NORMAL
    
    local planes = {}
    local parentOfCube = scene:entity()
    local halfSize = size / 2
    for i = 1, 4 do
        local planeEntity = scene:entity()
        local model = craft.model.plane(vec2(size, size * 1.15))
        local renderer = planeEntity:add(craft.renderer, model)
        renderer.shader = customShader
        renderer.material = customMaterial
        renderer.renderQueue = OPAQUE
        planeEntity.parent = parentOfCube
        planes[i] = planeEntity
    end
    
    -- Position and rotation adjustments
    planes[1].position = vec3(0, 0, -halfSize) -- Back
    planes[1].rotation = quat.eulerAngles(-90, 0, 0)
    
    planes[2].position = vec3(-halfSize, 0, 0) -- Right
    planes[2].rotation = quat.eulerAngles(-90, 90, 0)
    
    planes[3].position = vec3(0, 0, halfSize) -- Front
    planes[3].rotation = quat.eulerAngles(-90, 180, 0)
    
    planes[4].position = vec3(halfSize, 0, 0) -- Left
    planes[4].rotation = quat.eulerAngles(-90, 270, 0)
    
    return parentOfCube
end

function createTransparentCube(size, position, scene)
    
    local customTexture = readImage(asset.builtin.SpaceCute.Beetle_Ship)
    local customMaterial = craft.material(asset.builtin.Materials.Standard)
    customMaterial.map = customTexture
    customMaterial.blendMode = NORMAL
    customMaterial.opacity = 1.0
    
    local customShader = shader(asset.builtin.Materials.Basic)
    customShader.blendMode = NORMAL
    
    local planes = {}
    local parentOfCube = scene:entity()
    local halfSize = size * 0.5 -- half the size of the cube's side length
    local epsilon = 0.001 -- small value to prevent z-fighting
    for i = 1, 4 do
        local planeEntity = scene:entity()
        local model = craft.model.plane(vec2(size, size))
        local renderer = planeEntity:add(craft.renderer, model)
        renderer.shader = customShader
        renderer.material = customMaterial
        planeEntity.parent = parentOfCube
        planes[i] = planeEntity
    end
    
    parentOfCube.position = position
    
    -- Position and rotation adjustments
    planes[1].position = vec3(0, 0, -halfSize + epsilon) -- Back
    planes[1].rotation = quat.eulerAngles(-90, 0, 0)
    
    planes[2].position = vec3(-halfSize + epsilon, 0, 0) -- Right
    planes[2].rotation = quat.eulerAngles(-90, 90, 0)
    
    planes[3].position = vec3(0, 0, halfSize - epsilon) -- Front
    planes[3].rotation = quat.eulerAngles(-90, 180, 0)
    
    planes[4].position = vec3(halfSize - epsilon, 0, 0) -- Left
    planes[4].rotation = quat.eulerAngles(-90, 270, 0)
    
    return parentOfCube
end


function createBoxSides(size)
    local m = craft.model()
    
    -- Generate positions, normals, and UVs for the four double-sided planes
    local halfSize = size * 0.5
    local positions = {
        -- Front
        vec3(-halfSize, -halfSize, halfSize),
        vec3(-halfSize, halfSize, halfSize),
        vec3(halfSize, halfSize, halfSize),
        vec3(halfSize, -halfSize, halfSize),
        
        -- Front (backface)
        vec3(halfSize, -halfSize, halfSize),
        vec3(halfSize, halfSize, halfSize),
        vec3(-halfSize, halfSize, halfSize),
        vec3(-halfSize, -halfSize, halfSize),
        
        -- Right
        vec3(halfSize, -halfSize, halfSize),
        vec3(halfSize, halfSize, halfSize),
        vec3(halfSize, halfSize, -halfSize),
        vec3(halfSize, -halfSize, -halfSize),
        
        -- Right (backface)
        vec3(halfSize, -halfSize, -halfSize),
        vec3(halfSize, halfSize, -halfSize),
        vec3(halfSize, halfSize, halfSize),
        vec3(halfSize, -halfSize, halfSize),
        
        -- Left
        vec3(-halfSize, -halfSize, -halfSize),
        vec3(-halfSize, halfSize, -halfSize),
        vec3(-halfSize, halfSize, halfSize),
        vec3(-halfSize, -halfSize, halfSize),
        
        -- Left (backface)
        vec3(-halfSize, -halfSize, halfSize),
        vec3(-halfSize, halfSize, halfSize),
        vec3(-halfSize, halfSize, -halfSize),
        vec3(-halfSize, -halfSize, -halfSize),
        
        -- Back
        vec3(halfSize, -halfSize, -halfSize),
        vec3(halfSize, halfSize, -halfSize),
        vec3(-halfSize, halfSize, -halfSize),
        vec3(-halfSize, -halfSize, -halfSize),
        
        -- Back (backface)
        vec3(-halfSize, -halfSize, -halfSize),
        vec3(-halfSize, halfSize, -halfSize),
        vec3(halfSize, halfSize, -halfSize),
        vec3(halfSize, -halfSize, -halfSize)
    }
    
    local normals = {
        -- Right
        vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0),
        vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0),
        
        -- Left
        vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0),
        vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0),
        
        -- Front
        vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1),
        vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1),
        
        -- Back
        vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1),
        vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1)
    }
    
    local uvs = {
        -- Right
        vec2(1, 0), vec2(1, 1), vec2(0, 1), vec2(0, 0),
        vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0),
        
        -- Left
        vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0),
        vec2(1, 0), vec2(1, 1), vec2(0, 1), vec2(0, 0),
        
        -- Front
        vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0),
        vec2(1, 0), vec2(1, 1), vec2(0, 1), vec2(0, 0),
        
        -- Back
        vec2(1, 0), vec2(1, 1), vec2(0, 1), vec2(0, 0),
        vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0)
    }
    

    
    -- Colors and indices
    local c = color(245, 3, 3, 255)
    local colors = {}
    for _ = 1, 32 do
        table.insert(colors, c)
    end
    
    local indices = {
        1, 2, 3, 1, 3, 4, -- Front
        5, 6, 7, 5, 7, 8, -- Front (backface)
        9, 10, 11, 9, 11, 12, -- Right
        13, 14, 15, 13, 15, 16, -- Right (backface)
        17, 18, 19, 17, 19, 20, -- Left
        21, 22, 23, 21, 23, 24, -- Left (backface)
        25, 26, 27, 25, 27, 28, -- Back
        29, 30, 31, 29, 31, 32  -- Back (backface)
    }
    
    -- Assign tables to model attributes
    m.positions = positions
    m.normals = normals
    m.uvs = uvs
    m.colors = colors
    m.indices = indices
    
    return m
end

function generatePositions(size)
    local halfSize = size * 0.5
    local positions = {
        -- Front
        vec3(-halfSize, -halfSize, halfSize),
        vec3(-halfSize, halfSize, halfSize),
        vec3(halfSize, halfSize, halfSize),
        vec3(halfSize, -halfSize, halfSize),
        
        -- Front (backface)
        vec3(halfSize, -halfSize, halfSize),
        vec3(halfSize, halfSize, halfSize),
        vec3(-halfSize, halfSize, halfSize),
        vec3(-halfSize, -halfSize, halfSize),
        
        -- Right
        vec3(halfSize, -halfSize, halfSize),
        vec3(halfSize, halfSize, halfSize),
        vec3(halfSize, halfSize, -halfSize),
        vec3(halfSize, -halfSize, -halfSize),
        
        -- Right (backface)
        vec3(halfSize, -halfSize, -halfSize),
        vec3(halfSize, halfSize, -halfSize),
        vec3(halfSize, halfSize, halfSize),
        vec3(halfSize, -halfSize, halfSize),
        
        -- Left
        vec3(-halfSize, -halfSize, -halfSize),
        vec3(-halfSize, halfSize, -halfSize),
        vec3(-halfSize, halfSize, halfSize),
        vec3(-halfSize, -halfSize, halfSize),
        
        -- Left (backface)
        vec3(-halfSize, -halfSize, halfSize),
        vec3(-halfSize, halfSize, halfSize),
        vec3(-halfSize, halfSize, -halfSize),
        vec3(-halfSize, -halfSize, -halfSize),
        
        -- Back
        vec3(halfSize, -halfSize, -halfSize),
        vec3(halfSize, halfSize, -halfSize),
        vec3(-halfSize, halfSize, -halfSize),
        vec3(-halfSize, -halfSize, -halfSize),
        
        -- Back (backface)
        vec3(-halfSize, -halfSize, -halfSize),
        vec3(-halfSize, halfSize, -halfSize),
        vec3(halfSize, halfSize, -halfSize),
        vec3(halfSize, -halfSize, -halfSize)
    }
    
    return positions
end

        
        function generateNormals()
            local normals = {
                -- Right
                vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0),
                vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0),
                
                -- Left
                vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0),
                vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0),
                
                -- Front
                vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1),
                vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1),
                
                -- Back
                vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1),
                vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1)
            }
            
            return normals
        end
        
        function generateUVs()
            local uvs = {
                -- Right
                vec2(1, 0), vec2(1, 1), vec2(0, 1), vec2(0, 0),
                vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0),
                
                -- Left
                vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0),
                vec2(1, 0), vec2(1, 1), vec2(0, 1), vec2(0, 0),
                
                -- Front
                vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0),
                vec2(1, 0), vec2(1, 1), vec2(0, 1), vec2(0, 0),
                
                -- Back
                vec2(1, 0), vec2(1, 1), vec2(0, 1), vec2(0, 0),
                vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0)
            }
            
            return uvs
        end
        
        