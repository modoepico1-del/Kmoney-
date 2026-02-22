-- ============================================
--         KMONEY TWEAKING HUB v4
-- ============================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local StarterGui   = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputSvc = game:GetService("UserInputService")
local TeleportSvc  = game:GetService("TeleportService")
local LocalPlayer  = Players.LocalPlayer

local CYAN   = Color3.fromRGB(0, 220, 255)
local CYAN_D = Color3.fromRGB(0, 80, 110)
local BLACK  = Color3.fromRGB(8, 8, 10)
local WHITE  = Color3.fromRGB(255, 255, 255)

-- ============================================
--              SCREENGUI
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KMoneyHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- ============================================
--   $K LOGO (shown when hub closed)
-- ============================================

local LogoHolder = Instance.new("Frame")
LogoHolder.Size = UDim2.new(0, 80, 0, 96)
LogoHolder.Position = UDim2.new(0, 18, 0.5, -48)
LogoHolder.BackgroundTransparency = 1
LogoHolder.BorderSizePixel = 0
LogoHolder.Visible = false
LogoHolder.ZIndex = 10
LogoHolder.Active = true
LogoHolder.Parent = ScreenGui

local LogoBtn = Instance.new("TextButton")
LogoBtn.Size = UDim2.new(0, 64, 0, 64)
LogoBtn.Position = UDim2.new(0.5, -32, 0, 0)
LogoBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LogoBtn.BorderSizePixel = 0
LogoBtn.Text = "$K"
LogoBtn.TextColor3 = CYAN
LogoBtn.Font = Enum.Font.GothamBold
LogoBtn.TextSize = 22
LogoBtn.ZIndex = 10
LogoBtn.Parent = LogoHolder
Instance.new("UICorner", LogoBtn).CornerRadius = UDim.new(1, 0)

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = CYAN
LogoStroke.Thickness = 2
LogoStroke.Parent = LogoBtn

-- Logo drag
local logoDragging, logoDragStart, logoStartPos = false, nil, nil
LogoBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        logoDragging = true; logoDragStart = inp.Position; logoStartPos = LogoHolder.Position
    end
end)
UserInputSvc.InputChanged:Connect(function(inp)
    if logoDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - logoDragStart
        LogoHolder.Position = UDim2.new(logoStartPos.X.Scale, logoStartPos.X.Offset + d.X, logoStartPos.Y.Scale, logoStartPos.Y.Offset + d.Y)
    end
end)
UserInputSvc.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then logoDragging = false end
end)

-- $K neon pulse
task.spawn(function()
    while true do
        TweenService:Create(LogoStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness=4}):Play()
        task.wait(1)
        TweenService:Create(LogoStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness=1.5}):Play()
        task.wait(1)
    end
end)

-- KMONEY letters: alternating cyan/black with neon pulse
local kmoneyChars = {"K","M","O","N","E","Y"}
local letterLabels = {}
local lspc = 10
local lstart = math.floor((80 - #kmoneyChars * lspc) / 2)
for i, ch in ipairs(kmoneyChars) do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, lspc, 0, 14)
    lbl.Position = UDim2.new(0, lstart + (i-1)*lspc, 0, 74)
    lbl.BackgroundTransparency = 1
    lbl.Text = ch
    lbl.TextColor3 = (i%2==1) and CYAN or Color3.fromRGB(0,0,0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ZIndex = 10
    lbl.Parent = LogoHolder
    letterLabels[i] = lbl
end

local neonT = 0
RunService.Heartbeat:Connect(function(dt)
    if not LogoHolder.Visible then return end
    neonT = neonT + dt * 1.2
    for i, lbl in ipairs(letterLabels) do
        if i % 2 == 1 then
            local b = 0.8 + math.sin(neonT + i * 0.9) * 0.2
            lbl.TextColor3 = Color3.fromRGB(0, math.floor(180*b+40), math.floor(230*b+25))
        else
            local v = math.floor(math.sin(neonT + i) * 8 + 10)
            lbl.TextColor3 = Color3.fromRGB(v, v, v)
        end
    end
end)

-- ============================================
--              MAIN FRAME
-- ============================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 600)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CYAN
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

task.spawn(function()
    while true do
        TweenService:Create(MainStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness=3.5}):Play()
        task.wait(1.8)
        TweenService:Create(MainStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness=1.5}):Play()
        task.wait(1.8)
    end
