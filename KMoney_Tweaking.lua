-- ██████████████████████████████████████████
-- ██         DRAGON HUB - by Script         ██
-- ██     discord.gg/dragonhub               ██
-- ██████████████████████████████████████████

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")

local LocalPlayer   = Players.LocalPlayer
local Character     = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid      = Character:WaitForChild("Humanoid")
local RootPart      = Character:WaitForChild("HumanoidRootPart")

-- ══════════════════════════════════════════
--              CONFIGURACIÓN
-- ══════════════════════════════════════════
local Config = {
    NormalSpeed  = 59.5,
    CarrySpeed   = 30,
    Mode         = "Carry",    -- "Carry" | "Normal"
    ModeKey      = Enum.KeyCode.Q,
    SpeedEnabled = true,
}

-- ══════════════════════════════════════════
--               GUI BUILDER
-- ══════════════════════════════════════════
local function Make(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15), props):Play()
end

-- ── ScreenGui ──────────────────────────────
local ScreenGui = Make("ScreenGui", {
    Name            = "DragonHub",
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    Parent          = (syn and syn.protect_gui and syn.protect_gui(Instance.new("ScreenGui")) and nil) or
                      (gethui and gethui()) or
                      LocalPlayer:WaitForChild("PlayerGui"),
})
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ── Speed Billboard (encima del personaje, compatible con shift lock) ──
local SpeedLabel = nil

local function CreateSpeedBillboard()
    local char = LocalPlayer.Character
    if not char then return nil end
    local old = char:FindFirstChild("SpeedBillboard")
    if old then old:Destroy() end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local billboard = Make("BillboardGui", {
        Name         = "SpeedBillboard",
        Size         = UDim2.new(0, 200, 0, 40),
        StudsOffset  = Vector3.new(0, 3.5, 0),
        AlwaysOnTop  = true,
        ResetOnSpawn = false,
        Parent       = root,
    })
    return Make("TextLabel", {
        Name                   = "SpeedLabel",
        Text                   = "Speed: 0.0",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(255, 255, 255),
        TextStrokeColor3       = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = 0.3,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 18,
        Parent                 = billboard,
    })
end

SpeedLabel = CreateSpeedBillboard()

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid  = newChar:WaitForChild("Humanoid")
    RootPart  = newChar:WaitForChild("HumanoidRootPart")
    task.wait(0.15)
    SpeedLabel = CreateSpeedBillboard()
end)

-- ── Main Frame ────────────────────────────
local MainFrame = Make("Frame", {
    Name            = "MainFrame",
    Size            = UDim2.new(0, 310, 0, 460),
    Position        = UDim2.new(0.5, -155, 0.5, -230),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
    Parent          = ScreenGui,
})
Make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainFrame })
Make("UIStroke", { Color = Color3.fromRGB(50, 50, 50), Thickness = 1, Parent = MainFrame })

-- ── Drag Logic ────────────────────────────
do
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ── Top Bar ───────────────────────────────
local TopBar = Make("Frame", {
    Name            = "TopBar",
    Size            = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(22, 22, 22),
    BorderSizePixel = 0,
    Parent          = MainFrame,
})
Make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TopBar })

Make("TextLabel", {
    Name            = "Title",
    Text            = "DRAGON HUB",
    Size            = UDim2.new(0, 100, 1, 0),
    Position        = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(255, 255, 255),
    Font            = Enum.Font.GothamBlack,
    TextSize        = 13,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = TopBar,
})

Make("TextLabel", {
    Name            = "Discord",
    Text            = "discord.gg/dragonhub",
    Size            = UDim2.new(0, 140, 1, 0),
    Position        = UDim2.new(0, 120, 0, 0),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(130, 130, 130),
    Font            = Enum.Font.Gotham,
    TextSize        = 10,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = TopBar,
})

-- Close Button
local CloseBtn = Make("TextButton", {
    Name            = "CloseBtn",
    Text            = "−",
    Size            = UDim2.new(0, 28, 0, 20),
    Position        = UDim2.new(1, -32, 0.5, -10),
    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
    TextColor3      = Color3.fromRGB(200, 200, 200),
    Font            = Enum.Font.GothamBold,
    TextSize        = 18,
    BorderSizePixel = 0,
    Parent          = TopBar,
})
Make("UICorner", { CornerRadius = UDim.new(0, 5), Parent = CloseBtn })
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, { Size = UDim2.new(0, 310, 0, 0) }, 0.2)
    task.delay(0.22, function() MainFrame.Visible = false end)
