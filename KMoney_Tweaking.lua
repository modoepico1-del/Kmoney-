-- ╔══════════════════════════════════════╗
-- ║        DEMONTIME HUB x NEBULA TP     ║
-- ╚══════════════════════════════════════╝
-- Merged: Anti-Ragdoll TP + Medusa Mode + Full GUI

repeat task.wait() until game:IsLoaded()

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

local me          = Players.LocalPlayer
local player      = me
local LocalPlayer = me
local RS          = RunService
local Camera      = workspace.CurrentCamera

-- ══════════════════════════════════════
--  SAVE / LOAD CONFIG
-- ══════════════════════════════════════

local CONFIG_FILE = "DEMONTIME_config.json"

local function saveConfig()
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({}))
    end)
end

local savedCfg = {}
pcall(function() savedCfg = HttpService:JSONDecode(readfile(CONFIG_FILE)) end)

-- ══════════════════════════════════════
--  NEBULA TP: POSITIONS & STATE
-- ══════════════════════════════════════

local RIGHT_STEP_1 = Vector3.new(-468, -6, 41)
local RIGHT_STEP_2 = Vector3.new(-473, -6, 24)
local RIGHT_STEP_3 = Vector3.new(-484, -4, 20)

local LEFT_STEP_1  = Vector3.new(-469, -6, 78)
local LEFT_STEP_2  = Vector3.new(-471, -6, 96)
local LEFT_STEP_3  = Vector3.new(-484, -4, 99)

local ReturnLeftActive  = true
local ReturnRightActive = false
local medusaMode        = false
local justTeleported    = false
local TP_COOLDOWN       = 0.2
local connections       = {}

local function cleanup()
    for _, c in pairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}
end

local function isRagdolled(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Physics or
       state == Enum.HumanoidStateType.Ragdoll or
       state == Enum.HumanoidStateType.FallingDown then
        return true
    end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Motor6D") and obj.Enabled == false then
            return true
        end
    end
    return false
end

local function forceExitRagdoll(char)
    if not char then return end
    if justTeleported then return end
    justTeleported = true

    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not (root and hum) then
        task.delay(TP_COOLDOWN, function() justTeleported = false end)
        return
    end

    local isLeft = ReturnLeftActive
    local step1  = isLeft and LEFT_STEP_1 or RIGHT_STEP_1
    local step2  = isLeft and LEFT_STEP_2 or RIGHT_STEP_2
    local step3  = isLeft and LEFT_STEP_3 or RIGHT_STEP_3

    root.CFrame = CFrame.new(step1 + Vector3.new(0, 3, 0))
    root.Velocity                  = Vector3.new(0,0,0)
    root.AssemblyLinearVelocity    = Vector3.new(0,0,0)
    root.AssemblyAngularVelocity   = Vector3.new(0,0,0)

    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    task.wait(0.04)
    hum:ChangeState(Enum.HumanoidStateType.Running)
    Camera.CameraSubject = hum

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Motor6D") and not obj.Enabled then
            obj.Enabled = true
        end
    end

    task.spawn(function()
        task.wait(0.07)
        if root and root.Parent then
            root.CFrame = CFrame.new(step2 + Vector3.new(0, 2.5, 0))
            root.Velocity               = Vector3.new(0,0,0)
            root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end)

    if not medusaMode then
        task.spawn(function()
            task.wait(0.14)
            if root and root.Parent then
                root.CFrame = CFrame.new(step3 + Vector3.new(0, 2, 0))
                root.Velocity               = Vector3.new(0,0,0)
                root.AssemblyLinearVelocity = Vector3.new(0,0,0)
            end
        end)
    end

    task.delay(TP_COOLDOWN, function()
        justTeleported = false
    end)
end

-- Main heartbeat loop
local hb = RunService.Heartbeat:Connect(function()
    local char = player.Character
    if char and isRagdolled(char) then
        forceExitRagdoll(char)
        task.delay(0.2, function()
            if char and char.Parent and isRagdolled(char) then
                forceExitRagdoll(char)
            end
        end)
    end
end)
table.insert(connections, hb)

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.4)
    cleanup()
    local newHb = RunService.Heartbeat:Connect(function()
        if newChar and newChar.Parent and isRagdolled(newChar) then
            forceExitRagdoll(newChar)
        end
    end)
    table.insert(connections, newHb)
