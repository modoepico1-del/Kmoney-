-- ══════════════════════════════════════
--  LOCK TARGET FLOTANTE (derecha, movible)
-- ══════════════════════════════════════

local LOCK_RADIUS = 50
local lockOn = false
local lockTarget = nil
local lockConnection = nil

-- Frame flotante
local LockFrame = Instance.new("Frame")
LockFrame.Size               = UDim2.new(0, 220, 0, 130)
LockFrame.Position           = UDim2.new(1, -230, 0, 4)  -- derecha
LockFrame.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
LockFrame.BackgroundTransparency = 0
LockFrame.BorderSizePixel    = 0
LockFrame.Active             = true
LockFrame.ZIndex             = 10
LockFrame.Parent             = ScreenGui
Instance.new("UICorner", LockFrame).CornerRadius = UDim.new(0, 10)
local lfStroke = Instance.new("UIStroke", LockFrame)
lfStroke.Color = Color3.fromRGB(255, 0, 0); lfStroke.Thickness = 1.2

-- Title
local lockTitle = Instance.new("TextLabel")
lockTitle.Text               = "LOCK TARGET"
lockTitle.Size               = UDim2.new(1, 0, 0, 36)
lockTitle.Position           = UDim2.new(0, 0, 0, 0)
lockTitle.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
lockTitle.BackgroundTransparency = 0
lockTitle.TextColor3         = Color3.fromRGB(255, 0, 0)
lockTitle.TextSize           = 15
lockTitle.Font               = Enum.Font.GothamBlack
lockTitle.ZIndex             = 11
lockTitle.Parent             = LockFrame
Instance.new("UICorner", lockTitle).CornerRadius = UDim.new(0, 10)

-- Toggle row
local lockRow = Instance.new("Frame")
lockRow.Size             = UDim2.new(1, -16, 0, 38)
lockRow.Position         = UDim2.new(0, 8, 0, 42)
lockRow.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
lockRow.BorderSizePixel  = 0
lockRow.ZIndex           = 11
lockRow.Parent           = LockFrame
Instance.new("UICorner", lockRow).CornerRadius = UDim.new(0, 7)
local lrStroke = Instance.new("UIStroke", lockRow)
lrStroke.Color = Color3.fromRGB(255,0,0); lrStroke.Thickness = 0.8; lrStroke.Transparency = 0.5

local lockLabel = Instance.new("TextLabel")
lockLabel.Text               = "ENABLE"
lockLabel.Size               = UDim2.new(1, -60, 1, 0)
lockLabel.Position           = UDim2.new(0, 12, 0, 0)
lockLabel.BackgroundTransparency = 1
lockLabel.TextColor3         = Color3.fromRGB(220, 220, 220)
lockLabel.TextSize           = 13
lockLabel.Font               = Enum.Font.GothamBlack
lockLabel.TextXAlignment     = Enum.TextXAlignment.Left
lockLabel.ZIndex             = 12
lockLabel.Parent             = lockRow

local lockTrack = Instance.new("TextButton")
lockTrack.Text               = ""
lockTrack.Size               = UDim2.new(0, 44, 0, 24)
lockTrack.Position           = UDim2.new(1, -52, 0.5, -12)
lockTrack.BackgroundColor3   = Color3.fromRGB(40, 40, 40)
lockTrack.BorderSizePixel    = 0
lockTrack.ZIndex             = 12
lockTrack.Parent             = lockRow
Instance.new("UICorner", lockTrack).CornerRadius = UDim.new(1, 0)

local lockThumb = Instance.new("Frame")
lockThumb.Size               = UDim2.new(0, 18, 0, 18)
lockThumb.Position           = UDim2.new(0, 3, 0.5, -9)
lockThumb.BackgroundColor3   = Color3.fromRGB(180, 180, 180)
lockThumb.BorderSizePixel    = 0
lockThumb.ZIndex             = 13
lockThumb.Parent             = lockTrack
Instance.new("UICorner", lockThumb).CornerRadius = UDim.new(1, 0)

