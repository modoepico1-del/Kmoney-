-- ██████████████████████████████████████████
-- ██         VYSE HUB - Dragon UI           ██
-- ██     discord.gg/jRsgRcun                ██
-- ██████████████████████████████████████████

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local AnimalsData = require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals"))
local Camera      = Workspace.CurrentCamera

-- ══════════════════════════════════════════
--   CONFIG
-- ══════════════════════════════════════════
local CONFIG = {
    AUTO_STEAL_NEAREST  = false,
    INFINITE_JUMP       = false,
    BAT_AIMBOT_AUTOBAT  = false,
    OPTIMIZER           = false,
    ANTI_RAGDOLL        = true,
    SPEED_BOOST         = false,
}

local NORMAL_SPEED   = 60
local CARRY_SPEED    = 30
local speedToggled   = false
local autoBatKey     = Enum.KeyCode.E

-- ══════════════════════════════════════════
--   SAVE / LOAD
-- ══════════════════════════════════════════
local function saveConfig()
    local configData = {
        AUTO_STEAL_NEAREST     = CONFIG.AUTO_STEAL_NEAREST,
        INFINITE_JUMP          = CONFIG.INFINITE_JUMP,
        BAT_AIMBOT_AUTOBAT     = CONFIG.BAT_AIMBOT_AUTOBAT,
        OPTIMIZER              = CONFIG.OPTIMIZER,
        ANTI_RAGDOLL           = CONFIG.ANTI_RAGDOLL,
        SPEED_BOOST            = CONFIG.SPEED_BOOST,
        NORMAL_SPEED           = NORMAL_SPEED,
        CARRY_SPEED            = CARRY_SPEED,
        AUTO_STEAL_PROX_RADIUS = AUTO_STEAL_PROX_RADIUS,
        AUTO_BAT_KEY           = autoBatKey.Name,
    }
    writefile("VyseHub_Config.json", game:GetService("HttpService"):JSONEncode(configData))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Vyse Hub", Text = "Config saved!", Duration = 3
    })
end

local function loadConfig()
    if isfile("VyseHub_Config.json") then
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("VyseHub_Config.json"))
        end)
        if ok and data then
            CONFIG.AUTO_STEAL_NEAREST = data.AUTO_STEAL_NEAREST or false
            CONFIG.INFINITE_JUMP      = data.INFINITE_JUMP or false
            CONFIG.BAT_AIMBOT_AUTOBAT = data.BAT_AIMBOT_AUTOBAT or false
            CONFIG.OPTIMIZER          = data.OPTIMIZER or false
            CONFIG.ANTI_RAGDOLL       = data.ANTI_RAGDOLL ~= nil and data.ANTI_RAGDOLL or true
            CONFIG.SPEED_BOOST        = data.SPEED_BOOST or false
            NORMAL_SPEED              = data.NORMAL_SPEED or 60
            CARRY_SPEED               = data.CARRY_SPEED or 30
            if data.AUTO_STEAL_PROX_RADIUS then AUTO_STEAL_PROX_RADIUS = data.AUTO_STEAL_PROX_RADIUS end
            if data.AUTO_BAT_KEY and Enum.KeyCode[data.AUTO_BAT_KEY] then autoBatKey = Enum.KeyCode[data.AUTO_BAT_KEY] end
            return true
        end
    end
    return false
end

-- ══════════════════════════════════════════
--   VARIABLES
-- ══════════════════════════════════════════
local AUTO_STEAL_PROX_RADIUS = 20
local IsStealing             = false
local StealProgress          = 0
local CurrentStealTarget     = nil
local allAnimalsCache        = {}
local PromptMemoryCache      = {}
local InternalStealCache     = {}
local LastPlayerPosition     = nil
local PlayerVelocity         = Vector3.zero
local stealConnection        = nil
local velocityConnection     = nil

local h, hrp, speedLbl

local autoBatToggled  = false
local hittingCooldown = false
local SAFE_DELAY      = 0.08

local optimizerDescendantConnection = nil
local optimizerLightingConnection   = nil

-- ══════════════════════════════════════════
--   CORE FUNCTIONS (originales, sin cambios)
-- ══════════════════════════════════════════
local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
end

local function isMyBase(plotName)
    local plot = workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then return yourBase.Enabled == true end
    end
    return false
end

