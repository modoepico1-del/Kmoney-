-- ============================================
--         KMONEY TWEAKING HUB v8
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
--   $K LOGO
-- ============================================

local LogoHolder = Instance.new("Frame")
LogoHolder.Size = UDim2.new(0,70,0,86)
LogoHolder.Position = UDim2.new(0,14,0.3,-43)
LogoHolder.BackgroundTransparency = 1
LogoHolder.BorderSizePixel = 0
LogoHolder.Visible = false
LogoHolder.ZIndex = 10
LogoHolder.Active = true
LogoHolder.Parent = ScreenGui

local LogoBtn = Instance.new("TextButton")
LogoBtn.Size = UDim2.new(0,56,0,56)
LogoBtn.Position = UDim2.new(0.5,-28,0,0)
LogoBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
LogoBtn.BorderSizePixel = 0
LogoBtn.Text = "$K"
LogoBtn.TextColor3 = VIO
LogoBtn.Font = Enum.Font.GothamBold
LogoBtn.TextSize = 20
LogoBtn.ZIndex = 10
LogoBtn.Parent = LogoHolder
Instance.new("UICorner",LogoBtn).CornerRadius = UDim.new(1,0)

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = VIO; LogoStroke.Thickness = 2; LogoStroke.Parent = LogoBtn

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

