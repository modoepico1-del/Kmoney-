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
    DARK_MODE           = false,
    WHITE_MODE          = false,
    ESP                 = false,
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
        DARK_MODE              = CONFIG.DARK_MODE,
        WHITE_MODE             = CONFIG.WHITE_MODE,
        ESP                    = CONFIG.ESP,
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
            CONFIG.DARK_MODE          = data.DARK_MODE or false
            CONFIG.WHITE_MODE         = data.WHITE_MODE or false
            CONFIG.ESP                = data.ESP or false
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
local AUTO_STEAL_PROX_RADIUS = 7
local stealConnection        = nil
local velocityConnection     = nil

local h, hrp, speedLbl

local autoBatToggled  = false
local hittingCooldown = false
local SAFE_DELAY      = 0.08

local optimizerDescendantConnection = nil
local optimizerLightingConnection   = nil

-- ══════════════════════════════════════════
--   DARK MODE
-- ══════════════════════════════════════════
local darkCC                   = nil
local darkOriginalTransparency = {}
local darkXrayActive           = false

local function enableDarkMode()
    if darkCC and darkCC.Parent then return end
    darkCC = Instance.new("ColorCorrectionEffect")
    darkCC.Name="NebulaDarkMode"; darkCC.Brightness=-0.25
    darkCC.Contrast=0.1; darkCC.Saturation=-0.1
    darkCC.Enabled=true; darkCC.Parent=Lighting
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd=9e9; Lighting.FogStart=9e9
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("PostEffect") and fx ~= darkCC then fx.Enabled = false end
        end
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false; obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false; obj.Material = Enum.Material.Plastic
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
                            child:Destroy()
                        end
                    end
                elseif obj:IsA("Sky") then obj:Destroy() end
            end)
        end
    end)
    darkXrayActive = true
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored
            and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                darkOriginalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.88
            end
        end
    end)
end

local function disableDarkMode()
    if darkCC then darkCC:Destroy(); darkCC = nil end
    pcall(function()
        Lighting.GlobalShadows = true
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("PostEffect") then fx.Enabled = true end
        end
    end)
    if darkXrayActive then
        for part, value in pairs(darkOriginalTransparency) do
            if part and part.Parent then part.LocalTransparencyModifier = value end
        end
        darkOriginalTransparency = {}; darkXrayActive = false
    end
end

-- ══════════════════════════════════════════
--   GALAXY SKY
-- ══════════════════════════════════════════
local galaxySkyActive         = false
local galaxySkyInstance       = nil
local galaxySkyOriginalSkybox = nil
local galaxySkyConn           = nil
local galaxySkyPlanets        = {}
local galaxySkyBloom          = nil
local galaxySkyCC             = nil