end)

-- ============================================
--   SNOW (neon cyan)
-- ============================================

local SnowCanvas = Instance.new("Frame")
SnowCanvas.Size = UDim2.new(1,0,1,0); SnowCanvas.BackgroundTransparency=1
SnowCanvas.BorderSizePixel=0; SnowCanvas.ZIndex=1; SnowCanvas.Parent=MainFrame

local snowballs = {}
for i = 1, 30 do
    local s = math.random(5, 14)
    local ball = Instance.new("Frame")
    ball.Size=UDim2.new(0,s,0,s); ball.BackgroundColor3=CYAN
    ball.BackgroundTransparency=math.random(1,4)*0.15; ball.BorderSizePixel=0; ball.ZIndex=2; ball.Parent=SnowCanvas
    Instance.new("UICorner",ball).CornerRadius=UDim.new(1,0)
    snowballs[i]={frame=ball,speed=math.random(6,14)/1000,xBase=math.random(),progress=math.random()}
end
RunService.RenderStepped:Connect(function()
    for _,s in ipairs(snowballs) do
        s.progress=s.progress+s.speed
        if s.progress>1.1 then s.progress=-0.05; s.xBase=math.random() end
        local xOff=math.sin(s.progress*math.pi*2.5)*0.025
        s.frame.Position=UDim2.new(math.clamp(s.xBase+xOff,0,0.97),0,s.progress,0)
    end
end)

-- ============================================
--   TITLE BAR
-- ============================================

local TitleBar = Instance.new("Frame")
TitleBar.Size=UDim2.new(1,0,0,60); TitleBar.BackgroundColor3=Color3.fromRGB(0,0,0)
TitleBar.BorderSizePixel=0; TitleBar.ZIndex=5; TitleBar.Parent=MainFrame
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,14)

local TFix=Instance.new("Frame"); TFix.Size=UDim2.new(1,0,0.5,0); TFix.Position=UDim2.new(0,0,0.5,0)
TFix.BackgroundColor3=Color3.fromRGB(0,0,0); TFix.BorderSizePixel=0; TFix.ZIndex=5; TFix.Parent=TitleBar

-- KMONEY TWEAKING title
local TitleLabel=Instance.new("TextLabel")
TitleLabel.Size=UDim2.new(1,-55,0,26); TitleLabel.Position=UDim2.new(0,14,0,4)
TitleLabel.BackgroundTransparency=1; TitleLabel.Text="KMONEY TWEAKING"; TitleLabel.TextColor3=CYAN
TitleLabel.TextScaled=true; TitleLabel.Font=Enum.Font.GothamBold; TitleLabel.TextXAlignment=Enum.TextXAlignment.Left
TitleLabel.ZIndex=6; TitleLabel.Parent=TitleBar

task.spawn(function()
    while true do
        TweenService:Create(TitleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {TextColor3=Color3.fromRGB(180,245,255)}):Play()
        task.wait(1.5)
        TweenService:Create(TitleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {TextColor3=Color3.fromRGB(0,200,240)}):Play()
        task.wait(1.5)
    end
end)

-- PREMIUM label
local PremiumLabel=Instance.new("TextLabel")
PremiumLabel.Size=UDim2.new(1,-55,0,14); PremiumLabel.Position=UDim2.new(0,16,0,32)
PremiumLabel.BackgroundTransparency=1; PremiumLabel.Text="✦ PREMIUM ✦"; PremiumLabel.TextColor3=CYAN
PremiumLabel.TextScaled=true; PremiumLabel.Font=Enum.Font.GothamBold; PremiumLabel.TextXAlignment=Enum.TextXAlignment.Left
PremiumLabel.ZIndex=6; PremiumLabel.Parent=TitleBar

