-- ============================================
--         KMONEY TWEAKING HUB v9
-- ============================================
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local StarterGui   = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputSvc = game:GetService("UserInputService")
local TeleportSvc  = game:GetService("TeleportService")
local LocalPlayer  = Players.LocalPlayer

local VIO   = Color3.fromRGB(210, 0, 255)
local VIO_D = Color3.fromRGB(90,  0, 130)
local VIO_L = Color3.fromRGB(255, 80, 255)
local BLACK = Color3.fromRGB(6, 6, 9)
local WHITE = Color3.fromRGB(255, 255, 255)

-- ============================================
-- AUTO SPEED
-- ============================================
local WALK_SPEED = 30
local function SetSpeed()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = WALK_SPEED end
    end
end
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    hum.WalkSpeed = WALK_SPEED
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum.WalkSpeed ~= WALK_SPEED then hum.WalkSpeed = WALK_SPEED end
    end)
end)
SetSpeed()

-- ============================================
-- GUI ROOT
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KMoneyHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- ============================================
-- LOGO (visible cuando hub cerrado)
-- ============================================
local LogoHolder = Instance.new("Frame")
LogoHolder.Size = UDim2.new(0,62,0,76)
LogoHolder.Position = UDim2.new(1,-70,0,4)
LogoHolder.BackgroundTransparency = 1
LogoHolder.BorderSizePixel = 0
LogoHolder.Visible = false
LogoHolder.ZIndex = 10
LogoHolder.Active = true
LogoHolder.Parent = ScreenGui

local LogoBtn = Instance.new("TextButton")
LogoBtn.Size = UDim2.new(0,50,0,50)
LogoBtn.Position = UDim2.new(0.5,-25,0,0)
LogoBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
LogoBtn.BorderSizePixel = 0
LogoBtn.Text = "$K"
LogoBtn.TextColor3 = VIO
LogoBtn.Font = Enum.Font.GothamBold
LogoBtn.TextSize = 18
LogoBtn.ZIndex = 10
LogoBtn.Parent = LogoHolder
Instance.new("UICorner", LogoBtn).CornerRadius = UDim.new(1,0)

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = VIO; LogoStroke.Thickness = 2.5; LogoStroke.Parent = LogoBtn

-- Drag logo
local logoDragging, logoDragStart, logoStartPos = false, nil, nil
LogoBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        logoDragging = true; logoDragStart = inp.Position; logoStartPos = LogoHolder.Position
    end
end)
UserInputSvc.InputChanged:Connect(function(inp)
    if logoDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - logoDragStart
        LogoHolder.Position = UDim2.new(logoStartPos.X.Scale, logoStartPos.X.Offset+d.X, logoStartPos.Y.Scale, logoStartPos.Y.Offset+d.Y)
    end
end)
UserInputSvc.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then logoDragging = false end
end)

task.spawn(function()
    while true do
        TweenService:Create(LogoStroke, TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Thickness=4, Color=VIO_L}):Play()
        TweenService:Create(LogoBtn,    TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {TextColor3=VIO_L}):Play()
        task.wait(1)
        TweenService:Create(LogoStroke, TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Thickness=1.5, Color=VIO}):Play()
        TweenService:Create(LogoBtn,    TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {TextColor3=VIO}):Play()
        task.wait(1)
    end
end)

-- Letras KMONEY
local kmoneyChars = {"K","M","O","N","E","Y"}
local letterLabels = {}
local lspc = 8
local lstart = math.floor((62 - #kmoneyChars * lspc) / 2)
for i, ch in ipairs(kmoneyChars) do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0,lspc,0,11)
    lbl.Position = UDim2.new(0, lstart+(i-1)*lspc, 0, 56)
    lbl.BackgroundTransparency = 1; lbl.Text = ch
    lbl.TextColor3 = Color3.fromRGB(20,20,20)
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 8
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ZIndex = 10; lbl.Parent = LogoHolder
    letterLabels[i] = lbl
end
local neonT = 0
RunService.Heartbeat:Connect(function(dt)
    if not LogoHolder.Visible then return end
    neonT = neonT + dt * 1.2
    for i, lbl in ipairs(letterLabels) do
        local b = math.floor(math.sin(neonT + i*0.8)*12+16)
        lbl.TextColor3 = Color3.fromRGB(b,b,b)
    end
end)

-- ============================================
-- MAIN FRAME
-- ============================================
local HW = 220
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0,HW,0,400)
MainFrame.Position = UDim2.new(1,-224,0,4)
MainFrame.BackgroundColor3 = Color3.fromRGB(10,10,12)
MainFrame.BackgroundTransparency = 0.45
MainFrame.BorderSizePixel = 0
MainFrame.Active = true; MainFrame.Draggable = false; MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = VIO; MainStroke.Thickness = 2.5; MainStroke.Parent = MainFrame
task.spawn(function()
    while true do
        TweenService:Create(MainStroke, TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Thickness=4.5, Color=VIO_L}):Play()
        task.wait(1.8)
        TweenService:Create(MainStroke, TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Thickness=2, Color=VIO}):Play()
        task.wait(1.8)
    end
