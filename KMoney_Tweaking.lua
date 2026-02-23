-- ============================================
--         KMONEY TWEAKING HUB v6
-- ============================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local StarterGui   = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputSvc = game:GetService("UserInputService")
local TeleportSvc  = game:GetService("TeleportService")
local LocalPlayer  = Players.LocalPlayer

local VIO   = Color3.fromRGB(180, 0, 255)
local VIO_D = Color3.fromRGB(70,  0, 110)
local VIO_L = Color3.fromRGB(220,130, 255)
local BLACK = Color3.fromRGB(8, 8, 10)
local WHITE = Color3.fromRGB(255,255,255)

-- ============================================
--   SCREENGUI
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
LogoHolder.Size = UDim2.new(0,80,0,96)
LogoHolder.Position = UDim2.new(0,18,0.3,-48)
LogoHolder.BackgroundTransparency = 1
LogoHolder.BorderSizePixel = 0
LogoHolder.Visible = false
LogoHolder.ZIndex = 10
LogoHolder.Active = true
LogoHolder.Parent = ScreenGui

-- Black circle background, violet neon $K text
local LogoBtn = Instance.new("TextButton")
LogoBtn.Size = UDim2.new(0,64,0,64)
LogoBtn.Position = UDim2.new(0.5,-32,0,0)
LogoBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
LogoBtn.BorderSizePixel = 0
LogoBtn.Text = "$K"
LogoBtn.TextColor3 = VIO
LogoBtn.Font = Enum.Font.GothamBold
LogoBtn.TextSize = 22
LogoBtn.ZIndex = 10
LogoBtn.Parent = LogoHolder
Instance.new("UICorner",LogoBtn).CornerRadius = UDim.new(1,0)

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = VIO; LogoStroke.Thickness = 2; LogoStroke.Parent = LogoBtn

-- Logo drag
local logoDragging,logoDragStart,logoStartPos = false,nil,nil
LogoBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        logoDragging=true; logoDragStart=inp.Position; logoStartPos=LogoHolder.Position
    end
end)
UserInputSvc.InputChanged:Connect(function(inp)
    if logoDragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d=inp.Position-logoDragStart
        LogoHolder.Position=UDim2.new(logoStartPos.X.Scale,logoStartPos.X.Offset+d.X,logoStartPos.Y.Scale,logoStartPos.Y.Offset+d.Y)
    end
end)
UserInputSvc.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then logoDragging=false end
end)

-- $K neon pulse (text color pulses violet)
task.spawn(function()
    while true do
        TweenService:Create(LogoStroke,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Thickness=4,Color=VIO_L}):Play()
        TweenService:Create(LogoBtn,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{TextColor3=VIO_L}):Play()
        task.wait(1)
        TweenService:Create(LogoStroke,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Thickness=1.5,Color=VIO}):Play()
        TweenService:Create(LogoBtn,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{TextColor3=VIO}):Play()
        task.wait(1)
    end
end)

-- KMONEY label: black neon below logo
local kmoneyChars = {"K","M","O","N","E","Y"}
local letterLabels = {}
local lspc=10; local lstart=math.floor((80-#kmoneyChars*lspc)/2)
for i,ch in ipairs(kmoneyChars) do
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(0,lspc,0,14); lbl.Position=UDim2.new(0,lstart+(i-1)*lspc,0,74)
    lbl.BackgroundTransparency=1; lbl.Text=ch; lbl.TextColor3=Color3.fromRGB(20,20,20)
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Center; lbl.ZIndex=10; lbl.Parent=LogoHolder
    letterLabels[i]=lbl
end

-- KMONEY black neon pulse (dark shimmer)
local neonT=0
RunService.Heartbeat:Connect(function(dt)
    if not LogoHolder.Visible then return end
    neonT=neonT+dt*1.2
    for i,lbl in ipairs(letterLabels) do
        local b=math.floor(math.sin(neonT+i*0.8)*20+28)
        lbl.TextColor3=Color3.fromRGB(b,b,b)
    end
end)

-- ============================================
--   MAIN FRAME
-- ============================================

local MainFrame=Instance.new("Frame")
MainFrame.Name="MainFrame"
MainFrame.Size=UDim2.new(0,340,0,600)
MainFrame.Position=UDim2.new(0.5,-170,0.5,-300)
MainFrame.BackgroundColor3=Color3.fromRGB(10,10,12)
MainFrame.BackgroundTransparency=0.5
MainFrame.BorderSizePixel=0
MainFrame.Active=true; MainFrame.Draggable=true; MainFrame.ClipsDescendants=true
MainFrame.Parent=ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,14)

local MainStroke=Instance.new("UIStroke")
MainStroke.Color=VIO; MainStroke.Thickness=2; MainStroke.Parent=MainFrame

task.spawn(function()
    while true do
        TweenService:Create(MainStroke,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Thickness=3.5,Color=VIO_L}):Play()
        task.wait(1.8)
        TweenService:Create(MainStroke,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Thickness=1.5,Color=VIO}):Play()
        task.wait(1.8)
    end