task.spawn(function()
    while true do
        TweenService:Create(PremiumLabel, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {TextColor3=Color3.fromRGB(200,255,255)}):Play()
        task.wait(1.2)
        TweenService:Create(PremiumLabel, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {TextColor3=Color3.fromRGB(0,150,190)}):Play()
        task.wait(1.2)
    end
end)

-- Close button
local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,32,0,32); CloseBtn.Position=UDim2.new(1,-42,0,10)
CloseBtn.BackgroundColor3=Color3.fromRGB(170,35,35); CloseBtn.Text="X"; CloseBtn.TextColor3=WHITE
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.TextScaled=true; CloseBtn.BorderSizePixel=0
CloseBtn.ZIndex=7; CloseBtn.Parent=TitleBar
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,8)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible=false; LogoHolder.Visible=true end)
LogoBtn.MouseButton1Click:Connect(function() LogoHolder.Visible=false; MainFrame.Visible=true end)

-- ============================================
--   STATS: FOV / FPS / PING (stacked)
-- ============================================

local function MakeStat(label, yPos)
    local box=Instance.new("Frame"); box.Size=UDim2.new(0,298,0,28); box.Position=UDim2.new(0.5,-149,0,yPos)
    box.BackgroundColor3=Color3.fromRGB(0,0,0); box.BorderSizePixel=0; box.ZIndex=5; box.Parent=MainFrame
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,7)
    local st=Instance.new("UIStroke"); st.Color=CYAN_D; st.Thickness=1.2; st.Parent=box
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
    lbl.Text=label; lbl.TextColor3=CYAN; lbl.Font=Enum.Font.GothamBold; lbl.TextScaled=true
    lbl.ZIndex=6; lbl.Parent=box
    return lbl
end

local FovStatLbl  = MakeStat("FOV: 70",  68)
local FPSStatLbl  = MakeStat("FPS: --",  102)
local PingStatLbl = MakeStat("PING: --", 136)

local lastT, fc = tick(), 0
RunService.RenderStepped:Connect(function()
    fc+=1; local now=tick()
    if now-lastT>=1 then FPSStatLbl.Text="FPS: "..math.floor(fc/(now-lastT)); fc=0; lastT=now end
end)
RunService.Heartbeat:Connect(function()
    PingStatLbl.Text="PING: "..math.floor(LocalPlayer:GetNetworkPing()*1000).."ms"
end)

-- ============================================
--   TOGGLE HELPER
-- ============================================

local toggleVisuals = {}

local function MakeToggle(name, yPos, callback, height, saveKey)
    height = height or 36
    local Btn=Instance.new("TextButton"); Btn.Size=UDim2.new(0,298,0,height); Btn.Position=UDim2.new(0.5,-149,0,yPos)
    Btn.BackgroundColor3=BLACK; Btn.BorderSizePixel=0; Btn.Text=""; Btn.ZIndex=5; Btn.Parent=MainFrame
    Instance.new("UICorner",Btn).CornerRadius=UDim.new(0,9)

    local BtnStroke=Instance.new("UIStroke"); BtnStroke.Color=CYAN_D; BtnStroke.Thickness=1.2; BtnStroke.Parent=Btn

    local BtnLbl=Instance.new("TextLabel"); BtnLbl.Size=UDim2.new(0.7,0,1,0); BtnLbl.Position=UDim2.new(0,12,0,0)
    BtnLbl.BackgroundTransparency=1; BtnLbl.Text=name; BtnLbl.TextColor3=Color3.fromRGB(225,225,225)
    BtnLbl.Font=Enum.Font.GothamBold; BtnLbl.TextScaled=true; BtnLbl.TextXAlignment=Enum.TextXAlignment.Left
    BtnLbl.ZIndex=6; BtnLbl.Parent=Btn

    local Track=Instance.new("Frame"); Track.Size=UDim2.new(0,46,0,24); Track.Position=UDim2.new(1,-56,0.5,-12)
    Track.BackgroundColor3=Color3.fromRGB(45,45,60); Track.BorderSizePixel=0; Track.ZIndex=6; Track.Parent=Btn
    Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)

    local Circle=Instance.new("Frame"); Circle.Size=UDim2.new(0,18,0,18); Circle.Position=UDim2.new(0,3,0.5,-9)
    Circle.BackgroundColor3=Color3.fromRGB(160,160,160); Circle.BorderSizePixel=0; Circle.ZIndex=7; Circle.Parent=Track
    Instance.new("UICorner",Circle).CornerRadius=UDim.new(1,0)

    if saveKey then toggleVisuals[saveKey]={track=Track,circle=Circle,stroke=BtnStroke} end

    local enabled=false
    Btn.MouseButton1Click:Connect(function()
        enabled=not enabled
        if enabled then
            TweenService:Create(Track,TweenInfo.new(0.18),{BackgroundColor3=BLACK}):Play()
            TweenService:Create(Circle,TweenInfo.new(0.18),{Position=UDim2.new(0,24,0.5,-9),BackgroundColor3=WHITE}):Play()
            BtnStroke.Color=CYAN
        else
            TweenService:Create(Track,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(45,45,60)}):Play()
            TweenService:Create(Circle,TweenInfo.new(0.18),{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(160,160,160)}):Play()
            BtnStroke.Color=CYAN_D
        end
        callback(enabled)
    end)