end)

-- ── Left Panel (Tabs) ────────────────────
local LeftPanel = Make("Frame", {
    Name            = "LeftPanel",
    Size            = UDim2.new(0, 100, 1, -40),
    Position        = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Parent          = MainFrame,
})
Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = LeftPanel })

-- ── Right Panel ──────────────────────────
local RightPanel = Make("Frame", {
    Name            = "RightPanel",
    Size            = UDim2.new(1, -108, 1, -48),
    Position        = UDim2.new(0, 106, 0, 44),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
    Parent          = MainFrame,
})

-- ══════════════════════════════════════════
--              TAB SYSTEM
-- ══════════════════════════════════════════
local Tabs    = {}
local TabBtns = {}

local function CreateTab(name, index)
    local btn = Make("TextButton", {
        Name            = name .. "Tab",
        Text            = name,
        Size            = UDim2.new(1, -10, 0, 36),
        Position        = UDim2.new(0, 5, 0, 8 + (index - 1) * 42),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        TextColor3      = Color3.fromRGB(180, 180, 180),
        Font            = Enum.Font.GothamSemibold,
        TextSize        = 12,
        BorderSizePixel = 0,
        Parent          = LeftPanel,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = btn })

    local content = Make("Frame", {
        Name            = name .. "Content",
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible         = false,
        Parent          = RightPanel,
    })

    Tabs[name]    = content
    TabBtns[name] = btn
    return btn, content
end

local function SelectTab(name)
    for n, c in pairs(Tabs) do
        c.Visible = (n == name)
        local btn = TabBtns[n]
        if n == name then
            Tween(btn, { BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                         TextColor3 = Color3.fromRGB(10, 10, 10) })
            btn.Font = Enum.Font.GothamBlack
        else
            Tween(btn, { BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                         TextColor3 = Color3.fromRGB(180, 180, 180) })
            btn.Font = Enum.Font.GothamSemibold
        end
    end
end

-- ══════════════════════════════════════════
--         CREATE ALL TABS
-- ══════════════════════════════════════════
local tabNames = {"Speed", "Bat Aimbot", "Mechanics", "Movement", "Settings"}
for i, name in ipairs(tabNames) do
    local btn, _ = CreateTab(name, i)
    btn.MouseButton1Click:Connect(function() SelectTab(name) end)
end

-- ══════════════════════════════════════════
--       SPEED TAB CONTENT
-- ══════════════════════════════════════════
local SpeedContent = Tabs["Speed"]

-- Section title
Make("TextLabel", {
    Text            = "SPEED CONFIGURATION",
    Size            = UDim2.new(1, -10, 0, 20),
    Position        = UDim2.new(0, 5, 0, 6),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(100, 100, 100),
    Font            = Enum.Font.GothamBold,
    TextSize        = 9,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = SpeedContent,
})

local function CreateSliderRow(parent, label, desc, value, yPos, callback)
    local row = Make("Frame", {
        Size            = UDim2.new(1, -6, 0, 48),
        Position        = UDim2.new(0, 3, 0, yPos),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Parent          = parent,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = row })

    Make("TextLabel", {
        Text            = label,
        Size            = UDim2.new(0.65, 0, 0, 20),
        Position        = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        TextColor3      = Color3.fromRGB(220, 220, 220),
        Font            = Enum.Font.GothamSemibold,
        TextSize        = 12,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = row,
    })

    Make("TextLabel", {
        Text            = desc,
        Size            = UDim2.new(0.65, 0, 0, 14),
        Position        = UDim2.new(0, 10, 0, 22),
        BackgroundTransparency = 1,
        TextColor3      = Color3.fromRGB(90, 90, 90),
        Font            = Enum.Font.Gotham,
        TextSize        = 9,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = row,
    })

    local valBox = Make("Frame", {
        Size            = UDim2.new(0, 48, 0, 26),
        Position        = UDim2.new(1, -54, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Parent          = row,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = valBox })

    local valLabel = Make("TextLabel", {
        Text            = tostring(value),
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3      = Color3.fromRGB(220, 220, 220),
        Font            = Enum.Font.GothamBold,
        TextSize        = 12,
        Parent          = valBox,
    })

    -- Slider bar
    local sliderBG = Make("Frame", {
        Size            = UDim2.new(1, -20, 0, 4),
        Position        = UDim2.new(0, 10, 1, -8),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 0,
        Parent          = row,
    })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderBG })

    local sliderFill = Make("Frame", {
        Size            = UDim2.new(value / 100, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        BorderSizePixel = 0,
        Parent          = sliderBG,
    })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderFill })

    -- Draggable slider
    local dragging = false
    sliderBG.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (inp.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local newVal = math.round(rel * 200 * 10) / 10  -- 0 to 200 range
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(newVal)
            if callback then callback(newVal) end
        end
    end)

    return valLabel