local function enableWhiteMode()
    if galaxySkyInstance then return end
    galaxySkyOriginalSkybox = Lighting:FindFirstChildOfClass("Sky")
    if galaxySkyOriginalSkybox then galaxySkyOriginalSkybox.Parent = nil end
    galaxySkyInstance = Instance.new("Sky")
    galaxySkyInstance.SkyboxBk="rbxassetid://1534951537"
    galaxySkyInstance.SkyboxDn="rbxassetid://1534951537"
    galaxySkyInstance.SkyboxFt="rbxassetid://1534951537"
    galaxySkyInstance.SkyboxLf="rbxassetid://1534951537"
    galaxySkyInstance.SkyboxRt="rbxassetid://1534951537"
    galaxySkyInstance.SkyboxUp="rbxassetid://1534951537"
    galaxySkyInstance.StarCount=10000
    galaxySkyInstance.CelestialBodiesShown=false
    galaxySkyInstance.Parent=Lighting
    galaxySkyBloom=Instance.new("BloomEffect")
    galaxySkyBloom.Intensity=1.5; galaxySkyBloom.Size=40
    galaxySkyBloom.Threshold=0.8; galaxySkyBloom.Parent=Lighting
    galaxySkyCC=Instance.new("ColorCorrectionEffect")
    galaxySkyCC.Saturation=0.8; galaxySkyCC.Contrast=0.3
    galaxySkyCC.TintColor=Color3.fromRGB(200,150,255)
    galaxySkyCC.Parent=Lighting
    Lighting.Ambient=Color3.fromRGB(120,60,180)
    Lighting.Brightness=3; Lighting.ClockTime=0
    for i=1,2 do
        local p=Instance.new("Part"); p.Shape=Enum.PartType.Ball
        p.Size=Vector3.new(800+i*200,800+i*200,800+i*200)
        p.Anchored=true; p.CanCollide=false; p.CastShadow=false
        p.Material=Enum.Material.Neon
        p.Color=Color3.fromRGB(140+i*20,60+i*10,200+i*15)
        p.Transparency=0.3
        p.Position=Vector3.new(math.cos(i*2)*(3000+i*500),1500+i*300,math.sin(i*2)*(3000+i*500))
        p.Parent=workspace
        table.insert(galaxySkyPlanets,p)
    end
    galaxySkyConn=RunService.Heartbeat:Connect(function()
        if not CONFIG.WHITE_MODE then return end
        local t=tick()*0.5
        Lighting.Ambient=Color3.fromRGB(
            120+math.floor(math.sin(t)*60),
            50+math.floor(math.sin(t*0.8)*40),
            180+math.floor(math.sin(t*1.2)*50)
        )
        if galaxySkyBloom then galaxySkyBloom.Intensity=1.2+math.sin(t*2)*0.4 end
    end)
    galaxySkyActive = true
end

local function disableWhiteMode()
    if galaxySkyConn then galaxySkyConn:Disconnect(); galaxySkyConn=nil end
    if galaxySkyInstance then galaxySkyInstance:Destroy(); galaxySkyInstance=nil end
    if galaxySkyOriginalSkybox then galaxySkyOriginalSkybox.Parent=Lighting end
    if galaxySkyBloom then galaxySkyBloom:Destroy(); galaxySkyBloom=nil end
    if galaxySkyCC then galaxySkyCC:Destroy(); galaxySkyCC=nil end
    for _,obj in ipairs(galaxySkyPlanets) do if obj and obj.Parent then obj:Destroy() end end
    galaxySkyPlanets={}
    Lighting.Ambient=Color3.fromRGB(127,127,127)
    Lighting.Brightness=2; Lighting.ClockTime=14
    galaxySkyActive = false
end

-- ══════════════════════════════════════════
--   CORE FUNCTIONS
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

-- ══════════════════════════════════════════
--   ESP (Demontime - color gris)
-- ══════════════════════════════════════════
local espObjects = {}
local espConnections = {}

local function createESP(plr)
    if plr == LocalPlayer then return end
    if not plr.Character then return end
    if plr.Character:FindFirstChild("VyseESP") then return end
    local c = plr.Character
    local hrpESP = c:FindFirstChild("HumanoidRootPart"); if not hrpESP then return end
    local head = c:FindFirstChild("Head")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "VyseESP"; hitbox.Adornee = hrpESP; hitbox.Size = Vector3.new(4,6,2)
    hitbox.Color3 = Color3.fromRGB(180,180,180); hitbox.Transparency = 0.3
    hitbox.ZIndex = 10; hitbox.AlwaysOnTop = true; hitbox.Parent = c
    espObjects[plr] = hitbox
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "VyseESP_Name"; billboard.Adornee = head
        billboard.Size = UDim2.new(0,200,0,50); billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true; billboard.Parent = c
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1
        label.Text = plr.DisplayName or plr.Name
        label.TextColor3 = Color3.fromRGB(200,200,200)
        label.Font = Enum.Font.GothamBold; label.TextScaled = true
        label.TextStrokeTransparency = 0.6
        label.TextStrokeColor3 = Color3.fromRGB(0,0,0); label.Parent = billboard
    end
end

local function removeESP(plr)
    pcall(function()
        if plr.Character then
            local hESP = plr.Character:FindFirstChild("VyseESP"); if hESP then hESP:Destroy() end
            local n = plr.Character:FindFirstChild("VyseESP_Name"); if n then n:Destroy() end
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Automatic end
        end
        espObjects[plr] = nil
    end)
