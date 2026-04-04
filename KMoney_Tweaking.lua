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
--      AUTO ROUTE CONSTANTS
-- ══════════════════════════════════════════
local NORMAL_SPEED = 60
local SLOW_SPEED   = 29
local POS_L1    = Vector3.new(-476.48, -6.28,  92.73)
local POS_L2    = Vector3.new(-483.12, -4.95,  94.80)
local POS_R1    = Vector3.new(-476.16, -6.52,  25.62)
local POS_R2    = Vector3.new(-483.04, -5.09,  23.14)
local LFINAL    = Vector3.new(-473.38, -8.40,  22.34)
local RFINAL    = Vector3.new(-476.17, -7.91,  97.91)

local autoRouteActive   = false
local autoRouteThread   = nil
local currentRouteSide  = nil  -- "L" or "R"

local function walkToPoint(target, speed, tolerance)
    tolerance = tolerance or 3.5
    local char = LocalPlayer.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return false end

    local bv = root:FindFirstChild("DragonRouteBV")
    if not bv then
        bv           = Instance.new("BodyVelocity")
        bv.Name      = "DragonRouteBV"
        bv.MaxForce  = Vector3.new(1e5, 0, 1e5)
        bv.Velocity  = Vector3.zero
        bv.P         = 1e4
        bv.Parent    = root
    end

    while autoRouteActive do
        char = LocalPlayer.Character
        if not char then break end
        root = char:FindFirstChild("HumanoidRootPart")
        if not root then break end

        local diff = target - root.Position
        local dist = Vector3.new(diff.X, 0, diff.Z).Magnitude

        if dist <= tolerance then
            bv.Velocity = Vector3.zero
            return true
        end

        local dir    = Vector3.new(diff.X, 0, diff.Z).Unit
        local factor = math.clamp(dist / 10, 0.3, 1)
        bv.Velocity  = dir * (speed * factor)

        task.wait()
    end

    local bv2 = root and root:FindFirstChild("DragonRouteBV")
    if bv2 then bv2:Destroy() end
    return false
end

local function cleanRouteBV()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bv = root:FindFirstChild("DragonRouteBV")
    if bv then bv:Destroy() end
end

local function runRoute(side)
    autoRouteActive  = true
    currentRouteSide = side

    local p1, p2, pFinal
    if side == "L" then
        p1 = POS_L1; p2 = POS_L2; pFinal = LFINAL
    else
        p1 = POS_R1; p2 = POS_R2; pFinal = RFINAL
    end

    if not walkToPoint(p1, NORMAL_SPEED) then cleanRouteBV(); return end
    task.wait(0.1)
    if not walkToPoint(p2, NORMAL_SPEED) then cleanRouteBV(); return end
    task.wait(0.1)
    if not walkToPoint(pFinal, SLOW_SPEED, 2) then cleanRouteBV(); return end

    cleanRouteBV()
    autoRouteActive  = false
    currentRouteSide = nil
end

local function stopRoute()
    autoRouteActive  = false
    currentRouteSide = nil
    cleanRouteBV()
end

-- ── ANTI RAGDOLL + ANTI KNOCKBACK ────────
local ragdollConnections = {}
local antiRagdollMode    = nil
local cachedCharData     = {}

local MAX_KNOCKBACK_VELOCITY = 28
local MAX_VERTICAL_VELOCITY  = 35

local function disconnectAllRagdoll()
    for _, conn in pairs(ragdollConnections) do pcall(function() conn:Disconnect() end) end
    ragdollConnections = {}
end

local function cacheCharacterData()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    cachedCharData = {
        character        = char,
        humanoid         = hum,
        root             = root,
        originalWalkSpeed = hum.WalkSpeed,
        originalJumpPower = hum.JumpPower,
        isFrozen         = false,
    }
    return true
end

local function isRagdolled()
    if not cachedCharData.humanoid then return false end
    local state = cachedCharData.humanoid:GetState()
    if state == Enum.HumanoidStateType.Physics
    or state == Enum.HumanoidStateType.Ragdoll
    or state == Enum.HumanoidStateType.FallingDown then return true end
    return false
end