local kmoneyChars = {"K","M","O","N","E","Y"}
local letterLabels = {}
local lspc=9; local lstart=math.floor((70-#kmoneyChars*lspc)/2)
for i,ch in ipairs(kmoneyChars) do
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(0,lspc,0,12); lbl.Position=UDim2.new(0,lstart+(i-1)*lspc,0,64)
    lbl.BackgroundTransparency=1; lbl.Text=ch; lbl.TextColor3=Color3.fromRGB(20,20,20)
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Center; lbl.ZIndex=10; lbl.Parent=LogoHolder
    letterLabels[i]=lbl
end

local neonT=0
RunService.Heartbeat:Connect(function(dt)
    if not LogoHolder.Visible then return end
    neonT=neonT+dt*1.2
    for i,lbl in ipairs(letterLabels) do
        local b=math.floor(math.sin(neonT+i*0.8)*12+16)
        lbl.TextColor3=Color3.fromRGB(b,b,b)
    end
end)

-- ============================================
--   MAIN FRAME  (chico: 260px ancho)
-- ============================================

local MainFrame=Instance.new("Frame")
MainFrame.Name="MainFrame"
MainFrame.Size=UDim2.new(0,260,0,500)
MainFrame.Position=UDim2.new(0.5,-130,0.5,-250)
MainFrame.BackgroundColor3=Color3.fromRGB(10,10,12)
MainFrame.BackgroundTransparency=0.45
MainFrame.BorderSizePixel=0
MainFrame.Active=true; MainFrame.Draggable=true; MainFrame.ClipsDescendants=true
MainFrame.Parent=ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,12)

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
--   NIEVE VIOLETA NEON
-- ============================================

local SnowCanvas=Instance.new("Frame"); SnowCanvas.Size=UDim2.new(1,0,1,0)
SnowCanvas.BackgroundTransparency=1; SnowCanvas.BorderSizePixel=0; SnowCanvas.ZIndex=1; SnowCanvas.Parent=MainFrame

local snowballs={}
for i=1,28 do
    local s=math.random(4,10)
    local ball=Instance.new("Frame"); ball.Size=UDim2.new(0,s,0,s)
    ball.BackgroundColor3=VIO; ball.BackgroundTransparency=math.random(1,3)*0.2
    ball.BorderSizePixel=0; ball.ZIndex=2; ball.Parent=SnowCanvas
    Instance.new("UICorner",ball).CornerRadius=UDim.new(1,0)
    local st=Instance.new("UIStroke"); st.Color=VIO_L; st.Thickness=1.5; st.Parent=ball
    snowballs[i]={frame=ball,stroke=st,speed=math.random(5,13)/1000,xBase=math.random(),progress=math.random()}
end

local snowT2=0
RunService.RenderStepped:Connect(function(dt)
    snowT2=snowT2+dt*0.9
    local pulse=math.abs(math.sin(snowT2*1.6))
    local nr=math.floor(170+pulse*50)
    local nb=math.floor(210+pulse*45)
    for _,s in ipairs(snowballs) do
        s.progress=s.progress+s.speed
        if s.progress>1.1 then s.progress=-0.05; s.xBase=math.random() end
        local xOff=math.sin(s.progress*math.pi*2.5)*0.025
        s.frame.Position=UDim2.new(math.clamp(s.xBase+xOff,0,0.96),0,s.progress,0)
        s.frame.BackgroundColor3=Color3.fromRGB(nr,0,nb)
        s.stroke.Color=Color3.fromRGB(math.min(nr+50,255),0,math.min(nb+40,255))
    end
end)

-- ============================================
--   TITLE BAR
-- ============================================

local TitleBar=Instance.new("Frame"); TitleBar.Size=UDim2.new(1,0,0,74)
TitleBar.BackgroundTransparency=1; TitleBar.BorderSizePixel=0; TitleBar.ZIndex=5; TitleBar.Parent=MainFrame

local TitleLabel=Instance.new("TextLabel")
TitleLabel.Size=UDim2.new(0.82,0,0,21); TitleLabel.Position=UDim2.new(0,12,0,4)
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

local FPSInTitle=Instance.new("TextLabel")
FPSInTitle.Size=UDim2.new(0.45,0,0,11); FPSInTitle.Position=UDim2.new(0,12,0,28)
FPSInTitle.BackgroundTransparency=1; FPSInTitle.Text="FPS: --"; FPSInTitle.TextColor3=VIO
FPSInTitle.Font=Enum.Font.GothamBold; FPSInTitle.TextSize=9
FPSInTitle.TextXAlignment=Enum.TextXAlignment.Left; FPSInTitle.ZIndex=6; FPSInTitle.Parent=TitleBar

local PingInTitle=Instance.new("TextLabel")
PingInTitle.Size=UDim2.new(0.45,0,0,11); PingInTitle.Position=UDim2.new(0,12,0,41)
PingInTitle.BackgroundTransparency=1; PingInTitle.Text="PING: --"; PingInTitle.TextColor3=VIO
PingInTitle.Font=Enum.Font.GothamBold; PingInTitle.TextSize=9
PingInTitle.TextXAlignment=Enum.TextXAlignment.Left; PingInTitle.ZIndex=6; PingInTitle.Parent=TitleBar

-- PREMIUM sin emojis, alineado exactamente con FPS/PING (x=12)
local PremiumLbl=Instance.new("TextLabel")
PremiumLbl.Size=UDim2.new(0.5,0,0,10); PremiumLbl.Position=UDim2.new(0,12,0,54)
PremiumLbl.BackgroundTransparency=1; PremiumLbl.Text="PREMIUM"; PremiumLbl.TextColor3=VIO
PremiumLbl.Font=Enum.Font.GothamBold; PremiumLbl.TextSize=8
PremiumLbl.TextXAlignment=Enum.TextXAlignment.Left; PremiumLbl.ZIndex=6; PremiumLbl.Parent=TitleBar
task.spawn(function()
    while true do
        TweenService:Create(PremiumLbl,TweenInfo.new(1.1,Enum.EasingStyle.Sine),{TextColor3=VIO_L}):Play()
        task.wait(1.1)
        TweenService:Create(PremiumLbl,TweenInfo.new(1.1,Enum.EasingStyle.Sine),{TextColor3=VIO}):Play()
        task.wait(1.1)
    end
end)

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

local lastT,fc=tick(),0
RunService.RenderStepped:Connect(function()
    fc+=1; local now=tick()
    if now-lastT>=1 then FPSInTitle.Text="FPS: "..math.floor(fc/(now-lastT)); fc=0; lastT=now end
end)
RunService.Heartbeat:Connect(function()
    PingInTitle.Text="PING: "..math.floor(LocalPlayer:GetNetworkPing()*1000).."ms"
end)

local CloseBtn=Instance.new("TextButton"); CloseBtn.Size=UDim2.new(0,22,0,22); CloseBtn.Position=UDim2.new(1,-30,0,6)
CloseBtn.BackgroundTransparency=1; CloseBtn.Text="X"; CloseBtn.TextColor3=Color3.fromRGB(255,80,80)
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.TextScaled=true; CloseBtn.BorderSizePixel=0
CloseBtn.ZIndex=7; CloseBtn.Parent=TitleBar
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,5)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible=false; LogoHolder.Visible=true end)
LogoBtn.MouseButton1Click:Connect(function() LogoHolder.Visible=false; MainFrame.Visible=true end)