end

-- ============================================
--   FEATURES
-- ============================================

local savedLighting={
    ClockTime=Lighting.ClockTime, Brightness=Lighting.Brightness,
    Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient,
    FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart
}

local dayConn=nil
local function ApplyDaySky(state)
    if state then
        if dayConn then dayConn:Disconnect() end
        local function setDay()
            Lighting.ClockTime=14; Lighting.Brightness=3
            Lighting.Ambient=Color3.fromRGB(120,140,180); Lighting.OutdoorAmbient=Color3.fromRGB(130,160,200)
            Lighting.FogEnd=300000; Lighting.FogStart=200000
        end
        setDay()
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
        local sky=Instance.new("Sky")
        sky.SkyboxBk="rbxassetid://129462011"; sky.SkyboxDn="rbxassetid://129456754"
        sky.SkyboxFt="rbxassetid://129461087"; sky.SkyboxLf="rbxassetid://129461249"
        sky.SkyboxRt="rbxassetid://129461521"; sky.SkyboxUp="rbxassetid://129462237"
        sky.Parent=Lighting
        dayConn=RunService.Heartbeat:Connect(function()
            if Lighting.ClockTime<12 or Lighting.ClockTime>16 then setDay() end
        end)
    else
        if dayConn then dayConn:Disconnect(); dayConn=nil end
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
        Lighting.ClockTime=savedLighting.ClockTime; Lighting.Brightness=savedLighting.Brightness
        Lighting.Ambient=savedLighting.Ambient; Lighting.OutdoorAmbient=savedLighting.OutdoorAmbient
        Lighting.FogEnd=savedLighting.FogEnd; Lighting.FogStart=savedLighting.FogStart
    end
end

local function ApplyNightSky(state)
    if state then
        Lighting.ClockTime=0; Lighting.Brightness=0.1
        Lighting.Ambient=Color3.fromRGB(10,10,30); Lighting.OutdoorAmbient=Color3.fromRGB(15,15,40)
        Lighting.FogEnd=100000; Lighting.FogStart=80000
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
        local sky=Instance.new("Sky")
        sky.SkyboxBk="rbxassetid://159454286"; sky.SkyboxDn="rbxassetid://159454286"
        sky.SkyboxFt="rbxassetid://159454286"; sky.SkyboxLf="rbxassetid://159454286"
        sky.SkyboxRt="rbxassetid://159454286"; sky.SkyboxUp="rbxassetid://159454286"
        sky.StarCount=3000; sky.Parent=Lighting
    else
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
        Lighting.ClockTime=savedLighting.ClockTime; Lighting.Brightness=savedLighting.Brightness
        Lighting.Ambient=savedLighting.Ambient; Lighting.OutdoorAmbient=savedLighting.OutdoorAmbient
    end
end

