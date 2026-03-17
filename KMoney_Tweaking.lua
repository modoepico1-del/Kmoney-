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

local me          = Players.LocalPlayer
local RS          = RunService
local Camera      = workspace.CurrentCamera

local unwalkOn           = false
local unwalkConn         = nil
local xrayOn             = false
local espOn              = false
local antiRagdollEnabled = false
local fovValue           = 70
local infJumpOn          = false
local autoStealActive    = false
local AUTO_STEAL_PROX_RADIUS = 7
local galaxySkyOn        = false

local CONFIG_FILE = "DEMONTIME_config.json"

local function saveConfig()
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            Unwalk      = unwalkOn,
            Xray        = xrayOn,
            ESP         = espOn,
            AntiRagdoll = antiRagdollEnabled,
            FOV         = fovValue,
            InfJump     = infJumpOn,
            AutoSteal   = autoStealActive,
            StealRadius = AUTO_STEAL_PROX_RADIUS,
            GalaxySky   = galaxySkyOn,
        }))
    end)
end

local savedCfg = {}
pcall(function() savedCfg = HttpService:JSONDecode(readfile(CONFIG_FILE)) end)

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

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size                   = UDim2.new(1, 0, 1, -170)
ContentArea.Position               = UDim2.new(0, 0, 0, 42)
ContentArea.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
ContentArea.BackgroundTransparency = 0
ContentArea.BorderSizePixel        = 0
ContentArea.ZIndex                 = 3
ContentArea.ScrollBarThickness     = 4
ContentArea.ScrollBarImageColor3   = Color3.fromRGB(255, 0, 0)
ContentArea.CanvasSize             = UDim2.new(0, 0, 0, 620)
ContentArea.AutomaticCanvasSize    = Enum.AutomaticSize.Y
ContentArea.ScrollingDirection     = Enum.ScrollingDirection.Y
ContentArea.ElasticBehavior        = Enum.ElasticBehavior.Never
ContentArea.Parent                 = MainFrame

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
    TweenService:Create(lbl.Parent, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15,0,0)}):Play()
    TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200,0,0)}):Play()
    TweenService:Create(thumb, TweenInfo.new(0.2), {Position = UDim2.new(0,23,0.5,-9), BackgroundColor3 = Color3.fromRGB(255,0,0)}):Play()
    TweenService:Create(lbl,   TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,0,0)}):Play()
end
local function toggleOff(lbl, track, thumb)
    TweenService:Create(lbl.Parent, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15,0,0)}):Play()
    TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
    TweenService:Create(thumb, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0.5,-9), BackgroundColor3 = Color3.fromRGB(180,180,180)}):Play()
    TweenService:Create(lbl,   TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220,220,220)}):Play()
end

-- UNWALK
local unwalkLabel, unwalkTrack, unwalkThumb = makeOptionRow(ContentArea, "UNWALK", 10)
local function enableUnwalk()
    local char = me.Character if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid") if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator") if not anim then return end
    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
    if unwalkConn then unwalkConn:Disconnect() end
    unwalkConn = RS.Heartbeat:Connect(function()
        if not unwalkOn then unwalkConn:Disconnect() unwalkConn = nil return end
        local c  = me.Character if not c then return end
        local h  = c:FindFirstChildOfClass("Humanoid") if not h then return end
        local an = h:FindFirstChildOfClass("Animator") if not an then return end
        for _, t in ipairs(an:GetPlayingAnimationTracks()) do t:Stop(0) end
    end)
end
local function disableUnwalk()
    if unwalkConn then unwalkConn:Disconnect() unwalkConn = nil end
end
unwalkTrack.MouseButton1Click:Connect(function()
    unwalkOn = not unwalkOn
    if unwalkOn then toggleOn(unwalkLabel, unwalkTrack, unwalkThumb); enableUnwalk()
    else toggleOff(unwalkLabel, unwalkTrack, unwalkThumb); disableUnwalk() end
end)

-- XRAY
local xrayLabel, xrayTrack, xrayThumb = makeOptionRow(ContentArea, "XRAY", 64)
local originalTransparency = {}
local xrayDescConn, xrayCharConn = nil, nil
local function startXray()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj:Destroy()
                elseif obj:IsA("BasePart") then obj.CastShadow = false; obj.Material = Enum.Material.Plastic end
            end)
        end
    end)
    local function cleanChar(char)
        if char == me.Character then return end
        pcall(function()
            for _, a in ipairs(char:GetChildren()) do if a:IsA("Accessory") then a:Destroy() end end
            char.ChildAdded:Connect(function(c) if xrayOn and c:IsA("Accessory") then c:Destroy() end end)
        end)
    end
    pcall(function()
        for _, h in ipairs(workspace:GetDescendants()) do
            if h:IsA("Humanoid") then cleanChar(h.Parent) end
        end
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and
               (obj.Name:lower():find("base") or obj.Name:lower():find("claim") or
               (obj.Parent and (obj.Parent.Name:lower():find("base") or obj.Parent.Name:lower():find("claim")))) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end)
    xrayDescConn = workspace.DescendantAdded:Connect(function(obj)
        if not xrayOn then return end
        pcall(function()
            if obj:IsA("BasePart") and obj.Anchored and
               (obj.Name:lower():find("base") or obj.Name:lower():find("claim") or
               (obj.Parent and (obj.Parent.Name:lower():find("base") or obj.Parent.Name:lower():find("claim")))) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end)
    end)
    xrayCharConn = me.CharacterAdded:Connect(function() task.wait(0.5); if xrayOn then startXray() end end)
