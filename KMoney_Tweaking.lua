local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Evita duplicados
if LocalPlayer:WaitForChild('PlayerGui'):FindFirstChild('DemonTimeGUI') then
    return
end

local bgColor = Color3.fromRGB(0, 0, 0)
local barColor = Color3.fromRGB(5, 5, 5)

-- Config global para flags
local config = {
    GalaxySkyBright = false,
    Optimize = false,
}

local DemonTimeGUI = Instance.new('ScreenGui')
DemonTimeGUI.Name = 'DemonTimeGUI'
DemonTimeGUI.ResetOnSpawn = false
DemonTimeGUI.Parent = LocalPlayer:WaitForChild('PlayerGui')

local Main = Instance.new('Frame')
Main.Name = 'Main'
Main.Size = UDim2.new(0, 300, 0, 680)
Main.Position = UDim2.new(0, 16, 0.5, -340)
Main.BackgroundColor3 = bgColor
Main.BackgroundTransparency = 0
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = DemonTimeGUI

local UICorner = Instance.new('UICorner')
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

local TitleBar = Instance.new('Frame')
TitleBar.Name = 'TitleBar'
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = barColor
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new('UICorner')
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new('Frame')
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = barColor
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new('TextLabel')
TitleLabel.Name = 'TitleLabel'
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = 'DemonTime'
TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local NeonStroke = Instance.new('UIStroke')
NeonStroke.Color = Color3.fromRGB(0, 0, 0)
NeonStroke.Thickness = 3
NeonStroke.Transparency = 0
NeonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
NeonStroke.Parent = TitleLabel

local Content = Instance.new('Frame')
Content.Name = 'Content'
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = Main

local UIListLayout = Instance.new('UIListLayout')
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Content

-- ========================================
-- HELPER: Crear fila toggle reutilizable
-- ========================================
local function createToggleRow(labelText, icon, layoutOrder)
    local Row = Instance.new('Frame')
    Row.Size = UDim2.new(1, 0, 0, 36)
    Row.BackgroundColor3 = barColor
    Row.BorderSizePixel = 0
    Row.LayoutOrder = layoutOrder
    Row.Parent = Content

    local RowCorner = Instance.new('UICorner')
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = Row

    local Label = Instance.new('TextLabel')
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = icon .. ' ' .. labelText
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local BG = Instance.new('Frame')
    BG.Size = UDim2.new(0, 44, 0, 22)
    BG.Position = UDim2.new(1, -52, 0.5, -11)
    BG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    BG.BorderSizePixel = 0
    BG.Parent = Row

    local BGCorner = Instance.new('UICorner')
    BGCorner.CornerRadius = UDim.new(1, 0)
    BGCorner.Parent = BG

    local Circle = Instance.new('Frame')
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 3, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.BorderSizePixel = 0
    Circle.Parent = BG

    local CircleCorner = Instance.new('UICorner')
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local Button = Instance.new('TextButton')
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ''
    Button.Parent = Row

    return { Row = Row, Label = Label, BG = BG, Circle = Circle, Button = Button }
end

local function animateToggle(toggle, enabled, activeColor)
    local color = enabled and activeColor or Color3.fromRGB(60, 60, 60)
    local pos = enabled and UDim2.new(0, 25, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    local textColor = enabled and activeColor or Color3.fromRGB(255, 255, 255)
    TweenService:Create(toggle.BG, TweenInfo.new(0.2), { BackgroundColor3 = color }):Play()
    TweenService:Create(toggle.Circle, TweenInfo.new(0.2), { Position = pos }):Play()
    toggle.Label.TextColor3 = textColor
end

-- ========================================
-- FPS + PING TRACKER
-- ========================================

local FpsLabel = Instance.new('TextLabel')
FpsLabel.Name = 'FpsLabel'
FpsLabel.Size = UDim2.new(1, 0, 0, 30)
FpsLabel.BackgroundColor3 = barColor
FpsLabel.BorderSizePixel = 0
FpsLabel.Text = 'FPS: -- | PING: -- ms'
FpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
FpsLabel.TextSize = 14
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.LayoutOrder = 1
FpsLabel.Parent = Content

local FpsCorner = Instance.new('UICorner')
FpsCorner.CornerRadius = UDim.new(0, 6)
FpsCorner.Parent = FpsLabel

local mgFpsValue = 0
local pingValue = 0
local fpsFrameCount = 0
local fpsLastTime = tick()

RunService.Heartbeat:Connect(function()
    fpsFrameCount = fpsFrameCount + 1
    local now = tick()
    if now - fpsLastTime >= 0.5 then
        mgFpsValue = math.floor(fpsFrameCount / (now - fpsLastTime))
        fpsFrameCount = 0
        fpsLastTime = now

        local fpsColor
        if mgFpsValue >= 50 then
            fpsColor = Color3.fromRGB(0, 255, 0)
        elseif mgFpsValue >= 25 then
            fpsColor = Color3.fromRGB(255, 165, 0)
        else
            fpsColor = Color3.fromRGB(255, 0, 0)
        end

        FpsLabel.TextColor3 = fpsColor
        FpsLabel.Text = string.format('FPS: %d | PING: %d ms', mgFpsValue, pingValue)
    end

    pcall(function()
        pingValue = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
end)

-- ========================================
-- OPTIMIZER
-- ========================================

local originalTransparency = {}
local xrayEnabled = false

local function enableOptimizer()
    if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
    if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.Brightness = 3
        Lighting.FogEnd = 9e9
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false
                    obj.Material = Enum.Material.Plastic
                end
            end)
        end
    end)