end)

-- ============================================
--   SNOW (violet neon pulsing)
-- ============================================

local SnowCanvas=Instance.new("Frame"); SnowCanvas.Size=UDim2.new(1,0,1,0)
SnowCanvas.BackgroundTransparency=1; SnowCanvas.BorderSizePixel=0; SnowCanvas.ZIndex=1; SnowCanvas.Parent=MainFrame
local snowballs={}
for i=1,30 do
    local s=math.random(5,14)
    local ball=Instance.new("Frame"); ball.Size=UDim2.new(0,s,0,s)
    ball.BackgroundColor3=VIO; ball.BackgroundTransparency=math.random(1,4)*0.15
    ball.BorderSizePixel=0; ball.ZIndex=2; ball.Parent=SnowCanvas
    Instance.new("UICorner",ball).CornerRadius=UDim.new(1,0)
    snowballs[i]={frame=ball,speed=math.random(6,14)/1000,xBase=math.random(),progress=math.random()}
end

local snowT=0
RunService.RenderStepped:Connect(function(dt)
    snowT=snowT+dt*0.8
    local r=math.floor(140+math.sin(snowT)*40)
    local b=math.floor(220+math.sin(snowT+1)*35)
    for _,s in ipairs(snowballs) do
        s.progress=s.progress+s.speed
        if s.progress>1.1 then s.progress=-0.05; s.xBase=math.random() end
        local xOff=math.sin(s.progress*math.pi*2.5)*0.025
        s.frame.Position=UDim2.new(math.clamp(s.xBase+xOff,0,0.97),0,s.progress,0)
        s.frame.BackgroundColor3=Color3.fromRGB(r,0,b)
    end
end)

-- ============================================
--   TITLE BAR  (no PREMIUM - replaced by FPS+PING)
-- ============================================

local TitleBar=Instance.new("Frame"); TitleBar.Size=UDim2.new(1,0,0,68)
TitleBar.BackgroundColor3=Color3.fromRGB(0,0,0); TitleBar.BackgroundTransparency=0.55; TitleBar.BorderSizePixel=0; TitleBar.ZIndex=5; TitleBar.Parent=MainFrame
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,14)
local TFix=Instance.new("Frame"); TFix.Size=UDim2.new(1,0,0.5,0); TFix.Position=UDim2.new(0,0,0.5,0)
TFix.BackgroundColor3=Color3.fromRGB(0,0,0); TFix.BackgroundTransparency=0.55; TFix.BorderSizePixel=0; TFix.ZIndex=5; TFix.Parent=TitleBar

-- KMONEY TWEAKING title (top line)
local TitleLabel=Instance.new("TextLabel")
TitleLabel.Size=UDim2.new(0.82,0,0,24); TitleLabel.Position=UDim2.new(0,14,0,4)
TitleLabel.BackgroundTransparency=1; TitleLabel.Text="KMONEY TWEAKING"
TitleLabel.TextColor3=VIO; TitleLabel.TextScaled=true; TitleLabel.Font=Enum.Font.GothamBold
TitleLabel.TextXAlignment=Enum.TextXAlignment.Left; TitleLabel.ZIndex=6; TitleLabel.Parent=TitleBar

task.spawn(function()
    while true do
        TweenService:Create(TitleLabel,TweenInfo.new(1.5,Enum.EasingStyle.Sine),{TextColor3=VIO_L}):Play()
        task.wait(1.5)
        TweenService:Create(TitleLabel,TweenInfo.new(1.5,Enum.EasingStyle.Sine),{TextColor3=VIO}):Play()
        task.wait(1.5)
    end
end)