end

local function enableESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if plr.Character then pcall(function() createESP(plr) end) end
            table.insert(espConnections, plr.CharacterAdded:Connect(function()
                task.wait(0.1); if CONFIG.ESP then pcall(function() createESP(plr) end) end
            end))
        end
    end
    table.insert(espConnections, Players.PlayerAdded:Connect(function(plr)
        if plr == LocalPlayer then return end
        table.insert(espConnections, plr.CharacterAdded:Connect(function()
            task.wait(0.1); if CONFIG.ESP then pcall(function() createESP(plr) end) end
        end))
    end))
end

local function disableESP()
    for _, plr in ipairs(Players:GetPlayers()) do pcall(function() removeESP(plr) end) end
    for _, conn in ipairs(espConnections) do if conn and conn.Connected then conn:Disconnect() end end
    espConnections = {}; espObjects = {}
end

-- ══════════════════════════════════════════
--   AUTO STEAL (Demontime)
-- ══════════════════════════════════════════
local autoStealActive        = false
local autoStealStealConn     = nil
local autoStealAnimalsCache  = {}
local autoStealPromptCache   = {}
local autoStealInternalCache = {}
local autoStealIsStealing    = false

local animalsDataAS = {}
pcall(function()
    animalsDataAS = require(ReplicatedStorage:WaitForChild("Datas",5):WaitForChild("Animals",5))
end)

local function autoSteal_getHRP()
    local char = LocalPlayer.Character
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
        if yourBase and yourBase:IsA("BillboardGui") then return yourBase.Enabled == true end
    end
    return false
end

local function autoSteal_scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if autoSteal_isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return end
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
                uid = plot.Name.."_"..podium.Name,
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
        local plots = workspace:WaitForChild("Plots",10); if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then autoSteal_scanPlot(plot) end end
        plots.ChildAdded:Connect(function(plot) if plot:IsA("Model") then task.wait(0.5); autoSteal_scanPlot(plot) end end)
        task.spawn(function()
            while task.wait(5) do
                autoStealAnimalsCache = {}
                for _, plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then autoSteal_scanPlot(plot) end end
            end
        end)
    end)
end

local function autoSteal_findPrompt(animalData)
    if not animalData then return nil end
    local cached = autoStealPromptCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(animalData.plot); if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot); if not podium then return nil end
    local base = podium:FindFirstChild("Base"); if not base then return nil end
    local spawn = base:FindFirstChild("Spawn"); if not spawn then return nil end
    local attach = spawn:FindFirstChild("PromptAttachment"); if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then autoStealPromptCache[animalData.uid] = p; return p end
    end
    return nil
end

