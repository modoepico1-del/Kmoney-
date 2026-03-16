-- ╔══════════════════════════════════════╗
-- ║           DEMONTIME HUB              ║
-- ╚══════════════════════════════════════╝

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local CoreGui          = game:GetService("CoreGui")

local me     = Players.LocalPlayer
local RS     = RunService
local Camera = workspace.CurrentCamera

-- ══════════════════════════════════════
--  GUI SETUP
-- ══════════════════════════════════════

if CoreGui:FindFirstChild("DEMONTIME_GUI") then
    CoreGui:FindFirstChild("DEMONTIME_GUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "DEMONTIME_GUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size               = UDim2.new(0, 300, 0, 700)
MainFrame.Position           = UDim2.new(0, 0, 0, 4)
MainFrame.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel    = 0
MainFrame.Active             = false
MainFrame.Draggable          = false
MainFrame.ClipsDescendants   = true
MainFrame.Visible            = true
MainFrame.Parent             = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local function addNeonBorder(parent, thickness, color)
    local glow = Instance.new("Frame")
    glow.Size                   = UDim2.new(1, thickness*6, 1, thickness*6)
    glow.Position               = UDim2.new(0, -thickness*3, 0, -thickness*3)
    glow.BackgroundColor3       = color
    glow.BackgroundTransparency = 0.72
    glow.BorderSizePixel        = 0
    glow.ZIndex                 = parent.ZIndex - 1
    glow.Parent                 = parent
    Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 14)
    local mid = Instance.new("Frame")
    mid.Size                   = UDim2.new(1, thickness*3, 1, thickness*3)
    mid.Position               = UDim2.new(0, -thickness*1.5, 0, -thickness*1.5)
    mid.BackgroundColor3       = color
    mid.BackgroundTransparency = 0.50
    mid.BorderSizePixel        = 0
    mid.ZIndex                 = parent.ZIndex - 1
    mid.Parent                 = parent
    Instance.new("UICorner", mid).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke")
    stroke.Color           = color
    stroke.Thickness       = thickness
    stroke.Transparency    = 0.0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent          = parent
end

addNeonBorder(MainFrame, 2, Color3.fromRGB(0, 0, 0))

-- ══════════════════════════════════════
--  TITLE BAR
-- ══════════════════════════════════════

local TitleBar = Instance.new("Frame")
TitleBar.Size              = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
TitleBar.BorderSizePixel   = 0
TitleBar.ZIndex            = 3
TitleBar.Parent            = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local lineGlow = Instance.new("Frame")
lineGlow.Size                   = UDim2.new(1, 0, 0, 8)
lineGlow.Position               = UDim2.new(0, 0, 1, -5)
lineGlow.BackgroundColor3       = Color3.fromRGB(30, 30, 30)
lineGlow.BackgroundTransparency = 0.6
lineGlow.BorderSizePixel        = 0
lineGlow.ZIndex                 = 3
lineGlow.Parent                 = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text                   = "$KMONEY HUB"
TitleLabel.Size                   = UDim2.new(1, -50, 1, 0)
TitleLabel.Position               = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3             = Color3.fromRGB(255, 0, 0)
TitleLabel.TextSize               = 17
TitleLabel.Font                   = Enum.Font.GothamBlack
TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
TitleLabel.ZIndex                 = 5
TitleLabel.Parent                 = TitleBar

-- ══════════════════════════════════════
--  CONTENT AREA
-- ══════════════════════════════════════

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size                   = UDim2.new(1, 0, 1, -42)
ContentArea.Position               = UDim2.new(0, 0, 0, 42)
ContentArea.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
ContentArea.BackgroundTransparency = 0
ContentArea.BorderSizePixel        = 0
ContentArea.ZIndex                 = 3
ContentArea.ScrollBarThickness     = 4
ContentArea.ScrollBarImageColor3   = Color3.fromRGB(255, 0, 0)
ContentArea.CanvasSize             = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize    = Enum.AutomaticSize.Y
ContentArea.ScrollingDirection     = Enum.ScrollingDirection.Y
ContentArea.ElasticBehavior        = Enum.ElasticBehavior.Never
ContentArea.Parent                 = MainFrame

-- ══════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════