-- FPS and PING below title, small, violet neon
local FPSInTitle=Instance.new("TextLabel")
FPSInTitle.Size=UDim2.new(0.42,0,0,12); FPSInTitle.Position=UDim2.new(0,14,0,32)
FPSInTitle.BackgroundTransparency=1; FPSInTitle.Text="FPS: --"; FPSInTitle.TextColor3=VIO
FPSInTitle.Font=Enum.Font.GothamBold; FPSInTitle.TextSize=10
FPSInTitle.TextXAlignment=Enum.TextXAlignment.Left; FPSInTitle.ZIndex=6; FPSInTitle.Parent=TitleBar

local PingInTitle=Instance.new("TextLabel")
PingInTitle.Size=UDim2.new(0.42,0,0,12); PingInTitle.Position=UDim2.new(0,14,0,46)
PingInTitle.BackgroundTransparency=1; PingInTitle.Text="PING: --"; PingInTitle.TextColor3=VIO
PingInTitle.Font=Enum.Font.GothamBold; PingInTitle.TextSize=10
PingInTitle.TextXAlignment=Enum.TextXAlignment.Left; PingInTitle.ZIndex=6; PingInTitle.Parent=TitleBar

-- Violet neon pulse on FPS/PING labels
task.spawn(function()
    while true do
        TweenService:Create(FPSInTitle, TweenInfo.new(1.2,Enum.EasingStyle.Sine),{TextColor3=VIO_L}):Play()
        TweenService:Create(PingInTitle,TweenInfo.new(1.2,Enum.EasingStyle.Sine),{TextColor3=VIO_L}):Play()
        task.wait(1.2)
        TweenService:Create(FPSInTitle, TweenInfo.new(1.2,Enum.EasingStyle.Sine),{TextColor3=VIO}):Play()
        TweenService:Create(PingInTitle,TweenInfo.new(1.2,Enum.EasingStyle.Sine),{TextColor3=VIO}):Play()
        task.wait(1.2)
    end
end)

-- Update FPS/PING
local lastT,fc=tick(),0
RunService.RenderStepped:Connect(function()
    fc+=1; local now=tick()
    if now-lastT>=1 then FPSInTitle.Text="FPS: "..math.floor(fc/(now-lastT)); fc=0; lastT=now end
end)
RunService.Heartbeat:Connect(function()
    PingInTitle.Text="PING: "..math.floor(LocalPlayer:GetNetworkPing()*1000).."ms"
end)

-- Close button
local CloseBtn=Instance.new("TextButton"); CloseBtn.Size=UDim2.new(0,28,0,28); CloseBtn.Position=UDim2.new(1,-38,0,8)
CloseBtn.BackgroundColor3=Color3.fromRGB(170,35,35); CloseBtn.Text="X"; CloseBtn.TextColor3=WHITE
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.TextScaled=true; CloseBtn.BorderSizePixel=0
CloseBtn.ZIndex=7; CloseBtn.Parent=TitleBar
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,7)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible=false; LogoHolder.Visible=true end)
LogoBtn.MouseButton1Click:Connect(function() LogoHolder.Visible=false; MainFrame.Visible=true end)

-- ============================================
--   FOV STAT (transparent, small, below title)
-- ============================================

local FovStatBox=Instance.new("Frame"); FovStatBox.Size=UDim2.new(0,298,0,22); FovStatBox.Position=UDim2.new(0.5,-149,0,68)
FovStatBox.BackgroundTransparency=1; FovStatBox.BorderSizePixel=0; FovStatBox.ZIndex=5; FovStatBox.Parent=MainFrame

local FovStatLbl=Instance.new("TextLabel"); FovStatLbl.Size=UDim2.new(1,0,1,0); FovStatLbl.BackgroundTransparency=1
FovStatLbl.Text="FOV: 70"; FovStatLbl.TextColor3=VIO; FovStatLbl.Font=Enum.Font.GothamBold
FovStatLbl.TextSize=12; FovStatLbl.TextXAlignment=Enum.TextXAlignment.Center; FovStatLbl.ZIndex=6; FovStatLbl.Parent=FovStatBox

-- ============================================
--   TOGGLE HELPER
-- ============================================

local toggleVisuals={}