local function ApplyFPSBoost(state)
    if state then
        if setfpscap then setfpscap(0) end
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        Lighting.GlobalShadows=false; Lighting.FogEnd=100000
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false end
        end
    else
        settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic; Lighting.GlobalShadows=true
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=true end
        end
    end
end

local pingConn=nil
local function ApplyPingLow(state)
    if state then
        pingConn=RunService.Heartbeat:Connect(function() end)
    else
        if pingConn then pingConn:Disconnect(); pingConn=nil end
    end
end

local function ApplyTweaking(state)
    if state then
        if setfpscap then setfpscap(0) end
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level03
        Lighting.GlobalShadows=false
        pcall(function() settings().Physics.PhysicsEnvironmentalThrottle=Enum.EnviromentalPhysicsThrottle.Disabled end)
    else
        settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic; Lighting.GlobalShadows=true
    end
end

-- ============================================
--   SAVE / LOAD
-- ============================================

local SAVE_FILE="kmoney_v4.txt"
local toggleStates={tweaking=false,fps=false,ping=false,day=false,night=false,brightness=false,autorejoin=false,autokit=false,autoload=false}

local function SaveSettings()
    pcall(function()
        local d=""
        for k,v in pairs(toggleStates) do d=d..k.."="..tostring(v).."\n" end
        writefile(SAVE_FILE,d)
    end)
end

local function LoadSettings()
    local ok,d=pcall(function() return readfile(SAVE_FILE) end)
    if ok and d and d~="" then
        local t={}
        for k,v in string.gmatch(d,"(%a+)=(%a+)") do t[k]=(v=="true") end
        return t
    end
    return nil
end

local function ApplyToggleVisual(key,state)
    local v=toggleVisuals[key]; if not v then return end
    if state then
        TweenService:Create(v.track,TweenInfo.new(0.18),{BackgroundColor3=BLACK}):Play()
        TweenService:Create(v.circle,TweenInfo.new(0.18),{Position=UDim2.new(0,24,0.5,-9),BackgroundColor3=WHITE}):Play()
        v.stroke.Color=CYAN
    else
        TweenService:Create(v.track,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(45,45,60)}):Play()
        TweenService:Create(v.circle,TweenInfo.new(0.18),{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(160,160,160)}):Play()
        v.stroke.Color=CYAN_D
    end
end

-- ============================================
--   BUILD TOGGLES
-- ============================================

local Y = 172

MakeToggle("TWEAKING",  Y, function(s) toggleStates.tweaking=s;  ApplyTweaking(s);  SaveSettings() end, 36, "tweaking");  Y=Y+42
MakeToggle("FPS BOOST", Y, function(s) toggleStates.fps=s;       ApplyFPSBoost(s);  SaveSettings() end, 36, "fps");       Y=Y+42
MakeToggle("PING LOW",  Y, function(s) toggleStates.ping=s;      ApplyPingLow(s);   SaveSettings() end, 36, "ping");      Y=Y+42
MakeToggle("DAY SKY",   Y, function(s) toggleStates.day=s;       ApplyDaySky(s);    SaveSettings() end, 36, "day");       Y=Y+42
MakeToggle("NIGHT SKY", Y, function(s) toggleStates.night=s;     ApplyNightSky(s);  SaveSettings() end, 36, "night");     Y=Y+42
MakeToggle("BRIGHTNESS",Y, function(s)
    toggleStates.brightness=s
    if s then Lighting.Brightness=6; Lighting.Ambient=Color3.fromRGB(200,200,200); Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
    else Lighting.Brightness=savedLighting.Brightness; Lighting.Ambient=savedLighting.Ambient; Lighting.OutdoorAmbient=savedLighting.OutdoorAmbient end
    SaveSettings()
end, 36, "brightness"); Y=Y+42

-- ============================================
--   FOV SLIDER
-- ============================================

local FOVBox=Instance.new("Frame"); FOVBox.Size=UDim2.new(0,298,0,56); FOVBox.Position=UDim2.new(0.5,-149,0,Y)
FOVBox.BackgroundColor3=BLACK; FOVBox.BorderSizePixel=0; FOVBox.ZIndex=5; FOVBox.Parent=MainFrame
Instance.new("UICorner",FOVBox).CornerRadius=UDim.new(0,9)
local FOVS=Instance.new("UIStroke"); FOVS.Color=CYAN_D; FOVS.Thickness=1.2; FOVS.Parent=FOVBox

