-- BackgroundSystem: Dynamic procedural backgrounds with shaders
-- Supports multiple themes controlled by level scripts

local BackgroundSystem = {
  currentTheme = "space",
  transitionTime = 0,
  transitionDuration = 2.0,
  previousTheme = nil,
  time = 0,
  canvas = nil,
  shaders = {},
  particleLayers = {}
}

-- GLSL Shaders for different themes
local shaderCode = {
  -- Water/Ocean shader with waves and caustics
  water = [[
    uniform float time;
    uniform vec2 resolution;
    
    vec3 hash3(vec2 p) {
      vec3 q = vec3(dot(p, vec2(127.1, 311.7)),
                    dot(p, vec2(269.5, 183.3)),
                    dot(p, vec2(419.2, 371.9)));
      return fract(sin(q) * 43758.5453);
    }
    
    float noise(vec2 p) {
      vec2 i = floor(p);
      vec2 f = fract(p);
      vec2 u = f * f * (3.0 - 2.0 * f);
      return mix(mix(hash3(i + vec2(0.0, 0.0)).x,
                     hash3(i + vec2(1.0, 0.0)).x, u.x),
                 mix(hash3(i + vec2(0.0, 1.0)).x,
                     hash3(i + vec2(1.0, 1.0)).x, u.x), u.y);
    }
    
    vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
      vec2 uv = screen_coords / resolution;
      
      // Animated waves
      float wave1 = sin(uv.x * 8.0 + time * 0.8 + uv.y * 3.0) * 0.5 + 0.5;
      float wave2 = sin(uv.x * 12.0 - time * 1.2 + uv.y * 5.0) * 0.5 + 0.5;
      float wave3 = sin(uv.x * 6.0 + time * 0.5 + uv.y * 2.0) * 0.5 + 0.5;
      
      // Caustics effect
      float caustic = noise(vec2(uv.x * 10.0 + time * 0.3, uv.y * 10.0 + time * 0.2));
      caustic += noise(vec2(uv.x * 20.0 - time * 0.4, uv.y * 20.0 + time * 0.3)) * 0.5;
      
      // Depth gradient
      float depth = uv.y * 0.7 + 0.3;
      
      // Ocean colors
      vec3 deepWater = vec3(0.0, 0.05, 0.15);
      vec3 shallowWater = vec3(0.0, 0.2, 0.4);
      vec3 waterColor = mix(shallowWater, deepWater, depth);
      
      // Add wave highlights
      float wavePattern = (wave1 + wave2 + wave3) / 3.0;
      waterColor += vec3(0.0, 0.1, 0.2) * wavePattern * (1.0 - depth);
      
      // Add caustics
      waterColor += vec3(0.1, 0.2, 0.3) * caustic * 0.15 * (1.0 - depth * 0.5);
      
      return vec4(waterColor, 1.0);
    }
  ]],
  
  -- Mechanical/Tech shader with circuits and grids
  mechanical = [[
    uniform float time;
    uniform vec2 resolution;
    
    float hash(vec2 p) {
      return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
    }
    
    vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
      vec2 uv = screen_coords / resolution;
      
      // Grid lines
      vec2 grid = fract(uv * 20.0);
      float gridPattern = 0.0;
      gridPattern += step(0.95, grid.x) * 0.3;
      gridPattern += step(0.95, grid.y) * 0.3;
      
      // Large grid
      vec2 largeGrid = fract(uv * 5.0);
      gridPattern += step(0.98, largeGrid.x) * 0.4;
      gridPattern += step(0.98, largeGrid.y) * 0.4;
      
      // Circuit patterns
      vec2 circuitPos = floor(uv * 10.0);
      float circuit = hash(circuitPos);
      
      // Animated energy flow
      float flow = fract(uv.y * 5.0 - time * 0.5);
      float energyLine = step(0.9, flow) * circuit;
      
      // Hex pattern
      float hexScale = 15.0;
      vec2 hexUV = uv * hexScale;
      vec2 hexID = floor(hexUV);
      float hexPattern = step(0.85, hash(hexID));
      hexPattern *= step(0.7, fract(length(fract(hexUV) - 0.5) * 2.0));
      
      // Base mechanical color
      vec3 baseColor = vec3(0.05, 0.08, 0.12);
      
      // Add grid
      baseColor += vec3(0.1, 0.15, 0.2) * gridPattern;
      
      // Add circuit glow
      baseColor += vec3(0.0, 0.3, 0.5) * energyLine * 0.5;
      
      // Add hex pattern
      baseColor += vec3(0.2, 0.25, 0.3) * hexPattern * 0.2;
      
      // Scanline effect
      float scanline = sin(uv.y * 200.0 + time * 2.0) * 0.5 + 0.5;
      baseColor *= 1.0 - scanline * 0.05;
      
      return vec4(baseColor, 1.0);
    }
  ]],
  
  -- Crystal/Geometric shader with fractal patterns
  crystal = [[
    uniform float time;
    uniform vec2 resolution;
    
    float hash(vec2 p) {
      return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
    }
    
    vec2 rotate(vec2 p, float angle) {
      float c = cos(angle);
      float s = sin(angle);
      return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
    }
    
    vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
      vec2 uv = screen_coords / resolution;
      vec2 center = uv - 0.5;
      
      // Rotating kaleidoscope effect
      float angle = atan(center.y, center.x);
      float radius = length(center);
      
      // Symmetry
      float sectors = 6.0;
      angle = mod(angle + time * 0.2, 3.14159 * 2.0 / sectors);
      angle = abs(angle - 3.14159 / sectors);
      
      vec2 pattern = vec2(cos(angle), sin(angle)) * radius;
      
      // Fractal layers
      float fractal = 0.0;
      float scale = 1.0;
      for (int i = 0; i < 4; i++) {
        pattern = rotate(pattern, time * 0.1 * float(i + 1));
        fractal += abs(sin(pattern.x * 10.0 * scale) * sin(pattern.y * 10.0 * scale)) / scale;
        scale *= 2.0;
      }
      
      // Geometric shards
      vec2 shardUV = uv * 8.0;
      vec2 shardID = floor(shardUV);
      float shard = hash(shardID);
      float shardPattern = step(0.7, shard) * step(0.8, fract(length(fract(shardUV) - 0.5) * 3.0));
      
      // Crystal colors (purple/pink/blue)
      vec3 color1 = vec3(0.4, 0.1, 0.6);
      vec3 color2 = vec3(0.8, 0.2, 0.9);
      vec3 color3 = vec3(0.2, 0.1, 0.5);
      
      vec3 crystalColor = mix(color1, color2, fractal);
      crystalColor = mix(crystalColor, color3, radius * 2.0);
      
      // Add geometric highlights
      crystalColor += vec3(1.0, 0.5, 1.0) * shardPattern * 0.3;
      
      // Depth fade
      crystalColor *= 0.4 + 0.6 * (1.0 - uv.y);
      
      return vec4(crystalColor, 1.0);
    }
  ]],
  
  -- Nebula/Space shader with clouds
  nebula = [[
    uniform float time;
    uniform vec2 resolution;
    
    vec3 hash3(vec2 p) {
      vec3 q = vec3(dot(p, vec2(127.1, 311.7)),
                    dot(p, vec2(269.5, 183.3)),
                    dot(p, vec2(419.2, 371.9)));
      return fract(sin(q) * 43758.5453);
    }
    
    float noise(vec2 p) {
      vec2 i = floor(p);
      vec2 f = fract(p);
      vec2 u = f * f * (3.0 - 2.0 * f);
      return mix(mix(hash3(i + vec2(0.0, 0.0)).x,
                     hash3(i + vec2(1.0, 0.0)).x, u.x),
                 mix(hash3(i + vec2(0.0, 1.0)).x,
                     hash3(i + vec2(1.0, 1.0)).x, u.x), u.y);
    }
    
    float fbm(vec2 p) {
      float value = 0.0;
      float amplitude = 0.5;
      for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
      }
      return value;
    }
    
    vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords) {
      vec2 uv = screen_coords / resolution;
      
      // Animated nebula clouds
      float cloud1 = fbm(uv * 3.0 + vec2(time * 0.05, time * 0.03));
      float cloud2 = fbm(uv * 5.0 - vec2(time * 0.03, time * 0.07));
      float cloud3 = fbm(uv * 7.0 + vec2(time * 0.02, -time * 0.04));
      
      // Nebula colors (purple, pink, blue)
      vec3 color1 = vec3(0.5, 0.1, 0.8);
      vec3 color2 = vec3(0.9, 0.2, 0.5);
      vec3 color3 = vec3(0.1, 0.3, 0.8);
      
      vec3 nebulaColor = mix(color1, color2, cloud1);
      nebulaColor = mix(nebulaColor, color3, cloud2);
      
      // Add brightness variation
      float brightness = (cloud1 + cloud2 + cloud3) / 3.0;
      nebulaColor *= 0.3 + brightness * 0.4;
      
      // Add stars
      float stars = noise(uv * 200.0);
      stars = step(0.99, stars);
      nebulaColor += vec3(1.0) * stars * 0.5;
      
      // Dark space background
      vec3 space = vec3(0.01, 0.01, 0.03);
      nebulaColor = mix(space, nebulaColor, brightness * 0.7);
      
      return vec4(nebulaColor, 1.0);
    }
  ]]
}

