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
local HttpService      = game:GetService("HttpService")

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

-- ══════════════════════════════════════
--  NEON BORDER
-- ══════════════════════════════════════

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
--  HELPER TOGGLE ROW
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
--  RADIO VISUAL - RING (solo contorno)
-- ══════════════════════════════════════

local AUTO_STEAL_PROX_RADIUS = 7
local ringParts = {}
local circleConnection = nil
local RING_SEGMENTS = 60  -- cuantos segmentos forma el aro
local RING_THICKNESS = 0.15
local RING_HEIGHT    = 0.08

local function hideRing()
    for _, p in ipairs(ringParts) do
        pcall(function() p:Destroy() end)
    end
    ringParts = {}
    if circleConnection then
        circleConnection:Disconnect()
        circleConnection = nil
    end
end

local function buildRing(radius)
    hideRing()
    for i = 1, RING_SEGMENTS do
        local angle = (i / RING_SEGMENTS) * math.pi * 2
        local seg = Instance.new("Part")
        seg.Anchored    = true
        seg.CanCollide  = false
        seg.CastShadow  = false
        seg.Material    = Enum.Material.Neon
        seg.Color       = Color3.fromRGB(0, 0, 0)
        seg.Transparency = 0.0
        seg.Size        = Vector3.new(RING_THICKNESS, RING_HEIGHT, (2 * math.pi * radius) / RING_SEGMENTS + 0.01)
        seg.Parent      = workspace
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
    local radius = AUTO_STEAL_PROX_RADIUS
    for i, seg in ipairs(ringParts) do
        local angle = (i / RING_SEGMENTS) * math.pi * 2
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        seg.CFrame = CFrame.new(center + Vector3.new(x, 0, z))
                   * CFrame.Angles(0, -angle, 0)
    end
end

local function showRing(radius)
    buildRing(radius)
    circleConnection = RunService.Heartbeat:Connect(updateRingPosition)
end

-- ══════════════════════════════════════
--  AUTO STEAL
-- ══════════════════════════════════════

local autoStealActive = false
local autoStealLabel, autoStealTrack, autoStealThumb = makeOptionRow(ContentArea, "AUTO STEAL", 10)

local autoStealStealConnection = nil
local autoStealAnimalsCache = {}
local autoStealPromptCache = {}
local autoStealInternalCache = {}
local autoStealLastUID = nil
local autoStealIsStealing = false

local animalsDataAS = {}
pcall(function()
    animalsDataAS = require(ReplicatedStorage:WaitForChild("Datas", 5):WaitForChild("Animals", 5))
end)

local function autoSteal_getHRP()
    local char = me.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
end

local function autoSteal_isMyBase(plotName)
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            return yourBase.Enabled == true
        end
    end
    return false
end

local function autoSteal_scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if autoSteal_isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end
    for _, podium in ipairs(podiums:GetChildren()) do
        if podium:IsA("Model") and podium:FindFirstChild("Base") then
            local animalName = "Unknown"
            local spawn = podium.Base:FindFirstChild("Spawn")
            if spawn then
                for _, child in ipairs(spawn:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                        animalName = child.Name
                        local info = animalsDataAS[animalName]
                        if info and info.DisplayName then animalName = info.DisplayName end
                        break
                    end
                end
            end
            table.insert(autoStealAnimalsCache, {
                name = animalName,
                plot = plot.Name,
                slot = podium.Name,
                worldPosition = podium:GetPivot().Position,
                uid = plot.Name .. "_" .. podium.Name,
            })
        end
    end
end

local autoStealScannerStarted = false
local function autoSteal_initScanner()
    if autoStealScannerStarted then return end
    autoStealScannerStarted = true
    task.spawn(function()
        task.wait(2)
        local plots = workspace:WaitForChild("Plots", 10)
        if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:IsA("Model") then autoSteal_scanPlot(plot) end
        end
        plots.ChildAdded:Connect(function(plot)
            if plot:IsA("Model") then task.wait(0.5) autoSteal_scanPlot(plot) end
        end)
        task.spawn(function()
            while task.wait(5) do
                autoStealAnimalsCache = {}
                for _, plot in ipairs(plots:GetChildren()) do
                    if plot:IsA("Model") then autoSteal_scanPlot(plot) end
                end
            end
        end)
    end)
end

local function autoSteal_findPrompt(animalData)
    if not animalData then return nil end
    local cached = autoStealPromptCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local attach = spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            autoStealPromptCache[animalData.uid] = p
            return p
        end
    end
    return nil
end

local function autoSteal_buildCallbacks(prompt)
    if autoStealInternalCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table" then
        for _, conn in ipairs(conns1) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table" then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) then
        autoStealInternalCache[prompt] = data
    end
end

local function autoSteal_execute(prompt)
    local data = autoStealInternalCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    autoStealIsStealing = true
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        task.wait(0.2)
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        task.wait(0.01)
        data.ready = true
        task.wait(0.01)
        autoStealIsStealing = false
    end)
    return true
end

local function autoSteal_attempt(prompt)
    if not prompt or not prompt.Parent then return false end
    autoSteal_buildCallbacks(prompt)
    if not autoStealInternalCache[prompt] then return false end
    return autoSteal_execute(prompt)
end

local function autoSteal_getNearest()
    local hrp = autoSteal_getHRP()
    if not hrp then return nil end
    local nearest, minDist = nil, math.huge
    for _, animalData in ipairs(autoStealAnimalsCache) do
        if autoSteal_isMyBase(animalData.plot) then continue end
        if animalData.worldPosition then
            local dist = (hrp.Position - animalData.worldPosition).Magnitude
            if dist < minDist then minDist = dist nearest = animalData end
        end
    end
    return nearest