local function MakeToggle(name,yPos,callback,height,saveKey)
    height=height or 36
    local Btn=Instance.new("TextButton"); Btn.Size=UDim2.new(0,298,0,height); Btn.Position=UDim2.new(0.5,-149,0,yPos)
    Btn.BackgroundColor3=BLACK; Btn.BackgroundTransparency=0.6; Btn.BorderSizePixel=0; Btn.Text=""; Btn.ZIndex=5; Btn.Parent=MainFrame
    Instance.new("UICorner",Btn).CornerRadius=UDim.new(0,9)
    local BtnStroke=Instance.new("UIStroke"); BtnStroke.Color=VIO_D; BtnStroke.Thickness=1.2; BtnStroke.Parent=Btn
    local BtnLbl=Instance.new("TextLabel"); BtnLbl.Size=UDim2.new(0.7,0,1,0); BtnLbl.Position=UDim2.new(0,12,0,0)
    BtnLbl.BackgroundTransparency=1; BtnLbl.Text=name; BtnLbl.TextColor3=VIO
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
            BtnStroke.Color=VIO; BtnLbl.TextColor3=VIO_L
        else
            TweenService:Create(Track,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(45,45,60)}):Play()
            TweenService:Create(Circle,TweenInfo.new(0.18),{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(160,160,160)}):Play()
            BtnStroke.Color=VIO_D; BtnLbl.TextColor3=VIO
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

-- DAY sky ID: 2083298847
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
        -- Use the custom CIELO asset for all faces
        local id="rbxassetid://11904277833"
        sky.SkyboxBk=id; sky.SkyboxDn=id; sky.SkyboxFt=id
        sky.SkyboxLf=id; sky.SkyboxRt=id; sky.SkyboxUp=id
        sky.Parent=Lighting
        dayConn=RunService.Heartbeat:Connect(function()
            if Lighting.ClockTime<12 or Lighting.ClockTime>16 then Lighting.ClockTime=14 end
        end)
    else
        if dayConn then dayConn:Disconnect(); dayConn=nil end
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
        Lighting.ClockTime=savedLighting.ClockTime; Lighting.Brightness=savedLighting.Brightness
        Lighting.Ambient=savedLighting.Ambient; Lighting.OutdoorAmbient=savedLighting.OutdoorAmbient
        Lighting.FogEnd=savedLighting.FogEnd; Lighting.FogStart=savedLighting.FogStart
    end
end

-- NIGHT sky ID: 10608647954
local nightConn=nil
local function ApplyNightSky(state)
    if state then
        if nightConn then nightConn:Disconnect() end
        local function setNight()
            Lighting.ClockTime=0; Lighting.Brightness=0.1
            Lighting.Ambient=Color3.fromRGB(10,10,30); Lighting.OutdoorAmbient=Color3.fromRGB(15,15,40)
            Lighting.FogEnd=100000; Lighting.FogStart=80000
        end
        setNight()
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
        local sky=Instance.new("Sky")
        local id="rbxassetid://9016402918"
        sky.SkyboxBk=id; sky.SkyboxDn=id; sky.SkyboxFt=id
        sky.SkyboxLf=id; sky.SkyboxRt=id; sky.SkyboxUp=id
        sky.StarCount=3000; sky.Parent=Lighting
        nightConn=RunService.Heartbeat:Connect(function()
            if Lighting.ClockTime>2 then Lighting.ClockTime=0 end
        end)
    else
        if nightConn then nightConn:Disconnect(); nightConn=nil end
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
        Lighting.ClockTime=savedLighting.ClockTime; Lighting.Brightness=savedLighting.Brightness
        Lighting.Ambient=savedLighting.Ambient; Lighting.OutdoorAmbient=savedLighting.OutdoorAmbient
        Lighting.FogEnd=savedLighting.FogEnd; Lighting.FogStart=savedLighting.FogStart
    end
end

local function ApplyLowGraphics(state)
    if state then
        if setfpscap then setfpscap(0) end
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        Lighting.GlobalShadows=false; Lighting.FogEnd=100000
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false end
        end
        pcall(function() settings().Physics.PhysicsEnvironmentalThrottle=Enum.EnviromentalPhysicsThrottle.Disabled end)
    else
        settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic; Lighting.GlobalShadows=true
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=true end
        end
    end
end

local function ApplyFPSBoost(state)
    if state then
        if setfpscap then setfpscap(0) end
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        Lighting.GlobalShadows=false
    else
        if setfpscap then setfpscap(60) end
        settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic
        Lighting.GlobalShadows=true
    end