end

-- Normal Speed Row
local NSpeedLabel = CreateSliderRow(SpeedContent, "Normal Speed", "Walking / Running speed",
    Config.NormalSpeed, 30, function(v)
        Config.NormalSpeed = v
    end)

-- Carry Speed Row
local CSpeedLabel = CreateSliderRow(SpeedContent, "Carry Speed", "Speed while holding an item",
    Config.CarrySpeed, 86, function(v)
        Config.CarrySpeed = v
    end)

-- Mode Row
local modeRow = Make("Frame", {
    Size            = UDim2.new(1, -6, 0, 40),
    Position        = UDim2.new(0, 3, 0, 142),
    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
    BorderSizePixel = 0,
    Parent          = SpeedContent,
})
Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = modeRow })

Make("TextLabel", {
    Text            = "Mode",
    Size            = UDim2.new(0.5, 0, 1, 0),
    Position        = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(220, 220, 220),
    Font            = Enum.Font.GothamSemibold,
    TextSize        = 12,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = modeRow,
})

local modeDisplay = Make("Frame", {
    Size            = UDim2.new(0, 80, 0, 26),
    Position        = UDim2.new(1, -86, 0.5, -13),
    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
    BorderSizePixel = 0,
    Parent          = modeRow,
})
Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = modeDisplay })

local modeLabel = Make("TextLabel", {
    Text            = Config.Mode,
    Size            = UDim2.new(0.7, 0, 1, 0),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(220, 220, 220),
    Font            = Enum.Font.GothamSemibold,
    TextSize        = 11,
    Parent          = modeDisplay,
})

local keyLabel = Make("TextLabel", {
    Text            = "Q",
    Size            = UDim2.new(0, 20, 0, 20),
    Position        = UDim2.new(1, -22, 0.5, -10),
    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
    TextColor3      = Color3.fromRGB(200, 200, 200),
    Font            = Enum.Font.GothamBold,
    TextSize        = 10,
    Parent          = modeDisplay,
})
Make("UICorner", { CornerRadius = UDim.new(0, 4), Parent = keyLabel })

-- Toggle mode on Q
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Config.ModeKey then
        Config.Mode = (Config.Mode == "Carry") and "Normal" or "Carry"
        modeLabel.Text = Config.Mode
    end
end)

-- ══════════════════════════════════════════
--       BAT AIMBOT TAB
-- ══════════════════════════════════════════
local BatContent = Tabs["Bat Aimbot"]

Make("TextLabel", {
    Text            = "BAT AIMBOT",
    Size            = UDim2.new(1, -10, 0, 20),
    Position        = UDim2.new(0, 5, 0, 6),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(100, 100, 100),
    Font            = Enum.Font.GothamBold,
    TextSize        = 9,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = BatContent,
})

-- Toggle row helper
local function CreateToggle(parent, label, yPos, default, callback)
    local row = Make("Frame", {
        Size            = UDim2.new(1, -6, 0, 38),
        Position        = UDim2.new(0, 3, 0, yPos),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Parent          = parent,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = row })

    Make("TextLabel", {
        Text            = label,
        Size            = UDim2.new(0.7, 0, 1, 0),
        Position        = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3      = Color3.fromRGB(220, 220, 220),
        Font            = Enum.Font.GothamSemibold,
        TextSize        = 12,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = row,
    })

    local state  = default
    local togBG  = Make("Frame", {
        Size            = UDim2.new(0, 42, 0, 22),
        Position        = UDim2.new(1, -48, 0.5, -11),
        BackgroundColor3 = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent          = row,
    })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = togBG })

    local knob = Make("Frame", {
        Size            = UDim2.new(0, 16, 0, 16),
        Position        = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent          = togBG,
    })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

    local btn = Make("TextButton", {
        Text            = "",
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent          = row,
    })
    btn.MouseButton1Click:Connect(function()
        state = not state
        Tween(togBG, { BackgroundColor3 = state and Color3.fromRGB(240,240,240) or Color3.fromRGB(55,55,55) })
        Tween(knob, { Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) })
        if callback then callback(state) end
    end)