end)

-- Nieve
local SnowCanvas = Instance.new("Frame")
SnowCanvas.Size = UDim2.new(1,0,1,0)
SnowCanvas.BackgroundTransparency = 1; SnowCanvas.BorderSizePixel = 0
SnowCanvas.ZIndex = 1; SnowCanvas.Parent = MainFrame

local snowballs = {}
for i = 1, 22 do
    local s = math.random(3,9)
    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0,s,0,s)
    ball.BackgroundColor3 = VIO
    ball.BackgroundTransparency = math.random(1,3) * 0.2
    ball.BorderSizePixel = 0; ball.ZIndex = 2; ball.Parent = SnowCanvas
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)
    local st = Instance.new("UIStroke"); st.Color = VIO_L; st.Thickness = 1.5; st.Parent = ball
    snowballs[i] = {frame=ball, stroke=st, speed=math.random(5,12)/1000, xBase=math.random(), progress=math.random()}
end
local snowT = 0
RunService.RenderStepped:Connect(function(dt)
    snowT = snowT + dt * 0.9
    local pulse = math.abs(math.sin(snowT * 1.6))
    local nr = math.floor(170 + pulse*50)
    local nb = math.floor(210 + pulse*45)
    for _, s in ipairs(snowballs) do
        s.progress = s.progress + s.speed
        if s.progress > 1.1 then s.progress = -0.05; s.xBase = math.random() end
        local xOff = math.sin(s.progress * math.pi * 2.5) * 0.022
        s.frame.Position = UDim2.new(math.clamp(s.xBase+xOff,0,0.95), 0, s.progress, 0)
        s.frame.BackgroundColor3 = Color3.fromRGB(nr,0,nb)
        s.stroke.Color = Color3.fromRGB(math.min(nr+50,255), 0, math.min(nb+40,255))
    end
end)

-- ============================================
-- TITLE BAR
-- ============================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,42)
TitleBar.BackgroundTransparency = 1; TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 5; TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.82,0,0,20); TitleLabel.Position = UDim2.new(0,10,0,3)
TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "KMONEY TWEAKING"
TitleLabel.TextColor3 = VIO; TitleLabel.TextScaled = true; TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.ZIndex = 6; TitleLabel.Parent = TitleBar
task.spawn(function()
    while true do
        TweenService:Create(TitleLabel, TweenInfo.new(1.5,Enum.EasingStyle.Sine), {TextColor3=VIO_L}):Play(); task.wait(1.5)
        TweenService:Create(TitleLabel, TweenInfo.new(1.5,Enum.EasingStyle.Sine), {TextColor3=VIO}):Play();  task.wait(1.5)
    end
end)

local FPSInTitle = Instance.new("TextLabel")
FPSInTitle.Size = UDim2.new(0.4,0,0,10); FPSInTitle.Position = UDim2.new(0,10,0,25)
FPSInTitle.BackgroundTransparency = 1; FPSInTitle.Text = "FPS: --"; FPSInTitle.TextColor3 = VIO
FPSInTitle.Font = Enum.Font.GothamBold; FPSInTitle.TextSize = 8
FPSInTitle.TextXAlignment = Enum.TextXAlignment.Left; FPSInTitle.ZIndex = 6; FPSInTitle.Parent = TitleBar

local PingInTitle = Instance.new("TextLabel")
PingInTitle.Size = UDim2.new(0.4,0,0,10); PingInTitle.Position = UDim2.new(0.4,0,0,25)
PingInTitle.BackgroundTransparency = 1; PingInTitle.Text = "PING: --"; PingInTitle.TextColor3 = VIO
PingInTitle.Font = Enum.Font.GothamBold; PingInTitle.TextSize = 8
PingInTitle.TextXAlignment = Enum.TextXAlignment.Left; PingInTitle.ZIndex = 6; PingInTitle.Parent = TitleBar