local function autoSteal_buildCallbacks(prompt)
    if autoStealInternalCache[prompt] then return end
    local data = { holdCallbacks={}, triggerCallbacks={}, ready=true }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1)=="table" then
        for _, conn in ipairs(conns1) do if type(conn.Function)=="function" then table.insert(data.holdCallbacks, conn.Function) end end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2)=="table" then
        for _, conn in ipairs(conns2) do if type(conn.Function)=="function" then table.insert(data.triggerCallbacks, conn.Function) end end
    end
    if (#data.holdCallbacks>0) or (#data.triggerCallbacks>0) then autoStealInternalCache[prompt] = data end
end

local function autoSteal_execute(prompt)
    local data = autoStealInternalCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false; autoStealIsStealing = true
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        task.wait(0.2)
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        task.wait(0.01); data.ready = true; task.wait(0.01); autoStealIsStealing = false
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
    local hrpAS = autoSteal_getHRP(); if not hrpAS then return nil end
    local nearest, minDist = nil, math.huge
    for _, animalData in ipairs(autoStealAnimalsCache) do
        if autoSteal_isMyBase(animalData.plot) then continue end
        if animalData.worldPosition then
            local dist = (hrpAS.Position - animalData.worldPosition).Magnitude
            if dist < minDist then minDist = dist; nearest = animalData end
        end
    end
    return nearest
end

local function startAutoStealLoop()
    if autoStealStealConn then autoStealStealConn:Disconnect() end
    autoStealStealConn = RunService.Heartbeat:Connect(function()
        if not autoStealActive or autoStealIsStealing then return end
        local target = autoSteal_getNearest(); if not target or not target.worldPosition then return end
        local hrpAS = autoSteal_getHRP(); if not hrpAS then return end
        if (hrpAS.Position - target.worldPosition).Magnitude > AUTO_STEAL_PROX_RADIUS then return end
        local prompt = autoStealPromptCache[target.uid]
        if not prompt or not prompt.Parent then prompt = autoSteal_findPrompt(target) end
        if prompt then autoSteal_attempt(prompt) end
    end)
end

local function enableAutoSteal()
    autoStealActive = true; autoSteal_initScanner(); startAutoStealLoop()
end

local function disableAutoSteal()
    autoStealActive = false
    if autoStealStealConn then autoStealStealConn:Disconnect(); autoStealStealConn = nil end
    autoStealIsStealing = false
end

-- ══════════════════════════════════════════
--   BAT AIMBOT (Demontime)
-- ══════════════════════════════════════════
local batAimbotOn = false
local batAimbotConnection = nil

local function findBat()
    local c = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if c then for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    return nil
end

local function findNearestEnemy(myHRP)
    local nearest, nearestDist, nearestTorso = nil, math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
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
        local c = LocalPlayer.Character; if not c then return end
        local hb = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hb or not hum then return end
        local bat = findBat()
        if bat and bat.Parent ~= c then hum:EquipTool(bat) end
        local target, _, torso = findNearestEnemy(hb)
        if target and torso then
            local dir = (torso.Position - hb.Position)
            local flatDir = Vector3.new(dir.X, 0, dir.Z)
            if flatDir.Magnitude > 1.5 then
                local moveDir = flatDir.Unit
                hb.AssemblyLinearVelocity = Vector3.new(moveDir.X*55, hb.AssemblyLinearVelocity.Y, moveDir.Z*55)
            else
                local tv = target.AssemblyLinearVelocity
                hb.AssemblyLinearVelocity = Vector3.new(tv.X, hb.AssemblyLinearVelocity.Y, tv.Z)
            end
        end
    end)
end

local function stopBatAimbot()
    if batAimbotConnection then batAimbotConnection:Disconnect(); batAimbotConnection = nil end
end

-- ══════════════════════════════════════════
--   ROUTE (Auto Left Z / Auto Right C)
-- ══════════════════════════════════════════
local AutoLeftEnabled  = false
local AutoRightEnabled = false
local autoLeftConn     = nil
local autoRightConn    = nil
local autoLeftPhase    = 1
local autoRightPhase   = 1
local ROUTE_SPEED      = 60

local POSITION_L1 = Vector3.new(-476.48, -6.28,  92.73)
local POSITION_L2 = Vector3.new(-483.12, -4.95,  94.80)
local POSITION_R1 = Vector3.new(-476.16, -6.52,  25.62)
local POSITION_R2 = Vector3.new(-483.04, -5.09,  23.14)

-- Referencias para los toggles de Route (se asignan después de crear la GUI)
local routeLeftTogRef  = nil
local routeRightTogRef = nil

local function stopAutoLeft()
    if autoLeftConn then autoLeftConn:Disconnect(); autoLeftConn = nil end
    autoLeftPhase = 1
    local c = LocalPlayer.Character
    if c then local hm = c:FindFirstChildOfClass("Humanoid"); if hm then hm:Move(Vector3.zero, false) end end
end

local function stopAutoRight()
    if autoRightConn then autoRightConn:Disconnect(); autoRightConn = nil end
    autoRightPhase = 1
    local c = LocalPlayer.Character
    if c then local hm = c:FindFirstChildOfClass("Humanoid"); if hm then hm:Move(Vector3.zero, false) end end
end