-- FOV stat
local FovStatLbl=Instance.new("TextLabel")
FovStatLbl.Size=UDim2.new(1,0,0,16); FovStatLbl.Position=UDim2.new(0,0,0,76)
FovStatLbl.BackgroundTransparency=1; FovStatLbl.Text="FOV: 70"
FovStatLbl.TextColor3=VIO; FovStatLbl.Font=Enum.Font.GothamBold
FovStatLbl.TextSize=10; FovStatLbl.TextXAlignment=Enum.TextXAlignment.Center
FovStatLbl.ZIndex=6; FovStatLbl.Parent=MainFrame

-- ============================================
--   TOGGLE HELPER
-- ============================================

local toggleVisuals={}

local function MakeToggle(name,yPos,callback,height,saveKey)
    height=height or 32
    local W=236
    local Btn=Instance.new("TextButton"); Btn.Size=UDim2.new(0,W,0,height); Btn.Position=UDim2.new(0.5,-(W/2),0,yPos)
    Btn.BackgroundColor3=BLACK; Btn.BackgroundTransparency=0.6; Btn.BorderSizePixel=0; Btn.Text=""; Btn.ZIndex=5; Btn.Parent=MainFrame
    Instance.new("UICorner",Btn).CornerRadius=UDim.new(0,8)
    local BtnStroke=Instance.new("UIStroke"); BtnStroke.Color=VIO_D; BtnStroke.Thickness=1.2; BtnStroke.Parent=Btn
    local BtnLbl=Instance.new("TextLabel"); BtnLbl.Size=UDim2.new(0.72,0,1,0); BtnLbl.Position=UDim2.new(0,10,0,0)
    BtnLbl.BackgroundTransparency=1; BtnLbl.Text=name; BtnLbl.TextColor3=VIO
    BtnLbl.Font=Enum.Font.GothamBold; BtnLbl.TextSize=12; BtnLbl.TextXAlignment=Enum.TextXAlignment.Left
    BtnLbl.ZIndex=6; BtnLbl.Parent=Btn
    task.spawn(function()
        while BtnLbl.Parent do
            TweenService:Create(BtnLbl,TweenInfo.new(1.3,Enum.EasingStyle.Sine),{TextColor3=VIO_L}):Play()
            task.wait(1.3)
            TweenService:Create(BtnLbl,TweenInfo.new(1.3,Enum.EasingStyle.Sine),{TextColor3=VIO}):Play()
            task.wait(1.3)
        end
    end)
    local Track=Instance.new("Frame"); Track.Size=UDim2.new(0,42,0,22); Track.Position=UDim2.new(1,-48,0.5,-11)
    Track.BackgroundColor3=Color3.fromRGB(45,45,60); Track.BorderSizePixel=0; Track.ZIndex=6; Track.Parent=Btn
    Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)
    local Circle=Instance.new("Frame"); Circle.Size=UDim2.new(0,16,0,16); Circle.Position=UDim2.new(0,3,0.5,-8)
    Circle.BackgroundColor3=Color3.fromRGB(160,160,160); Circle.BorderSizePixel=0; Circle.ZIndex=7; Circle.Parent=Track
    Instance.new("UICorner",Circle).CornerRadius=UDim.new(1,0)
    if saveKey then toggleVisuals[saveKey]={track=Track,circle=Circle,stroke=BtnStroke} end
    local enabled=false
    Btn.MouseButton1Click:Connect(function()
        enabled=not enabled
        if enabled then
            TweenService:Create(Track,TweenInfo.new(0.18),{BackgroundColor3=BLACK}):Play()
            TweenService:Create(Circle,TweenInfo.new(0.18),{Position=UDim2.new(0,22,0.5,-8),BackgroundColor3=WHITE}):Play()
            BtnStroke.Color=VIO; BtnLbl.TextColor3=VIO_L
        else
            TweenService:Create(Track,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(45,45,60)}):Play()
            TweenService:Create(Circle,TweenInfo.new(0.18),{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=Color3.fromRGB(160,160,160)}):Play()
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

local dayConn=nil
local function ApplyDaySky(state)
    if state then
        if dayConn then dayConn:Disconnect() end
        Lighting.ClockTime=14; Lighting.Brightness=3
        Lighting.Ambient=Color3.fromRGB(120,140,180); Lighting.OutdoorAmbient=Color3.fromRGB(130,160,200)
        Lighting.FogEnd=300000; Lighting.FogStart=200000
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
        local sky=Instance.new("Sky"); local id="rbxassetid://75213778961746"
        sky.SkyboxBk=id; sky.SkyboxDn=id; sky.SkyboxFt=id; sky.SkyboxLf=id; sky.SkyboxRt=id; sky.SkyboxUp=id; sky.Parent=Lighting
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