task.spawn(function()
    while true do
        TweenService:Create(FPSInTitle,  TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO_L}):Play()
        TweenService:Create(PingInTitle, TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO_L}):Play()
        task.wait(1.2)
        TweenService:Create(FPSInTitle,  TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO}):Play()
        TweenService:Create(PingInTitle, TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO}):Play()
        task.wait(1.2)
    end
end)

local lastT = tick(); local fc = 0
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local now = tick()
    if now - lastT >= 1 then
        FPSInTitle.Text = "FPS: " .. math.floor(fc / (now - lastT))
        fc = 0; lastT = now
    end
end)
RunService.Heartbeat:Connect(function()
    PingInTitle.Text = "PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,20,0,20); CloseBtn.Position = UDim2.new(1,-26,0,4)
CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255,80,80)
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextScaled = true; CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 7; CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,5)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; LogoHolder.Visible = true end)
LogoBtn.MouseButton1Click:Connect(function() LogoHolder.Visible = false; MainFrame.Visible = true end)

-- ============================================
-- SAVE / LOAD
-- ============================================
local SAVE_FILE = "kmoney_v9.txt"
local currentFOV = 70
local currentOpacity = 0
-- NOTA: Se eliminó "day" de los toggleStates. "night" ahora = cielo negro total.
local toggleStates = {lowgfx=false, fps=false, ping=false, delay=false, night=false, brightness=false}

local function SaveSettings()
    pcall(function()
        local d = "fov="..math.floor(currentFOV).."\nopacity="..math.floor(currentOpacity).."\n"
        for k,v in pairs(toggleStates) do d = d..k.."="..tostring(v).."\n" end
        writefile(SAVE_FILE, d)
    end)
end

local function LoadSettings()
    local ok, d = pcall(function() return readfile(SAVE_FILE) end)
    if not (ok and d and d ~= "") then return nil end
    local t = {}
    for k,v in string.gmatch(d, "([%w]+)=([%w%.]+)") do
        if k=="fov" then t.fov=tonumber(v)
        elseif k=="opacity" then t.opacity=tonumber(v)
        else t[k]=(v=="true") end
    end
    return t
end

-- ============================================
-- TOGGLE HELPER
-- ============================================
local toggleVisuals = {}
local BW = HW - 24

local function ApplyToggleVisual(key, state)
    local v = toggleVisuals[key]; if not v then return end
    if state then
        TweenService:Create(v.btn, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(40,0,70), BackgroundTransparency=0.1}):Play()
        v.stroke.Color = VIO_L; v.stroke.Thickness = 2
    else
        TweenService:Create(v.btn, TweenInfo.new(0.15), {BackgroundColor3=BLACK, BackgroundTransparency=0.55}):Play()
        v.stroke.Color = VIO_D; v.stroke.Thickness = 1.2
    end
end

local function MakeToggle(name, yPos, callback, saveKey)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0,BW,0,28); Btn.Position = UDim2.new(0.5,-(BW/2),0,yPos)
    Btn.BackgroundColor3 = BLACK; Btn.BackgroundTransparency = 0.55
    Btn.BorderSizePixel = 0; Btn.Text = name; Btn.TextColor3 = VIO
    Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 11; Btn.ZIndex = 5; Btn.Parent = MainFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,7)
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = VIO_D; BtnStroke.Thickness = 1.2; BtnStroke.Parent = Btn
    toggleVisuals[saveKey] = {btn=Btn, stroke=BtnStroke}
    task.spawn(function()
        while Btn.Parent do
            TweenService:Create(Btn, TweenInfo.new(1.3,Enum.EasingStyle.Sine), {TextColor3=VIO_L}):Play(); task.wait(1.3)
            TweenService:Create(Btn, TweenInfo.new(1.3,Enum.EasingStyle.Sine), {TextColor3=VIO}):Play();   task.wait(1.3)
        end
    end)
    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        ApplyToggleVisual(saveKey, enabled)
        callback(enabled)
    end)
end

-- ============================================
-- FEATURES
-- ============================================
local savedLighting = {
    ClockTime=Lighting.ClockTime, Brightness=Lighting.Brightness,
    Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient,
    FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart
}