-- Background theme definitions
local themes = {
  space = {
    name = "Deep Space",
    shader = nil, -- Uses default starfield
    particleCount = 150,
    scrollSpeed = {y = 50},
    colors = {{0.8, 0.8, 1}, {0.6, 0.6, 0.9}, {0.9, 0.9, 1}}
  },
  
  water = {
    name = "Ocean Depths",
    shader = "water",
    particleCount = 80,
    scrollSpeed = {y = 30},
    particleType = "bubbles",
    colors = {{0.3, 0.6, 0.8, 0.3}, {0.2, 0.5, 0.7, 0.4}}
  },
  
  mechanical = {
    name = "Tech Sector",
    shader = "mechanical",
    particleCount = 50,
    scrollSpeed = {y = 20},
    particleType = "sparks",
    colors = {{0.4, 0.7, 1, 0.5}, {0.2, 0.5, 0.8, 0.4}}
  },
  
  crystal = {
    name = "Crystal Caverns",
    shader = "crystal",
    particleCount = 60,
    scrollSpeed = {y = 25},
    particleType = "gems",
    colors = {{0.8, 0.3, 1, 0.4}, {0.6, 0.2, 0.8, 0.5}, {1, 0.5, 1, 0.3}}
  },
  
  nebula = {
    name = "Nebula Field",
    shader = "nebula",
    particleCount = 100,
    scrollSpeed = {y = 40},
    particleType = "dust",
    colors = {{0.8, 0.4, 1, 0.2}, {0.6, 0.3, 0.8, 0.3}}
  },
  
  forest = {
    name = "Forest Canopy",
    shader = nil,
    particleCount = 100,
    scrollSpeed = {y = 60},
    particleType = "leaves",
    colors = {{0.2, 0.6, 0.3, 0.4}, {0.3, 0.7, 0.2, 0.5}, {0.4, 0.8, 0.3, 0.3}},
    treeColors = {{0.1, 0.3, 0.15}, {0.15, 0.4, 0.2}, {0.08, 0.25, 0.12}}
  }
}