local nightConn=nil
local function ApplyNightSky(state)
    if state then
        if nightConn then nightConn:Disconnect() end
        Lighting.ClockTime=0; Lighting.Brightness=0.1
        Lighting.Ambient=Color3.fromRGB(10,10,30); Lighting.OutdoorAmbient=Color3.fromRGB(15,15,40)
        Lighting.FogEnd=100000; Lighting.FogStart=80000
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
        local sky=Instance.new("Sky"); local id="rbxassetid://5347804161"
        sky.SkyboxBk=id; sky.SkyboxDn=id; sky.SkyboxFt=id; sky.SkyboxLf=id; sky.SkyboxRt=id; sky.SkyboxUp=id
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

-- DELAY: elimina lag/retraso del juego para que se sienta fluido
local delayConn=nil
local function ApplyDelay(state)
    if state then
        pcall(function()
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
            settings().Physics.AllowSleep = false
        end)
        if setfpscap then setfpscap(0) end
        for _,fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("BlurEffect") then fx.Size=0
            elseif fx:IsA("DepthOfFieldEffect") then fx.Enabled=false
            elseif fx:IsA("SunRaysEffect") then fx.Intensity=0 end
        end
        -- Loop vacio para mantener Heartbeat activo sin acumulacion
        delayConn=RunService.Heartbeat:Connect(function() end)
    else
        if delayConn then delayConn:Disconnect(); delayConn=nil end
        pcall(function() settings().Physics.AllowSleep=true end)
        for _,fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("DepthOfFieldEffect") then fx.Enabled=true
            elseif fx:IsA("SunRaysEffect") then fx.Intensity=0.25 end
        end
    end
end

-- ============================================
--   SAVE / LOAD
-- ============================================

local SAVE_FILE="kmoney_v8.txt"
local currentFOV=70
local toggleStates={lowgfx=false,fps=false,ping=false,delay=false,day=false,night=false,brightness=false,autorejoin=false,autokit=false,autoload=false}

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
        TweenService:Create(v.circle,TweenInfo.new(0.18),{Position=UDim2.new(0,22,0.5,-8),BackgroundColor3=WHITE}):Play()
        v.stroke.Color=VIO
    else
        TweenService:Create(v.track,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(45,45,60)}):Play()
        TweenService:Create(v.circle,TweenInfo.new(0.18),{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=Color3.fromRGB(160,160,160)}):Play()
        v.stroke.Color=VIO_D
    end
end

-- SetFOV declarada antes de usarla
local SetFOV

-- ============================================
--   BUILD TOGGLES  (Y desde 96)
-- ============================================

local Y=96

MakeToggle("LOW GRAPHICS",Y,function(s) toggleStates.lowgfx=s; ApplyLowGraphics(s); SaveSettings() end,32,"lowgfx"); Y=Y+38
MakeToggle("FPS BOOST",   Y,function(s) toggleStates.fps=s;    ApplyFPSBoost(s);    SaveSettings() end,32,"fps");    Y=Y+38
MakeToggle("PING LOW",    Y,function(s) toggleStates.ping=s;   ApplyPingLow(s);     SaveSettings() end,32,"ping");   Y=Y+38
MakeToggle("DELAY",       Y,function(s) toggleStates.delay=s;  ApplyDelay(s);       SaveSettings() end,32,"delay");  Y=Y+38
MakeToggle("DAY",         Y,function(s) toggleStates.day=s;    ApplyDaySky(s);      SaveSettings() end,32,"day");    Y=Y+38
MakeToggle("NIGHT",       Y,function(s) toggleStates.night=s;  ApplyNightSky(s);    SaveSettings() end,32,"night");  Y=Y+38
MakeToggle("BRIGHT",      Y,function(s)
    toggleStates.brightness=s
    if s then
        Lighting.Brightness=6
        Lighting.Ambient=Color3.fromRGB(200,200,200)
        Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
    else
        Lighting.Brightness=savedLighting.Brightness
        Lighting.Ambient=savedLighting.Ambient
        Lighting.OutdoorAmbient=savedLighting.OutdoorAmbient
    end
    SaveSettings()
end,32,"brightness"); Y=Y+38

-- ============================================
--   FOV SLIDER
-- ============================================