end)

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

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Text             = "DEMONTIME"
ToggleBtn.Size             = UDim2.new(0, 110, 0, 28)
ToggleBtn.Position         = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.TextColor3       = Color3.fromRGB(255, 0, 0)
ToggleBtn.TextSize         = 12
ToggleBtn.Font             = Enum.Font.GothamBlack
ToggleBtn.BorderSizePixel  = 0
ToggleBtn.ZIndex           = 10
ToggleBtn.Parent           = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent       = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color        = Color3.fromRGB(255, 0, 0)
ToggleStroke.Thickness    = 1.5
ToggleStroke.Transparency = 0.0
ToggleStroke.Parent       = ToggleBtn

-- GUI height aumentado para los 3 toggles extra
local MainFrame = Instance.new("Frame")
MainFrame.Size               = UDim2.new(0, 300, 0, 360)
MainFrame.Position           = UDim2.new(0, 16, 0.5, -180)
MainFrame.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel    = 0
MainFrame.Active             = true
MainFrame.Draggable          = true
MainFrame.ClipsDescendants   = true
MainFrame.Visible            = true
MainFrame.Parent             = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent       = MainFrame

local function addNeonBorder(parent, thickness, color)
    local glow = Instance.new("Frame")
    glow.Size                   = UDim2.new(1, thickness*6, 1, thickness*6)
    glow.Position               = UDim2.new(0, -thickness*3, 0, -thickness*3)
    glow.BackgroundColor3       = color
    glow.BackgroundTransparency = 0.72
    glow.BorderSizePixel        = 0
    glow.ZIndex                 = parent.ZIndex - 1
    glow.Parent                 = parent
    local gc = Instance.new("UICorner")
    gc.CornerRadius = UDim.new(0, 14)
    gc.Parent       = glow
    local mid = Instance.new("Frame")
    mid.Size                   = UDim2.new(1, thickness*3, 1, thickness*3)
    mid.Position               = UDim2.new(0, -thickness*1.5, 0, -thickness*1.5)
    mid.BackgroundColor3       = color
    mid.BackgroundTransparency = 0.50
    mid.BorderSizePixel        = 0
    mid.ZIndex                 = parent.ZIndex - 1
    mid.Parent                 = parent
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 12)
    mc.Parent       = mid
    local stroke = Instance.new("UIStroke")
    stroke.Color           = color
    stroke.Thickness       = thickness
    stroke.Transparency    = 0.0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent          = parent
end

addNeonBorder(MainFrame, 2, Color3.fromRGB(255, 0, 0))

local TitleBar = Instance.new("Frame")
TitleBar.Size              = UDim2.new(1, 0, 0, 42)
TitleBar.Position          = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
TitleBar.BorderSizePixel   = 0
TitleBar.ZIndex            = 3
TitleBar.Parent            = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent       = TitleBar

local TitleLine = Instance.new("Frame")
TitleLine.Size             = UDim2.new(1, 0, 0, 2)
TitleLine.Position         = UDim2.new(0, 0, 1, -2)
TitleLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TitleLine.BorderSizePixel  = 0
TitleLine.ZIndex           = 4
TitleLine.Parent           = TitleBar