end

local function startAutoStealLoop()
    if autoStealStealConnection then autoStealStealConnection:Disconnect() end
    autoStealStealConnection = RunService.Heartbeat:Connect(function()
        if not autoStealActive then return end
        if autoStealIsStealing then return end
        local target = autoSteal_getNearest()
        if not target or not target.worldPosition then return end
        local hrp = autoSteal_getHRP()
        if not hrp then return end
        if (hrp.Position - target.worldPosition).Magnitude > AUTO_STEAL_PROX_RADIUS then return end
        if autoStealLastUID ~= target.uid then autoStealLastUID = target.uid end
        local prompt = autoStealPromptCache[target.uid]
        if not prompt or not prompt.Parent then prompt = autoSteal_findPrompt(target) end
        if prompt then autoSteal_attempt(prompt) end
    end)
end

local function stopAutoStealLoop()
    if autoStealStealConnection then autoStealStealConnection:Disconnect() autoStealStealConnection = nil end
    autoStealIsStealing = false
end

local function enableAutoSteal()
    autoStealActive = true
    autoSteal_initScanner()
    startAutoStealLoop()
end

local function disableAutoSteal()
    autoStealActive = false
    stopAutoStealLoop()
end

autoStealTrack.MouseButton1Click:Connect(function()
    autoStealActive = not autoStealActive
    if autoStealActive then
        toggleOn(autoStealLabel, autoStealTrack, autoStealThumb)
        showRing(AUTO_STEAL_PROX_RADIUS)
        enableAutoSteal()
    else
        toggleOff(autoStealLabel, autoStealTrack, autoStealThumb)
        hideRing()
        disableAutoSteal()
    end
end)

-- ══════════════════════════════════════
--  RADIUS FRAME FLOTANTE (separado, movible)
-- ══════════════════════════════════════

local RadiusFrame = Instance.new("Frame")
RadiusFrame.Size               = UDim2.new(0, 200, 0, 44)
RadiusFrame.Position           = UDim2.new(0, 0, 0, 714)  -- debajo del hub
RadiusFrame.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
RadiusFrame.BackgroundTransparency = 0
RadiusFrame.BorderSizePixel    = 0
RadiusFrame.Active             = true
RadiusFrame.ZIndex             = 10
RadiusFrame.Parent             = ScreenGui
Instance.new("UICorner", RadiusFrame).CornerRadius = UDim.new(0, 8)
local rfStroke = Instance.new("UIStroke", RadiusFrame)
rfStroke.Color = Color3.fromRGB(255,0,0); rfStroke.Thickness = 1.2

local radiusTitleLabel = Instance.new("TextLabel")
radiusTitleLabel.Text = "STEAL RADIUS"
radiusTitleLabel.Size = UDim2.new(0, 110, 1, 0)
radiusTitleLabel.Position = UDim2.new(0, 10, 0, 0)
radiusTitleLabel.BackgroundTransparency = 1
radiusTitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
radiusTitleLabel.TextSize = 12
radiusTitleLabel.Font = Enum.Font.GothamBlack
radiusTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusTitleLabel.ZIndex = 11
radiusTitleLabel.Parent = RadiusFrame

local radiusInput = Instance.new("TextBox")
radiusInput.Text = tostring(AUTO_STEAL_PROX_RADIUS)
radiusInput.Size = UDim2.new(0, 55, 0, 26)
radiusInput.Position = UDim2.new(1, -63, 0.5, -13)
radiusInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
radiusInput.BorderSizePixel = 0
radiusInput.TextColor3 = Color3.fromRGB(180, 180, 180)
radiusInput.PlaceholderText = "7"
radiusInput.TextSize = 13
radiusInput.Font = Enum.Font.GothamBlack
radiusInput.ClearTextOnFocus = true
radiusInput.ZIndex = 12
radiusInput.Parent = RadiusFrame
Instance.new("UICorner", radiusInput).CornerRadius = UDim.new(0, 5)
local riStroke = Instance.new("UIStroke", radiusInput)
riStroke.Color = Color3.fromRGB(255,0,0); riStroke.Thickness = 1.0

radiusInput.FocusLost:Connect(function()
    local val = tonumber(radiusInput.Text)
    if val and val > 0 then
        AUTO_STEAL_PROX_RADIUS = math.floor(val)
        radiusInput.Text = tostring(AUTO_STEAL_PROX_RADIUS)
        if autoStealActive then
            buildRing(AUTO_STEAL_PROX_RADIUS)
        end
    else
        radiusInput.Text = tostring(AUTO_STEAL_PROX_RADIUS)
    end
end)

-- Drag del RadiusFrame
local rfDragging, rfDragInput, rfDragStart, rfStartPos = false, nil, nil, nil

RadiusFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        rfDragging = true
        rfDragStart = input.Position
        rfStartPos = RadiusFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then rfDragging = false end
        end)
    end
end)
RadiusFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        rfDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == rfDragInput and rfDragging then
        local delta = input.Position - rfDragStart
        RadiusFrame.Position = UDim2.new(
            rfStartPos.X.Scale, rfStartPos.X.Offset + delta.X,
            rfStartPos.Y.Scale, rfStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ══════════════════════════════════════
--  DRAG HUB
-- ══════════════════════════════════════

local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
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
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
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
    RadiusFrame.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    RadiusFrame.BackgroundTransparency = 0
end)

-- ══════════════════════════════════════
--  APERTURA
-- ══════════════════════════════════════

MainFrame.Size = UDim2.new(0, 300, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 700)}):Play()
