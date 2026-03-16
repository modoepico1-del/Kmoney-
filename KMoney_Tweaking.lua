-- ══════════════════════════════════════
--  GALAXY SKY (automático al cargar)
-- ══════════════════════════════════════

local originalSkybox, galaxySkyBright, galaxySkyBrightConn
local galaxyPlanets = {}
local galaxyBloom, galaxyCC
local galaxySkyOn = true

local function enableGalaxySkyBright()
    if galaxySkyBright then return end
    originalSkybox = Lighting:FindFirstChildOfClass("Sky")
    if originalSkybox then originalSkybox.Parent = nil end
    galaxySkyBright = Instance.new("Sky")
    galaxySkyBright.SkyboxBk = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxDn = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxFt = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxLf = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxRt = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxUp = "rbxassetid://1534951537"
    galaxySkyBright.StarCount = 10000
    galaxySkyBright.CelestialBodiesShown = false
    galaxySkyBright.Parent = Lighting
    galaxyBloom = Instance.new("BloomEffect")
    galaxyBloom.Intensity = 1.5; galaxyBloom.Size = 40; galaxyBloom.Threshold = 0.8
    galaxyBloom.Parent = Lighting
    galaxyCC = Instance.new("ColorCorrectionEffect")
    galaxyCC.Saturation = 0.8; galaxyCC.Contrast = 0.3
    galaxyCC.TintColor = Color3.fromRGB(200, 150, 255)
    galaxyCC.Parent = Lighting
    Lighting.Ambient = Color3.fromRGB(120, 60, 180)
    Lighting.Brightness = 3
    Lighting.ClockTime = 0
    for i = 1, 2 do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(800+i*200, 800+i*200, 800+i*200)
        p.Anchored = true; p.CanCollide = false; p.CastShadow = false
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(140+i*20, 60+i*10, 200+i*15)
        p.Transparency = 0.3
        p.Position = Vector3.new(
            math.cos(i*2) * (3000+i*500),
            1500+i*300,
            math.sin(i*2) * (3000+i*500)
        )
        p.Parent = workspace
        table.insert(galaxyPlanets, p)
    end
    galaxySkyBrightConn = RunService.Heartbeat:Connect(function()
        if not galaxySkyOn then return end
        local t = tick() * 0.5
        Lighting.Ambient = Color3.fromRGB(
            120 + math.sin(t) * 60,
            50  + math.sin(t * 0.8) * 40,
            180 + math.sin(t * 1.2) * 50
        )
        if galaxyBloom then
            galaxyBloom.Intensity = 1.2 + math.sin(t * 2) * 0.4
        end
    end)
end

-- Se activa automáticamente al cargar
task.defer(function()
    task.wait(1)
    enableGalaxySkyBright()
end)

-- Se reactiva si el personaje respawnea
me.CharacterAdded:Connect(function()
    task.wait(1)
    galaxySkyBright = nil -- fuerza recrear
    enableGalaxySkyBright()
end)