local function makeOptionRow(parent, labelText, yPos)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -20, 0, 44)
    row.Position         = UDim2.new(0, 10, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
    row.BorderSizePixel  = 0
    row.ZIndex           = 4
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
    local rs = Instance.new("UIStroke")
    rs.Color = Color3.fromRGB(255,0,0); rs.Thickness = 0.8; rs.Transparency = 0.5; rs.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Text = labelText; lbl.Size = UDim2.new(1,-70,1,0); lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextSize = 14; lbl.Font = Enum.Font.GothamBlack
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5; lbl.Parent = row
    local track = Instance.new("TextButton")
    track.Text = ""; track.Size = UDim2.new(0,44,0,24); track.Position = UDim2.new(1,-54,0.5,-12)
    track.BackgroundColor3 = Color3.fromRGB(40,40,40); track.BorderSizePixel = 0
    track.ZIndex = 5; track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0,18,0,18); thumb.Position = UDim2.new(0,3,0.5,-9)
    thumb.BackgroundColor3 = Color3.fromRGB(180,180,180); thumb.BorderSizePixel = 0
    thumb.ZIndex = 6; thumb.Parent = track
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)
    return lbl, track, thumb
end

local function toggleOn(lbl, track, thumb)
    TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200,0,0)}):Play()
    TweenService:Create(thumb, TweenInfo.new(0.2), {Position = UDim2.new(0,23,0.5,-9), BackgroundColor3 = Color3.fromRGB(255,0,0)}):Play()
    TweenService:Create(lbl,   TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,0,0)}):Play()
end
local function toggleOff(lbl, track, thumb)
    TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
    TweenService:Create(thumb, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0.5,-9), BackgroundColor3 = Color3.fromRGB(180,180,180)}):Play()
    TweenService:Create(lbl,   TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220,220,220)}):Play()
end

-- ══════════════════════════════════════
--  RING
-- ══════════════════════════════════════

local AUTO_STEAL_PROX_RADIUS = 7
local ringParts      = {}
local circleConnection = nil
local RING_SEGMENTS  = 60
local RING_THICKNESS = 0.15
local RING_HEIGHT    = 0.08

local function hideRing()
    for _, p in ipairs(ringParts) do pcall(function() p:Destroy() end) end
    ringParts = {}
    if circleConnection then circleConnection:Disconnect(); circleConnection = nil end
end

local function buildRing(radius)
    hideRing()
    for i = 1, RING_SEGMENTS do
        local seg = Instance.new("Part")
        seg.Anchored     = true
        seg.CanCollide   = false
        seg.CastShadow   = false
        seg.Material     = Enum.Material.Neon
        seg.Color        = Color3.fromRGB(0, 0, 0)
        seg.Transparency = 0.0
        seg.Size         = Vector3.new(RING_THICKNESS, RING_HEIGHT, (2 * math.pi * radius) / RING_SEGMENTS + 0.01)
        seg.Parent       = workspace
        table.insert(ringParts, seg)
    end
end

local function updateRingPosition()
    if #ringParts == 0 then return end
    local char = me.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local center = root.Position + Vector3.new(0, -2.5, 0)
    for i, seg in ipairs(ringParts) do
        local angle = (i / RING_SEGMENTS) * math.pi * 2
        seg.CFrame = CFrame.new(center + Vector3.new(math.cos(angle) * AUTO_STEAL_PROX_RADIUS, 0, math.sin(angle) * AUTO_STEAL_PROX_RADIUS)) * CFrame.Angles(0, -angle, 0)
    end
end

local function showRing(radius)
    buildRing(radius)
    circleConnection = RunService.Heartbeat:Connect(updateRingPosition)
end

-- ══════════════════════════════════════
--  GALAXY SKY
-- ══════════════════════════════════════

local galaxySkyOn = false
local galaxySkyLabel, galaxySkyTrack, galaxySkyThumb = makeOptionRow(ContentArea, "GALAXY SKY", 10)

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
        if galaxyBloom then galaxyBloom.Intensity = 1.2 + math.sin(t * 2) * 0.4 end
    end)
end

local function disableGalaxySkyBright()
    if galaxySkyBrightConn then galaxySkyBrightConn:Disconnect(); galaxySkyBrightConn = nil end
    if galaxySkyBright then galaxySkyBright:Destroy(); galaxySkyBright = nil end
    if originalSkybox then originalSkybox.Parent = Lighting end
    if galaxyBloom then galaxyBloom:Destroy(); galaxyBloom = nil end
    if galaxyCC then galaxyCC:Destroy(); galaxyCC = nil end
    for _, obj in ipairs(galaxyPlanets) do if obj then obj:Destroy() end end
    galaxyPlanets = {}
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
end