-- ============================================
-- NIGHT (CIELO NEGRO: borra Sky completamente)
-- ============================================
local nightConn = nil

local function ApplyNightSky(state)
    if state then
        if nightConn then nightConn:Disconnect(); nightConn = nil end

        -- Borrar Sky, Atmosphere y nubes del juego
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds") then
                pcall(function() v:Destroy() end)
            end
        end

        -- Sin Sky = fondo negro puro en Roblox
        -- Iluminacion totalmente oscura
        Lighting.ClockTime               = 0
        Lighting.Brightness              = 0
        Lighting.Ambient                 = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient          = Color3.fromRGB(0, 0, 0)
        Lighting.GlobalShadows           = false
        Lighting.EnvironmentalDiffuseScale  = 0
        Lighting.EnvironmentalSpecularScale = 0

        -- Loop: destruir cualquier Sky que el juego intente agregar
        nightConn = RunService.Heartbeat:Connect(function()
            Lighting.Brightness              = 0
            Lighting.Ambient                 = Color3.fromRGB(0, 0, 0)
            Lighting.OutdoorAmbient          = Color3.fromRGB(0, 0, 0)
            Lighting.EnvironmentalDiffuseScale  = 0
            Lighting.EnvironmentalSpecularScale = 0
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") or v:IsA("Atmosphere") then
                    pcall(function() v:Destroy() end)
                end
            end
        end)

    else
        if nightConn then nightConn:Disconnect(); nightConn = nil end
        Lighting.ClockTime               = savedLighting.ClockTime
        Lighting.Brightness              = savedLighting.Brightness
        Lighting.Ambient                 = savedLighting.Ambient
        Lighting.OutdoorAmbient          = savedLighting.OutdoorAmbient
        Lighting.FogEnd                  = savedLighting.FogEnd
        Lighting.FogStart                = savedLighting.FogStart
        Lighting.GlobalShadows           = true
        Lighting.EnvironmentalDiffuseScale  = 1
        Lighting.EnvironmentalSpecularScale = 1
    end
end

local function ApplyLowGraphics(state)
    if state then
        if setfpscap then setfpscap(0) end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false; Lighting.FogEnd = 100000
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
        pcall(function() settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled end)
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.GlobalShadows = true
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = true
            end
        end
    end
end

local function ApplyFPSBoost(state)
    if state then
        if setfpscap then setfpscap(0) end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
    else
        if setfpscap then setfpscap(60) end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.GlobalShadows = true
    end
end

local pingConn = nil
local function ApplyPingLow(state)
    if state then
        pingConn = RunService.Heartbeat:Connect(function() end)
    else
        if pingConn then pingConn:Disconnect(); pingConn = nil end
    end
end

local delayConn = nil
local function ApplyDelay(state)
    if state then
        pcall(function()
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
            settings().Physics.AllowSleep = false
        end)
        if setfpscap then setfpscap(0) end
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("BlurEffect") then fx.Size = 0
            elseif fx:IsA("DepthOfFieldEffect") then fx.Enabled = false
            elseif fx:IsA("SunRaysEffect") then fx.Intensity = 0 end
        end
        delayConn = RunService.Heartbeat:Connect(function() end)
    else
        if delayConn then delayConn:Disconnect(); delayConn = nil end
        pcall(function() settings().Physics.AllowSleep = true end)
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("DepthOfFieldEffect") then fx.Enabled = true
            elseif fx:IsA("SunRaysEffect") then fx.Intensity = 0.25 end
        end
    end
end

local function ApplyBrightness(state)
    if state then
        Lighting.Brightness = 2.5
        Lighting.Ambient = Color3.fromRGB(160,160,160)
        Lighting.OutdoorAmbient = Color3.fromRGB(170,170,170)
    else
        Lighting.Brightness=savedLighting.Brightness
        Lighting.Ambient=savedLighting.Ambient
        Lighting.OutdoorAmbient=savedLighting.OutdoorAmbient
    end
end