end
local function stopXray()
    if xrayDescConn then xrayDescConn:Disconnect(); xrayDescConn = nil end
    if xrayCharConn then xrayCharConn:Disconnect(); xrayCharConn = nil end
    for obj, val in pairs(originalTransparency) do pcall(function() obj.LocalTransparencyModifier = val end) end
    originalTransparency = {}
end
xrayTrack.MouseButton1Click:Connect(function()
    xrayOn = not xrayOn
    if xrayOn then toggleOn(xrayLabel, xrayTrack, xrayThumb); startXray()
    else toggleOff(xrayLabel, xrayTrack, xrayThumb); stopXray() end
end)

-- ESP
local espLabel, espTrack, espThumb = makeOptionRow(ContentArea, "ESP", 118)
local espObjects, espConnections = {}, {}
local function createESP(plr)
    if plr == me then return end
    if not plr.Character then return end
    if plr.Character:FindFirstChild("NightESP") then return end
    local c = plr.Character
    local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "NightESP"; hitbox.Adornee = hrp; hitbox.Size = Vector3.new(4,6,2)
    hitbox.Color3 = Color3.fromRGB(255,0,50); hitbox.Transparency = 0.3
    hitbox.ZIndex = 10; hitbox.AlwaysOnTop = true; hitbox.Parent = c
    espObjects[plr] = hitbox
end
local function removeESP(plr)
    pcall(function()
        if plr.Character then
            local h = plr.Character:FindFirstChild("NightESP") if h then h:Destroy() end
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Automatic end
        end
        espObjects[plr] = nil
    end)
end
local function enableESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= me then
            if plr.Character then pcall(function() createESP(plr) end) end
            table.insert(espConnections, plr.CharacterAdded:Connect(function()
                task.wait(0.1); if espOn then pcall(function() createESP(plr) end) end
            end))
        end
    end
    table.insert(espConnections, Players.PlayerAdded:Connect(function(plr)
        if plr == me then return end
        table.insert(espConnections, plr.CharacterAdded:Connect(function()
            task.wait(0.1); if espOn then pcall(function() createESP(plr) end) end
        end))
    end))
end
local function disableESP()
    for _, plr in ipairs(Players:GetPlayers()) do pcall(function() removeESP(plr) end) end
    for _, conn in ipairs(espConnections) do if conn and conn.Connected then conn:Disconnect() end end
    espConnections = {}; espObjects = {}
end
espTrack.MouseButton1Click:Connect(function()
    espOn = not espOn
    if espOn then toggleOn(espLabel, espTrack, espThumb); enableESP()
    else toggleOff(espLabel, espTrack, espThumb); disableESP() end
end)

-- DARKMODE
local function startDarkMode()
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then child.Parent = nil end
    end
    local sky = Instance.new("Sky")
    sky.SkyboxBk="rbxassetid://2013298"; sky.SkyboxDn="rbxassetid://2013298"
    sky.SkyboxFt="rbxassetid://2013298"; sky.SkyboxLf="rbxassetid://2013298"
    sky.SkyboxRt="rbxassetid://2013298"; sky.SkyboxUp="rbxassetid://2013298"
    sky.StarCount=0; sky.CelestialBodiesShown=false; sky.Parent=Lighting
    Lighting.FogStart = 10000
end
task.defer(function() task.wait(0.5); startDarkMode() end)
me.CharacterAdded:Connect(function() task.wait(1); startDarkMode() end)

-- ANTI RAGDOLL
local ragdollLabel, ragdollTrack, ragdollThumb = makeOptionRow(ContentArea, "ANTI RAGDOLL", 172)

-- INF JUMP
local infJumpLabel, infJumpTrack, infJumpThumb = makeOptionRow(ContentArea, "INF JUMP", 226)
local jumpForce = 50
local clampFallSpeed = 80
RunService.Heartbeat:Connect(function()
    if not infJumpOn then return end
    local char = me.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Velocity.Y < -clampFallSpeed then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, -clampFallSpeed, hrp.Velocity.Z)
    end
end)
UserInputService.JumpRequest:Connect(function()
    if not infJumpOn then return end
    local char = me.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpForce, hrp.Velocity.Z) end
end)
infJumpTrack.MouseButton1Click:Connect(function()
    infJumpOn = not infJumpOn
    if infJumpOn then toggleOn(infJumpLabel, infJumpTrack, infJumpThumb)
    else toggleOff(infJumpLabel, infJumpTrack, infJumpThumb) end
end)

local RAGDOLL_SPEED = 16