local function removeRagdollConstraints()
    if not cachedCharData.character then return end
    for _, descendant in ipairs(cachedCharData.character:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint")
        or (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            pcall(function() descendant:Destroy() end)
        end
    end
end

local function forceExitRagdoll()
    local hum  = cachedCharData.humanoid
    local root = cachedCharData.root
    if not hum or not root then return end
    if hum.Health > 0 then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    root.Anchored = false
    local vel = root.AssemblyLinearVelocity
    if vel.Magnitude > 80 then
        root.AssemblyLinearVelocity  = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function clampKnockback()
    local root = cachedCharData.root
    if not root then return end
    local vel = root.AssemblyLinearVelocity
    local horizontal = Vector3.new(vel.X, 0, vel.Z)
    local vertical   = vel.Y

    local needsClamp = false
    local clampedH   = horizontal
    local clampedV   = vertical

    if horizontal.Magnitude > MAX_KNOCKBACK_VELOCITY then
        clampedH   = horizontal.Unit * MAX_KNOCKBACK_VELOCITY
        needsClamp = true
    end
    if vertical > MAX_VERTICAL_VELOCITY then
        clampedV   = MAX_VERTICAL_VELOCITY
        needsClamp = true
    end

    if needsClamp then
        root.AssemblyLinearVelocity = Vector3.new(clampedH.X, clampedV, clampedH.Z)
    end
end

local function antiRagdollLoop()
    while antiRagdollMode do
        task.wait()
        if not cachedCharData.humanoid then continue end

        if isRagdolled() then
            removeRagdollConstraints()
            forceExitRagdoll()
        end

        clampKnockback()

        local cam = workspace.CurrentCamera
        if cam and cachedCharData.humanoid and cam.CameraSubject ~= cachedCharData.humanoid then
            cam.CameraSubject = cachedCharData.humanoid
        end
    end
end

local function toggleAntiRagdoll(enable)
    if enable then
        disconnectAllRagdoll()
        if not cacheCharacterData() then return end
        antiRagdollMode = "v2"

        local charConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if antiRagdollMode then cacheCharacterData() end
        end)
        table.insert(ragdollConnections, charConn)
        task.spawn(antiRagdollLoop)
    else
        antiRagdollMode = nil
        disconnectAllRagdoll()
        cachedCharData  = {}
    end
end

-- ══════════════════════════════════════════
--           INF JUMP
-- ══════════════════════════════════════════
local INF_JUMP_FORCE = 50
local CLAMP_FALL     = 80
local infJumpEnabled = false

local function getHRP()
    local c = LocalPlayer.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

UserInputService.JumpRequest:Connect(function()
    if not infJumpEnabled then return end
    local h = getHRP() if not h then return end
    h.AssemblyLinearVelocity = Vector3.new(
        h.AssemblyLinearVelocity.X,
        INF_JUMP_FORCE,
        h.AssemblyLinearVelocity.Z
    )
end)

RunService.Heartbeat:Connect(function()
    if not infJumpEnabled then return end
    local h = getHRP() if not h then return end
    if h.AssemblyLinearVelocity.Y < -CLAMP_FALL then
        h.AssemblyLinearVelocity = Vector3.new(
            h.AssemblyLinearVelocity.X,
            -CLAMP_FALL,
            h.AssemblyLinearVelocity.Z
        )
    end
end)

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

-- ── Speed Billboard ──────────────────────
local speedBB = nil

local function makeSpeedBB()
    local c = LocalPlayer.Character
    if not c then return end
    local head = c:FindFirstChild("Head")
    if not head then return end
    if speedBB then pcall(function() speedBB:Destroy() end) end

    speedBB             = Instance.new("BillboardGui")
    speedBB.Name        = "DragonSpeedBB"
    speedBB.Adornee     = head
    speedBB.Size        = UDim2.new(0, 160, 0, 36)
    speedBB.StudsOffset = Vector3.new(0, 3.2, 0)
    speedBB.AlwaysOnTop = true
    speedBB.Parent      = head

    local lbl                    = Instance.new("TextLabel")
    lbl.Name                     = "SpeedLbl"
    lbl.Size                     = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency   = 1
    lbl.TextColor3               = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeColor3         = Color3.fromRGB(0, 0, 0)
    lbl.TextStrokeTransparency   = 0.3
    lbl.Font                     = Enum.Font.GothamBold
    lbl.TextScaled               = true
    lbl.Text                     = "Speed: 0"
    lbl.Parent                   = speedBB
end

makeSpeedBB()

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid  = newChar:WaitForChild("Humanoid")
    RootPart  = newChar:WaitForChild("HumanoidRootPart")
    task.wait(0.15)
    makeSpeedBB()
end)

RunService.RenderStepped:Connect(function()
    if not speedBB or not speedBB.Parent then return end
    local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local lbl = speedBB:FindFirstChild("SpeedLbl")
    if not lbl then return end
    local v = hrp.AssemblyLinearVelocity
    lbl.Text = "Speed: " .. math.floor(Vector3.new(v.X, 0, v.Z).Magnitude)
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
            local newVal = math.round(rel * 200 * 10) / 10
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(newVal)
            if callback then callback(newVal) end
        end
    end)

    return valLabel
end

local NSpeedLabel = CreateSliderRow(SpeedContent, "Normal Speed", "Walking / Running speed",
    Config.NormalSpeed, 30, function(v)
        Config.NormalSpeed = v
    end)

local CSpeedLabel = CreateSliderRow(SpeedContent, "Carry Speed", "Speed while holding an item",
    Config.CarrySpeed, 86, function(v)
        Config.CarrySpeed = v
    end)

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
CreateToggle(BatContent, "Enable Aimbot",   30, false, function(v) AimbotEnabled = v end)
CreateToggle(BatContent, "Silent Aim",      76, false, function(v) end)
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

-- ── INFINITE JUMP (integrado) ─────────────
CreateToggle(MechContent, "Infinite Jump", 30, false, function(v)
    infJumpEnabled = v
end)