galaxySkyTrack.MouseButton1Click:Connect(function()
    galaxySkyOn = not galaxySkyOn
    if galaxySkyOn then
        toggleOn(galaxySkyLabel, galaxySkyTrack, galaxySkyThumb)
        enableGalaxySkyBright()
    else
        toggleOff(galaxySkyLabel, galaxySkyTrack, galaxySkyThumb)
        disableGalaxySkyBright()
    end
end)

-- ══════════════════════════════════════
--  STEAL RADIUS (anclado abajo en MainFrame)
-- ══════════════════════════════════════

local radiusRow = Instance.new("Frame")
radiusRow.Size                   = UDim2.new(1, -20, 0, 44)
radiusRow.Position               = UDim2.new(0, 10, 1, -54)
radiusRow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
radiusRow.BackgroundTransparency = 0
radiusRow.BorderSizePixel        = 0
radiusRow.ZIndex                 = 4
radiusRow.Parent                 = MainFrame
Instance.new("UICorner", radiusRow).CornerRadius = UDim.new(0, 7)

local radiusTitleLabel = Instance.new("TextLabel")
radiusTitleLabel.Text="STEAL RADIUS"; radiusTitleLabel.Size=UDim2.new(0,130,1,0); radiusTitleLabel.Position=UDim2.new(0,10,0,0)
radiusTitleLabel.BackgroundTransparency=1; radiusTitleLabel.TextColor3=Color3.fromRGB(255,0,0)
radiusTitleLabel.TextSize=13; radiusTitleLabel.Font=Enum.Font.GothamBlack
radiusTitleLabel.TextXAlignment=Enum.TextXAlignment.Left; radiusTitleLabel.ZIndex=5; radiusTitleLabel.Parent=radiusRow

local radiusInput = Instance.new("TextBox")
radiusInput.Text = tostring(AUTO_STEAL_PROX_RADIUS)
radiusInput.Size = UDim2.new(0, 70, 0, 28)
radiusInput.Position = UDim2.new(1, -80, 0.5, -14)
radiusInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
radiusInput.BorderSizePixel = 0
radiusInput.TextColor3 = Color3.fromRGB(180, 180, 180)
radiusInput.PlaceholderText = "7"
radiusInput.TextSize = 13
radiusInput.Font = Enum.Font.GothamBlack
radiusInput.ClearTextOnFocus = true
radiusInput.ZIndex = 6
radiusInput.Parent = radiusRow
Instance.new("UICorner", radiusInput).CornerRadius = UDim.new(0, 5)
local radiusInputStroke = Instance.new("UIStroke", radiusInput)
radiusInputStroke.Color = Color3.fromRGB(255,0,0); radiusInputStroke.Thickness = 1.2

radiusInput.FocusLost:Connect(function()
    local val = tonumber(radiusInput.Text)
    if val and val > 0 then
        AUTO_STEAL_PROX_RADIUS = math.floor(val)
        radiusInput.Text = tostring(AUTO_STEAL_PROX_RADIUS)
        buildRing(AUTO_STEAL_PROX_RADIUS)
    else
        radiusInput.Text = tostring(AUTO_STEAL_PROX_RADIUS)
    end
end)

-- ══════════════════════════════════════
--  DRAG HUB
-- ══════════════════════════════════════

local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ══════════════════════════════════════
--  FORCE BLACK BG
-- ══════════════════════════════════════

RS.Heartbeat:Connect(function()
    MainFrame.BackgroundColor3         = Color3.fromRGB(0, 0, 0)
    MainFrame.BackgroundTransparency   = 0
    ContentArea.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    ContentArea.BackgroundTransparency = 0
    radiusRow.BackgroundColor3         = Color3.fromRGB(0, 0, 0)
    radiusRow.BackgroundTransparency   = 0
end)

-- ══════════════════════════════════════
--  APERTURA + RING
-- ══════════════════════════════════════

MainFrame.Size = UDim2.new(0, 300, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 700)}):Play()

showRing(AUTO_STEAL_PROX_RADIUS)