-- AUTO STEAL
local autoStealLabel, autoStealTrack, autoStealThumb = makeOptionRow(ContentArea, "AUTO STEAL", 280)
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
                name = animalName, plot = plot.Name, slot = podium.Name,
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
        enableAutoSteal()
    else
        toggleOff(autoStealLabel, autoStealTrack, autoStealThumb)
        disableAutoSteal()
    end
end)

-- ══════════════════════════════════════
--  BARRA DE PROGRESO + RADIO VISUAL
-- ══════════════════════════════════════

local progressBarBg = Instance.new("Frame")
progressBarBg.Size = UDim2.new(0, 240, 0, 10)
progressBarBg.Position = UDim2.new(0.5, -120, 0, 52)
progressBarBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
progressBarBg.BackgroundTransparency = 0.25
progressBarBg.Visible = false
progressBarBg.Parent = ScreenGui
Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(0, 8)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
progressFill.Parent = progressBarBg
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 8)

local percentLabel = Instance.new("TextLabel")
percentLabel.Size = UDim2.new(1, 0, 1, 0)
percentLabel.BackgroundTransparency = 1
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextSize = 11
percentLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
percentLabel.Text = "0%"
percentLabel.Parent = progressBarBg

local stealSquarePart = nil
local circleConnection = nil
local grabRadius = AUTO_STEAL_PROX_RADIUS

local function hideSquare()
    if stealSquarePart then stealSquarePart:Destroy(); stealSquarePart = nil end
    if circleConnection then circleConnection:Disconnect(); circleConnection = nil end
end

local function createOrUpdateSquare(radius)
    if not stealSquarePart then
        stealSquarePart = Instance.new("Part")
        stealSquarePart.Name = "StealCircle"
        stealSquarePart.Anchored = true
        stealSquarePart.CanCollide = false
        stealSquarePart.Transparency = 0.7
        stealSquarePart.Material = Enum.Material.Neon
        stealSquarePart.Color = Color3.fromRGB(0, 120, 255)
        stealSquarePart.Shape = Enum.PartType.Cylinder
        stealSquarePart.Size = Vector3.new(0.05, radius*2, radius*2)
        stealSquarePart.Parent = workspace
    else
        stealSquarePart.Size = Vector3.new(0.05, radius*2, radius*2)
    end
end

local function updateSquarePosition()
    if stealSquarePart and me.Character then
        local root = me.Character:FindFirstChild("HumanoidRootPart")
        if root then
            stealSquarePart.CFrame =
                CFrame.new(root.Position + Vector3.new(0, -2.5, 0))
                * CFrame.Angles(0, 0, math.rad(90))
        end
    end
end

if circleConnection then circleConnection:Disconnect() end
circleConnection = RunService.Heartbeat:Connect(function()
    if not autoStealActive then hideSquare(); return end
    updateSquarePosition()
end)

local function animateProgressBar()
    progressBarBg.Visible = true
    task.spawn(function()
        for i = 1, 20 do
            local pct = i / 20
            TweenService:Create(progressFill, TweenInfo.new(0.01), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
            percentLabel.Text = math.floor(pct * 100) .. "%"
            task.wait(0.01)
        end
        task.wait(0.4)
        TweenService:Create(progressFill, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 1, 0)}):Play()
        percentLabel.Text = "0%"
        task.wait(0.3)
        progressBarBg.Visible = false
    end)
end

local _origEnable = enableAutoSteal
enableAutoSteal = function()
    _origEnable()
    grabRadius = AUTO_STEAL_PROX_RADIUS
    createOrUpdateSquare(grabRadius)
end

local _origDisable = disableAutoSteal
disableAutoSteal = function()
    _origDisable()
    hideSquare()
    progressBarBg.Visible = false
end

local _origExecute = autoSteal_execute
autoSteal_execute = function(prompt)
    local result = _origExecute(prompt)
    if result then animateProgressBar() end
    return result
end

local galaxySkyLabel, galaxySkyTrack, galaxySkyThumb = makeOptionRow(ContentArea, "GALAXY SKY", 334)
local originalSkybox, galaxySkyBright, galaxySkyBrightConn
local galaxyPlanets = {}
local galaxyBloom, galaxyCC