local lineGlow = Instance.new("Frame")
lineGlow.Size                   = UDim2.new(1, 0, 0, 8)
lineGlow.Position               = UDim2.new(0, 0, 1, -5)
lineGlow.BackgroundColor3       = Color3.fromRGB(255, 0, 0)
lineGlow.BackgroundTransparency = 0.6
lineGlow.BorderSizePixel        = 0
lineGlow.ZIndex                 = 3
lineGlow.Parent                 = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text                   = "DEMONTIME x NEBULA TP"
TitleLabel.Size                   = UDim2.new(1, -50, 1, 0)
TitleLabel.Position               = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3             = Color3.fromRGB(255, 0, 0)
TitleLabel.TextSize               = 14
TitleLabel.Font                   = Enum.Font.GothamBlack
TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
TitleLabel.ZIndex                 = 5
TitleLabel.Parent                 = TitleBar

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color        = Color3.fromRGB(0, 0, 0)
TitleStroke.Thickness    = 2.5
TitleStroke.Transparency = 0.0
TitleStroke.Parent       = TitleLabel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text              = "X"
CloseBtn.Size              = UDim2.new(0, 28, 0, 28)
CloseBtn.Position          = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
CloseBtn.TextColor3        = Color3.fromRGB(255, 0, 0)
CloseBtn.TextSize          = 13
CloseBtn.Font              = Enum.Font.GothamBlack
CloseBtn.BorderSizePixel   = 0
CloseBtn.ZIndex            = 6
CloseBtn.Parent            = TitleBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent       = CloseBtn

local CloseBtnStroke = Instance.new("UIStroke")
CloseBtnStroke.Color        = Color3.fromRGB(255, 0, 0)
CloseBtnStroke.Thickness    = 1.2
CloseBtnStroke.Transparency = 0.1
CloseBtnStroke.Parent       = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180,0,0), TextColor3 = Color3.fromRGB(255,255,255)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0,0,0), TextColor3 = Color3.fromRGB(255,0,0)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,300,0,0)}):Play()
    task.delay(0.27, function()
        MainFrame.Visible = false
        MainFrame.Size    = UDim2.new(0,300,0,360)
    end)
end)

local ContentArea = Instance.new("Frame")
ContentArea.Size             = UDim2.new(1, 0, 1, -102)
ContentArea.Position         = UDim2.new(0, 0, 0, 42)
ContentArea.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ContentArea.BorderSizePixel  = 0
ContentArea.ZIndex           = 3
ContentArea.Parent           = MainFrame

-- ══════════════════════════════════════
--  HELPER: ROW + TOGGLE
-- ══════════════════════════════════════

local function makeOptionRow(parent, labelText, yPos)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -20, 0, 44)
    row.Position         = UDim2.new(0, 10, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
    row.BorderSizePixel  = 0
    row.ZIndex           = 4
    row.Parent           = parent
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 7)
    rc.Parent       = row
    local rs2 = Instance.new("UIStroke")
    rs2.Color        = Color3.fromRGB(255, 0, 0)
    rs2.Thickness    = 0.8
    rs2.Transparency = 0.5
    rs2.Parent       = row
    local lbl = Instance.new("TextLabel")
    lbl.Text                  = labelText
    lbl.Size                  = UDim2.new(1, -70, 1, 0)
    lbl.Position              = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency= 1
    lbl.TextColor3            = Color3.fromRGB(220, 220, 220)
    lbl.TextSize              = 14
    lbl.Font                  = Enum.Font.GothamBlack
    lbl.TextXAlignment        = Enum.TextXAlignment.Left
    lbl.ZIndex                = 5
    lbl.Parent                = row
    local track = Instance.new("TextButton")
    track.Text             = ""
    track.Size             = UDim2.new(0, 44, 0, 24)
    track.Position         = UDim2.new(1, -54, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel  = 0
    track.ZIndex           = 5
    track.Parent           = row
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent       = track
    local thumb = Instance.new("Frame")
    thumb.Size             = UDim2.new(0, 18, 0, 18)
    thumb.Position         = UDim2.new(0, 3, 0.5, -9)
    thumb.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    thumb.BorderSizePixel  = 0
    thumb.ZIndex           = 6
    thumb.Parent           = track
    local thc = Instance.new("UICorner")
    thc.CornerRadius = UDim.new(1, 0)
    thc.Parent       = thumb
    return lbl, track, thumb
end

local function toggleOn(lbl, track, thumb)
    TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200,0,0)}):Play()
    TweenService:Create(thumb, TweenInfo.new(0.2), {Position = UDim2.new(0,23,0.5,-9), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
    TweenService:Create(lbl,   TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,80,80)}):Play()