CreateToggle(MechContent, "No Clip", 76, false, function(v)
    if v then
        RunService.Stepped:Connect(function()
            for _, p in pairs(Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end)

CreateToggle(MechContent, "Anti Ragdoll", 122, false, function(v)
    toggleAntiRagdoll(v)
end)

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
CreateToggle(MovContent, "Fly",           30, false, function(v) end)
CreateToggle(MovContent, "Speed Boost",   76, false, function(v)
    if v then Config.NormalSpeed = 100 else Config.NormalSpeed = 16 end
end)
CreateToggle(MovContent, "Low Gravity",  122, false, function(v)
    workspace.Gravity = v and 30 or 196.2
end)

Make("TextLabel", {
    Text            = "AUTO ROUTE",
    Size            = UDim2.new(1, -10, 0, 16),
    Position        = UDim2.new(0, 5, 0, 170),
    BackgroundTransparency = 1,
    TextColor3      = Color3.fromRGB(100, 100, 100),
    Font            = Enum.Font.GothamBold,
    TextSize        = 9,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = MovContent,
})

local function MakeRouteBtn(label, xPos, side)
    local btn = Make("TextButton", {
        Text            = label,
        Size            = UDim2.new(0.44, 0, 0, 34),
        Position        = UDim2.new(xPos, 0, 0, 190),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        TextColor3      = Color3.fromRGB(210, 210, 210),
        Font            = Enum.Font.GothamBold,
        TextSize        = 11,
        BorderSizePixel = 0,
        Parent          = MovContent,
    })
    Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = btn })

    btn.MouseButton1Click:Connect(function()
        if currentRouteSide == side then
            stopRoute()
            Tween(btn, { BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                         TextColor3 = Color3.fromRGB(210, 210, 210) })
        else
            stopRoute()
            task.wait(0.05)
            Tween(btn, { BackgroundColor3 = Color3.fromRGB(220, 220, 220),
                         TextColor3 = Color3.fromRGB(10, 10, 10) })
            task.spawn(function()
                runRoute(side)
                Tween(btn, { BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                             TextColor3 = Color3.fromRGB(210, 210, 210) })
            end)
        end
    end)
    return btn
end

MakeRouteBtn("ROUTE LEFT  ←",  0.03, "L")
MakeRouteBtn("ROUTE RIGHT →",  0.52, "R")

local stopBtn = Make("TextButton", {
    Text            = "■  STOP ROUTE",
    Size            = UDim2.new(0.94, 0, 0, 28),
    Position        = UDim2.new(0.03, 0, 0, 232),
    BackgroundColor3 = Color3.fromRGB(50, 25, 25),
    TextColor3      = Color3.fromRGB(220, 100, 100),
    Font            = Enum.Font.GothamBold,
    TextSize        = 11,
    BorderSizePixel = 0,
    Parent          = MovContent,
})
Make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = stopBtn })
stopBtn.MouseButton1Click:Connect(function()
    stopRoute()
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
    if speedBB then speedBB.Enabled = v end
end)
CreateToggle(SetContent, "Keybind Mode", 76, false, function(v) end)

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
--   SPEED ENGINE v2 - BodyVelocity bypass
-- ══════════════════════════════════════════
local speedBV     = nil
local speedActive = false

local function removeSpeedBV()
    if speedBV and speedBV.Parent then
        speedBV:Destroy()
    end
    speedBV = nil
end

local function getSpeedBV()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local existing = root:FindFirstChild("DragonSpeedBV")
    if existing then return existing end

    local bv          = Instance.new("BodyVelocity")
    bv.Name           = "DragonSpeedBV"
    bv.MaxForce       = Vector3.new(1e5, 0, 1e5)
    bv.Velocity       = Vector3.zero
    bv.P              = 1e4
    bv.Parent         = root
    speedBV           = bv
    return bv
end

RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then
        removeSpeedBV()
        return
    end

    local char = LocalPlayer.Character
    if not char then removeSpeedBV(); return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then removeSpeedBV(); return end

    if hum.Health <= 0 then removeSpeedBV(); return end

    local moveDir = hum.MoveDirection
    local spd     = (Config.Mode == "Carry") and Config.CarrySpeed or Config.NormalSpeed

    local bv = getSpeedBV()
    if not bv then return end

    if moveDir.Magnitude > 0.1 then
        bv.Velocity = moveDir * spd
    else
        bv.Velocity = Vector3.zero
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    speedBV   = nil
    Character = newChar
    Humanoid  = newChar:WaitForChild("Humanoid")
    RootPart  = newChar:WaitForChild("HumanoidRootPart")
end)

-- ══════════════════════════════════════════
--    Default tab & open animation
-- ══════════════════════════════════════════
SelectTab("Speed")
MainFrame.Size = UDim2.new(0, 310, 0, 0)
Tween(MainFrame, { Size = UDim2.new(0, 310, 0, 460) }, 0.25)

print("[DRAGON HUB] Loaded! discord.gg/dragonhub")