local function scanSinglePlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return end
    for _, podium in ipairs(podiums:GetChildren()) do
        if podium:IsA("Model") and podium:FindFirstChild("Base") then
            local animalName = "Unknown"
            local spawn = podium.Base:FindFirstChild("Spawn")
            if spawn then
                for _, child in ipairs(spawn:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                        animalName = child.Name
                        local info = AnimalsData[animalName]
                        if info and info.DisplayName then animalName = info.DisplayName end
                        break
                    end
                end
            end
            table.insert(allAnimalsCache, {
                name = animalName, plot = plot.Name, slot = podium.Name,
                worldPosition = podium:GetPivot().Position,
                uid = plot.Name .. "_" .. podium.Name,
            })
        end
    end
end

local function initializeScanner()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots", 10); if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanSinglePlot(plot) end end
    plots.ChildAdded:Connect(function(plot) if plot:IsA("Model") then task.wait(0.5); scanSinglePlot(plot) end end)
    task.spawn(function()
        while task.wait(5) do
            allAnimalsCache = {}
            for _, plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanSinglePlot(plot) end end
        end
    end)
end

local function findProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    local cached = PromptMemoryCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local plot = workspace.Plots:FindFirstChild(animalData.plot); if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
    local podium  = podiums:FindFirstChild(animalData.slot); if not podium then return nil end
    local base    = podium:FindFirstChild("Base"); if not base then return nil end
    local spawn   = base:FindFirstChild("Spawn"); if not spawn then return nil end
    local attach  = spawn:FindFirstChild("PromptAttachment"); if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then PromptMemoryCache[animalData.uid] = p; return p end
    end
    return nil
end

local function updatePlayerVelocity()
    local currentHrp = getHRP(); if not currentHrp then return end
    local currentPos = currentHrp.Position
    if LastPlayerPosition then
        local dt = task.wait()
        if dt > 0 then PlayerVelocity = (currentPos - LastPlayerPosition) / dt end
    end
    LastPlayerPosition = currentPos
end

local function shouldSteal(animalData)
    if not animalData or not animalData.worldPosition then return false end
    local currentHrp = getHRP(); if not currentHrp then return false end
    return (currentHrp.Position - animalData.worldPosition).Magnitude <= AUTO_STEAL_PROX_RADIUS
end

local function buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 then for _, conn in ipairs(conns1) do if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end end end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 then for _, conn in ipairs(conns2) do if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end end end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then InternalStealCache[prompt] = data end
end

local function executeInternalStealAsync(prompt, animalData)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false; IsStealing = true; StealProgress = 0; CurrentStealTarget = animalData
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do pcall(function() fn() end) end
        local startTime = tick(); local stealDuration = 1.3
        while tick() - startTime < stealDuration do StealProgress = (tick() - startTime) / stealDuration; task.wait(0.01) end
        StealProgress = 1
        for _, fn in ipairs(data.triggerCallbacks) do pcall(function() fn() end) end
        data.ready = true; IsStealing = false; StealProgress = 0; CurrentStealTarget = nil
    end)
    return true
end

local function attemptSteal(prompt, animalData)
    if not prompt or not prompt.Parent then return false end
    buildStealCallbacks(prompt)
    if not InternalStealCache[prompt] then return false end
    return executeInternalStealAsync(prompt, animalData)
end

local function getNearestAnimal()
    local currentHrp = getHRP(); if not currentHrp then return nil end
    local nearest, minDist = nil, math.huge
    for _, animal in ipairs(allAnimalsCache) do
        if isMyBase(animal.plot) then continue end
        local dist = (currentHrp.Position - animal.worldPosition).Magnitude
        if dist < minDist then minDist = dist; nearest = animal end
    end
    return nearest
end

-- ══════════════════════════════════════════
--   BAT FUNCTIONS (originales)
-- ══════════════════════════════════════════
local function getBat()
    local char = LocalPlayer.Character; if not char then return nil end
    local tool = char:FindFirstChild("Bat"); if tool then return tool end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then tool = bp:FindFirstChild("Bat"); if tool then tool.Parent = char; return tool end end
    return nil
end

local function tryHitBat()
    if hittingCooldown then return end
    hittingCooldown = true
    local bat = getBat()
    if bat then pcall(function() bat:Activate(); local evt = bat:FindFirstChildWhichIsA("RemoteEvent"); if evt then evt:FireServer() end end) end
    task.delay(SAFE_DELAY, function() hittingCooldown = false end)
end

local function getClosestPlayer()
    local closestPlayer, closestDist = nil, math.huge
    local currentHrp = getHRP(); if not currentHrp then return nil, math.huge end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (currentHrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then closestDist = dist; closestPlayer = plr end
        end
    end
    return closestPlayer, closestDist
end

local function flyToFrontOfTarget(targetHRP)
    local currentHrp = getHRP(); if not currentHrp then return end
    local frontPos = targetHRP.Position + targetHRP.CFrame.LookVector * 4
    local direction = (frontPos - currentHrp.Position).Unit
    currentHrp.Velocity = Vector3.new(direction.X * 55, direction.Y * 55, direction.Z * 55)
end

-- ══════════════════════════════════════════
--   SPEED HUD
-- ══════════════════════════════════════════
local function setupChar(char)
    h   = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in pairs(head:GetChildren()) do if child:IsA("BillboardGui") then child:Destroy() end end
        local bb = Instance.new("BillboardGui", head)
        bb.Size = UDim2.new(0,160,0,30); bb.StudsOffset = Vector3.new(0,3.2,0); bb.AlwaysOnTop = true
        speedLbl = Instance.new("TextLabel", bb)
        speedLbl.Size = UDim2.new(1,0,1,0); speedLbl.BackgroundTransparency = 1
        speedLbl.TextColor3 = Color3.fromRGB(255,255,255)
        speedLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0); speedLbl.TextStrokeTransparency = 0.3
        speedLbl.Font = Enum.Font.GothamBold; speedLbl.TextScaled = true; speedLbl.Text = "Speed: 0.0"
    end
end

LocalPlayer.CharacterAdded:Connect(setupChar)
if LocalPlayer.Character then setupChar(LocalPlayer.Character) end