local FOVTit=Instance.new("TextLabel"); FOVTit.Size=UDim2.new(0.55,0,0,22); FOVTit.Position=UDim2.new(0,12,0,5)
FOVTit.BackgroundTransparency=1; FOVTit.Text="FOV"; FOVTit.TextColor3=Color3.fromRGB(225,225,225)
FOVTit.Font=Enum.Font.GothamBold; FOVTit.TextScaled=true; FOVTit.TextXAlignment=Enum.TextXAlignment.Left
FOVTit.ZIndex=6; FOVTit.Parent=FOVBox

local FOVVal=Instance.new("TextLabel"); FOVVal.Size=UDim2.new(0.4,0,0,22); FOVVal.Position=UDim2.new(0.58,0,0,5)
FOVVal.BackgroundTransparency=1; FOVVal.Text="70"; FOVVal.TextColor3=CYAN
FOVVal.Font=Enum.Font.GothamBold; FOVVal.TextScaled=true; FOVVal.TextXAlignment=Enum.TextXAlignment.Right
FOVVal.ZIndex=6; FOVVal.Parent=FOVBox

local FovTrack=Instance.new("Frame"); FovTrack.Size=UDim2.new(1,-24,0,8); FovTrack.Position=UDim2.new(0,12,0,34)
FovTrack.BackgroundColor3=Color3.fromRGB(38,38,52); FovTrack.BorderSizePixel=0; FovTrack.ZIndex=6; FovTrack.Parent=FOVBox
Instance.new("UICorner",FovTrack).CornerRadius=UDim.new(1,0)

local FovFill=Instance.new("Frame"); FovFill.Size=UDim2.new(0.25,0,1,0); FovFill.BackgroundColor3=CYAN
FovFill.BorderSizePixel=0; FovFill.ZIndex=7; FovFill.Parent=FovTrack
Instance.new("UICorner",FovFill).CornerRadius=UDim.new(1,0)

local FovThumb=Instance.new("TextButton"); FovThumb.Size=UDim2.new(0,20,0,20); FovThumb.Position=UDim2.new(0.25,-10,0.5,-10)
FovThumb.BackgroundColor3=WHITE; FovThumb.Text=""; FovThumb.BorderSizePixel=0; FovThumb.ZIndex=8; FovThumb.Parent=FovTrack
Instance.new("UICorner",FovThumb).CornerRadius=UDim.new(1,0)

local FOV_MIN,FOV_MAX=40,160; local draggingFOV=false
local function SetFOV(fov)
    local cam=workspace.CurrentCamera; if cam then cam.FieldOfView=fov end
    local pct=(fov-FOV_MIN)/(FOV_MAX-FOV_MIN)
    FovFill.Size=UDim2.new(pct,0,1,0); FovThumb.Position=UDim2.new(pct,-10,0.5,-10)
    FOVVal.Text=math.floor(fov)..""; FovStatLbl.Text="FOV: "..math.floor(fov)
end
FovThumb.MouseButton1Down:Connect(function() draggingFOV=true end)
UserInputSvc.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then draggingFOV=false end end)
RunService.RenderStepped:Connect(function()
    if draggingFOV then
        local pct=math.clamp((UserInputSvc:GetMouseLocation().X-FovTrack.AbsolutePosition.X)/FovTrack.AbsoluteSize.X,0,1)
        SetFOV(FOV_MIN+pct*(FOV_MAX-FOV_MIN))
    end
end)
SetFOV(70); Y=Y+64

-- ============================================
--   AUTO REJOIN 0.1
-- ============================================

local autoRejoinConn=nil
MakeToggle("AUTO REJOIN  0.1", Y, function(s)
    toggleStates.autorejoin=s
    if s then
        autoRejoinConn=task.spawn(function()
            while toggleStates.autorejoin do
                task.wait(0.1)
                pcall(function() TeleportSvc:Teleport(game.PlaceId, LocalPlayer) end)
            end
        end)
    else
        toggleStates.autorejoin=false
    end
    SaveSettings()
end, 36, "autorejoin"); Y=Y+42