end

local pingConn=nil
local function ApplyPingLow(state)
    if state then pingConn=RunService.Heartbeat:Connect(function() end)
    else if pingConn then pingConn:Disconnect(); pingConn=nil end end
end

-- ============================================
--   SAVE / LOAD (includes FOV)
-- ============================================

local SAVE_FILE="kmoney_v6.txt"
local currentFOV=70
local toggleStates={lowgfx=false,fps=false,ping=false,day=false,night=false,brightness=false,autorejoin=false,autokit=false,autoload=false}

local function SaveSettings()
    pcall(function()
        local d="fov="..tostring(math.floor(currentFOV)).."\n"
        for k,v in pairs(toggleStates) do d=d..k.."="..tostring(v).."\n" end
        writefile(SAVE_FILE,d)
    end)
end

local function LoadSettings()
    local ok,d=pcall(function() return readfile(SAVE_FILE) end)
    if ok and d and d~="" then
        local t={}
        for k,v in string.gmatch(d,"([%a]+)=([%w%.]+)") do
            if k=="fov" then t.fov=tonumber(v) else t[k]=(v=="true") end
        end
        return t
    end
    return nil
end

local function ApplyToggleVisual(key,state)
    local v=toggleVisuals[key]; if not v then return end
    if state then
        TweenService:Create(v.track,TweenInfo.new(0.18),{BackgroundColor3=BLACK}):Play()
        TweenService:Create(v.circle,TweenInfo.new(0.18),{Position=UDim2.new(0,24,0.5,-9),BackgroundColor3=WHITE}):Play()
        v.stroke.Color=VIO
    else
        TweenService:Create(v.track,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(45,45,60)}):Play()
        TweenService:Create(v.circle,TweenInfo.new(0.18),{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(160,160,160)}):Play()
        v.stroke.Color=VIO_D
    end
end

-- ============================================
--   SLIDER HELPER (for rejoin + kit)
-- ============================================