-- ══════════════════════════════════════════
--   GUI HELPERS (Dragon Hub style)
-- ══════════════════════════════════════════
local function Make(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end
local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15), props):Play()
end

local ScreenGui = Make("ScreenGui", {
    Name="VyseHubDragon", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    Parent=(gethui and gethui()) or PlayerGui,
})

-- MAIN FRAME
local MainFrame = Make("Frame", {
    Name="MainFrame", Size=UDim2.new(0,310,0,500), Position=UDim2.new(0.5,-155,0.5,-250),
    BackgroundColor3=Color3.fromRGB(18,18,18), BorderSizePixel=0, Parent=ScreenGui,
})
Make("UICorner", { CornerRadius=UDim.new(0,10), Parent=MainFrame })
Make("UIStroke", { Color=Color3.fromRGB(50,50,50), Thickness=1, Parent=MainFrame })

-- Drag
do
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=inp.Position; startPos=MainFrame.Position end
    end)
    MainFrame.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=inp.Position-dragStart
            MainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
end

-- TOP BAR
local TopBar = Make("Frame", { Size=UDim2.new(1,0,0,38), BackgroundColor3=Color3.fromRGB(22,22,22), BorderSizePixel=0, Parent=MainFrame })
Make("UICorner", { CornerRadius=UDim.new(0,10), Parent=TopBar })
Make("TextLabel", { Text="VYSE HUB", Size=UDim2.new(0,100,1,0), Position=UDim2.new(0,12,0,0), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.GothamBlack, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=TopBar })
Make("TextLabel", { Text="discord.gg/jRsgRcun", Size=UDim2.new(0,150,1,0), Position=UDim2.new(0,110,0,0), BackgroundTransparency=1, TextColor3=Color3.fromRGB(130,130,130), Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, Parent=TopBar })
local CloseBtn = Make("TextButton", { Text="−", Size=UDim2.new(0,28,0,20), Position=UDim2.new(1,-32,0.5,-10), BackgroundColor3=Color3.fromRGB(50,50,50), TextColor3=Color3.fromRGB(200,200,200), Font=Enum.Font.GothamBold, TextSize=18, BorderSizePixel=0, Parent=TopBar })
Make("UICorner", { CornerRadius=UDim.new(0,5), Parent=CloseBtn })
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, { Size=UDim2.new(0,310,0,0) }, 0.2)
    task.delay(0.22, function() MainFrame.Visible=false end)
end)

-- PANELS
local LeftPanel = Make("Frame", { Size=UDim2.new(0,100,1,-40), Position=UDim2.new(0,0,0,40), BackgroundColor3=Color3.fromRGB(25,25,25), BorderSizePixel=0, Parent=MainFrame })
Make("UICorner", { CornerRadius=UDim.new(0,8), Parent=LeftPanel })
local RightPanel = Make("Frame", { Size=UDim2.new(1,-108,1,-48), Position=UDim2.new(0,106,0,44), BackgroundColor3=Color3.fromRGB(18,18,18), BorderSizePixel=0, Parent=MainFrame })

-- ══════════════════════════════════════════
--   TABS
-- ══════════════════════════════════════════
local Tabs    = {}
local TabBtns = {}
local function CreateTab(name, index)
    local btn = Make("TextButton", { Name=name.."Tab", Text=name, Size=UDim2.new(1,-10,0,36), Position=UDim2.new(0,5,0,8+(index-1)*42), BackgroundColor3=Color3.fromRGB(35,35,35), TextColor3=Color3.fromRGB(180,180,180), Font=Enum.Font.GothamSemibold, TextSize=11, BorderSizePixel=0, Parent=LeftPanel })
    Make("UICorner", { CornerRadius=UDim.new(0,7), Parent=btn })
    local content = Make("Frame", { Name=name.."Content", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false, Parent=RightPanel })
    Tabs[name]=content; TabBtns[name]=btn
    return btn, content
end
local function SelectTab(name)
    for n, c in pairs(Tabs) do
        c.Visible=(n==name)
        local btn=TabBtns[n]
        if n==name then
            Tween(btn, {BackgroundColor3=Color3.fromRGB(255,255,255), TextColor3=Color3.fromRGB(10,10,10)})
            btn.Font=Enum.Font.GothamBlack
        else
            Tween(btn, {BackgroundColor3=Color3.fromRGB(35,35,35), TextColor3=Color3.fromRGB(180,180,180)})
            btn.Font=Enum.Font.GothamSemibold
        end
    end
end

local tabNames = {"Speed", "Steal", "Combat", "Features", "Settings"}
for i, name in ipairs(tabNames) do
    local btn = CreateTab(name, i)
    btn.MouseButton1Click:Connect(function() SelectTab(name) end)
end