-- ============================================
-- BUILD TOGGLES  (sin DAY)
-- ============================================
local Y = 48
MakeToggle("LOW GRAPHICS", Y, function(s) toggleStates.lowgfx=s;     ApplyLowGraphics(s); SaveSettings() end, "lowgfx");    Y=Y+34
MakeToggle("FPS BOOST",    Y, function(s) toggleStates.fps=s;        ApplyFPSBoost(s);    SaveSettings() end, "fps");       Y=Y+34
MakeToggle("PING LOW",     Y, function(s) toggleStates.ping=s;       ApplyPingLow(s);     SaveSettings() end, "ping");      Y=Y+34
MakeToggle("DELAY 0",      Y, function(s) toggleStates.delay=s;      ApplyDelay(s);       SaveSettings() end, "delay");     Y=Y+34
MakeToggle("NIGHT",        Y, function(s) toggleStates.night=s;      ApplyNightSky(s);    SaveSettings() end, "night");     Y=Y+34
MakeToggle("BRIGHT",       Y, function(s) toggleStates.brightness=s; ApplyBrightness(s);  SaveSettings() end, "brightness"); Y=Y+34

-- ============================================
-- FOV SLIDER
-- ============================================
local SetFOV
local FOVBox = Instance.new("Frame")
FOVBox.Size = UDim2.new(0,BW,0,42); FOVBox.Position = UDim2.new(0.5,-(BW/2),0,Y)
FOVBox.BackgroundTransparency = 0.55; FOVBox.BackgroundColor3 = BLACK
FOVBox.BorderSizePixel = 0; FOVBox.ZIndex = 5; FOVBox.Parent = MainFrame
Instance.new("UICorner", FOVBox).CornerRadius = UDim.new(0,7)
local FOVS = Instance.new("UIStroke"); FOVS.Color = VIO_D; FOVS.Thickness = 1.2; FOVS.Parent = FOVBox

local FOVTit = Instance.new("TextLabel")
FOVTit.Size = UDim2.new(0.5,0,0,18); FOVTit.Position = UDim2.new(0,9,0,3)
FOVTit.BackgroundTransparency = 1; FOVTit.Text = "FOV"; FOVTit.TextColor3 = VIO
FOVTit.Font = Enum.Font.GothamBold; FOVTit.TextSize = 11
FOVTit.TextXAlignment = Enum.TextXAlignment.Left; FOVTit.ZIndex = 6; FOVTit.Parent = FOVBox

local FOVVal = Instance.new("TextLabel")
FOVVal.Size = UDim2.new(0.42,0,0,18); FOVVal.Position = UDim2.new(0.56,0,0,3)
FOVVal.BackgroundTransparency = 1; FOVVal.Text = "70"; FOVVal.TextColor3 = VIO
FOVVal.Font = Enum.Font.GothamBold; FOVVal.TextSize = 11
FOVVal.TextXAlignment = Enum.TextXAlignment.Right; FOVVal.ZIndex = 6; FOVVal.Parent = FOVBox
task.spawn(function()
    while FOVVal.Parent do
        TweenService:Create(FOVVal, TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO_L}):Play(); task.wait(1.2)
        TweenService:Create(FOVVal, TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO}):Play();   task.wait(1.2)
    end
end)

local FovTrack = Instance.new("Frame")
FovTrack.Size = UDim2.new(1,-16,0,6); FovTrack.Position = UDim2.new(0,8,0,28)
FovTrack.BackgroundColor3 = Color3.fromRGB(38,38,52); FovTrack.BorderSizePixel = 0
FovTrack.ZIndex = 6; FovTrack.Parent = FOVBox
Instance.new("UICorner", FovTrack).CornerRadius = UDim.new(1,0)

local FovFill = Instance.new("Frame")
FovFill.Size = UDim2.new(0.25,0,1,0); FovFill.BackgroundColor3 = VIO
FovFill.BorderSizePixel = 0; FovFill.ZIndex = 7; FovFill.Parent = FovTrack
Instance.new("UICorner", FovFill).CornerRadius = UDim.new(1,0)

local FovThumb = Instance.new("TextButton")
FovThumb.Size = UDim2.new(0,16,0,16); FovThumb.Position = UDim2.new(0.25,-8,0.5,-8)
FovThumb.BackgroundColor3 = WHITE; FovThumb.Text = ""; FovThumb.BorderSizePixel = 0
FovThumb.ZIndex = 8; FovThumb.Parent = FovTrack
Instance.new("UICorner", FovThumb).CornerRadius = UDim.new(1,0)

local FOV_MIN, FOV_MAX = 40, 200
local draggingFOV = false