-- ============================================
--   AUTO KIT 0.1
-- ============================================

local autoKitEnabled=false
MakeToggle("AUTO KIT  0.1", Y, function(s)
    toggleStates.autokit=s; autoKitEnabled=s
    if s then
        task.spawn(function()
            while autoKitEnabled do
                task.wait(0.1)
                local char=LocalPlayer.Character
                if char then
                    for _,obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (obj.Name:lower():find("kit") or obj.Name:lower():find("spawn")) then
                            local hrp=char:FindFirstChild("HumanoidRootPart")
                            if hrp and (hrp.Position-obj.Position).Magnitude<25 then
                                pcall(function() hrp.CFrame=CFrame.new(obj.Position+Vector3.new(0,3,0)) end)
                            end
                        end
                    end
                end
            end
        end)
    end
    SaveSettings()
end, 36, "autokit"); Y=Y+42

-- ============================================
--   AUTO LOAD
-- ============================================

MakeToggle("AUTO LOAD", Y, function(s)
    toggleStates.autoload=s
    if s then
        local saved=LoadSettings()
        if saved then
            task.delay(0.15, function()
                if saved.tweaking  then ApplyTweaking(true);  toggleStates.tweaking=true;  ApplyToggleVisual("tweaking",true)  end
                if saved.fps       then ApplyFPSBoost(true);  toggleStates.fps=true;       ApplyToggleVisual("fps",true)       end
                if saved.ping      then ApplyPingLow(true);   toggleStates.ping=true;      ApplyToggleVisual("ping",true)      end
                if saved.day       then ApplyDaySky(true);    toggleStates.day=true;       ApplyToggleVisual("day",true)       end
                if saved.night     then ApplyNightSky(true);  toggleStates.night=true;     ApplyToggleVisual("night",true)     end
                if saved.brightness then
                    Lighting.Brightness=6; Lighting.Ambient=Color3.fromRGB(200,200,200); Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
                    toggleStates.brightness=true; ApplyToggleVisual("brightness",true)
                end
                StarterGui:SetCore("SendNotification",{Title="KMoney",Text="Settings loaded!",Duration=3})
            end)
        else
            StarterGui:SetCore("SendNotification",{Title="KMoney",Text="No saves yet - toggle options to save",Duration=4})
        end
    end
    SaveSettings()
end, 36, "autoload"); Y=Y+42

-- Resize frame
MainFrame.Size=UDim2.new(0,340,0,Y+16)
MainFrame.Position=UDim2.new(0.5,-170,0.5,-(Y+16)/2)

-- ============================================
--   AUTO STARTUP LOAD
-- ============================================

task.delay(0.25, function()
    local saved=LoadSettings()
    if saved then
        if saved.tweaking  then ApplyTweaking(true);  toggleStates.tweaking=true;  ApplyToggleVisual("tweaking",true)  end
        if saved.fps       then ApplyFPSBoost(true);  toggleStates.fps=true;       ApplyToggleVisual("fps",true)       end
        if saved.ping      then ApplyPingLow(true);   toggleStates.ping=true;      ApplyToggleVisual("ping",true)      end
        if saved.day       then ApplyDaySky(true);    toggleStates.day=true;       ApplyToggleVisual("day",true)       end
        if saved.night     then ApplyNightSky(true);  toggleStates.night=true;     ApplyToggleVisual("night",true)     end
        if saved.brightness then
            Lighting.Brightness=6; Lighting.Ambient=Color3.fromRGB(200,200,200); Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
            toggleStates.brightness=true; ApplyToggleVisual("brightness",true)
        end
        StarterGui:SetCore("SendNotification",{Title="KMoney",Text="Auto-loaded settings!",Duration=3})
    end
end)

StarterGui:SetCore("SendNotification",{Title="KMoney Tweaking",Text="Hub v4 loaded!",Duration=4})
print("[KMoney v4] Hub loaded!")