-- ══════════════════════════════════════════
--   UI COMPONENTS
-- ══════════════════════════════════════════
local function CreateToggle(parent, label, yPos, default, callback)
    local row = Make("Frame", { Size=UDim2.new(1,-6,0,38), Position=UDim2.new(0,3,0,yPos), BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0, Parent=parent })
    Make("UICorner", { CornerRadius=UDim.new(0,7), Parent=row })
    Make("TextLabel", { Text=label, Size=UDim2.new(0.7,0,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=Color3.fromRGB(220,220,220), Font=Enum.Font.GothamSemibold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=row })
    local state = default
    local togBG = Make("Frame", { Size=UDim2.new(0,42,0,22), Position=UDim2.new(1,-48,0.5,-11), BackgroundColor3=state and Color3.fromRGB(240,240,240) or Color3.fromRGB(55,55,55), BorderSizePixel=0, Parent=row })
    Make("UICorner", { CornerRadius=UDim.new(1,0), Parent=togBG })
    local knob = Make("Frame", { Size=UDim2.new(0,16,0,16), Position=state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, Parent=togBG })
    Make("UICorner", { CornerRadius=UDim.new(1,0), Parent=knob })
    local btn = Make("TextButton", { Text="", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=row })
    local togRef = { state=state, togBG=togBG, knob=knob }
    btn.MouseButton1Click:Connect(function()
        togRef.state = not togRef.state
        Tween(togBG, {BackgroundColor3=togRef.state and Color3.fromRGB(240,240,240) or Color3.fromRGB(55,55,55)})
        Tween(knob,  {Position=togRef.state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
        if callback then callback(togRef.state) end
    end)
    return togRef
end

local function CreateSectionLabel(parent, text, yPos)
    Make("TextLabel", { Text=text, Size=UDim2.new(1,-10,0,20), Position=UDim2.new(0,5,0,yPos), BackgroundTransparency=1, TextColor3=Color3.fromRGB(100,100,100), Font=Enum.Font.GothamBold, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left, Parent=parent })
end

local function CreateInputRow(parent, label, yPos, defaultVal, callback)
    local row = Make("Frame", { Size=UDim2.new(1,-6,0,38), Position=UDim2.new(0,3,0,yPos), BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0, Parent=parent })
    Make("UICorner", { CornerRadius=UDim.new(0,7), Parent=row })
    Make("TextLabel", { Text=label, Size=UDim2.new(0.55,0,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=Color3.fromRGB(220,220,220), Font=Enum.Font.GothamSemibold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=row })
    local valBox = Make("Frame", { Size=UDim2.new(0,80,0,26), Position=UDim2.new(1,-84,0.5,-13), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0, Parent=row })
    Make("UICorner", { CornerRadius=UDim.new(0,6), Parent=valBox })
    local tb = Instance.new("TextBox")
    tb.Size=UDim2.new(1,0,1,0); tb.BackgroundTransparency=1; tb.Text=tostring(defaultVal)
    tb.TextColor3=Color3.fromRGB(220,220,220); tb.Font=Enum.Font.GothamBold; tb.TextSize=12
    tb.ClearTextOnFocus=false; tb.BorderSizePixel=0; tb.Parent=valBox
    tb:GetPropertyChangedSignal("Text"):Connect(function()
        local val = tonumber(tb.Text)
        if val and callback then callback(val) end
    end)
    return tb
end

local function CreateButton(parent, label, yPos, callback)
    local btn = Make("TextButton", { Text=label, Size=UDim2.new(1,-6,0,34), Position=UDim2.new(0,3,0,yPos), BackgroundColor3=Color3.fromRGB(35,35,35), TextColor3=Color3.fromRGB(210,210,210), Font=Enum.Font.GothamBold, TextSize=12, BorderSizePixel=0, Parent=parent })
    Make("UICorner", { CornerRadius=UDim.new(0,7), Parent=btn })
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

-- ══════════════════════════════════════════
--   SPEED TAB
-- ══════════════════════════════════════════
local SpeedContent = Tabs["Speed"]
CreateSectionLabel(SpeedContent, "SPEED CONFIGURATION", 6)

CreateInputRow(SpeedContent, "Normal Speed", 30, NORMAL_SPEED, function(v) NORMAL_SPEED = v end)
CreateInputRow(SpeedContent, "Carry Speed",  76, CARRY_SPEED,  function(v) CARRY_SPEED  = v end)

local modeRow = Make("Frame", { Size=UDim2.new(1,-6,0,38), Position=UDim2.new(0,3,0,122), BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0, Parent=SpeedContent })
Make("UICorner", { CornerRadius=UDim.new(0,7), Parent=modeRow })
Make("TextLabel", { Text="Mode", Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, TextColor3=Color3.fromRGB(220,220,220), Font=Enum.Font.GothamSemibold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=modeRow })
local modeDisplay = Make("Frame", { Size=UDim2.new(0,80,0,26), Position=UDim2.new(1,-86,0.5,-13), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0, Parent=modeRow })
Make("UICorner", { CornerRadius=UDim.new(0,6), Parent=modeDisplay })
local modeLbl = Make("TextLabel", { Text="Normal", Size=UDim2.new(0.7,0,1,0), BackgroundTransparency=1, TextColor3=Color3.fromRGB(220,220,220), Font=Enum.Font.GothamSemibold, TextSize=11, Parent=modeDisplay })
local keyLbl  = Make("TextLabel", { Text="Q", Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-22,0.5,-10), BackgroundColor3=Color3.fromRGB(60,60,60), TextColor3=Color3.fromRGB(200,200,200), Font=Enum.Font.GothamBold, TextSize=10, Parent=modeDisplay })
Make("UICorner", { CornerRadius=UDim.new(0,4), Parent=keyLbl })

local speedToggleRef = CreateToggle(SpeedContent, "Speed Boost", 168, false, function(v)
    CONFIG.SPEED_BOOST = v
end)

-- ══════════════════════════════════════════
--   STEAL TAB
-- ══════════════════════════════════════════
local StealContent = Tabs["Steal"]
CreateSectionLabel(StealContent, "AUTO STEAL", 6)

local instaGrabTogRef = CreateToggle(StealContent, "Insta Grab", 30, false, function(v)
    CONFIG.AUTO_STEAL_NEAREST = v
    CONFIG.SPEED_BOOST = v
    if v then
        pcall(autoStealLoop)
    else
        if stealConnection then stealConnection:Disconnect(); stealConnection = nil end
        if velocityConnection then velocityConnection:Disconnect(); velocityConnection = nil end
    end
end)

CreateSectionLabel(StealContent, "RADIUS CONTROL", 80)
local radiusInputTb = CreateInputRow(StealContent, "Grab Radius", 100, AUTO_STEAL_PROX_RADIUS, function(v)
    AUTO_STEAL_PROX_RADIUS = v
end)

-- ══════════════════════════════════════════
--   COMBAT TAB
-- ══════════════════════════════════════════
local CombatContent = Tabs["Combat"]
CreateSectionLabel(CombatContent, "BAT AIMBOT", 6)

local autoBatTogRef = CreateToggle(CombatContent, "Auto-Bat", 30, false, function(v)
    CONFIG.BAT_AIMBOT_AUTOBAT = v
    autoBatToggled = v
end)

local autoBatKeyInputTb = CreateInputRow(CombatContent, "Bat Keybind", 76, autoBatKey.Name, function(_)
    -- handled via text signal below
end)
-- override callback for key parsing
autoBatKeyInputTb:GetPropertyChangedSignal("Text"):Connect(function()
    local newKeyName = autoBatKeyInputTb.Text:upper()
    if Enum.KeyCode[newKeyName] then autoBatKey = Enum.KeyCode[newKeyName] end
end)

-- ══════════════════════════════════════════
--   FEATURES TAB
-- ══════════════════════════════════════════
local FeatContent = Tabs["Features"]
CreateSectionLabel(FeatContent, "FEATURES", 6)

CreateToggle(FeatContent, "Infinite Jump", 30, false, function(v) CONFIG.INFINITE_JUMP = v end)
CreateToggle(FeatContent, "Optimizer",     76, false, function(v)
    CONFIG.OPTIMIZER = v
    if v then pcall(applyAdvancedOptimizer) else pcall(disableOptimizer) end
end)
CreateToggle(FeatContent, "Anti-Ragdoll", 122, true, function(v) CONFIG.ANTI_RAGDOLL = v end)

-- ══════════════════════════════════════════
--   SETTINGS TAB
-- ══════════════════════════════════════════
local SetContent = Tabs["Settings"]
CreateSectionLabel(SetContent, "SETTINGS", 6)

CreateButton(SetContent, "💾 Save Config", 30, function() saveConfig() end)
CreateButton(SetContent, "📋 Copy Discord", 72, function()
    setclipboard("https://discord.gg/jRsgRcun")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Vyse Hub", Text = "Discord copied!", Duration = 3
    })
end)
Make("TextLabel", { Text="discord.gg/jRsgRcun", Size=UDim2.new(1,-10,0,20), Position=UDim2.new(0,5,1,-30), BackgroundTransparency=1, TextColor3=Color3.fromRGB(70,70,70), Font=Enum.Font.Gotham, TextSize=9, TextXAlignment=Enum.TextXAlignment.Center, Parent=SetContent })

-- ══════════════════════════════════════════
--   PROGRESS BAR (bottom, igual al original)
-- ══════════════════════════════════════════
local StealBarGui = Make("ScreenGui", {
    Name="VyseStealBar", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    Parent=(gethui and gethui()) or PlayerGui,
})
local StealBarFrame = Make("Frame", {
    Size=UDim2.new(0,380,0,50), Position=UDim2.new(0.5,-190,1,-70),
    BackgroundColor3=Color3.fromRGB(10,10,10), BorderSizePixel=0,
    Visible=false, Parent=StealBarGui,
})
Make("UICorner", { CornerRadius=UDim.new(0,10), Parent=StealBarFrame })
Make("UIStroke", { Color=Color3.fromRGB(50,50,50), Thickness=1, Parent=StealBarFrame })

local ProgressPct = Make("TextLabel", {
    Text="0%", Size=UDim2.new(0,50,0,20), Position=UDim2.new(0,8,0,4),
    BackgroundTransparency=1, TextColor3=Color3.fromRGB(220,220,220),
    Font=Enum.Font.GothamBold, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left,
    Parent=StealBarFrame,
})
local RadiusLbl = Make("TextLabel", {
    Text="Radius: "..AUTO_STEAL_PROX_RADIUS,
    Size=UDim2.new(0,120,0,20), Position=UDim2.new(1,-124,0,4),
    BackgroundTransparency=1, TextColor3=Color3.fromRGB(220,220,220),
    Font=Enum.Font.GothamBold, TextSize=13, TextXAlignment=Enum.TextXAlignment.Right,
    Parent=StealBarFrame,
})
local BarBG = Make("Frame", { Size=UDim2.new(1,-12,0,12), Position=UDim2.new(0,6,1,-18), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0, Parent=StealBarFrame })
Make("UICorner", { CornerRadius=UDim.new(1,0), Parent=BarBG })
local BarFill = Make("Frame", { Size=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(0,255,0), BorderSizePixel=0, Parent=BarBG })
Make("UICorner", { CornerRadius=UDim.new(1,0), Parent=BarFill })

-- Drag steal bar
do
    local dragSB, dragStartSB, startPosSB
    StealBarFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragSB=true; dragStartSB=inp.Position; startPosSB=StealBarFrame.Position end
    end)
    StealBarFrame.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragSB=false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragSB and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=inp.Position-dragStartSB
            StealBarFrame.Position=UDim2.new(startPosSB.X.Scale,startPosSB.X.Offset+delta.X,startPosSB.Y.Scale,startPosSB.Y.Offset+delta.Y)
        end
    end)