local function MakeSliderBox(name, yPos, minVal, maxVal, startVal, onToggle, onSlide, saveKey)
    local Box=Instance.new("Frame"); Box.Size=UDim2.new(0,298,0,72); Box.Position=UDim2.new(0.5,-149,0,yPos)
    Box.BackgroundColor3=BLACK; Box.BackgroundTransparency=0.6; Box.BorderSizePixel=0; Box.ZIndex=5; Box.Parent=MainFrame
    Instance.new("UICorner",Box).CornerRadius=UDim.new(0,9)
    local BoxStroke=Instance.new("UIStroke"); BoxStroke.Color=VIO_D; BoxStroke.Thickness=1.2; BoxStroke.Parent=Box

    local NameLbl=Instance.new("TextLabel"); NameLbl.Size=UDim2.new(0.62,0,0,28); NameLbl.Position=UDim2.new(0,12,0,0)
    NameLbl.BackgroundTransparency=1; NameLbl.Text=name; NameLbl.TextColor3=VIO
    NameLbl.Font=Enum.Font.GothamBold; NameLbl.TextScaled=true; NameLbl.TextXAlignment=Enum.TextXAlignment.Left
    NameLbl.ZIndex=6; NameLbl.Parent=Box

    local BTrack=Instance.new("Frame"); BTrack.Size=UDim2.new(0,46,0,24); BTrack.Position=UDim2.new(1,-56,0,2)
    BTrack.BackgroundColor3=Color3.fromRGB(45,45,60); BTrack.BorderSizePixel=0; BTrack.ZIndex=6; BTrack.Parent=Box
    Instance.new("UICorner",BTrack).CornerRadius=UDim.new(1,0)
    local BCircle=Instance.new("Frame"); BCircle.Size=UDim2.new(0,18,0,18); BCircle.Position=UDim2.new(0,3,0.5,-9)
    BCircle.BackgroundColor3=Color3.fromRGB(160,160,160); BCircle.BorderSizePixel=0; BCircle.ZIndex=7; BCircle.Parent=BTrack
    Instance.new("UICorner",BCircle).CornerRadius=UDim.new(1,0)

    local ValLbl=Instance.new("TextLabel"); ValLbl.Size=UDim2.new(1,0,0,14); ValLbl.Position=UDim2.new(0,0,0,30)
    ValLbl.BackgroundTransparency=1; ValLbl.TextColor3=VIO_L; ValLbl.Font=Enum.Font.Gotham; ValLbl.TextSize=11
    ValLbl.TextXAlignment=Enum.TextXAlignment.Center; ValLbl.ZIndex=6; ValLbl.Parent=Box

    local STrack=Instance.new("Frame"); STrack.Size=UDim2.new(1,-24,0,8); STrack.Position=UDim2.new(0,12,0,50)
    STrack.BackgroundColor3=Color3.fromRGB(38,38,52); STrack.BorderSizePixel=0; STrack.ZIndex=6; STrack.Parent=Box
    Instance.new("UICorner",STrack).CornerRadius=UDim.new(1,0)

    local SFill=Instance.new("Frame"); SFill.BackgroundColor3=VIO; SFill.BorderSizePixel=0; SFill.ZIndex=7; SFill.Parent=STrack
    Instance.new("UICorner",SFill).CornerRadius=UDim.new(1,0)

    local SThumb=Instance.new("TextButton"); SThumb.Size=UDim2.new(0,18,0,18); SThumb.BackgroundColor3=WHITE
    SThumb.Text=""; SThumb.BorderSizePixel=0; SThumb.ZIndex=8; SThumb.Parent=STrack
    Instance.new("UICorner",SThumb).CornerRadius=UDim.new(1,0)

    local curVal=startVal
    local function SetVal(v)
        v=math.clamp(v,minVal,maxVal)
        v=math.floor(v*10+0.5)/10
        curVal=v
        local pct=(v-minVal)/(maxVal-minVal)
        SFill.Size=UDim2.new(pct,0,1,0); SThumb.Position=UDim2.new(pct,-9,0.5,-9)
        ValLbl.Text="Delay: "..string.format("%.1f",v).."s"
        if onSlide then onSlide(v) end
    end
    SetVal(startVal)

    local dragging=false
    SThumb.MouseButton1Down:Connect(function() dragging=true end)
    UserInputSvc.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local pct=math.clamp((UserInputSvc:GetMouseLocation().X-STrack.AbsolutePosition.X)/STrack.AbsoluteSize.X,0,1)
            SetVal(minVal+pct*(maxVal-minVal))
        end
    end)

    if saveKey then toggleVisuals[saveKey]={track=BTrack,circle=BCircle,stroke=BoxStroke} end

    local enabled=false
    Box.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            local my=inp.Position.Y-Box.AbsolutePosition.Y
            if my>45 then return end -- ignore slider area clicks
            enabled=not enabled
            if enabled then
                TweenService:Create(BTrack,TweenInfo.new(0.18),{BackgroundColor3=BLACK}):Play()
                TweenService:Create(BCircle,TweenInfo.new(0.18),{Position=UDim2.new(0,24,0.5,-9),BackgroundColor3=WHITE}):Play()
                BoxStroke.Color=VIO; NameLbl.TextColor3=VIO_L
            else
                TweenService:Create(BTrack,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(45,45,60)}):Play()
                TweenService:Create(BCircle,TweenInfo.new(0.18),{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(160,160,160)}):Play()
                BoxStroke.Color=VIO_D; NameLbl.TextColor3=VIO
            end
            if onToggle then onToggle(enabled, curVal) end
        end
    end)

    return enabled
end

-- ============================================
--   BUILD TOGGLES  (Y starts at 96)
-- ============================================

local Y=96

MakeToggle("LOW GRAPHICS",Y,function(s) toggleStates.lowgfx=s;  ApplyLowGraphics(s); SaveSettings() end,36,"lowgfx");  Y=Y+42
MakeToggle("FPS BOOST",   Y,function(s) toggleStates.fps=s;     ApplyFPSBoost(s);    SaveSettings() end,36,"fps");     Y=Y+42
MakeToggle("PING LOW",    Y,function(s) toggleStates.ping=s;    ApplyPingLow(s);     SaveSettings() end,36,"ping");    Y=Y+42
MakeToggle("DAY",         Y,function(s) toggleStates.day=s;     ApplyDaySky(s);      SaveSettings() end,36,"day");     Y=Y+42
MakeToggle("SKY",         Y,function(s) toggleStates.night=s;   ApplyNightSky(s);    SaveSettings() end,36,"night");   Y=Y+42
MakeToggle("BRIGHT",  Y,function(s)
    toggleStates.brightness=s
    if s then Lighting.Brightness=6; Lighting.Ambient=Color3.fromRGB(200,200,200); Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
    else Lighting.Brightness=savedLighting.Brightness; Lighting.Ambient=savedLighting.Ambient; Lighting.OutdoorAmbient=savedLighting.OutdoorAmbient end
    SaveSettings()
end,36,"brightness"); Y=Y+42