-- Range row
local rangeRow = Instance.new("Frame")
rangeRow.Size             = UDim2.new(1, -16, 0, 38)
rangeRow.Position         = UDim2.new(0, 8, 0, 86)
rangeRow.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
rangeRow.BorderSizePixel  = 0
rangeRow.ZIndex           = 11
rangeRow.Parent           = LockFrame
Instance.new("UICorner", rangeRow).CornerRadius = UDim.new(0, 7)
local rrStroke = Instance.new("UIStroke", rangeRow)
rrStroke.Color = Color3.fromRGB(255,0,0); rrStroke.Thickness = 0.8; rrStroke.Transparency = 0.5

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Text              = "RANGE"
rangeLabel.Size              = UDim2.new(0, 90, 1, 0)
rangeLabel.Position          = UDim2.new(0, 12, 0, 0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3        = Color3.fromRGB(220, 220, 220)
rangeLabel.TextSize          = 13
rangeLabel.Font              = Enum.Font.GothamBlack
rangeLabel.TextXAlignment    = Enum.TextXAlignment.Left
rangeLabel.ZIndex            = 12
rangeLabel.Parent            = rangeRow

local lockTextbox = Instance.new("TextBox")
lockTextbox.Size             = UDim2.new(0, 60, 0, 26)
lockTextbox.Position         = UDim2.new(1, -68, 0.5, -13)
lockTextbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
lockTextbox.BorderSizePixel  = 0
lockTextbox.TextColor3       = Color3.fromRGB(180, 180, 180)
lockTextbox.Font             = Enum.Font.GothamBlack
lockTextbox.TextSize         = 13
lockTextbox.Text             = tostring(LOCK_RADIUS)
lockTextbox.ClearTextOnFocus = false
lockTextbox.ZIndex           = 13
lockTextbox.Parent           = rangeRow
Instance.new("UICorner", lockTextbox).CornerRadius = UDim.new(0, 5)
local ltStroke = Instance.new("UIStroke", lockTextbox)
ltStroke.Color = Color3.fromRGB(255, 0, 0); ltStroke.Thickness = 1.0

lockTextbox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(lockTextbox.Text)
        if num and num > 5 and num <= 500 then
            LOCK_RADIUS = num
        else
            lockTextbox.Text = tostring(LOCK_RADIUS)
        end
    end
end)

-- ══════════════════════════════════════
--  LOCK LOGIC
-- ══════════════════════════════════════

local function findLockTarget()
    local hrp = me.Character and me.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= me and plr.Character then
            local eh  = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local dist = (eh.Position - hrp.Position).Magnitude
                if dist < LOCK_RADIUS and dist < minDist then
                    minDist = dist
                    nearest = plr.Character
                end
            end
        end
    end
    return nearest
end

local function enableLock()
    lockConnection = RunService.Heartbeat:Connect(function()
        if not lockOn then return end
        local char = me.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        lockTarget = findLockTarget()
        if lockTarget then
            local targetHRP = lockTarget:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local dir = (targetHRP.Position - hrp.Position).Unit
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
            end
        end
    end)
end

local function disableLock()
    if lockConnection then lockConnection:Disconnect(); lockConnection = nil end
    lockTarget = nil
end

lockTrack.MouseButton1Click:Connect(function()
    lockOn = not lockOn
    if lockOn then
        TweenService:Create(lockTrack, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200,0,0)}):Play()
        TweenService:Create(lockThumb, TweenInfo.new(0.2), {Position = UDim2.new(0,23,0.5,-9), BackgroundColor3 = Color3.fromRGB(255,0,0)}):Play()
        TweenService:Create(lockLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,0,0)}):Play()
        enableLock()
    else
        TweenService:Create(lockTrack, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
        TweenService:Create(lockThumb, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0.5,-9), BackgroundColor3 = Color3.fromRGB(180,180,180)}):Play()
        TweenService:Create(lockLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220,220,220)}):Play()
        disableLock()
    end
end)

-- ══════════════════════════════════════
--  DRAG LOCK FRAME
-- ══════════════════════════════════════

local lfDragging, lfDragInput, lfDragStart, lfStartPos = false, nil, nil, nil

lockTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        lfDragging = true
        lfDragStart = input.Position
        lfStartPos = LockFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then lfDragging = false end
        end)
    end
end)
lockTitle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        lfDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == lfDragInput and lfDragging then
        local delta = input.Position - lfDragStart
        LockFrame.Position = UDim2.new(
            lfStartPos.X.Scale, lfStartPos.X.Offset + delta.X,
            lfStartPos.Y.Scale, lfStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Force black
RS.Heartbeat:Connect(function()
    LockFrame.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    LockFrame.BackgroundTransparency = 0
    lockTitle.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    lockTitle.BackgroundTransparency = 0
end)
