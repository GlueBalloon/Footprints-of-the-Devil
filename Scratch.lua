-- Main
function setup()
scene = craft.scene()

-- Set up camera
scene.camera:add(OrbitViewer, vec3(0, 5, 20), 30, 0, 2000)

-- Create a cube
createTransparentCube(vec3(0, 0, 0))
end

function draw()
update(DeltaTime)
scene:draw()
end

function update(dt)
scene:update(dt)
end

-- Custom transparent cube
function createTransparentCube(position)
local cube = scene:entity()
cube.position = position

local model = craft.model.cube(vec3(1, 1, 1))
local renderer = cube:add(craft.renderer, model)

-- Load custom texture (replace with your own texture asset)
local customTexture = readImage(asset.myTransparentTexture)

-- Create a custom material
local customMaterial = craft.material(asset.builtin.Materials.Standard)
customMaterial.map = customTexture
customMaterial.blendMode = NORMAL
customMaterial.opacity = 0.0 -- Make it invisible

-- Apply the custom material to the cube
renderer.material = customMaterial

-- Create a custom shader to handle transparency
local customShader = shader(asset.builtin.shaders.VertexColorNormalMap)
customShader.blendMode = NORMAL
renderer.shader = customShader

-- Add a rigid body for physics simulation
cube:add(craft.rigidbody, STATIC)
cube:add(craft.shape.box, vec3(1, 1, 1))
end