end

-- ══════════════════════════════════════════
--   FPS / PING (top right, igual al original)
-- ══════════════════════════════════════════
local fpsFrame = Make("Frame", {
    Size=UDim2.new(0,150,0,60), Position=UDim2.new(1,-160,0,10),
    BackgroundColor3=Color3.fromRGB(18,18,18), BorderSizePixel=0, Parent=ScreenGui,
})
Make("UICorner", { CornerRadius=UDim.new(0,8), Parent=fpsFrame })
Make("UIStroke", { Color=Color3.fromRGB(50,50,50), Thickness=1, Parent=fpsFrame })
local fpsLabel = Make("TextLabel", { Size=UDim2.new(1,0,0.5,0), BackgroundTransparency=1, Text="FPS: 60", TextColor3=Color3.fromRGB(0,255,0), Font=Enum.Font.GothamBold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Center, Parent=fpsFrame })
local pingLabel= Make("TextLabel", { Size=UDim2.new(1,0,0.5,0), Position=UDim2.new(0,0,0.5,0), BackgroundTransparency=1, Text="PING: 0ms", TextColor3=Color3.fromRGB(0,255,0), Font=Enum.Font.GothamBold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Center, Parent=fpsFrame })

-- ══════════════════════════════════════════
--   AUTO STEAL LOOP (original)
-- ══════════════════════════════════════════
function autoStealLoop()
    if stealConnection then stealConnection:Disconnect(); stealConnection = nil end
    if velocityConnection then velocityConnection:Disconnect(); velocityConnection = nil end
    velocityConnection = RunService.Heartbeat:Connect(function() pcall(updatePlayerVelocity) end)
    stealConnection = RunService.Heartbeat:Connect(function()
        if not CONFIG.AUTO_STEAL_NEAREST then return end
        if IsStealing then return end
        local target = getNearestAnimal(); if not target then return end
        if not shouldSteal(target) then return end
        local prompt = PromptMemoryCache[target.uid]
        if not prompt or not prompt.Parent then prompt = findProximityPromptForAnimal(target) end
        if prompt then pcall(function() attemptSteal(prompt, target) end) end
    end)