local function enableGalaxySkyBright()
    if galaxySkyBright then return end
    originalSkybox = Lighting:FindFirstChildOfClass("Sky")
    if originalSkybox then originalSkybox.Parent = nil end
    galaxySkyBright = Instance.new("Sky")
    galaxySkyBright.SkyboxBk="rbxassetid://1534951537"; galaxySkyBright.SkyboxDn="rbxassetid://1534951537"
    galaxySkyBright.SkyboxFt="rbxassetid://1534951537"; galaxySkyBright.SkyboxLf="rbxassetid://1534951537"
    galaxySkyBright.SkyboxRt="rbxassetid://1534951537"; galaxySkyBright.SkyboxUp="rbxassetid://1534951537"
    galaxySkyBright.StarCount=10000; galaxySkyBright.CelestialBodiesShown=false; galaxySkyBright.Parent=Lighting
    galaxyBloom=Instance.new("BloomEffect"); galaxyBloom.Intensity=1.5; galaxyBloom.Size=40; galaxyBloom.Threshold=0.8; galaxyBloom.Parent=Lighting
    galaxyCC=Instance.new("ColorCorrectionEffect"); galaxyCC.Saturation=0.8; galaxyCC.Contrast=0.3; galaxyCC.TintColor=Color3.fromRGB(200,150,255); galaxyCC.Parent=Lighting
    Lighting.Ambient=Color3.fromRGB(120,60,180); Lighting.Brightness=3; Lighting.ClockTime=0
    for i=1,2 do
        local p=Instance.new("Part"); p.Shape=Enum.PartType.Ball
        p.Size=Vector3.new(800+i*200,800+i*200,800+i*200); p.Anchored=true; p.CanCollide=false; p.CastShadow=false
        p.Material=Enum.Material.Neon; p.Color=Color3.fromRGB(140+i*20,60+i*10,200+i*15); p.Transparency=0.3
        p.Position=Vector3.new(math.cos(i*2)*(3000+i*500),1500+i*300,math.sin(i*2)*(3000+i*500)); p.Parent=workspace
        table.insert(galaxyPlanets,p)
    end
    galaxySkyBrightConn=RunService.Heartbeat:Connect(function()
        if not galaxySkyOn then return end
        local t=tick()*0.5
        Lighting.Ambient=Color3.fromRGB(120+math.sin(t)*60,50+math.sin(t*0.8)*40,180+math.sin(t*1.2)*50)
        if galaxyBloom then galaxyBloom.Intensity=1.2+math.sin(t*2)*0.4 end
    end)
end

local function disableGalaxySkyBright()
    if galaxySkyBrightConn then galaxySkyBrightConn:Disconnect(); galaxySkyBrightConn=nil end
    if galaxySkyBright then galaxySkyBright:Destroy(); galaxySkyBright=nil end
    if originalSkybox then originalSkybox.Parent=Lighting end
    if galaxyBloom then galaxyBloom:Destroy(); galaxyBloom=nil end
    if galaxyCC then galaxyCC:Destroy(); galaxyCC=nil end
    for _,obj in ipairs(galaxyPlanets) do if obj then obj:Destroy() end end
    galaxyPlanets={}
    Lighting.Ambient=Color3.fromRGB(127,127,127); Lighting.Brightness=2; Lighting.ClockTime=14
end

galaxySkyTrack.MouseButton1Click:Connect(function()
    galaxySkyOn = not galaxySkyOn
    if galaxySkyOn then toggleOn(galaxySkyLabel, galaxySkyTrack, galaxySkyThumb); enableGalaxySkyBright()
    else toggleOff(galaxySkyLabel, galaxySkyTrack, galaxySkyThumb); disableGalaxySkyBright() end
end)

-- BAT AIMBOT
local batAimbotOn = false
local batAimbotLabel, batAimbotTrack, batAimbotThumb = makeOptionRow(ContentArea, "BAT AIMBOT [E]", 388)
local batAimbotConnection = nil

local function findBat()
    local c = me.Character
    local bp = me:FindFirstChildOfClass("Backpack")
    if c then for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    return nil
end

local function findNearestEnemy(myHRP)
    local nearest, nearestDist, nearestTorso = nil, math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= me and p.Character then
            local eh = p.Character:FindFirstChild("HumanoidRootPart")
            local tor = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local d = (eh.Position - myHRP.Position).Magnitude
                if d < nearestDist then nearestDist = d; nearest = eh; nearestTorso = tor or eh end
            end
        end
    end
    return nearest, nearestDist, nearestTorso
end

local function startBatAimbot()
    if batAimbotConnection then return end
    batAimbotConnection = RunService.Heartbeat:Connect(function()
        if not batAimbotOn then return end
        local c = me.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local bat = findBat()
        if bat and bat.Parent ~= c then hum:EquipTool(bat) end
        local target, _, torso = findNearestEnemy(h)
        if target and torso then
            local dir = (torso.Position - h.Position)
            local flatDir = Vector3.new(dir.X, 0, dir.Z)
            if flatDir.Magnitude > 1.5 then
                local moveDir = flatDir.Unit
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X*55, h.AssemblyLinearVelocity.Y, moveDir.Z*55)
            else
                local tv = target.AssemblyLinearVelocity
                h.AssemblyLinearVelocity = Vector3.new(tv.X, h.AssemblyLinearVelocity.Y, tv.Z)
            end
        end
    end)
end

local function stopBatAimbot()
    if batAimbotConnection then batAimbotConnection:Disconnect(); batAimbotConnection = nil end
end

batAimbotTrack.MouseButton1Click:Connect(function()
    batAimbotOn = not batAimbotOn
    if batAimbotOn then toggleOn(batAimbotLabel, batAimbotTrack, batAimbotThumb); startBatAimbot()
    else toggleOff(batAimbotLabel, batAimbotTrack, batAimbotThumb); stopBatAimbot() end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        batAimbotOn = not batAimbotOn
        if batAimbotOn then toggleOn(batAimbotLabel, batAimbotTrack, batAimbotThumb); startBatAimbot()
        else toggleOff(batAimbotLabel, batAimbotTrack, batAimbotThumb); stopBatAimbot() end
    end
end)