end

local function disableOptimizer()
    if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
    if xrayEnabled then
        for part, value in pairs(originalTransparency) do
            if part then part.LocalTransparencyModifier = value end
        end
        originalTransparency = {}
        xrayEnabled = false
    end
end

local optimizeToggle = createToggleRow('Optimize', '⚡', 2)
local optimizeEnabled = false

optimizeToggle.Button.MouseButton1Click:Connect(function()
    optimizeEnabled = not optimizeEnabled
    config.Optimize = optimizeEnabled
    if optimizeEnabled then enableOptimizer() else disableOptimizer() end
    animateToggle(optimizeToggle, optimizeEnabled, Color3.fromRGB(200, 0, 0))
end)

-- ========================================
-- GALAXY SKY
-- ========================================

local originalSkybox, galaxySkyBright, galaxySkyBrightConn
local galaxyPlanets = {}
local galaxyBloom, galaxyCC

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
    galaxyBloom.Intensity = 1.5
    galaxyBloom.Size = 40
    galaxyBloom.Threshold = 0.8
    galaxyBloom.Parent = Lighting

    galaxyCC = Instance.new("ColorCorrectionEffect")
    galaxyCC.Saturation = 0.8
    galaxyCC.Contrast = 0.3
    galaxyCC.TintColor = Color3.fromRGB(200, 150, 255)
    galaxyCC.Parent = Lighting

    Lighting.Ambient = Color3.fromRGB(120, 60, 180)
    Lighting.Brightness = 3
    Lighting.ClockTime = 0

    for i = 1, 2 do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(800 + i*200, 800 + i*200, 800 + i*200)
        p.Anchored = true
        p.CanCollide = false
        p.CastShadow = false
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(140 + i*20, 60 + i*10, 200 + i*15)
        p.Transparency = 0.3
        p.Position = Vector3.new(
            math.cos(i * 2) * (3000 + i*500),
            1500 + i*300,
            math.sin(i * 2) * (3000 + i*500)
        )
        p.Parent = workspace
        table.insert(galaxyPlanets, p)
    end

    galaxySkyBrightConn = RunService.Heartbeat:Connect(function()
        if not config.GalaxySkyBright then return end
        local t = tick() * 0.5
        Lighting.Ambient = Color3.fromRGB(
            120 + math.sin(t) * 60,
            50 + math.sin(t * 0.8) * 40,
            180 + math.sin(t * 1.2) * 50
        )
        if galaxyBloom then
            galaxyBloom.Intensity = 1.2 + math.sin(t * 2) * 0.4
        end
    end)
end

local function disableGalaxySkyBright()
    if galaxySkyBrightConn then galaxySkyBrightConn:Disconnect() galaxySkyBrightConn = nil end
    if galaxySkyBright then galaxySkyBright:Destroy() galaxySkyBright = nil end
    if originalSkybox then originalSkybox.Parent = Lighting end
    if galaxyBloom then galaxyBloom:Destroy() galaxyBloom = nil end
    if galaxyCC then galaxyCC:Destroy() galaxyCC = nil end
    for _, obj in ipairs(galaxyPlanets) do if obj then obj:Destroy() end end
    galaxyPlanets = {}
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
end

local galaxyToggle = createToggleRow('Galaxy Sky', '🌌', 3)
local galaxyEnabled = false

galaxyToggle.Button.MouseButton1Click:Connect(function()
    galaxyEnabled = not galaxyEnabled
    config.GalaxySkyBright = galaxyEnabled
    if galaxyEnabled then enableGalaxySkyBright() else disableGalaxySkyBright() end
    animateToggle(galaxyToggle, galaxyEnabled, Color3.fromRGB(140, 60, 200))
end)