end

-- ══════════════════════════════════════════
--   INPUT HANDLING (original)
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q and CONFIG.SPEED_BOOST then
        speedToggled = not speedToggled
        modeLbl.Text = speedToggled and "Carry" or "Normal"
    end
    if input.KeyCode == autoBatKey then
        CONFIG.BAT_AIMBOT_AUTOBAT = not CONFIG.BAT_AIMBOT_AUTOBAT
        autoBatToggled = CONFIG.BAT_AIMBOT_AUTOBAT
        -- sync toggle visual
        Tween(autoBatTogRef.togBG, {BackgroundColor3=autoBatToggled and Color3.fromRGB(240,240,240) or Color3.fromRGB(55,55,55)})
        Tween(autoBatTogRef.knob,  {Position=autoBatToggled and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
        autoBatTogRef.state = autoBatToggled
    end
end)

-- ══════════════════════════════════════════
--   INFINITE JUMP (original)
-- ══════════════════════════════════════════
local jumpForce = 55; local clampFallSpeed = 120
UserInputService.JumpRequest:Connect(function()
    if not CONFIG.INFINITE_JUMP then return end
    local char = LocalPlayer.Character; if not char then return end
    local currentHrp = char:FindFirstChild("HumanoidRootPart")
    if currentHrp then currentHrp.Velocity = Vector3.new(currentHrp.Velocity.X, jumpForce, currentHrp.Velocity.Z) end
end)
RunService.Heartbeat:Connect(function()
    if not CONFIG.INFINITE_JUMP then return end
    local char = LocalPlayer.Character; if not char then return end
    local currentHrp = char:FindFirstChild("HumanoidRootPart")
    if currentHrp and currentHrp.Velocity.Y < -clampFallSpeed then
        currentHrp.Velocity = Vector3.new(currentHrp.Velocity.X, -clampFallSpeed, currentHrp.Velocity.Z)
    end
end)

-- ══════════════════════════════════════════
--   AUTO BAT LOOP (original)
-- ══════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if autoBatToggled and h and hrp then
        local target, dist = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            flyToFrontOfTarget(target.Character.HumanoidRootPart)
            if dist <= 8 then tryHitBat() end
        end
    end
end)

