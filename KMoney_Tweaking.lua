local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Evita duplicados
if LocalPlayer:WaitForChild('PlayerGui'):FindFirstChild('DemonTimeGUI') then
    return
end

local bgColor = Color3.fromRGB(0, 0, 0)
local barColor = Color3.fromRGB(5, 5, 5)

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
-- OPTIMIZER TOGGLE
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

-- Contenedor del toggle Optimize
local OptimizeRow = Instance.new('Frame')
OptimizeRow.Name = 'OptimizeRow'
OptimizeRow.Size = UDim2.new(1, 0, 0, 36)
OptimizeRow.BackgroundColor3 = barColor
OptimizeRow.BorderSizePixel = 0
OptimizeRow.LayoutOrder = 2
OptimizeRow.Parent = Content

local OptimizeCorner = Instance.new('UICorner')
OptimizeCorner.CornerRadius = UDim.new(0, 6)
OptimizeCorner.Parent = OptimizeRow

-- Label "Optimize"
local OptimizeLabel = Instance.new('TextLabel')
OptimizeLabel.Size = UDim2.new(1, -60, 1, 0)
OptimizeLabel.Position = UDim2.new(0, 10, 0, 0)
OptimizeLabel.BackgroundTransparency = 1
OptimizeLabel.Text = '⚡ Optimize'
OptimizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
OptimizeLabel.TextSize = 14
OptimizeLabel.Font = Enum.Font.GothamBold
OptimizeLabel.TextXAlignment = Enum.TextXAlignment.Left
OptimizeLabel.Parent = OptimizeRow

-- Fondo del toggle (pill)
local ToggleBG = Instance.new('Frame')
ToggleBG.Size = UDim2.new(0, 44, 0, 22)
ToggleBG.Position = UDim2.new(1, -52, 0.5, -11)
ToggleBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBG.BorderSizePixel = 0
ToggleBG.Parent = OptimizeRow

local ToggleBGCorner = Instance.new('UICorner')
ToggleBGCorner.CornerRadius = UDim.new(1, 0)
ToggleBGCorner.Parent = ToggleBG

-- Círculo del toggle
local ToggleCircle = Instance.new('Frame')
ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
ToggleCircle.Position = UDim2.new(0, 3, 0.5, -8)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
ToggleCircle.BorderSizePixel = 0
ToggleCircle.Parent = ToggleBG

local ToggleCircleCorner = Instance.new('UICorner')
ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
ToggleCircleCorner.Parent = ToggleCircle

-- Botón invisible encima del toggle
local ToggleButton = Instance.new('TextButton')
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = ''
ToggleButton.Parent = OptimizeRow

-- Estado y lógica del toggle
local optimizeEnabled = false
local TweenService = game:GetService('TweenService')

ToggleButton.MouseButton1Click:Connect(function()
    optimizeEnabled = not optimizeEnabled

    if optimizeEnabled then
        enableOptimizer()
        -- Toggle ON: rojo + círculo a la derecha
        TweenService:Create(ToggleBG, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        }):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
            Position = UDim2.new(0, 25, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        OptimizeLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        disableOptimizer()
        -- Toggle OFF: gris + círculo a la izquierda
        TweenService:Create(ToggleBG, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
            Position = UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
        OptimizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)