function BackgroundSystem:init(width, height)
  self.width = width
  self.height = height
  self.canvas = love.graphics.newCanvas(width, height)
  
  -- Compile shaders
  for name, code in pairs(shaderCode) do
    local success, result = pcall(function()
      return love.graphics.newShader(code)
    end)
    if success then
      self.shaders[name] = result
    else
      print("Failed to compile " .. name .. " shader:", result)
    end
  end
  
  -- Initialize with space theme
  self:setTheme("space")
end

function BackgroundSystem:setTheme(themeName, instant)
  if not themes[themeName] then
    print("Unknown background theme:", themeName)
    return
  end
  
  if instant then
    self.currentTheme = themeName
    self.transitionTime = 0
    self.previousTheme = nil
  else
    self.previousTheme = self.currentTheme
    self.currentTheme = themeName
    self.transitionTime = 0
  end
  
  -- Initialize particles for this theme
  self:initParticles(themeName)
  
  -- Initialize forest trees if forest theme
  if themeName == "forest" then
    self:initForestTrees()
  end
end

function BackgroundSystem:initForestTrees()
  self.forestTrees = {}
  for i = 1, 15 do
    table.insert(self.forestTrees, {
      x = math.random(20, self.width - 20),
      yOffset = math.random(0, 100),
      size = math.random(15, 25),
      trunkWidth = math.random(8, 12),
      colorIndex = math.random(1, 3)
    })
  end