end
local function toggleOff(lbl, track, thumb)
    TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
    TweenService:Create(thumb, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0.5,-9), BackgroundColor3 = Color3.fromRGB(180,180,180)}):Play()
    TweenService:Create(lbl,   TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220,220,220)}):Play()
end

-- ══════════════════════════════════════
--  SECTION LABEL helper
-- ══════════════════════════════════════

local function makeSectionLabel(parent, text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Text                  = text
    lbl.Size                  = UDim2.new(1, -20, 0, 20)
    lbl.Position              = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency= 1
    lbl.TextColor3            = Color3.fromRGB(255, 60, 60)
    lbl.TextSize              = 11
    lbl.Font                  = Enum.Font.GothamBlack
    lbl.TextXAlignment        = Enum.TextXAlignment.Left
    lbl.ZIndex                = 5
    lbl.Parent                = parent
end

-- ══════════════════════════════════════
--  NEBULA TP ROWS (dentro de ContentArea)
-- ══════════════════════════════════════

makeSectionLabel(ContentArea, "── NEBULA DUELS TP ──", 6)

-- Return Left
local lblL, trackL, thumbL = makeOptionRow(ContentArea, "Return-Left", 28)
local stateL = true
toggleOn(lblL, trackL, thumbL)

-- Return Right
local lblR, trackR, thumbR = makeOptionRow(ContentArea, "Return-Right", 80)
local stateR = false

-- Medusa Mode
local lblM, trackM, thumbM = makeOptionRow(ContentArea, "Medusa Mode", 132)
local stateM = false

-- Discord label
local discordRow = Instance.new("Frame")
discordRow.Size             = UDim2.new(1, -20, 0, 30)
discordRow.Position         = UDim2.new(0, 10, 0, 185)
discordRow.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
discordRow.BorderSizePixel  = 0
discordRow.ZIndex           = 4
discordRow.Parent           = ContentArea
Instance.new("UICorner", discordRow).CornerRadius = UDim.new(0, 7)
local discordStroke = Instance.new("UIStroke", discordRow)
discordStroke.Color = Color3.fromRGB(88, 101, 242) discordStroke.Thickness = 0.8 discordStroke.Transparency = 0.4

local discordTagLbl = Instance.new("TextLabel", discordRow)
discordTagLbl.Text = "Discord:  discord.gg/nebula5"
discordTagLbl.Size = UDim2.new(0.65, 0, 1, 0)
discordTagLbl.Position = UDim2.new(0, 10, 0, 0)
discordTagLbl.BackgroundTransparency = 1
discordTagLbl.TextColor3 = Color3.fromRGB(180, 180, 255)
discordTagLbl.TextSize = 11
discordTagLbl.Font = Enum.Font.GothamSemibold
discordTagLbl.TextXAlignment = Enum.TextXAlignment.Left
discordTagLbl.ZIndex = 5

local copyBtn = Instance.new("TextButton", discordRow)
copyBtn.Text = "Copy"
copyBtn.Size = UDim2.new(0, 54, 0, 22)
copyBtn.Position = UDim2.new(1, -62, 0.5, -11)
copyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextSize = 11
copyBtn.Font = Enum.Font.GothamBold
copyBtn.BorderSizePixel = 0
copyBtn.ZIndex = 6
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
copyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("discord.gg/nebula5") end)
    copyBtn.Text = "✓"
    task.wait(1.5)
    copyBtn.Text = "Copy"
end)

-- ── Toggle logic con exclusividad Left/Right ──

local function setLeftToggle(v)
    stateL = v
    if v then toggleOn(lblL, trackL, thumbL) else toggleOff(lblL, trackL, thumbL) end