SetFOV = function(fov)
    fov = math.clamp(fov, FOV_MIN, FOV_MAX)
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = fov end
    local pct = (fov-FOV_MIN)/(FOV_MAX-FOV_MIN)
    FovFill.Size = UDim2.new(pct,0,1,0)
    FovThumb.Position = UDim2.new(pct,-8,0.5,-8)
    FOVVal.Text = math.floor(fov)..""
    currentFOV = fov; SaveSettings()
end

FovThumb.MouseButton1Down:Connect(function() draggingFOV = true end)
UserInputSvc.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingFOV = false end
end)
RunService.RenderStepped:Connect(function()
    if draggingFOV then
        local pct = math.clamp((UserInputSvc:GetMouseLocation().X - FovTrack.AbsolutePosition.X) / FovTrack.AbsoluteSize.X, 0, 1)
        SetFOV(FOV_MIN + pct*(FOV_MAX-FOV_MIN))
    end
end)
SetFOV(70); Y = Y + 50

-- ============================================
-- OPACITY SLIDER
-- ============================================
local SetOpacity
local OPBox = Instance.new("Frame")
OPBox.Size = UDim2.new(0,BW,0,42); OPBox.Position = UDim2.new(0.5,-(BW/2),0,Y)
OPBox.BackgroundTransparency = 0.55; OPBox.BackgroundColor3 = BLACK
OPBox.BorderSizePixel = 0; OPBox.ZIndex = 5; OPBox.Parent = MainFrame
Instance.new("UICorner", OPBox).CornerRadius = UDim.new(0,7)
local OPS = Instance.new("UIStroke"); OPS.Color = VIO_D; OPS.Thickness = 1.2; OPS.Parent = OPBox

local OPTit = Instance.new("TextLabel")
OPTit.Size = UDim2.new(0.6,0,0,18); OPTit.Position = UDim2.new(0,9,0,3)
OPTit.BackgroundTransparency = 1; OPTit.Text = "OPACIDAD"; OPTit.TextColor3 = VIO
OPTit.Font = Enum.Font.GothamBold; OPTit.TextSize = 11
OPTit.TextXAlignment = Enum.TextXAlignment.Left; OPTit.ZIndex = 6; OPTit.Parent = OPBox
task.spawn(function()
    while OPTit.Parent do
        TweenService:Create(OPTit, TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO_L}):Play(); task.wait(1.2)
        TweenService:Create(OPTit, TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO}):Play();   task.wait(1.2)
    end
end)

local OPVal = Instance.new("TextLabel")
OPVal.Size = UDim2.new(0.35,0,0,18); OPVal.Position = UDim2.new(0.63,0,0,3)
OPVal.BackgroundTransparency = 1; OPVal.Text = "0"; OPVal.TextColor3 = VIO
OPVal.Font = Enum.Font.GothamBold; OPVal.TextSize = 11
OPVal.TextXAlignment = Enum.TextXAlignment.Right; OPVal.ZIndex = 6; OPVal.Parent = OPBox
task.spawn(function()
    while OPVal.Parent do
        TweenService:Create(OPVal, TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO_L}):Play(); task.wait(1.2)
        TweenService:Create(OPVal, TweenInfo.new(1.2,Enum.EasingStyle.Sine), {TextColor3=VIO}):Play();   task.wait(1.2)
    end
end)

local OPTrack = Instance.new("Frame")
OPTrack.Size = UDim2.new(1,-16,0,6); OPTrack.Position = UDim2.new(0,8,0,28)
OPTrack.BackgroundColor3 = Color3.fromRGB(38,38,52); OPTrack.BorderSizePixel = 0
OPTrack.ZIndex = 6; OPTrack.Parent = OPBox
Instance.new("UICorner", OPTrack).CornerRadius = UDim.new(1,0)

local OPFill = Instance.new("Frame")
OPFill.Size = UDim2.new(0,0,1,0); OPFill.BackgroundColor3 = Color3.fromRGB(0,0,0)
OPFill.BorderSizePixel = 0; OPFill.ZIndex = 7; OPFill.Parent = OPTrack
Instance.new("UICorner", OPFill).CornerRadius = UDim.new(1,0)

local OPThumb = Instance.new("TextButton")
OPThumb.Size = UDim2.new(0,16,0,16); OPThumb.Position = UDim2.new(0,-8,0.5,-8)
OPThumb.BackgroundColor3 = WHITE; OPThumb.Text = ""; OPThumb.BorderSizePixel = 0
OPThumb.ZIndex = 8; OPThumb.Parent = OPTrack
Instance.new("UICorner", OPThumb).CornerRadius = UDim.new(1,0)

