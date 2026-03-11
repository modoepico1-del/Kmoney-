local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HRP       = character:WaitForChild("HumanoidRootPart", 5)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    HRP       = newChar:WaitForChild("HumanoidRootPart", 5)
end)

-- ─── STEAL LOGIC ───────────────────────────────────────────────
local stealEnabled  = false
local stealCooldown = 0.2
local HOLD_DURATION = 0.5
local stealThread   = nil

local function getPromptPart(prompt)
    local p = prompt.Parent
    if p:IsA("BasePart")   then return p end
    if p:IsA("Model")      then return p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart") end
    if p:IsA("Attachment") then return p.Parent end
    return p:FindFirstChildWhichIsA("BasePart", true)
end

local function findNearestStealPrompt()
    if not HRP then return nil end
    local nearest, minDist = nil, math.huge
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, desc in pairs(plots:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText == "Steal" then
            local part = getPromptPart(desc)
            if part then
                local dist = (HRP.Position - part.Position).Magnitude
                if dist < minDist then minDist = dist; nearest = desc end
            end
        end
    end
    return nearest
end

local function triggerStealPrompt(prompt)
    if not prompt or not prompt:IsDescendantOf(workspace) then return end
    prompt.MaxActivationDistance = 9e9
    prompt.RequiresLineOfSight   = false
    prompt.ClickablePrompt       = true
    local ok = pcall(function() fireproximityprompt(prompt, 9e9, HOLD_DURATION) end)
    if not ok then
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(HOLD_DURATION)
            prompt:InputHoldEnd()
        end)
    end
end

local function startAutoSteal()
    if stealThread then return end
    stealThread = task.spawn(function()
        while stealEnabled do
            local p = findNearestStealPrompt()
            if p then triggerStealPrompt(p) end
            task.wait(stealCooldown)
        end
        stealThread = nil
    end)
end

local function stopAutoSteal()
    stealEnabled = false
    stealThread  = nil
end

-- ─── GUI ───────────────────────────────────────────────────────
if CoreGui:FindFirstChild("KMoneyHub") then
    CoreGui:FindFirstChild("KMoneyHub"):Destroy()
end

local CYAN     = Color3.fromRGB(0, 230, 255)
local CYAN_DIM = Color3.fromRGB(0, 160, 200)
local BG       = Color3.fromRGB(2, 2, 4)
local CARD     = Color3.fromRGB(4, 7, 12)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "KMoneyHub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 999
pcall(function() ScreenGui.Parent = CoreGui end)

local Main = Instance.new("Frame", ScreenGui)
Main.Name             = "Main"
Main.Size             = UDim2.new(0, 262, 0, 120)
Main.Position         = UDim2.new(0.5, -131, 0.5, -60)
Main.BackgroundColor3 = BG
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local neonStroke = Instance.new("UIStroke", Main)
neonStroke.Color     = CYAN
neonStroke.Thickness = 2

local TopLine = Instance.new("Frame", Main)
TopLine.Size             = UDim2.new(1, 0, 0, 2)
TopLine.BackgroundColor3 = CYAN
TopLine.BorderSizePixel  = 0

-- Title bar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size             = UDim2.new(1, 0, 0, 44)
TitleBar.Position         = UDim2.new(0, 0, 0, 2)
TitleBar.BackgroundColor3 = CARD
TitleBar.BorderSizePixel  = 0

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size                   = UDim2.new(1, -46, 1, 0)
TitleLbl.Position               = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text                   = "KMONEY HUB"
TitleLbl.TextColor3             = CYAN
TitleLbl.TextStrokeColor3       = CYAN
TitleLbl.TextStrokeTransparency = 0.4
TitleLbl.Font                   = Enum.Font.GothamBold
TitleLbl.TextSize               = 17
TitleLbl.TextXAlignment         = Enum.TextXAlignment.Left

-- $ button — fondo totalmente transparente
local DollarBtn = Instance.new("TextButton", TitleBar)
DollarBtn.Size                   = UDim2.new(0, 28, 0, 28)
DollarBtn.Position               = UDim2.new(1, -36, 0.5, -14)
DollarBtn.BackgroundTransparency = 1
DollarBtn.Text                   = "$"
DollarBtn.TextColor3             = CYAN
DollarBtn.TextStrokeColor3       = CYAN
DollarBtn.TextStrokeTransparency = 0.3
DollarBtn.Font                   = Enum.Font.GothamBold
DollarBtn.TextSize               = 16
DollarBtn.BorderSizePixel        = 0