end
local function setRightToggle(v)
    stateR = v
    if v then toggleOn(lblR, trackR, thumbR) else toggleOff(lblR, trackR, thumbR) end
end

trackL.MouseButton1Click:Connect(function()
    stateL = not stateL
    ReturnLeftActive = stateL
    setLeftToggle(stateL)
    if stateL then
        ReturnRightActive = false
        setRightToggle(false)
    end
end)

trackR.MouseButton1Click:Connect(function()
    stateR = not stateR
    ReturnRightActive = stateR
    setRightToggle(stateR)
    if stateR then
        ReturnLeftActive = false
        setLeftToggle(false)
    end
end)

trackM.MouseButton1Click:Connect(function()
    stateM = not stateM
    medusaMode = stateM
    if stateM then toggleOn(lblM, trackM, thumbM) else toggleOff(lblM, trackM, thumbM) end
end)

-- ══════════════════════════════════════
--  SAVE CONFIG
-- ══════════════════════════════════════

local SaveFrame = Instance.new("Frame")
SaveFrame.Size                   = UDim2.new(1, -24, 0, 40)
SaveFrame.Position               = UDim2.new(0, 12, 1, -52)
SaveFrame.BackgroundTransparency = 1
SaveFrame.BorderSizePixel        = 0
SaveFrame.ZIndex                 = 6
SaveFrame.Parent                 = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size                   = UDim2.new(1, 0, 1, 0)
SaveBtn.BackgroundTransparency = 1
SaveBtn.Text                   = "SAVE CONFIG"
SaveBtn.Font                   = Enum.Font.GothamBlack
SaveBtn.TextSize               = 13
SaveBtn.TextColor3             = Color3.fromRGB(255, 80, 80)
SaveBtn.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
SaveBtn.TextStrokeTransparency = 0
SaveBtn.BorderSizePixel        = 0
SaveBtn.ZIndex                 = 7
SaveBtn.Parent                 = SaveFrame

Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)

local saveStroke = Instance.new("UIStroke", SaveBtn)
saveStroke.Color        = Color3.fromRGB(255, 0, 0)
saveStroke.Thickness    = 1.5
saveStroke.Transparency = 0

SaveBtn.MouseEnter:Connect(function()
    TweenService:Create(SaveBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
end)
SaveBtn.MouseLeave:Connect(function()
    TweenService:Create(SaveBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255,80,80)}):Play()
end)
SaveBtn.MouseButton1Click:Connect(function()
    saveConfig()
    SaveBtn.Text = "SAVED!"
    task.wait(1)
    SaveBtn.Text = "SAVE CONFIG"
end)

-- ══════════════════════════════════════
--  TOGGLE VENTANA
-- ══════════════════════════════════════

ToggleBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,300,0,0)}):Play()
        task.delay(0.27, function()
            MainFrame.Visible = false
            MainFrame.Size    = UDim2.new(0,300,0,360)
        end)
    else
        MainFrame.Size    = UDim2.new(0,300,0,0)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,300,0,360)}):Play()
    end
end)

-- ══════════════════════════════════════
--  ANIMACIONES NEON
-- ══════════════════════════════════════

task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(TitleStroke,  TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.6}):Play()
        task.wait(1.2)
        TweenService:Create(TitleStroke,  TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.0}):Play()
        task.wait(1.2)
    end
end)
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(TitleLine,    TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency=0.55}):Play()
        task.wait(1.0)
        TweenService:Create(TitleLine,    TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency=0.0}):Play()
        task.wait(1.0)
    end
end)
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(ToggleStroke, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.6}):Play()
        task.wait(1.0)
        TweenService:Create(ToggleStroke, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.0}):Play()
        task.wait(1.0)
    end
end)

-- ══════════════════════════════════════
--  APERTURA Y ARRASTRE
-- ══════════════════════════════════════

MainFrame.Size = UDim2.new(0, 300, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,300,0,360)}):Play()

local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
end)