-- ══════════════════════════════════════
--  SPEED
-- ══════════════════════════════════════

local speedOn = false
local speedConnection = nil
local speedNoStealValue = 53
local speedStealValue = 29

local speedSeparator = Instance.new("Frame")
speedSeparator.Size = UDim2.new(1, -20, 0, 2)
speedSeparator.Position = UDim2.new(0, 10, 0, 448)
speedSeparator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
speedSeparator.BackgroundTransparency = 0.6
speedSeparator.BorderSizePixel = 0
speedSeparator.ZIndex = 4
speedSeparator.Parent = ContentArea

local speedTitleLbl = Instance.new("TextLabel")
speedTitleLbl.Text = "— SPEED —"
speedTitleLbl.Size = UDim2.new(1, -20, 0, 20)
speedTitleLbl.Position = UDim2.new(0, 10, 0, 454)
speedTitleLbl.BackgroundTransparency = 1
speedTitleLbl.TextColor3 = Color3.fromRGB(255, 0, 0)
speedTitleLbl.TextSize = 12
speedTitleLbl.Font = Enum.Font.GothamBlack
speedTitleLbl.TextXAlignment = Enum.TextXAlignment.Center
speedTitleLbl.ZIndex = 5
speedTitleLbl.Parent = ContentArea

local speedRow = Instance.new("Frame")
speedRow.Size = UDim2.new(1, -20, 0, 60)
speedRow.Position = UDim2.new(0, 10, 0, 478)
speedRow.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
speedRow.BorderSizePixel = 0
speedRow.ZIndex = 4
speedRow.Parent = ContentArea
Instance.new("UICorner", speedRow).CornerRadius = UDim.new(0, 7)
local speedRowStroke = Instance.new("UIStroke", speedRow)
speedRowStroke.Color = Color3.fromRGB(255,0,0); speedRowStroke.Thickness = 0.8; speedRowStroke.Transparency = 0.5

local speedNormalLbl = Instance.new("TextLabel")
speedNormalLbl.Text = "SPEED"; speedNormalLbl.Size = UDim2.new(0,50,0,18); speedNormalLbl.Position = UDim2.new(0,8,0,4)
speedNormalLbl.BackgroundTransparency=1; speedNormalLbl.TextColor3=Color3.fromRGB(180,180,180)
speedNormalLbl.TextSize=10; speedNormalLbl.Font=Enum.Font.GothamBold
speedNormalLbl.TextXAlignment=Enum.TextXAlignment.Left; speedNormalLbl.ZIndex=5; speedNormalLbl.Parent=speedRow

local speedBox = Instance.new("TextBox")
speedBox.Text = tostring(speedNoStealValue); speedBox.Size = UDim2.new(0,55,0,22); speedBox.Position = UDim2.new(0,8,0,24)
speedBox.BackgroundColor3=Color3.fromRGB(20,20,20); speedBox.BorderSizePixel=0
speedBox.TextColor3=Color3.fromRGB(255,80,80); speedBox.TextSize=12; speedBox.Font=Enum.Font.GothamBold
speedBox.ClearTextOnFocus=true; speedBox.ZIndex=6; speedBox.Parent=speedRow
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,5)

local stealSpeedLbl = Instance.new("TextLabel")
stealSpeedLbl.Text = "STEAL"; stealSpeedLbl.Size = UDim2.new(0,50,0,18); stealSpeedLbl.Position = UDim2.new(0,72,0,4)
stealSpeedLbl.BackgroundTransparency=1; stealSpeedLbl.TextColor3=Color3.fromRGB(180,180,180)
stealSpeedLbl.TextSize=10; stealSpeedLbl.Font=Enum.Font.GothamBold
stealSpeedLbl.TextXAlignment=Enum.TextXAlignment.Left; stealSpeedLbl.ZIndex=5; stealSpeedLbl.Parent=speedRow

local stealBox = Instance.new("TextBox")
stealBox.Text = tostring(speedStealValue); stealBox.Size = UDim2.new(0,55,0,22); stealBox.Position = UDim2.new(0,72,0,24)
stealBox.BackgroundColor3=Color3.fromRGB(20,20,20); stealBox.BorderSizePixel=0
stealBox.TextColor3=Color3.fromRGB(255,80,80); stealBox.TextSize=12; stealBox.Font=Enum.Font.GothamBold
stealBox.ClearTextOnFocus=true; stealBox.ZIndex=6; stealBox.Parent=speedRow
Instance.new("UICorner", stealBox).CornerRadius = UDim.new(0,5)

local speedActivate = Instance.new("TextButton")
speedActivate.Text = "OFF"; speedActivate.Size = UDim2.new(0,60,0,40); speedActivate.Position = UDim2.new(1,-68,0.5,-20)
speedActivate.BackgroundColor3=Color3.fromRGB(25,25,25); speedActivate.TextColor3=Color3.fromRGB(220,220,220)
speedActivate.TextSize=13; speedActivate.Font=Enum.Font.GothamBlack; speedActivate.BorderSizePixel=0
speedActivate.ZIndex=6; speedActivate.Parent=speedRow
Instance.new("UICorner", speedActivate).CornerRadius = UDim.new(0,8)
local speedBtnStroke = Instance.new("UIStroke", speedActivate)
speedBtnStroke.Color=Color3.fromRGB(255,0,0); speedBtnStroke.Thickness=1.2