local function startAutoLeft()
    if autoLeftConn then autoLeftConn:Disconnect() end
    autoLeftPhase = 1
    autoLeftConn = RunService.Heartbeat:Connect(function()
        if not AutoLeftEnabled then return end
        local c = LocalPlayer.Character; if not c then return end
        local rp = c:FindFirstChild("HumanoidRootPart")
        local hm = c:FindFirstChildOfClass("Humanoid")
        if not rp or not hm then return end
        if autoLeftPhase == 1 then
            local tgt = Vector3.new(POSITION_L1.X, rp.Position.Y, POSITION_L1.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                autoLeftPhase = 2
                local d = (POSITION_L2 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
                hm:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*ROUTE_SPEED, rp.AssemblyLinearVelocity.Y, mv.Z*ROUTE_SPEED); return
            end
            local d = (POSITION_L1 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
            hm:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*ROUTE_SPEED, rp.AssemblyLinearVelocity.Y, mv.Z*ROUTE_SPEED)
        elseif autoLeftPhase == 2 then
            local tgt = Vector3.new(POSITION_L2.X, rp.Position.Y, POSITION_L2.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                hm:Move(Vector3.zero,false); rp.AssemblyLinearVelocity = Vector3.zero
                AutoLeftEnabled = false
                stopAutoLeft()
                if routeLeftTogRef then
                    routeLeftTogRef.state = false
                    TweenService:Create(routeLeftTogRef.togBG,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(55,55,55)}):Play()
                    TweenService:Create(routeLeftTogRef.knob,TweenInfo.new(0.15),{Position=UDim2.new(0,3,0.5,-8)}):Play()
                end
                return
            end
            local d = (POSITION_L2 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
            hm:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*ROUTE_SPEED, rp.AssemblyLinearVelocity.Y, mv.Z*ROUTE_SPEED)
        end
    end)
end

local function startAutoRight()
    if autoRightConn then autoRightConn:Disconnect() end
    autoRightPhase = 1
    autoRightConn = RunService.Heartbeat:Connect(function()
        if not AutoRightEnabled then return end
        local c = LocalPlayer.Character; if not c then return end
        local rp = c:FindFirstChild("HumanoidRootPart")
        local hm = c:FindFirstChildOfClass("Humanoid")
        if not rp or not hm then return end
        if autoRightPhase == 1 then
            local tgt = Vector3.new(POSITION_R1.X, rp.Position.Y, POSITION_R1.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                autoRightPhase = 2
                local d = (POSITION_R2 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
                hm:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*ROUTE_SPEED, rp.AssemblyLinearVelocity.Y, mv.Z*ROUTE_SPEED); return
            end
            local d = (POSITION_R1 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
            hm:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*ROUTE_SPEED, rp.AssemblyLinearVelocity.Y, mv.Z*ROUTE_SPEED)
        elseif autoRightPhase == 2 then
            local tgt = Vector3.new(POSITION_R2.X, rp.Position.Y, POSITION_R2.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                hm:Move(Vector3.zero,false); rp.AssemblyLinearVelocity = Vector3.zero
                AutoRightEnabled = false
                stopAutoRight()
                if routeRightTogRef then
                    routeRightTogRef.state = false
                    TweenService:Create(routeRightTogRef.togBG,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(55,55,55)}):Play()
                    TweenService:Create(routeRightTogRef.knob,TweenInfo.new(0.15),{Position=UDim2.new(0,3,0.5,-8)}):Play()
                end
                return
            end
            local d = (POSITION_R2 - rp.Position); local mv = Vector3.new(d.X,0,d.Z).Unit
            hm:Move(mv,false); rp.AssemblyLinearVelocity = Vector3.new(mv.X*ROUTE_SPEED, rp.AssemblyLinearVelocity.Y, mv.Z*ROUTE_SPEED)
        end
    end)
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
--   GUI HELPERS
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

local RightScroll = Make("ScrollingFrame", {
    Size=UDim2.new(1,0,1,0),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=3,
    ScrollBarImageColor3=Color3.fromRGB(80,80,80),
    CanvasSize=UDim2.new(0,0,0,0),
    Parent=RightPanel,
})

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

local tabNames = {"Speed", "Steal", "Combat", "Visual", "Features", "Settings"}
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
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
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

CreateToggle(SpeedContent, "Speed Boost", 168, false, function(v) CONFIG.SPEED_BOOST = v end)

-- ══════════════════════════════════════════
--   STEAL TAB
-- ══════════════════════════════════════════
local StealContent = Tabs["Steal"]
CreateSectionLabel(StealContent, "AUTO STEAL", 6)

local instaGrabTogRef = CreateToggle(StealContent, "Insta Grab", 30, false, function(v)
    CONFIG.AUTO_STEAL_NEAREST = v
    if v then enableAutoSteal() else disableAutoSteal() end
end)

CreateSectionLabel(StealContent, "RADIUS CONTROL", 80)
CreateInputRow(StealContent, "Grab Radius", 100, AUTO_STEAL_PROX_RADIUS, function(v)
    AUTO_STEAL_PROX_RADIUS = v
end)

-- ══════════════════════════════════════════
--   COMBAT TAB
-- ══════════════════════════════════════════
local CombatContent = Tabs["Combat"]
CreateSectionLabel(CombatContent, "BAT AIMBOT", 6)

local autoBatTogRef = CreateToggle(CombatContent, "Auto-Bat [E]", 30, false, function(v)
    CONFIG.BAT_AIMBOT_AUTOBAT = v
    batAimbotOn = v
    if v then startBatAimbot() else stopBatAimbot() end
end)

-- ══════════════════════════════════════════
--   VISUAL TAB
-- ══════════════════════════════════════════
local VisualContent = Tabs["Visual"]
CreateSectionLabel(VisualContent, "VISUAL", 6)

CreateToggle(VisualContent, "Optimizer", 30, false, function(v)
    CONFIG.OPTIMIZER = v
    if v then pcall(applyAdvancedOptimizer) else pcall(disableOptimizer) end
end)

CreateToggle(VisualContent, "Dark Mode", 76, false, function(v)
    CONFIG.DARK_MODE = v
    if v then pcall(enableDarkMode) else pcall(disableDarkMode) end
end)

CreateToggle(VisualContent, "Galaxy Sky", 122, false, function(v)
    CONFIG.WHITE_MODE = v
    if v then pcall(enableWhiteMode) else pcall(disableWhiteMode) end
end)

CreateSectionLabel(VisualContent, "FIELD OF VIEW", 172)
CreateInputRow(VisualContent, "FOV (70-120)", 192, math.floor(Camera.FieldOfView), function(v)
    Camera.FieldOfView = math.clamp(v, 70, 120)
end)

-- ══════════════════════════════════════════
--   FEATURES TAB
-- ══════════════════════════════════════════
local FeatContent = Tabs["Features"]
CreateSectionLabel(FeatContent, "FEATURES", 6)

CreateToggle(FeatContent, "Infinite Jump", 30, false, function(v) CONFIG.INFINITE_JUMP = v end)
CreateToggle(FeatContent, "Anti-Ragdoll",  76, true,  function(v) CONFIG.ANTI_RAGDOLL = v end)
CreateToggle(FeatContent, "ESP",           122, false, function(v)
    CONFIG.ESP = v
    if v then enableESP() else disableESP() end
end)

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

-- ROUTE en Settings
CreateSectionLabel(SetContent, "ROUTE  [Z] Left  [C] Right", 118)

routeLeftTogRef = CreateToggle(SetContent, "Auto Left [Z]", 138, false, function(v)
    AutoLeftEnabled = v
    if v then
        if AutoRightEnabled then
            AutoRightEnabled = false
            stopAutoRight()
            if routeRightTogRef then
                routeRightTogRef.state = false
                Tween(routeRightTogRef.togBG, {BackgroundColor3=Color3.fromRGB(55,55,55)})
                Tween(routeRightTogRef.knob,  {Position=UDim2.new(0,3,0.5,-8)})
            end
        end
        startAutoLeft()
    else
        stopAutoLeft()
    end
end)

routeRightTogRef = CreateToggle(SetContent, "Auto Right [C]", 184, false, function(v)
    AutoRightEnabled = v
    if v then
        if AutoLeftEnabled then
            AutoLeftEnabled = false
            stopAutoLeft()
            if routeLeftTogRef then
                routeLeftTogRef.state = false
                Tween(routeLeftTogRef.togBG, {BackgroundColor3=Color3.fromRGB(55,55,55)})
                Tween(routeLeftTogRef.knob,  {Position=UDim2.new(0,3,0.5,-8)})
            end
        end
        startAutoRight()
    else
        stopAutoRight()
    end
end)

Make("TextLabel", { Text="discord.gg/jRsgRcun", Size=UDim2.new(1,-10,0,20), Position=UDim2.new(0,5,1,-30), BackgroundTransparency=1, TextColor3=Color3.fromRGB(70,70,70), Font=Enum.Font.Gotham, TextSize=9, TextXAlignment=Enum.TextXAlignment.Center, Parent=SetContent })

-- ══════════════════════════════════════════
--   FPS / PING
-- ══════════════════════════════════════════
local fpsFrame = Make("Frame", {
    Size=UDim2.new(0,150,0,60), Position=UDim2.new(1,-160,0,10),
    BackgroundColor3=Color3.fromRGB(18,18,18), BorderSizePixel=0, Parent=ScreenGui,
})
Make("UICorner", { CornerRadius=UDim.new(0,8), Parent=fpsFrame })
Make("UIStroke", { Color=Color3.fromRGB(50,50,50), Thickness=1, Parent=fpsFrame })
local fpsLabel  = Make("TextLabel", { Size=UDim2.new(1,0,0.5,0), BackgroundTransparency=1, Text="FPS: 60", TextColor3=Color3.fromRGB(0,255,0), Font=Enum.Font.GothamBold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Center, Parent=fpsFrame })
local pingLabel = Make("TextLabel", { Size=UDim2.new(1,0,0.5,0), Position=UDim2.new(0,0,0.5,0), BackgroundTransparency=1, Text="PING: 0ms", TextColor3=Color3.fromRGB(0,255,0), Font=Enum.Font.GothamBold, TextSize=14, TextXAlignment=Enum.TextXAlignment.Center, Parent=fpsFrame })

-- ══════════════════════════════════════════
--   INPUT HANDLING
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Speed mode toggle
    if input.KeyCode == Enum.KeyCode.Q and CONFIG.SPEED_BOOST then
        speedToggled = not speedToggled
        modeLbl.Text = speedToggled and "Carry" or "Normal"
    end

    -- Bat aimbot keybind
    if input.KeyCode == autoBatKey then
        batAimbotOn = not batAimbotOn
        CONFIG.BAT_AIMBOT_AUTOBAT = batAimbotOn
        Tween(autoBatTogRef.togBG, {BackgroundColor3=batAimbotOn and Color3.fromRGB(240,240,240) or Color3.fromRGB(55,55,55)})
        Tween(autoBatTogRef.knob,  {Position=batAimbotOn and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
        autoBatTogRef.state = batAimbotOn
        if batAimbotOn then startBatAimbot() else stopBatAimbot() end
    end

    -- Route keybinds
    if input.KeyCode == Enum.KeyCode.Z then
        AutoLeftEnabled = not AutoLeftEnabled
        if AutoLeftEnabled then
            if AutoRightEnabled then
                AutoRightEnabled = false
                stopAutoRight()
                if routeRightTogRef then
                    routeRightTogRef.state = false
                    Tween(routeRightTogRef.togBG, {BackgroundColor3=Color3.fromRGB(55,55,55)})
                    Tween(routeRightTogRef.knob,  {Position=UDim2.new(0,3,0.5,-8)})
                end
            end
            startAutoLeft()
            if routeLeftTogRef then
                routeLeftTogRef.state = true
                Tween(routeLeftTogRef.togBG, {BackgroundColor3=Color3.fromRGB(240,240,240)})
                Tween(routeLeftTogRef.knob,  {Position=UDim2.new(1,-19,0.5,-8)})
            end
        else
            stopAutoLeft()
            if routeLeftTogRef then
                routeLeftTogRef.state = false
                Tween(routeLeftTogRef.togBG, {BackgroundColor3=Color3.fromRGB(55,55,55)})
                Tween(routeLeftTogRef.knob,  {Position=UDim2.new(0,3,0.5,-8)})
            end
        end
    end

    if input.KeyCode == Enum.KeyCode.C then
        AutoRightEnabled = not AutoRightEnabled
        if AutoRightEnabled then
            if AutoLeftEnabled then
                AutoLeftEnabled = false
                stopAutoLeft()
                if routeLeftTogRef then
                    routeLeftTogRef.state = false
                    Tween(routeLeftTogRef.togBG, {BackgroundColor3=Color3.fromRGB(55,55,55)})
                    Tween(routeLeftTogRef.knob,  {Position=UDim2.new(0,3,0.5,-8)})
                end
            end
            startAutoRight()
            if routeRightTogRef then
                routeRightTogRef.state = true
                Tween(routeRightTogRef.togBG, {BackgroundColor3=Color3.fromRGB(240,240,240)})
                Tween(routeRightTogRef.knob,  {Position=UDim2.new(1,-19,0.5,-8)})
            end
        else
            stopAutoRight()
            if routeRightTogRef then
                routeRightTogRef.state = false
                Tween(routeRightTogRef.togBG, {BackgroundColor3=Color3.fromRGB(55,55,55)})
                Tween(routeRightTogRef.knob,  {Position=UDim2.new(0,3,0.5,-8)})
            end
        end
    end
end)

-- ══════════════════════════════════════════
--   INFINITE JUMP
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
--   SPEED LOOP
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
--   OPTIMIZER
-- ══════════════════════════════════════════
local function optimizeObject(v)
    pcall(function()
        if v:IsA("Model") then v.LevelOfDetail=Enum.ModelLevelOfDetail.Disabled; v.ModelStreamingMode=Enum.ModelStreamingMode.Nonatomic
        elseif v:IsA("BasePart") and not v:IsA("MeshPart") then v.CastShadow=false; v.Material=Enum.Material.Plastic; v.Reflectance=0; v.MaterialVariant=""
        elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
        elseif v:IsA("MeshPart") then v.CastShadow=false; v.DoubleSided=false; v.RenderFidelity=Enum.RenderFidelity.Performance
        elseif v:IsA("SpecialMesh") then v.TextureId=0
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled=false
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled=false
        elseif v:IsA("Beam") then v.Enabled=false
        elseif v:IsA("SurfaceAppearance") then v:Destroy()
        elseif v:IsA("MaterialVariant") then v:Destroy() end
    end)
end

function applyAdvancedOptimizer()
    pcall(function() setfpscap(999999999) end)
    for _, v in pairs(Workspace:GetDescendants()) do optimizeObject(v) end
    for _, v in pairs(Lighting:GetDescendants()) do
        pcall(function()
            if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect")
            or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("PostEffect") then v:Destroy() end
        end)
    end
    pcall(function() Lighting.GlobalShadows=false; Lighting.FogEnd=9e9 end)
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
--   ANTI-RAGDOLL
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
--   FPS / PING MONITOR
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
if LocalPlayer.Character then setupAntiRagdoll(LocalPlayer.Character); setupChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char) setupAntiRagdoll(char); setupChar(char) end)
LocalPlayer.CharacterRemoving:Connect(function() cleanupRagdoll(); disconnectRemote(); currentCharacter=nil end)

loadConfig()

if CONFIG.BAT_AIMBOT_AUTOBAT then batAimbotOn=true; startBatAimbot() end
if CONFIG.OPTIMIZER then pcall(applyAdvancedOptimizer) end
if CONFIG.DARK_MODE then pcall(enableDarkMode) end
if CONFIG.WHITE_MODE then pcall(enableWhiteMode) end
if CONFIG.ESP then enableESP() end
if CONFIG.AUTO_STEAL_NEAREST then enableAutoSteal() end

SelectTab("Speed")
MainFrame.Size = UDim2.new(0,310,0,0)
Tween(MainFrame, { Size=UDim2.new(0,310,0,500) }, 0.25)

print("[VYSE HUB] Loaded! discord.gg/jRsgRcun")
