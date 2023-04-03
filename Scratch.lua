
function createOpenCube(size, position, scene)
    local cube = scene:entity()
    local model = createBoxSides(size)
    local customTexture = readImage(asset.builtin.SpaceCute.Beetle_Ship)
    local customMaterial = craft.material(asset.builtin.Materials.Standard)
    customMaterial.map = customTexture
    customMaterial.blendMode = NORMAL
    customMaterial.opacity = 1.0
    --customMaterial.depthWrite = false
    --customMaterial.depthMode = LEQUAL
    --[[
    local customShader = shader(asset.builtin.Materials.Basic)
    customShader.blendMode = NORMAL
    ]]
    
    local renderer = cube:add(craft.renderer, model)
    --renderer.shader = customShader
    renderer.material = customMaterial
    
    cube.position = position
    return cube
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
    

        local halfWidth = size.x / 2
        local halfHeight = size.y / 2
        local halfDepth = size.z / 2
        local epsilon = 0.001
        
    --[[
        positions = {
            -- Back
            vec3(-halfWidth, -halfHeight, -halfDepth - epsilon),
            vec3(-halfWidth, halfHeight, -halfDepth - epsilon),
            vec3(halfWidth, halfHeight, -halfDepth - epsilon),
            vec3(halfWidth, -halfHeight, -halfDepth - epsilon),
            vec3(-halfWidth, -halfHeight, -halfDepth),
            vec3(-halfWidth, halfHeight, -halfDepth),
            vec3(halfWidth, halfHeight, -halfDepth),
            vec3(halfWidth, -halfHeight, -halfDepth),
            
            -- Right
            vec3(-halfWidth - epsilon, -halfHeight, -halfDepth),
            vec3(-halfWidth - epsilon, halfHeight, -halfDepth),
            vec3(-halfWidth - epsilon, halfHeight, halfDepth),
            vec3(-halfWidth - epsilon, -halfHeight, halfDepth),
            vec3(-halfWidth, -halfHeight, -halfDepth),
            vec3(-halfWidth, halfHeight, -halfDepth),
            vec3(-halfWidth, halfHeight, halfDepth),
            vec3(-halfWidth, -halfHeight, halfDepth),
            
            -- Front
            vec3(-halfWidth, -halfHeight, halfDepth + epsilon),
            vec3(-halfWidth, halfHeight, halfDepth + epsilon),
            vec3(halfWidth, halfHeight, halfDepth + epsilon),
            vec3(halfWidth, -halfHeight, halfDepth + epsilon),
            vec3(-halfWidth, -halfHeight, halfDepth),
            vec3(-halfWidth, halfHeight, halfDepth),
            vec3(halfWidth, halfHeight, halfDepth),
            vec3(halfWidth, -halfHeight, halfDepth),
            
            -- Left
            vec3(halfWidth + epsilon, -halfHeight, -halfDepth),
            vec3(halfWidth + epsilon, halfHeight, -halfDepth),
            vec3(halfWidth + epsilon, halfHeight, halfDepth),
            vec3(halfWidth + epsilon, -halfHeight, halfDepth),
            vec3(halfWidth, -halfHeight, -halfDepth),
            vec3(halfWidth, halfHeight, -halfDepth),
            vec3(halfWidth, halfHeight, halfDepth),
            vec3(halfWidth, -halfHeight, halfDepth)
        }
    ]]
    
    -- Generate positions, normals, and UVs for the four double-sided planes

--[[
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
]]

    local w, h, d = size.x, size.y, size.z
    local halfW, halfH, halfD = w / 2, h / 2, d / 2
    
    positions = {
        -- Back plane
        vec3(-halfW, -halfH, -halfD), vec3(-halfW, halfH, -halfD), vec3(halfW, halfH, -halfD), vec3(halfW, -halfH, -halfD),
        vec3(halfW, -halfH, -halfD), vec3(halfW, halfH, -halfD), vec3(-halfW, halfH, -halfD), vec3(-halfW, -halfH, -halfD),
        
        -- Right plane
        vec3(halfW, -halfH, -halfD), vec3(halfW, halfH, -halfD), vec3(halfW, halfH, halfD), vec3(halfW, -halfH, halfD),
        vec3(halfW, -halfH, halfD), vec3(halfW, halfH, halfD), vec3(halfW, halfH, -halfD), vec3(halfW, -halfH, -halfD),
        
        -- Front plane
        vec3(halfW, -halfH, halfD), vec3(halfW, halfH, halfD), vec3(-halfW, halfH, halfD), vec3(-halfW, -halfH, halfD),
        vec3(-halfW, -halfH, halfD), vec3(-halfW, halfH, halfD), vec3(halfW, halfH, halfD), vec3(halfW, -halfH, halfD),
        
        -- Left plane
        vec3(-halfW, -halfH, halfD), vec3(-halfW, halfH, halfD), vec3(-halfW, halfH, -halfD), vec3(-halfW, -halfH, -halfD),
        vec3(-halfW, -halfH, -halfD), vec3(-halfW, halfH, -halfD), vec3(-halfW, halfH, halfD), vec3(-halfW, -halfH, halfD)
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

-- Add this new function below the createOpenCube function
function createInsetCube(parentEntity, size, cubeColor, scene)
    local cubeEntity = scene:entity()
    local model = craft.model.cube(size)
    local renderer = cubeEntity:add(craft.renderer, model)
    renderer.material = craft.material(asset.builtin.Materials.Standard)
    renderer.material.diffuse = cubeColor
    renderer.material.emissive = cubeColor * 0.2 -- Make the cube slightly glowing
    cubeEntity.parent = parentEntity
    return cubeEntity
end