-- ══════════════════════════════════════════
--   SPEED LOOP (original)
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not CONFIG.SPEED_BOOST then return end
    if not (h and hrp) then return end
    local md = h.MoveDirection
    local speed = speedToggled and CARRY_SPEED or NORMAL_SPEED
    if md.Magnitude > 0 then hrp.Velocity = Vector3.new(md.X*speed, hrp.Velocity.Y, md.Z*speed) end
    if speedLbl then
        local displaySpeed = Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude
        speedLbl.Text = "Speed: "..string.format("%.1f", displaySpeed)
    end
end)

-- ══════════════════════════════════════════
--   OPTIMIZER (original)
-- ══════════════════════════════════════════
local function optimizeObject(v)
    pcall(function()
        if v:IsA("Model") then v.LevelOfDetail=Enum.ModelLevelOfDetail.Disabled; v.ModelStreamingMode=Enum.ModelStreamingMode.Nonatomic
        elseif v:IsA("BasePart") and not v:IsA("MeshPart") then v.CastShadow=false; v.Material=Enum.Material.Plastic; v.Reflectance=0; v.MaterialVariant=""
        elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
        elseif v:IsA("MeshPart") then v.CastShadow=false; v.DoubleSided=false; v.RenderFidelity=Enum.RenderFidelity.Performance; pcall(function() v.TextureID=10385902758728957 end)
        elseif v:IsA("SpecialMesh") then v.TextureId=0
        elseif v:IsA("ShirtGraphic") then v.Graphic=0
        elseif v:IsA("Shirt") or v:IsA("Pants") then v[v.ClassName.."Template"]=0
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled=false
        elseif v:IsA("Explosion") then v.BlastPressure=1; v.BlastRadius=1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled=false
        elseif v:IsA("Beam") then v.Enabled=false
        elseif v:IsA("SurfaceAppearance") then v:Destroy()
        elseif v:IsA("Debris") then v:Destroy()
        elseif v:IsA("Attachment") then v.Visible=false
        elseif v:IsA("MaterialVariant") then v:Destroy() end
    end)
end

function applyAdvancedOptimizer()
    pcall(function() setfpscap(999999999) end)
    for _, v in pairs(Workspace:GetDescendants()) do optimizeObject(v) end
    for _, v in pairs(Lighting:GetDescendants()) do
        pcall(function()
            if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect")
            or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Clouds")
            or v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") then v:Destroy() end
        end)
    end
    pcall(function()
        pcall(function() sethiddenproperty(Lighting,"Technology",2) end)
        Lighting.GlobalShadows=false; Lighting.FogEnd=9e9; Lighting.Brightness=0
    end)
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then pcall(function()
        pcall(function() sethiddenproperty(terrain,"Decoration",false) end)
        terrain.WaterReflectance=0; terrain.WaterTransparency=0.7; terrain.WaterWaveSize=0; terrain.WaterWaveSpeed=0
    end) end
    if not optimizerLightingConnection then
        optimizerLightingConnection = Lighting.ChildAdded:Connect(function(v)
            if CONFIG.OPTIMIZER then task.spawn(function() pcall(function() v:Destroy() end) end) end
        end)
    end
    if not optimizerDescendantConnection then
        optimizerDescendantConnection = Workspace.DescendantAdded:Connect(function(v)
            if CONFIG.OPTIMIZER then task.spawn(function() optimizeObject(v) end) end
        end)
    end
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end

function disableOptimizer()
    if optimizerDescendantConnection then optimizerDescendantConnection:Disconnect(); optimizerDescendantConnection=nil end
    if optimizerLightingConnection   then optimizerLightingConnection:Disconnect();   optimizerLightingConnection=nil   end
    pcall(function() setfpscap(60) end)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
end

-- ══════════════════════════════════════════
--   ANTI-RAGDOLL (original)
-- ══════════════════════════════════════════
local currentCharacter        = nil
local ragdollRemoteConnection = nil
local moveConnection          = nil
local controls                = nil
pcall(function()
    local playerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    controls = playerModule:GetControls()
end)

local function cleanupRagdoll()
    if currentCharacter then
        local root = currentCharacter:FindFirstChild("HumanoidRootPart")
        if root then local anchor=root:FindFirstChild("RagdollAnchor"); if anchor then anchor:Destroy() end end
    end
    if moveConnection then moveConnection:Disconnect(); moveConnection=nil end
end

local function disconnectRemote()
    if ragdollRemoteConnection then ragdollRemoteConnection:Disconnect(); ragdollRemoteConnection=nil end
end