local W2=236
local FOVBox=Instance.new("Frame"); FOVBox.Size=UDim2.new(0,W2,0,46); FOVBox.Position=UDim2.new(0.5,-(W2/2),0,Y)
FOVBox.BackgroundTransparency=0.6; FOVBox.BackgroundColor3=BLACK; FOVBox.BorderSizePixel=0; FOVBox.ZIndex=5; FOVBox.Parent=MainFrame
Instance.new("UICorner",FOVBox).CornerRadius=UDim.new(0,8)
local FOVS=Instance.new("UIStroke"); FOVS.Color=VIO_D; FOVS.Thickness=1.2; FOVS.Parent=FOVBox

local FOVTit=Instance.new("TextLabel"); FOVTit.Size=UDim2.new(0.5,0,0,20); FOVTit.Position=UDim2.new(0,10,0,3)
FOVTit.BackgroundTransparency=1; FOVTit.Text="FOV"; FOVTit.TextColor3=VIO
FOVTit.Font=Enum.Font.GothamBold; FOVTit.TextSize=12; FOVTit.TextXAlignment=Enum.TextXAlignment.Left
FOVTit.ZIndex=6; FOVTit.Parent=FOVBox

local FOVVal=Instance.new("TextLabel"); FOVVal.Size=UDim2.new(0.42,0,0,20); FOVVal.Position=UDim2.new(0.56,0,0,3)
FOVVal.BackgroundTransparency=1; FOVVal.Text="70"; FOVVal.TextColor3=VIO
FOVVal.Font=Enum.Font.GothamBold; FOVVal.TextSize=12; FOVVal.TextXAlignment=Enum.TextXAlignment.Right
FOVVal.ZIndex=6; FOVVal.Parent=FOVBox
task.spawn(function()
    while FOVVal.Parent do
        TweenService:Create(FOVVal,TweenInfo.new(1.2,Enum.EasingStyle.Sine),{TextColor3=VIO_L}):Play()
        task.wait(1.2)
        TweenService:Create(FOVVal,TweenInfo.new(1.2,Enum.EasingStyle.Sine),{TextColor3=VIO}):Play()
        task.wait(1.2)
    end
end)

local FovTrack=Instance.new("Frame"); FovTrack.Size=UDim2.new(1,-18,0,7); FovTrack.Position=UDim2.new(0,9,0,30)
FovTrack.BackgroundColor3=Color3.fromRGB(38,38,52); FovTrack.BorderSizePixel=0; FovTrack.ZIndex=6; FovTrack.Parent=FOVBox
Instance.new("UICorner",FovTrack).CornerRadius=UDim.new(1,0)
local FovFill=Instance.new("Frame"); FovFill.Size=UDim2.new(0.25,0,1,0); FovFill.BackgroundColor3=VIO
FovFill.BorderSizePixel=0; FovFill.ZIndex=7; FovFill.Parent=FovTrack
Instance.new("UICorner",FovFill).CornerRadius=UDim.new(1,0)
local FovThumb=Instance.new("TextButton"); FovThumb.Size=UDim2.new(0,18,0,18); FovThumb.Position=UDim2.new(0.25,-9,0.5,-9)
FovThumb.BackgroundColor3=WHITE; FovThumb.Text=""; FovThumb.BorderSizePixel=0; FovThumb.ZIndex=8; FovThumb.Parent=FovTrack
Instance.new("UICorner",FovThumb).CornerRadius=UDim.new(1,0)

local FOV_MIN,FOV_MAX=40,200; local draggingFOV=false
SetFOV = function(fov)
    fov=math.clamp(fov,FOV_MIN,FOV_MAX)
    local cam=workspace.CurrentCamera; if cam then cam.FieldOfView=fov end
    local pct=(fov-FOV_MIN)/(FOV_MAX-FOV_MIN)
    FovFill.Size=UDim2.new(pct,0,1,0); FovThumb.Position=UDim2.new(pct,-9,0.5,-9)
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
SetFOV(70); Y=Y+54

-- ============================================
--   REJOIN  — toca el cuadro = rejoin instantaneo
--   KEY button asigna tecla que tb hace rejoin
-- ============================================

local rejoinKey=nil
local rejoinListening=false

local RejoinBox=Instance.new("Frame"); RejoinBox.Size=UDim2.new(0,W2,0,60); RejoinBox.Position=UDim2.new(0.5,-(W2/2),0,Y)
RejoinBox.BackgroundColor3=BLACK; RejoinBox.BackgroundTransparency=0.6; RejoinBox.BorderSizePixel=0; RejoinBox.ZIndex=5; RejoinBox.Parent=MainFrame
Instance.new("UICorner",RejoinBox).CornerRadius=UDim.new(0,8)
local RejoinStroke=Instance.new("UIStroke"); RejoinStroke.Color=VIO_D; RejoinStroke.Thickness=1.2; RejoinStroke.Parent=RejoinBox
toggleVisuals["autorejoin"]={track=nil,circle=nil,stroke=RejoinStroke}