-- ============================================
--   FOV SLIDER
-- ============================================

local FOVBox=Instance.new("Frame"); FOVBox.Size=UDim2.new(0,298,0,52); FOVBox.Position=UDim2.new(0.5,-149,0,Y)
FOVBox.BackgroundTransparency=0.6; FOVBox.BackgroundColor3=BLACK; FOVBox.BorderSizePixel=0; FOVBox.ZIndex=5; FOVBox.Parent=MainFrame
Instance.new("UICorner",FOVBox).CornerRadius=UDim.new(0,9)
local FOVS=Instance.new("UIStroke"); FOVS.Color=VIO_D; FOVS.Thickness=1.2; FOVS.Parent=FOVBox

local FOVTit=Instance.new("TextLabel"); FOVTit.Size=UDim2.new(0.5,0,0,22); FOVTit.Position=UDim2.new(0,12,0,4)
FOVTit.BackgroundTransparency=1; FOVTit.Text="FOV"; FOVTit.TextColor3=VIO
FOVTit.Font=Enum.Font.GothamBold; FOVTit.TextScaled=true; FOVTit.TextXAlignment=Enum.TextXAlignment.Left
FOVTit.ZIndex=6; FOVTit.Parent=FOVBox

local FOVVal=Instance.new("TextLabel"); FOVVal.Size=UDim2.new(0.42,0,0,22); FOVVal.Position=UDim2.new(0.56,0,0,4)
FOVVal.BackgroundTransparency=1; FOVVal.Text="70"; FOVVal.TextColor3=VIO_L
FOVVal.Font=Enum.Font.GothamBold; FOVVal.TextScaled=true; FOVVal.TextXAlignment=Enum.TextXAlignment.Right
FOVVal.ZIndex=6; FOVVal.Parent=FOVBox

local FovTrack=Instance.new("Frame"); FovTrack.Size=UDim2.new(1,-24,0,8); FovTrack.Position=UDim2.new(0,12,0,32)
FovTrack.BackgroundColor3=Color3.fromRGB(38,38,52); FovTrack.BorderSizePixel=0; FovTrack.ZIndex=6; FovTrack.Parent=FOVBox
Instance.new("UICorner",FovTrack).CornerRadius=UDim.new(1,0)

local FovFill=Instance.new("Frame"); FovFill.Size=UDim2.new(0.25,0,1,0); FovFill.BackgroundColor3=VIO
FovFill.BorderSizePixel=0; FovFill.ZIndex=7; FovFill.Parent=FovTrack
Instance.new("UICorner",FovFill).CornerRadius=UDim.new(1,0)

local FovThumb=Instance.new("TextButton"); FovThumb.Size=UDim2.new(0,20,0,20); FovThumb.Position=UDim2.new(0.25,-10,0.5,-10)
FovThumb.BackgroundColor3=WHITE; FovThumb.Text=""; FovThumb.BorderSizePixel=0; FovThumb.ZIndex=8; FovThumb.Parent=FovTrack
Instance.new("UICorner",FovThumb).CornerRadius=UDim.new(1,0)

local FOV_MIN,FOV_MAX=40,160; local draggingFOV=false
local function SetFOV(fov)
    fov=math.clamp(fov,FOV_MIN,FOV_MAX)
    local cam=workspace.CurrentCamera; if cam then cam.FieldOfView=fov end
    local pct=(fov-FOV_MIN)/(FOV_MAX-FOV_MIN)
    FovFill.Size=UDim2.new(pct,0,1,0); FovThumb.Position=UDim2.new(pct,-10,0.5,-10)
    FOVVal.Text=math.floor(fov)..""; FovStatLbl.Text="FOV: "..math.floor(fov)
    currentFOV=fov; SaveSettings()