end

function BackgroundSystem:initParticles(themeName)
  local theme = themes[themeName]
  self.particleLayers = {}
  
  if theme.particleType == "leaves" then
    -- Forest leaves
    for i = 1, theme.particleCount do
      table.insert(self.particleLayers, {
        x = math.random(0, self.width),
        y = math.random(-self.height, 0),
        size = math.random(4, 12),
        speed = math.random(30, 80),
        drift = math.random(-20, 20),
        rotation = math.random() * math.pi * 2,
        rotationSpeed = (math.random() - 0.5) * 2,
        color = theme.colors[math.random(#theme.colors)]
      })
    end
  elseif theme.particleType == "bubbles" then
    -- Water bubbles
    for i = 1, theme.particleCount do
      table.insert(self.particleLayers, {
        x = math.random(0, self.width),
        y = math.random(0, self.height),
        size = math.random(2, 8),
        speed = -math.random(20, 60), -- Rise up
        drift = math.random(-15, 15),
        alpha = math.random(20, 60) / 100,
        color = theme.colors[math.random(#theme.colors)]
      })
    end
  elseif theme.particleType == "sparks" then
    -- Tech sparks
    for i = 1, theme.particleCount do
      table.insert(self.particleLayers, {
        x = math.random(0, self.width),
        y = math.random(0, self.height),
        size = math.random(1, 4),
        speed = math.random(40, 100),
        drift = math.random(-30, 30),
        life = math.random(0, 100) / 100,
        color = theme.colors[math.random(#theme.colors)]
      })
    end
  elseif theme.particleType == "gems" then
    -- Crystal shards
    for i = 1, theme.particleCount do
      table.insert(self.particleLayers, {
        x = math.random(0, self.width),
        y = math.random(0, self.height),
        size = math.random(3, 10),
        speed = math.random(20, 50),
        rotation = math.random() * math.pi * 2,
        rotationSpeed = (math.random() - 0.5) * 3,
        glow = math.random(50, 100) / 100,
        color = theme.colors[math.random(#theme.colors)]
      })
    end
  elseif theme.particleType == "dust" then
    -- Nebula dust
    for i = 1, theme.particleCount do
      table.insert(self.particleLayers, {
        x = math.random(0, self.width),
        y = math.random(0, self.height),
        size = math.random(5, 15),
        speed = math.random(15, 45),
        drift = math.random(-25, 25),
        alpha = math.random(10, 40) / 100,
        color = theme.colors[math.random(#theme.colors)]
      })
    end
  end
end

function BackgroundSystem:update(dt)
  self.time = self.time + dt
  
  -- Update transition
  if self.previousTheme then
    self.transitionTime = self.transitionTime + dt
    if self.transitionTime >= self.transitionDuration then
      self.previousTheme = nil
      self.transitionTime = 0
    end
  end
  
  -- Update particles
  local theme = themes[self.currentTheme]
  for _, particle in ipairs(self.particleLayers) do
    particle.y = particle.y + particle.speed * dt
    if particle.drift then
      particle.x = particle.x + particle.drift * dt
    end
    if particle.rotation then
      particle.rotation = particle.rotation + (particle.rotationSpeed or 0) * dt
    end
    if particle.life then
      particle.life = particle.life + dt * 0.5
      if particle.life > 1 then particle.life = 0 end
    end
    
    -- Wrap around
    if particle.speed > 0 and particle.y > self.height + 50 then
      particle.y = -50
      particle.x = math.random(0, self.width)
    elseif particle.speed < 0 and particle.y < -50 then
      particle.y = self.height + 50
      particle.x = math.random(0, self.width)
    end
    
    if particle.x < -50 then particle.x = self.width + 50
    elseif particle.x > self.width + 50 then particle.x = -50 end
  end
end

function BackgroundSystem:draw()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  
  -- Draw theme background
  self:drawTheme(self.currentTheme, 1.0)
  
  -- Draw transition if active
  if self.previousTheme then
    local alpha = 1.0 - (self.transitionTime / self.transitionDuration)
    self:drawTheme(self.previousTheme, alpha)
  end
  
  love.graphics.setCanvas()
  
  -- Draw canvas to screen
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canvas, 0, 0)
end

function BackgroundSystem:drawTheme(themeName, alpha)
  local theme = themes[themeName]
  local shader = theme.shader and self.shaders[theme.shader]
  
  -- Use shader if available
  if shader then
    love.graphics.setShader(shader)
    shader:send("time", self.time)
    shader:send("resolution", {self.width, self.height})
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setShader()
  else
    -- Default rendering for non-shader themes
    if themeName == "space" then
      self:drawSpaceBackground(alpha)
    elseif themeName == "forest" then
      self:drawForestBackground(alpha)
    end
  end
  
  -- Draw particles
  self:drawParticles(theme, alpha)
end

function BackgroundSystem:drawSpaceBackground(alpha)
  -- Dark space gradient
  love.graphics.setColor(0.01, 0.01, 0.05, alpha)
  love.graphics.rectangle("fill", 0, 0, self.width, self.height)
end

function BackgroundSystem:drawForestBackground(alpha)
  -- Forest gradient (dark green to lighter)
  for y = 0, self.height, 5 do
    local t = y / self.height
    love.graphics.setColor(0.05 + t * 0.1, 0.15 + t * 0.15, 0.08 + t * 0.1, alpha)
    love.graphics.rectangle("fill", 0, y, self.width, 5)
  end
  
  -- Draw trees in background
  if not self.forestTrees then
    self:initForestTrees()
  end
  
  local theme = themes.forest
  for i, tree in ipairs(self.forestTrees) do
    local x = tree.x
    local treeY = (self.time * 30 + tree.yOffset) % (self.height + 100) - 50
    local treeColor = theme.treeColors[tree.colorIndex]
    
    love.graphics.setColor(treeColor[1], treeColor[2], treeColor[3], alpha * 0.6)
    -- Tree trunk
    love.graphics.rectangle("fill", x - tree.trunkWidth / 2, treeY, tree.trunkWidth, 40)
    -- Tree canopy (simple circles)
    love.graphics.circle("fill", x, treeY, tree.size)
    love.graphics.circle("fill", x - tree.size * 0.7, treeY + 10, tree.size * 0.75)
    love.graphics.circle("fill", x + tree.size * 0.7, treeY + 10, tree.size * 0.75)
  end
end

function BackgroundSystem:drawParticles(theme, alpha)
  for _, particle in ipairs(self.particleLayers) do
    local color = particle.color
    local particleAlpha = (alpha or 1.0) * (particle.alpha or particle.glow or 1.0)
    
    if #color == 4 then
      love.graphics.setColor(color[1], color[2], color[3], color[4] * particleAlpha)
    else
      love.graphics.setColor(color[1], color[2], color[3], particleAlpha)
    end
    
    if particle.rotation then
      love.graphics.push()
      love.graphics.translate(particle.x, particle.y)
      love.graphics.rotate(particle.rotation)
      
      if theme.particleType == "leaves" then
        -- Leaf shape
        love.graphics.ellipse("fill", 0, 0, particle.size, particle.size * 0.6)
      elseif theme.particleType == "gems" then
        -- Diamond shape
        love.graphics.polygon("fill",
          0, -particle.size,
          particle.size * 0.6, 0,
          0, particle.size,
          -particle.size * 0.6, 0
        )
      else
        love.graphics.circle("fill", 0, 0, particle.size)
      end
      
      love.graphics.pop()
    else
      if particle.life then
        -- Spark/flash
        local life = 1.0 - particle.life
        love.graphics.circle("fill", particle.x, particle.y, particle.size * life)
      else
        love.graphics.circle("fill", particle.x, particle.y, particle.size)
      end
    end
  end
end

return BackgroundSystem