speedBox.FocusLost:Connect(function()
    local num = tonumber(speedBox.Text)
    if num then
        num = math.clamp(num, 15, 200)
        speedBox.Text = tostring(num)
        speedNoStealValue = num
    else
        speedBox.Text = tostring(speedNoStealValue)
    end
end)

stealBox.FocusLost:Connect(function()
    local num = tonumber(stealBox.Text)
    if num then
        num = math.clamp(num, 15, 200)
        stealBox.Text = tostring(num)
        speedStealValue = num
    else
        stealBox.Text = tostring(speedStealValue)
    end
end)

speedActivate.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    if speedOn then
        speedActivate.Text = "ON"
        speedActivate.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        speedConnection = RunService.Heartbeat:Connect(function()
            local char = me.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            speedNoStealValue = tonumber(speedBox.Text) or 53
            speedStealValue = tonumber(stealBox.Text) or 29
            local moveDirection = hum.MoveDirection
            if moveDirection.Magnitude > 0 then
                local isSteal = hum.WalkSpeed < 25
                local currentSpeed = isSteal and speedStealValue or speedNoStealValue
                hrp.AssemblyLinearVelocity = Vector3.new(
                    moveDirection.X * currentSpeed,
                    hrp.AssemblyLinearVelocity.Y,
                    moveDirection.Z * currentSpeed
                )
            end
        end)
    else
        speedActivate.Text = "OFF"
        speedActivate.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    end
end)

local currentCharacter        = nil
local ragdollRemoteConnection = nil
local moveConnection          = nil
local playerModule, controls  = nil, nil

pcall(function()
    playerModule = require(me:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    controls     = playerModule:GetControls()
end)

local function cleanupRagdoll()
    if currentCharacter then
        local root = currentCharacter:FindFirstChild("HumanoidRootPart")
        if root then local a = root:FindFirstChild("RagdollAnchor"); if a then a:Destroy() end end
    end
    if moveConnection then moveConnection:Disconnect(); moveConnection = nil end
end
local function disconnectRemote()
    if ragdollRemoteConnection then ragdollRemoteConnection:Disconnect(); ragdollRemoteConnection = nil end
end
local function setupAntiRagdoll(char)
    currentCharacter = char
    cleanupRagdoll(); disconnectRemote()
    local humanoid = char:WaitForChild("Humanoid", 5)
    local root     = char:WaitForChild("HumanoidRootPart", 5)
    local head     = char:WaitForChild("Head", 5)
    if not (humanoid and root and head) then return end
    local ragdollRemote
    pcall(function()
        ragdollRemote = ReplicatedStorage:WaitForChild("Packages",8):WaitForChild("Ragdoll",5):WaitForChild("Ragdoll",5)
    end)
    if not ragdollRemote or not ragdollRemote:IsA("RemoteEvent") then return end
    ragdollRemoteConnection = ragdollRemote.OnClientEvent:Connect(function(arg1, arg2)
        if not antiRagdollEnabled then return end
        if arg1 == "Make" or arg2 == "manualM" then
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
            Camera.CameraSubject = head; root.CanCollide = false
            if controls then pcall(controls.Enable, controls) end
            cleanupRagdoll()
            local anchor = Instance.new("BodyPosition")
            anchor.Name="RagdollAnchor"; anchor.MaxForce=Vector3.new(1e5,1e5,1e5)
            anchor.Position=root.Position; anchor.D=200; anchor.P=5000; anchor.Parent=root
            moveConnection = RunService.Heartbeat:Connect(function()
                if not antiRagdollEnabled then cleanupRagdoll(); return end
                local moveDir = Vector3.zero
                if controls then pcall(function() moveDir = controls:GetMoveVector() end) end
                if moveDir.Magnitude > 0.1 then
                    local cf  = Camera.CFrame
                    local fwd = Vector3.new(cf.LookVector.X,0,cf.LookVector.Z).Unit
                    local rgt = Vector3.new(cf.RightVector.X,0,cf.RightVector.Z).Unit
                    anchor.Position = root.Position + (fwd*-moveDir.Z+rgt*moveDir.X).Unit*RAGDOLL_SPEED*0.1
                else
                    anchor.Position = root.Position
                end
            end)
        elseif arg1 == "Destroy" or arg2 == "manualD" then
            cleanupRagdoll()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            root.CanCollide=true; Camera.CameraSubject=humanoid
            if controls then pcall(controls.Enable, controls) end
        end
    end)
end

me.CharacterAdded:Connect(function(newChar)
    if antiRagdollEnabled then task.wait(1); setupAntiRagdoll(newChar) end
end)

ragdollTrack.MouseButton1Click:Connect(function()
    antiRagdollEnabled = not antiRagdollEnabled
    if antiRagdollEnabled then
        toggleOn(ragdollLabel, ragdollTrack, ragdollThumb)
        if me.Character then setupAntiRagdoll(me.Character) end
    else
        toggleOff(ragdollLabel, ragdollTrack, ragdollThumb)
        cleanupRagdoll(); disconnectRemote()
    end
end)

-- FPS BOOST
local fpsDescConn = nil
local function stripVisuals(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect")
        or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("Atmosphere") then
            obj:Destroy()
        elseif obj:IsA("BasePart") then obj.CastShadow = false end
    end)
end
local function enableFPSBoost()
    pcall(function()
        Lighting.GlobalShadows=false; Lighting.FogEnd=1000000; Lighting.FogStart=0
        Lighting.Brightness=2; Lighting.EnvironmentDiffuseScale=1; Lighting.EnvironmentSpecularScale=1
    end)
    pcall(function()
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect")
            or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then v:Destroy() end
        end
    end)
    pcall(function() for _, obj in pairs(workspace:GetDescendants()) do stripVisuals(obj) end end)
    if fpsDescConn then fpsDescConn:Disconnect() end
    fpsDescConn = workspace.DescendantAdded:Connect(stripVisuals)
end
task.defer(function() task.wait(1); enableFPSBoost() end)

-- RADIUS INPUT (fuera del hub, abajo)
local radiusRow = Instance.new("Frame")
radiusRow.Size                   = UDim2.new(0, 276, 0, 44)
radiusRow.Position               = UDim2.new(0, 0, 0, 708)
radiusRow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
radiusRow.BackgroundTransparency = 0
radiusRow.BorderSizePixel        = 0
radiusRow.ZIndex                 = 4
radiusRow.Parent                 = ScreenGui
Instance.new("UICorner", radiusRow).CornerRadius = UDim.new(0, 7)
local radiusRowStroke = Instance.new("UIStroke", radiusRow)
radiusRowStroke.Color = Color3.fromRGB(255,0,0); radiusRowStroke.Thickness = 0.8; radiusRowStroke.Transparency = 0.5

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
    else
        radiusInput.Text = tostring(AUTO_STEAL_PROX_RADIUS)
    end
end)