local draggingOP = false
SetOpacity = function(val)
    val = math.clamp(val, 0, 100)
    currentOpacity = val
    local pct = val/100
    MainFrame.BackgroundTransparency = 1-(pct*0.95)
    OPFill.Size = UDim2.new(pct,0,1,0)
    OPThumb.Position = UDim2.new(pct,-8,0.5,-8)
    OPVal.Text = math.floor(val)..""
    SaveSettings()
end

OPThumb.MouseButton1Down:Connect(function() draggingOP = true end)
UserInputSvc.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingOP = false end
end)
RunService.RenderStepped:Connect(function()
    if draggingOP then
        local pct = math.clamp((UserInputSvc:GetMouseLocation().X - OPTrack.AbsolutePosition.X) / OPTrack.AbsoluteSize.X, 0, 1)
        SetOpacity(pct*100)
    end
end)
SetOpacity(0); Y = Y + 50

-- ============================================
-- REJOIN
-- ============================================
local RejoinBtn = Instance.new("TextButton")
RejoinBtn.Size = UDim2.new(0,BW,0,28); RejoinBtn.Position = UDim2.new(0.5,-(BW/2),0,Y)
RejoinBtn.BackgroundColor3 = BLACK; RejoinBtn.BackgroundTransparency = 0.55
RejoinBtn.Text = "REJOIN"; RejoinBtn.TextColor3 = VIO
RejoinBtn.Font = Enum.Font.GothamBold; RejoinBtn.TextSize = 11
RejoinBtn.BorderSizePixel = 0; RejoinBtn.ZIndex = 5; RejoinBtn.Parent = MainFrame
Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0,7)
local RejoinStroke = Instance.new("UIStroke")
RejoinStroke.Color = VIO_D; RejoinStroke.Thickness = 1.2; RejoinStroke.Parent = RejoinBtn
task.spawn(function()
    while RejoinBtn.Parent do
        TweenService:Create(RejoinBtn, TweenInfo.new(1.3,Enum.EasingStyle.Sine), {TextColor3=VIO_L}):Play(); task.wait(1.3)
        TweenService:Create(RejoinBtn, TweenInfo.new(1.3,Enum.EasingStyle.Sine), {TextColor3=VIO}):Play();   task.wait(1.3)
    end
end)
RejoinBtn.MouseButton1Click:Connect(function()
    TweenService:Create(RejoinBtn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(40,0,70), BackgroundTransparency=0.1}):Play()
    RejoinStroke.Color = VIO_L; RejoinStroke.Thickness = 2
    task.wait(0.15)
    pcall(function() TeleportSvc:Teleport(game.PlaceId, LocalPlayer) end)
end)
Y = Y + 34

-- Resize final
MainFrame.Size = UDim2.new(0,HW,0,Y+12)
MainFrame.Position = UDim2.new(1,-224,0,4)

-- ============================================
-- AUTO LOAD
-- ============================================
task.delay(0.3, function()
    local saved = LoadSettings()
    if not saved then return end
    if saved.fov      then SetFOV(saved.fov) end
    if saved.opacity  then SetOpacity(saved.opacity) end
    if saved.lowgfx     then ApplyLowGraphics(true); toggleStates.lowgfx=true;     ApplyToggleVisual("lowgfx",true)     end
    if saved.fps        then ApplyFPSBoost(true);    toggleStates.fps=true;        ApplyToggleVisual("fps",true)        end
    if saved.ping       then ApplyPingLow(true);     toggleStates.ping=true;       ApplyToggleVisual("ping",true)       end
    if saved.delay      then ApplyDelay(true);       toggleStates.delay=true;      ApplyToggleVisual("delay",true)      end
    if saved.night      then ApplyNightSky(true);    toggleStates.night=true;      ApplyToggleVisual("night",true)      end
    if saved.brightness then ApplyBrightness(true);  toggleStates.brightness=true; ApplyToggleVisual("brightness",true) end
    pcall(function() StarterGui:SetCore("SendNotification",{Title="KMoney",Text="Config cargada!",Duration=3}) end)
end)

pcall(function() StarterGui:SetCore("SendNotification",{Title="KMoney Tweaking",Text="Hub v9 listo!",Duration=4}) end)
print("[KMoney v9] Hub loaded!")
