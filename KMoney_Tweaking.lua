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

local TitleLine = Instance.new("Frame")
TitleLine.Size             = UDim2.new(1, 0, 0, 2)
TitleLine.Position         = UDim2.new(0, 0, 1, -2)
TitleLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleLine.BorderSizePixel  = 0
TitleLine.ZIndex           = 4
TitleLine.Parent           = TitleBar

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
--  DRAG
-- ══════════════════════════════════════

local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
--  APERTURA
-- ══════════════════════════════════════

MainFrame.Size = UDim2.new(0, 300, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 700)}):Play()

-- ══════════════════════════════════════
--  FORCE BLACK BG
-- ══════════════════════════════════════

RS.Heartbeat:Connect(function()
    MainFrame.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    MainFrame.BackgroundTransparency = 0
    ContentArea.BackgroundColor3     = Color3.fromRGB(0, 0, 0)
    ContentArea.BackgroundTransparency = 0
end)