local RejoinNameLbl=Instance.new("TextLabel"); RejoinNameLbl.Size=UDim2.new(0.55,0,0,24); RejoinNameLbl.Position=UDim2.new(0,10,0,0)
RejoinNameLbl.BackgroundTransparency=1; RejoinNameLbl.Text="REJOIN"; RejoinNameLbl.TextColor3=VIO
RejoinNameLbl.Font=Enum.Font.GothamBold; RejoinNameLbl.TextSize=12; RejoinNameLbl.TextXAlignment=Enum.TextXAlignment.Left
RejoinNameLbl.ZIndex=6; RejoinNameLbl.Parent=RejoinBox
task.spawn(function() while RejoinNameLbl.Parent do TweenService:Create(RejoinNameLbl,TweenInfo.new(1.3,Enum.EasingStyle.Sine),{TextColor3=VIO_L}):Play() task.wait(1.3) TweenService:Create(RejoinNameLbl,TweenInfo.new(1.3,Enum.EasingStyle.Sine),{TextColor3=VIO}):Play() task.wait(1.3) end end)

local RTrack=Instance.new("Frame"); RTrack.Size=UDim2.new(0,42,0,22); RTrack.Position=UDim2.new(1,-48,0,1)
RTrack.BackgroundColor3=Color3.fromRGB(45,45,60); RTrack.BorderSizePixel=0; RTrack.ZIndex=6; RTrack.Parent=RejoinBox
Instance.new("UICorner",RTrack).CornerRadius=UDim.new(1,0)
local RCircle=Instance.new("Frame"); RCircle.Size=UDim2.new(0,16,0,16); RCircle.Position=UDim2.new(0,3,0.5,-8)
RCircle.BackgroundColor3=Color3.fromRGB(160,160,160); RCircle.BorderSizePixel=0; RCircle.ZIndex=7; RCircle.Parent=RTrack
Instance.new("UICorner",RCircle).CornerRadius=UDim.new(1,0)
toggleVisuals["autorejoin"].track=RTrack; toggleVisuals["autorejoin"].circle=RCircle

local RKeyBtn=Instance.new("TextButton"); RKeyBtn.Size=UDim2.new(1,-18,0,14); RKeyBtn.Position=UDim2.new(0,9,0,42)
RKeyBtn.BackgroundColor3=Color3.fromRGB(30,0,50); RKeyBtn.BackgroundTransparency=0.4
RKeyBtn.Text="KEY: NONE (toca para asignar)"; RKeyBtn.TextColor3=VIO
RKeyBtn.Font=Enum.Font.Gotham; RKeyBtn.TextSize=8; RKeyBtn.BorderSizePixel=0; RKeyBtn.ZIndex=6; RKeyBtn.Parent=RejoinBox
Instance.new("UICorner",RKeyBtn).CornerRadius=UDim.new(0,4)

RKeyBtn.MouseButton1Click:Connect(function()
    rejoinListening=true; RKeyBtn.Text="Presiona una tecla..."
    local conn; conn=UserInputSvc.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            rejoinKey=inp.KeyCode; rejoinListening=false
            RKeyBtn.Text="KEY: "..inp.KeyCode.Name.." (toca para cambiar)"
            conn:Disconnect()
        end
    end)
end)

-- Keybind: siempre activa rejoin al presionar la tecla asignada
UserInputSvc.InputBegan:Connect(function(inp)
    if not rejoinListening and rejoinKey and inp.KeyCode==rejoinKey then
        TweenService:Create(RTrack,TweenInfo.new(0.18),{BackgroundColor3=BLACK}):Play()
        TweenService:Create(RCircle,TweenInfo.new(0.18),{Position=UDim2.new(0,22,0.5,-8),BackgroundColor3=WHITE}):Play()
        RejoinStroke.Color=VIO
        pcall(function() TeleportSvc:Teleport(game.PlaceId,LocalPlayer) end)
    end
end)