-- FOV SLIDER
local FOV_MIN, FOV_MAX = 70, 120
local fovRow = Instance.new("Frame")
fovRow.Size=UDim2.new(1,-20,0,54); fovRow.Position=UDim2.new(0,10,1,-118)
fovRow.BackgroundColor3=Color3.fromRGB(0,0,0); fovRow.BackgroundTransparency=0
fovRow.BorderSizePixel=0; fovRow.ZIndex=4; fovRow.Parent=MainFrame
Instance.new("UICorner", fovRow).CornerRadius = UDim.new(0,7)

local fovTitleLabel = Instance.new("TextLabel")
fovTitleLabel.Text="FOV"; fovTitleLabel.Size=UDim2.new(0,80,0,20); fovTitleLabel.Position=UDim2.new(0,4,0,2)
fovTitleLabel.BackgroundTransparency=1; fovTitleLabel.TextColor3=Color3.fromRGB(255,0,0)
fovTitleLabel.TextSize=13; fovTitleLabel.Font=Enum.Font.GothamBlack
fovTitleLabel.TextXAlignment=Enum.TextXAlignment.Left; fovTitleLabel.ZIndex=5; fovTitleLabel.Parent=fovRow

local fovValLabel = Instance.new("TextLabel")
fovValLabel.Text=tostring(fovValue); fovValLabel.Size=UDim2.new(0,50,0,20); fovValLabel.Position=UDim2.new(1,-54,0,2)
fovValLabel.BackgroundTransparency=1; fovValLabel.TextColor3=Color3.fromRGB(180,180,180)
fovValLabel.TextSize=13; fovValLabel.Font=Enum.Font.GothamBlack
fovValLabel.TextXAlignment=Enum.TextXAlignment.Right; fovValLabel.ZIndex=5; fovValLabel.Parent=fovRow

local sliderTrack = Instance.new("Frame")
sliderTrack.Size=UDim2.new(1,-8,0,6); sliderTrack.Position=UDim2.new(0,4,0,30)
sliderTrack.BackgroundColor3=Color3.fromRGB(35,35,35); sliderTrack.BorderSizePixel=0
sliderTrack.ZIndex=5; sliderTrack.Parent=fovRow
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1,0)

local sliderFill = Instance.new("Frame")
sliderFill.Size=UDim2.new(0,0,1,0); sliderFill.BackgroundColor3=Color3.fromRGB(200,0,0)
sliderFill.BorderSizePixel=0; sliderFill.ZIndex=6; sliderFill.Parent=sliderTrack
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1,0)

local sliderThumb = Instance.new("Frame")
sliderThumb.Size=UDim2.new(0,28,0,28); sliderThumb.Position=UDim2.new(0,-14,0.5,-14)
sliderThumb.BackgroundTransparency=1; sliderThumb.BorderSizePixel=0
sliderThumb.ZIndex=8; sliderThumb.Parent=sliderTrack

local thumbImg = Instance.new("ImageLabel")
thumbImg.Size=UDim2.new(1,0,1,0); thumbImg.BackgroundTransparency=1
thumbImg.Image="rbxassetid://11662710259"; thumbImg.ImageColor3=Color3.fromRGB(255,0,0)
thumbImg.ScaleType=Enum.ScaleType.Fit; thumbImg.ZIndex=9; thumbImg.Parent=sliderThumb