local function setupAntiRagdoll(char)
    currentCharacter = char
    cleanupRagdoll(); disconnectRemote()
    local humanoid = char:WaitForChild("Humanoid",5)
    local root     = char:WaitForChild("HumanoidRootPart",5)
    local head     = char:WaitForChild("Head",5)
    if not (humanoid and root and head) then return end
    local ragdollRemote = ReplicatedStorage:WaitForChild("Packages",8):WaitForChild("Ragdoll",5):WaitForChild("Ragdoll",5)
    if not ragdollRemote or not ragdollRemote:IsA("RemoteEvent") then return end
    ragdollRemoteConnection = ragdollRemote.OnClientEvent:Connect(function(arg1, arg2)
        if not CONFIG.ANTI_RAGDOLL then return end
        if arg1=="Make" or arg2=="manualM" then
            task.wait(0.05)
            task.spawn(function()
                for i=1,5 do if humanoid and humanoid.Parent then humanoid:ChangeState(Enum.HumanoidStateType.Running) end; task.wait(0.02) end
            end)
            Camera.CameraSubject = humanoid; root.CanCollide = true
            if controls then pcall(function() controls:Enable() end) end
            task.spawn(function()
                for _, part in pairs(char:GetDescendants()) do
                    pcall(function()
                        if part:IsA("Motor6D") then part.Enabled=true
                        elseif part:IsA("BallSocketConstraint") or part:IsA("NoCollisionConstraint") then task.wait(0.01); part:Destroy() end
                    end)
                end
            end)
            task.spawn(function()
                for i=1,10 do
                    if root and root.Parent then root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.5 end
                    task.wait(0.02)
                end
            end)
        end
        if arg1=="Destroy" or arg2=="manualD" then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            Camera.CameraSubject=humanoid; root.CanCollide=true
            if controls then pcall(function() controls:Enable() end) end
            cleanupRagdoll()
        end
    end)
end

-- ══════════════════════════════════════════
--   PROGRESS BAR MONITOR (original logic)
-- ══════════════════════════════════════════
task.spawn(function()
    while task.wait(0.01) do
        pcall(function()
            StealBarFrame.Visible = true
            RadiusLbl.Text = "Radius: "..AUTO_STEAL_PROX_RADIUS
            if not CONFIG.AUTO_STEAL_NEAREST then
                ProgressPct.Text = "0%"; BarFill.Size = UDim2.new(0,0,1,0); return
            end
            local nearestAnimal = getNearestAnimal()
            local currentHrp   = getHRP()
            if nearestAnimal and currentHrp then
                local distance = (currentHrp.Position - nearestAnimal.worldPosition).Magnitude
                if distance <= AUTO_STEAL_PROX_RADIUS or IsStealing then
                    if IsStealing then
                        local fw = math.clamp(StealProgress,0,1)
                        ProgressPct.Text = math.floor(fw*100).."%"
                        TweenService:Create(BarFill, TweenInfo.new(0.05,Enum.EasingStyle.Linear), {Size=UDim2.new(fw,0,1,0)}):Play()
                    else
                        local ap = math.clamp(1-(distance/AUTO_STEAL_PROX_RADIUS),0,1)
                        ProgressPct.Text = math.floor(ap*100).."%"
                        TweenService:Create(BarFill, TweenInfo.new(0.1,Enum.EasingStyle.Linear), {Size=UDim2.new(ap,0,1,0)}):Play()
                    end
                else
                    ProgressPct.Text="0%"; BarFill.Size=UDim2.new(0,0,1,0)
                end
            else
                ProgressPct.Text="0%"; BarFill.Size=UDim2.new(0,0,1,0)
            end
        end)
    end
end)

-- ══════════════════════════════════════════
--   FPS / PING MONITOR (original)
-- ══════════════════════════════════════════
local lastFpsUpdate = tick(); local fpsCounter = 0
task.spawn(function()
    while task.wait() do
        pcall(function()
            fpsCounter = fpsCounter + 1
            if tick() - lastFpsUpdate >= 1 then
                local fps = fpsCounter
                fpsLabel.Text = "FPS: "..fps
                fpsLabel.TextColor3 = fps>=60 and Color3.fromRGB(0,255,0) or fps>=30 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
                ping = string.match(ping,"%d+") or "0"
                local pingNum = tonumber(ping)
                pingLabel.Text = "PING: "..ping.."ms"
                pingLabel.TextColor3 = pingNum<=100 and Color3.fromRGB(0,255,0) or pingNum<=200 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)
                fpsCounter=0; lastFpsUpdate=tick()
            end
        end)
    end
end)

-- ══════════════════════════════════════════
--   INIT
-- ══════════════════════════════════════════
initializeScanner()
if LocalPlayer.Character then setupAntiRagdoll(LocalPlayer.Character); setupChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char) setupAntiRagdoll(char); setupChar(char) end)
LocalPlayer.CharacterRemoving:Connect(function() cleanupRagdoll(); disconnectRemote(); currentCharacter=nil end)

loadConfig()

-- Sync toggles with loaded config
if CONFIG.INFINITE_JUMP then end -- toggles start at false, user re-enables
if CONFIG.BAT_AIMBOT_AUTOBAT then autoBatToggled=true end
if CONFIG.OPTIMIZER then pcall(applyAdvancedOptimizer) end

SelectTab("Speed")
MainFrame.Size = UDim2.new(0,310,0,0)
Tween(MainFrame, { Size=UDim2.new(0,310,0,500) }, 0.25)

print("[VYSE HUB] Loaded with Dragon UI! discord.gg/jRsgRcun")