-- Toca el cuadro = rejoin instantaneo
RejoinBox.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        local my=inp.Position.Y-RejoinBox.AbsolutePosition.Y
        if my>38 then return end
        TweenService:Create(RTrack,TweenInfo.new(0.18),{BackgroundColor3=BLACK}):Play()
        TweenService:Create(RCircle,TweenInfo.new(0.18),{Position=UDim2.new(0,22,0.5,-8),BackgroundColor3=WHITE}):Play()
        RejoinStroke.Color=VIO
        toggleStates.autorejoin=true; SaveSettings()
        pcall(function() TeleportSvc:Teleport(game.PlaceId,LocalPlayer) end)
    end
end)
Y=Y+68

-- ============================================
--   KIT — toca el cuadro = sale del juego en 0.1s
--   KEY asignable
-- ============================================

local kitKey=nil
local kitListening=false

local KitBox=Instance.new("Frame"); KitBox.Size=UDim2.new(0,W2,0,60); KitBox.Position=UDim2.new(0.5,-(W2/2),0,Y)
KitBox.BackgroundColor3=BLACK; KitBox.BackgroundTransparency=0.6; KitBox.BorderSizePixel=0; KitBox.ZIndex=5; KitBox.Parent=MainFrame
Instance.new("UICorner",KitBox).CornerRadius=UDim.new(0,8)
local KitStroke=Instance.new("UIStroke"); KitStroke.Color=VIO_D; KitStroke.Thickness=1.2; KitStroke.Parent=KitBox
toggleVisuals["autokit"]={track=nil,circle=nil,stroke=KitStroke}

local KitNameLbl=Instance.new("TextLabel"); KitNameLbl.Size=UDim2.new(0.55,0,0,24); KitNameLbl.Position=UDim2.new(0,10,0,0)
KitNameLbl.BackgroundTransparency=1; KitNameLbl.Text="KIT"; KitNameLbl.TextColor3=VIO
KitNameLbl.Font=Enum.Font.GothamBold; KitNameLbl.TextSize=12; KitNameLbl.TextXAlignment=Enum.TextXAlignment.Left
KitNameLbl.ZIndex=6; KitNameLbl.Parent=KitBox
task.spawn(function() while KitNameLbl.Parent do TweenService:Create(KitNameLbl,TweenInfo.new(1.3,Enum.EasingStyle.Sine),{TextColor3=VIO_L}):Play() task.wait(1.3) TweenService:Create(KitNameLbl,TweenInfo.new(1.3,Enum.EasingStyle.Sine),{TextColor3=VIO}):Play() task.wait(1.3) end end)

local KTrack=Instance.new("Frame"); KTrack.Size=UDim2.new(0,42,0,22); KTrack.Position=UDim2.new(1,-48,0,1)
KTrack.BackgroundColor3=Color3.fromRGB(45,45,60); KTrack.BorderSizePixel=0; KTrack.ZIndex=6; KTrack.Parent=KitBox
Instance.new("UICorner",KTrack).CornerRadius=UDim.new(1,0)
local KCircle=Instance.new("Frame"); KCircle.Size=UDim2.new(0,16,0,16); KCircle.Position=UDim2.new(0,3,0.5,-8)
KCircle.BackgroundColor3=Color3.fromRGB(160,160,160); KCircle.BorderSizePixel=0; KCircle.ZIndex=7; KCircle.Parent=KTrack
Instance.new("UICorner",KCircle).CornerRadius=UDim.new(1,0)
toggleVisuals["autokit"].track=KTrack; toggleVisuals["autokit"].circle=KCircle

local KKeyBtn=Instance.new("TextButton"); KKeyBtn.Size=UDim2.new(1,-18,0,14); KKeyBtn.Position=UDim2.new(0,9,0,42)
KKeyBtn.BackgroundColor3=Color3.fromRGB(30,0,50); KKeyBtn.BackgroundTransparency=0.4
KKeyBtn.Text="KEY: NONE (toca para asignar)"; KKeyBtn.TextColor3=VIO
KKeyBtn.Font=Enum.Font.Gotham; KKeyBtn.TextSize=8; KKeyBtn.BorderSizePixel=0; KKeyBtn.ZIndex=6; KKeyBtn.Parent=KitBox
Instance.new("UICorner",KKeyBtn).CornerRadius=UDim.new(0,4)

KKeyBtn.MouseButton1Click:Connect(function()
    kitListening=true; KKeyBtn.Text="Presiona una tecla..."
    local conn; conn=UserInputSvc.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            kitKey=inp.KeyCode; kitListening=false
            KKeyBtn.Text="KEY: "..inp.KeyCode.Name.." (toca para cambiar)"
            conn:Disconnect()
        end
    end)
end)