end

local AimbotEnabled = false
CreateToggle(BatContent, "Enable Aimbot", 30, false, function(v) AimbotEnabled = v end)
CreateToggle(BatContent, "Silent Aim",     76, false, function(v) end)
CreateToggle(BatContent, "Show FOV Circle",122, false, function(v) end)

-- ══════════════════════════════════════════
--       MECHANICS TAB
-- ══════════════════════════════════════════
local MechContent = Tabs["Mechanics"]

Make("TextLabel", {
    Text            = "MECHANICS",
    Size            = UDim2.new(1, -10, 0, 20),
    Position        = UDim2.new(0, 5, 0, 6),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(100, 100, 100),
    Font            = Enum.Font.GothamBold,
    TextSize        = 9,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = MechContent,
})
CreateToggle(MechContent, "Infinite Jump",  30, false, function(v)
    if v then
        UserInputService.JumpRequest:Connect(function()
            if Character and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)
CreateToggle(MechContent, "No Clip",        76, false, function(v)
    if v then
        RunService.Stepped:Connect(function()
            for _, p in pairs(Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end)
CreateToggle(MechContent, "Anti Ragdoll",  122, false, function(v) end)

-- ══════════════════════════════════════════
--       MOVEMENT TAB
-- ══════════════════════════════════════════
local MovContent = Tabs["Movement"]

Make("TextLabel", {
    Text            = "MOVEMENT",
    Size            = UDim2.new(1, -10, 0, 20),
    Position        = UDim2.new(0, 5, 0, 6),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(100, 100, 100),
    Font            = Enum.Font.GothamBold,
    TextSize        = 9,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = MovContent,
})
CreateToggle(MovContent, "Fly",            30, false, function(v) end)
CreateToggle(MovContent, "Speed Boost",    76, false, function(v)
    if v then Config.NormalSpeed = 100 else Config.NormalSpeed = 16 end
end)
CreateToggle(MovContent, "Low Gravity",   122, false, function(v)
    workspace.Gravity = v and 30 or 196.2
end)

-- ══════════════════════════════════════════
--       SETTINGS TAB
-- ══════════════════════════════════════════
local SetContent = Tabs["Settings"]

Make("TextLabel", {
    Text            = "SETTINGS",
    Size            = UDim2.new(1, -10, 0, 20),
    Position        = UDim2.new(0, 5, 0, 6),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(100, 100, 100),
    Font            = Enum.Font.GothamBold,
    TextSize        = 9,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = SetContent,
})
CreateToggle(SetContent, "Show Speed HUD", 30, true, function(v)
    SpeedLabel.Visible = v
end)
CreateToggle(SetContent, "Keybind Mode",   76, false, function(v) end)

-- Discord watermark
Make("TextLabel", {
    Text            = "discord.gg/dragonhub",
    Size            = UDim2.new(1, -10, 0, 20),
    Position        = UDim2.new(0, 5, 1, -30),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(70, 70, 70),
    Font            = Enum.Font.Gotham,
    TextSize        = 9,
    TextXAlignment  = Enum.TextXAlignment.Center,
    Parent          = SetContent,
})

-- ══════════════════════════════════════════
--           SPEED ENGINE (RunService)
-- ══════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    -- Refresh character refs
    Character = LocalPlayer.Character
    if not Character then return end
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end

    -- Apply speed
    if Config.SpeedEnabled then
        local spd = (Config.Mode == "Carry") and Config.CarrySpeed or Config.NormalSpeed
        Humanoid.WalkSpeed = spd
    end

    -- Update Speed Billboard
    if SpeedLabel and SpeedLabel.Parent then
        local vel = RootPart.Velocity
        local flat = Vector3.new(vel.X, 0, vel.Z).Magnitude
        SpeedLabel.Text = string.format("Speed: %.1f", flat)
    end
end)

-- ══════════════════════════════════════════
--    Default tab & open animation
-- ══════════════════════════════════════════
SelectTab("Speed")
MainFrame.Size = UDim2.new(0, 310, 0, 0)
Tween(MainFrame, { Size = UDim2.new(0, 310, 0, 460) }, 0.25)

print("[DRAGON HUB] Loaded! discord.gg/dragonhub")