end
FovThumb.MouseButton1Down:Connect(function() draggingFOV=true end)
UserInputSvc.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then draggingFOV=false end end)
RunService.RenderStepped:Connect(function()
    if draggingFOV then
        local pct=math.clamp((UserInputSvc:GetMouseLocation().X-FovTrack.AbsolutePosition.X)/FovTrack.AbsoluteSize.X,0,1)
        SetFOV(FOV_MIN+pct*(FOV_MAX-FOV_MIN))
    end
end)
SetFOV(70); Y=Y+60

-- ============================================
--   AUTO REJOIN (slider 0.1-2.0)
-- ============================================

local autoRejoinEnabled=false
local rejoinDelay=0.1

MakeSliderBox("AUTO REJOIN", Y, 0.1, 2.0, 0.1,
    function(s, delay) -- toggle callback
        autoRejoinEnabled=s; toggleStates.autorejoin=s; SaveSettings()
        if s then
            task.spawn(function()
                while autoRejoinEnabled do
                    task.wait(rejoinDelay)
                    pcall(function() TeleportSvc:Teleport(game.PlaceId,LocalPlayer) end)
                end
            end)
        else autoRejoinEnabled=false end
    end,
    function(v) rejoinDelay=v end, -- slider callback
    "autorejoin"
); Y=Y+80

-- ============================================
--   AUTO KIT (slider 0.1-2.0)
-- ============================================

local autoKitEnabled=false
local kitDelay=0.1

MakeSliderBox("AUTO KIT", Y, 0.1, 2.0, 0.1,
    function(s, delay)
        autoKitEnabled=s; toggleStates.autokit=s; SaveSettings()
        if s then
            task.spawn(function()
                while autoKitEnabled do
                    task.wait(kitDelay)
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
        else autoKitEnabled=false end
    end,
    function(v) kitDelay=v end,
    "autokit"
); Y=Y+80

-- ============================================
--   AUTO LOAD
-- ============================================

MakeToggle("AUTO LOAD",Y,function(s)
    toggleStates.autoload=s
    if s then
        local saved=LoadSettings()
        if saved then
            task.delay(0.15,function()
                if saved.fov      then SetFOV(saved.fov) end
                if saved.lowgfx   then ApplyLowGraphics(true); toggleStates.lowgfx=true;   ApplyToggleVisual("lowgfx",true)   end
                if saved.fps      then ApplyFPSBoost(true);    toggleStates.fps=true;       ApplyToggleVisual("fps",true)       end
                if saved.ping     then ApplyPingLow(true);     toggleStates.ping=true;      ApplyToggleVisual("ping",true)      end
                if saved.day      then ApplyDaySky(true);      toggleStates.day=true;       ApplyToggleVisual("day",true)       end
                if saved.night    then ApplyNightSky(true);    toggleStates.night=true;     ApplyToggleVisual("night",true)     end
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
end,36,"autoload"); Y=Y+42

-- Resize frame
MainFrame.Size=UDim2.new(0,340,0,Y+16)
MainFrame.Position=UDim2.new(0.5,-170,0.5,-(Y+16)/2)

-- ============================================
--   AUTO STARTUP LOAD
-- ============================================

task.delay(0.3,function()
    local saved=LoadSettings()
    if saved then
        if saved.fov      then SetFOV(saved.fov) end
        if saved.lowgfx   then ApplyLowGraphics(true); toggleStates.lowgfx=true;   ApplyToggleVisual("lowgfx",true)   end
        if saved.fps      then ApplyFPSBoost(true);    toggleStates.fps=true;       ApplyToggleVisual("fps",true)       end
        if saved.ping     then ApplyPingLow(true);     toggleStates.ping=true;      ApplyToggleVisual("ping",true)      end
        if saved.day      then ApplyDaySky(true);      toggleStates.day=true;       ApplyToggleVisual("day",true)       end
        if saved.night    then ApplyNightSky(true);    toggleStates.night=true;     ApplyToggleVisual("night",true)     end
        if saved.brightness then
            Lighting.Brightness=6; Lighting.Ambient=Color3.fromRGB(200,200,200); Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
            toggleStates.brightness=true; ApplyToggleVisual("brightness",true)
        end
        StarterGui:SetCore("SendNotification",{Title="KMoney",Text="Auto-loaded settings!",Duration=3})
    end
end)

StarterGui:SetCore("SendNotification",{Title="KMoney Tweaking",Text="Hub v6 loaded!",Duration=4})
print("[KMoney v6] Hub loaded!")