local function updateFOVVisual(pct)
    sliderFill.Size      = UDim2.new(pct, 0, 1, 0)
    sliderThumb.Position = UDim2.new(pct, -14, 0.5, -14)
    fovValLabel.Text     = tostring(fovValue)
end
updateFOVVisual((fovValue - FOV_MIN) / (FOV_MAX - FOV_MIN))

local draggingFOV = false
sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFOV = true
        TweenService:Create(thumbImg, TweenInfo.new(0.1), {ImageColor3 = Color3.fromRGB(255,80,80)}):Play()
    end
end)
sliderTrack.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFOV = false
        TweenService:Create(thumbImg, TweenInfo.new(0.1), {ImageColor3 = Color3.fromRGB(255,0,0)}):Play()
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingFOV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pct = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        fovValue = math.floor(FOV_MIN + pct * (FOV_MAX - FOV_MIN))
        Camera.FieldOfView = fovValue
        updateFOVVisual(pct)
    end
end)

-- SAVE CONFIG
local SaveFrame = Instance.new("Frame")
SaveFrame.Size=UDim2.new(1,-24,0,40); SaveFrame.Position=UDim2.new(0,12,1,-52)
SaveFrame.BackgroundColor3=Color3.fromRGB(0,0,0); SaveFrame.BackgroundTransparency=0
SaveFrame.BorderSizePixel=0; SaveFrame.ZIndex=6; SaveFrame.Parent=MainFrame
Instance.new("UICorner", SaveFrame).CornerRadius = UDim.new(0,7)
local sfStroke = Instance.new("UIStroke", SaveFrame)
sfStroke.Color=Color3.fromRGB(0,0,0); sfStroke.Thickness=1.5

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size=UDim2.new(1,0,1,0); SaveBtn.BackgroundTransparency=1
SaveBtn.Text="SAVE CONFIG"; SaveBtn.Font=Enum.Font.GothamBlack; SaveBtn.TextSize=13
SaveBtn.TextColor3=Color3.fromRGB(255,80,80); SaveBtn.TextStrokeColor3=Color3.fromRGB(0,0,0)
SaveBtn.TextStrokeTransparency=0; SaveBtn.BorderSizePixel=0; SaveBtn.ZIndex=7; SaveBtn.Parent=SaveFrame
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0,8)
local saveBtnStroke = Instance.new("UIStroke", SaveBtn)
saveBtnStroke.Color=Color3.fromRGB(0,0,0); saveBtnStroke.Thickness=1.5

SaveBtn.MouseEnter:Connect(function() TweenService:Create(SaveBtn,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(255,255,255)}):Play() end)
SaveBtn.MouseLeave:Connect(function() TweenService:Create(SaveBtn,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(255,80,80)}):Play() end)
SaveBtn.MouseButton1Click:Connect(function()
    saveConfig(); SaveBtn.Text="SAVED!"; task.wait(1); SaveBtn.Text="SAVE CONFIG"
end)

-- DRAG
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

-- APERTURA
MainFrame.Size = UDim2.new(0,300,0,0)
TweenService:Create(MainFrame, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,300,0,700)}):Play()

-- AUTO-LOAD CONFIG
task.defer(function()
    if savedCfg.Unwalk then
        unwalkOn = true; toggleOn(unwalkLabel, unwalkTrack, unwalkThumb); enableUnwalk()
    end
    if savedCfg.Xray then
        xrayOn = true; toggleOn(xrayLabel, xrayTrack, xrayThumb); startXray()
    end
    if savedCfg.ESP then
        espOn = true; toggleOn(espLabel, espTrack, espThumb); enableESP()
    end
    if savedCfg.AntiRagdoll then
        antiRagdollEnabled = true; toggleOn(ragdollLabel, ragdollTrack, ragdollThumb)
        if me.Character then setupAntiRagdoll(me.Character) end
    end
    if savedCfg.FOV then
        fovValue = math.clamp(savedCfg.FOV, FOV_MIN, FOV_MAX)
        Camera.FieldOfView = fovValue
        updateFOVVisual((fovValue - FOV_MIN) / (FOV_MAX - FOV_MIN))
    end
    if savedCfg.InfJump then
        infJumpOn = true; toggleOn(infJumpLabel, infJumpTrack, infJumpThumb)
    end
    if savedCfg.StealRadius then
        AUTO_STEAL_PROX_RADIUS = math.clamp(savedCfg.StealRadius, 1, 999)
        radiusInput.Text = tostring(AUTO_STEAL_PROX_RADIUS)
    end
    if savedCfg.AutoSteal then
        autoStealActive = true; toggleOn(autoStealLabel, autoStealTrack, autoStealThumb)
        enableAutoSteal()
    end
    if savedCfg.GalaxySky then
        galaxySkyOn = true; toggleOn(galaxySkyLabel, galaxySkyTrack, galaxySkyThumb)
        enableGalaxySkyBright()
    end
end)