local dollarStroke = Instance.new("UIStroke", DollarBtn)
dollarStroke.Color     = CYAN
dollarStroke.Thickness = 0

-- Content
local Content = Instance.new("Frame", Main)
Content.Size                   = UDim2.new(1, 0, 1, -47)
Content.Position               = UDim2.new(0, 0, 0, 47)
Content.BackgroundTransparency = 1

-- Toggle row
local Row = Instance.new("Frame", Content)
Row.Size             = UDim2.new(1, -28, 0, 44)
Row.Position         = UDim2.new(0, 14, 0, 12)
Row.BackgroundColor3 = CARD
Row.BorderSizePixel  = 0
Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

local rowStroke = Instance.new("UIStroke", Row)
rowStroke.Color       = CYAN_DIM
rowStroke.Thickness   = 1
rowStroke.Transparency = 0.45

local RowLbl = Instance.new("TextLabel", Row)
RowLbl.Size                   = UDim2.new(1, -60, 1, 0)
RowLbl.Position               = UDim2.new(0, 12, 0, 0)
RowLbl.BackgroundTransparency = 1
RowLbl.Text                   = "Auto Steal"
RowLbl.TextColor3             = Color3.fromRGB(180, 235, 255)
RowLbl.TextStrokeColor3       = CYAN
RowLbl.TextStrokeTransparency = 0.7
RowLbl.Font                   = Enum.Font.GothamBold
RowLbl.TextSize               = 14
RowLbl.TextXAlignment         = Enum.TextXAlignment.Left

local Toggle = Instance.new("TextButton", Row)
Toggle.Size             = UDim2.new(0, 46, 0, 24)
Toggle.Position         = UDim2.new(1, -54, 0.5, -12)
Toggle.BackgroundColor3 = Color3.fromRGB(10, 20, 32)
Toggle.Text             = ""
Toggle.BorderSizePixel  = 0
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke", Toggle)
toggleStroke.Color       = CYAN_DIM
toggleStroke.Thickness   = 1
toggleStroke.Transparency = 0.5

local Knob = Instance.new("Frame", Toggle)
Knob.Size             = UDim2.new(0, 18, 0, 18)
Knob.Position         = UDim2.new(0, 3, 0.5, -9)
Knob.BackgroundColor3 = Color3.fromRGB(50, 80, 100)
Knob.BorderSizePixel  = 0
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

-- ─── TOGGLE CLICK ──────────────────────────────────────────────
local ti = TweenInfo.new(0.18, Enum.EasingStyle.Quad)

Toggle.MouseButton1Click:Connect(function()
    stealEnabled = not stealEnabled
    if stealEnabled then
        startAutoSteal()
        TweenService:Create(Toggle, ti, {BackgroundColor3 = CYAN}):Play()
        TweenService:Create(Knob, ti, {
            Position         = UDim2.new(1, -21, 0.5, -9),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        }):Play()
        toggleStroke.Color        = CYAN
        toggleStroke.Transparency = 0
    else
        stopAutoSteal()
        TweenService:Create(Toggle, ti, {BackgroundColor3 = Color3.fromRGB(10, 20, 32)}):Play()
        TweenService:Create(Knob, ti, {
            Position         = UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = Color3.fromRGB(50, 80, 100),
        }):Play()
        toggleStroke.Color        = CYAN_DIM
        toggleStroke.Transparency = 0.5
    end
end)

-- ─── DRAGGABLE ─────────────────────────────────────────────────
do
    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = Main.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- ─── $ = MINIMIZAR / RESTAURAR ─────────────────────────────────
local minimized = false
DollarBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0, 262, 0, 48) or UDim2.new(0, 262, 0, 120)
    }):Play()
end)

-- ─── NEON PULSE ────────────────────────────────────────────────
task.spawn(function()
    local t = 0
    while ScreenGui.Parent do
        t = t + 0.045
        local pulse = (math.sin(t) + 1) / 2
        neonStroke.Transparency = 0.05 + pulse * 0.5
        task.wait(0.03)
    end
end)

-- ─── OPEN ANIMATION ────────────────────────────────────────────
Main.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(Main,
    TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 262, 0, 120)}
):Play()