local function DoKit()
    TweenService:Create(KTrack,TweenInfo.new(0.18),{BackgroundColor3=BLACK}):Play()
    TweenService:Create(KCircle,TweenInfo.new(0.18),{Position=UDim2.new(0,22,0.5,-8),BackgroundColor3=WHITE}):Play()
    KitStroke.Color=VIO
    task.wait(0.1)
    pcall(function() TeleportSvc:Teleport(game.PlaceId,LocalPlayer) end)
end

-- Keybind
UserInputSvc.InputBegan:Connect(function(inp)
    if not kitListening and kitKey and inp.KeyCode==kitKey then
        DoKit()
    end
end)

-- Toca el cuadro = sale en 0.1s
KitBox.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        local my=inp.Position.Y-KitBox.AbsolutePosition.Y
        if my>38 then return end
        toggleStates.autokit=true; SaveSettings()
        DoKit()
    end
end)
Y=Y+68

-- ============================================
--   AUTO LOAD — aplica config automaticamente
-- ============================================

MakeToggle("LOAD",Y,function(s)
    toggleStates.autoload=s
    if s then
        local saved=LoadSettings()
        if saved then
            if saved.fov        then SetFOV(saved.fov) end
            if saved.lowgfx     then ApplyLowGraphics(true);  toggleStates.lowgfx=true;  ApplyToggleVisual("lowgfx",true)  end
            if saved.fps        then ApplyFPSBoost(true);     toggleStates.fps=true;     ApplyToggleVisual("fps",true)     end
            if saved.ping       then ApplyPingLow(true);      toggleStates.ping=true;    ApplyToggleVisual("ping",true)    end
            if saved.delay      then ApplyDelay(true);        toggleStates.delay=true;   ApplyToggleVisual("delay",true)   end
            if saved.day        then ApplyDaySky(true);       toggleStates.day=true;     ApplyToggleVisual("day",true)     end
            if saved.night      then ApplyNightSky(true);     toggleStates.night=true;   ApplyToggleVisual("night",true)   end
            if saved.brightness then
                Lighting.Brightness=6
                Lighting.Ambient=Color3.fromRGB(200,200,200)
                Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
                toggleStates.brightness=true; ApplyToggleVisual("brightness",true)
            end
            pcall(function() StarterGui:SetCore("SendNotification",{Title="KMoney",Text="Configuracion cargada!",Duration=3}) end)
        else
            pcall(function() StarterGui:SetCore("SendNotification",{Title="KMoney",Text="Sin guardado, activa opciones para guardar",Duration=4}) end)
        end
    end
    SaveSettings()
end,32,"autoload"); Y=Y+38

-- Resize automatico
MainFrame.Size=UDim2.new(0,260,0,Y+14)
MainFrame.Position=UDim2.new(0.5,-130,0.5,-(Y+14)/2)

-- ============================================
--   AUTO STARTUP LOAD — aplica al iniciar
-- ============================================

task.delay(0.3,function()
    local saved=LoadSettings()
    if saved then
        if saved.fov        then SetFOV(saved.fov) end
        if saved.lowgfx     then ApplyLowGraphics(true);  toggleStates.lowgfx=true;  ApplyToggleVisual("lowgfx",true)  end
        if saved.fps        then ApplyFPSBoost(true);     toggleStates.fps=true;     ApplyToggleVisual("fps",true)     end
        if saved.ping       then ApplyPingLow(true);      toggleStates.ping=true;    ApplyToggleVisual("ping",true)    end
        if saved.delay      then ApplyDelay(true);        toggleStates.delay=true;   ApplyToggleVisual("delay",true)   end
        if saved.day        then ApplyDaySky(true);       toggleStates.day=true;     ApplyToggleVisual("day",true)     end
        if saved.night      then ApplyNightSky(true);     toggleStates.night=true;   ApplyToggleVisual("night",true)   end
        if saved.brightness then
            Lighting.Brightness=6
            Lighting.Ambient=Color3.fromRGB(200,200,200)
            Lighting.OutdoorAmbient=Color3.fromRGB(220,220,220)
            toggleStates.brightness=true; ApplyToggleVisual("brightness",true)
        end
        pcall(function() StarterGui:SetCore("SendNotification",{Title="KMoney",Text="Config auto-cargada!",Duration=3}) end)
    end
end)

pcall(function() StarterGui:SetCore("SendNotification",{Title="KMoney Tweaking",Text="Hub v8 listo!",Duration=4}) end)
print("[KMoney v8] Hub loaded!")
