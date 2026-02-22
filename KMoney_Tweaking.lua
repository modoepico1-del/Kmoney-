-- ============================================
--         KMONEY TWEAKING HUB v3
-- ============================================

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local Lighting      = game:GetService("Lighting")
local StarterGui    = game:GetService("StarterGui")
local TweenService  = game:GetService("TweenService")
local UserInputSvc  = game:GetService("UserInputService")
local LocalPlayer   = Players.LocalPlayer

-- ============================================
--              SCREENGUI
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KMoneyTweakingHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- ============================================
--   $K LOGO BUTTON + "KMONEY" label (hidden at start)
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
LogoBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
LogoBtn.BorderSizePixel = 0
LogoBtn.Text = "$K"
LogoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoBtn.Font = Enum.Font.GothamBold
LogoBtn.TextSize = 22
LogoBtn.ZIndex = 10
LogoBtn.Parent = LogoHolder

local LogoBtnCorner = Instance.new("UICorner")
LogoBtnCorner.CornerRadius = UDim.new(1, 0)
LogoBtnCorner.Parent = LogoBtn

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(255, 255, 255)
LogoStroke.Thickness = 2
LogoStroke.Parent = LogoBtn

-- Make logo draggable via mouse anywhere on screen
local logoDragging = false
local logoDragStart = nil
local logoStartPos = nil

LogoBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        logoDragging = true
        logoDragStart = input.Position
        logoStartPos = LogoHolder.Position
    end
end)

UserInputSvc.InputChanged:Connect(function(input)
    if logoDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - logoDragStart
        LogoHolder.Position = UDim2.new(
            logoStartPos.X.Scale,
            logoStartPos.X.Offset + delta.X,
            logoStartPos.Y.Scale,
            logoStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputSvc.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        logoDragging = false
    end
end)

-- KMONEY rainbow label (individual letters)
local rainbowColors = {
    Color3.fromRGB(255, 80,  80),
    Color3.fromRGB(255, 160, 40),
    Color3.fromRGB(255, 230, 40),
    Color3.fromRGB(80,  220, 80),
    Color3.fromRGB(60,  180, 255),
    Color3.fromRGB(160, 80,  255),
}
local kmoneyLetters = {"K","M","O","N","E","Y"}
local letterLabels = {}
local totalLetters = #kmoneyLetters
local letterSpacing = 10
local totalWidth = totalLetters * letterSpacing
local startX = math.floor((80 - totalWidth) / 2)

for i, char in ipairs(kmoneyLetters) do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, letterSpacing, 0, 14)
    lbl.Position = UDim2.new(0, startX + (i - 1) * letterSpacing, 0, 74)
    lbl.BackgroundTransparency = 1
    lbl.Text = char
    lbl.TextColor3 = rainbowColors[i]
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ZIndex = 10
    lbl.Parent = LogoHolder
    letterLabels[i] = lbl
end

-- Animate rainbow - slow sine wave, each letter offset differently
local rainbowOffset = 0
RunService.Heartbeat:Connect(function(dt)
    if not LogoHolder.Visible then return end
    rainbowOffset = rainbowOffset + dt * 0.4  -- very slow
    for i, lbl in ipairs(letterLabels) do
        -- Each letter uses a different phase so colors spread across letters non-linearly
        local phase = math.sin(rainbowOffset + i * 0.8) * 0.5 + (rainbowOffset * 0.3 + i * 0.15)
        lbl.TextColor3 = Color3.fromHSV(phase % 1, 0.95, 1)
    end
end)

-- Pulse animation for logo
task.spawn(function()
    while true do
        TweenService:Create(LogoStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 4}):Play()
        task.wait(1)
        TweenService:Create(LogoStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 1.5}):Play()
        task.wait(1)
    end
end)

-- ============================================
--              MAIN FRAME
-- ============================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 510)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -235)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BackgroundTransparency = 0.55
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 0, 0)
MainStroke.Thickness = 2.5
MainStroke.Parent = MainFrame

-- ============================================
--   SNOWBALL EFFECT (slow white circles)
-- ============================================

local SnowCanvas = Instance.new("Frame")
SnowCanvas.Size = UDim2.new(1, 0, 1, 0)
SnowCanvas.BackgroundTransparency = 1
SnowCanvas.BorderSizePixel = 0
SnowCanvas.ZIndex = 1
SnowCanvas.Parent = MainFrame

local snowballs = {}

for i = 1, 30 do
    local s = math.random(6, 16)
    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0, s, 0, s)
    ball.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
    ball.BackgroundTransparency = math.random(1, 4) * 0.15
    ball.BorderSizePixel = 0
    ball.ZIndex = 2
    ball.Parent = SnowCanvas
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

    snowballs[i] = {
        frame    = ball,
        speed    = math.random(6, 14) / 1000,   -- very slow
        sway     = math.random(-20, 20) / 2000,
        xBase    = math.random(),
        progress = math.random(),
    }
end

RunService.RenderStepped:Connect(function(dt)
    for _, s in ipairs(snowballs) do
        s.progress = s.progress + s.speed
        if s.progress > 1.1 then
            s.progress = -0.05
            s.xBase = math.random()
        end
        local xOff = math.sin(s.progress * math.pi * 2.5) * 0.025
        s.frame.Position = UDim2.new(math.clamp(s.xBase + xOff, 0, 0.97), 0, s.progress, 0)
    end
end)

-- ============================================
--              TITLE BAR (BLACK)
-- ============================================

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 52)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 5
TitleBar.Parent = MainFrame

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleFix.BorderSizePixel = 0
TitleFix.ZIndex = 5
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -55, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "KMONEY TWEAKING"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 6
TitleLabel.Parent = TitleBar

-- Close Button (RED, NO logo/icon, just X text)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 7
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    LogoHolder.Visible = true
end)

LogoBtn.MouseButton1Click:Connect(function()
    LogoHolder.Visible = false
    MainFrame.Visible = true
end)

-- ============================================
--         TOGGLE BUTTON HELPER
-- ============================================

local function CreateToggleButton(name, description, yPos, callback, height, saveKey)
    height = height or 44
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 298, 0, height)
    Btn.Position = UDim2.new(0.5, -149, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.ZIndex = 5
    Btn.Parent = MainFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 9)

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(35, 35, 50)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    local BtnLabel = Instance.new("TextLabel")
    BtnLabel.Size = UDim2.new(0.66, 0, 1, 0)
    BtnLabel.Position = UDim2.new(0, 12, 0, 0)
    BtnLabel.BackgroundTransparency = 1
    BtnLabel.Text = name
    BtnLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
    BtnLabel.Font = Enum.Font.GothamBold
    BtnLabel.TextScaled = true
    BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
    BtnLabel.ZIndex = 6
    BtnLabel.Parent = Btn

    local ToggleTrack = Instance.new("Frame")
    ToggleTrack.Size = UDim2.new(0, 46, 0, 24)
    ToggleTrack.Position = UDim2.new(1, -56, 0.5, -12)
    ToggleTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    ToggleTrack.BorderSizePixel = 0
    ToggleTrack.ZIndex = 6
    ToggleTrack.Parent = Btn
    Instance.new("UICorner", ToggleTrack).CornerRadius = UDim.new(1, 0)

    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    ToggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.ZIndex = 7
    ToggleCircle.Parent = ToggleTrack
    Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)

    -- Store visuals for auto load
    if saveKey then
        toggleVisuals[saveKey] = {track = ToggleTrack, circle = ToggleCircle, stroke = BtnStroke}
    end

    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(ToggleTrack,  TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.18), {
                Position = UDim2.new(0, 24, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            BtnStroke.Color = Color3.fromRGB(100, 100, 130)
        else
            TweenService:Create(ToggleTrack,  TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(45,45,60)}):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.18), {
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(160, 160, 160)
            }):Play()
            BtnStroke.Color = Color3.fromRGB(35, 35, 50)
        end
        callback(enabled)
    end)
end

-- ============================================
--          FEATURE FUNCTIONS
-- ============================================

-- FPS Boost
local function ApplyFPSBoost(state)
    if state then
        if setfpscap then setfpscap(0) end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
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

-- Ping Low
local pingConn = nil
local function ApplyPingLow(state)
    if state then
        if LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.AutoRotate = true end
        end
        pingConn = RunService.Heartbeat:Connect(function() end)
        StarterGui:SetCore("SendNotification", {Title = "KMoney", Text = "Ping Reducer ON", Duration = 3})
    else
        if pingConn then pingConn:Disconnect() pingConn = nil end
    end
end

-- Lighting Day (bright daylight sky)
local savedLighting = {}
local function SaveLighting()
    savedLighting = {
        ClockTime    = Lighting.ClockTime,
        Brightness   = Lighting.Brightness,
        Ambient      = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        FogColor     = Lighting.FogColor,
        FogEnd       = Lighting.FogEnd,
        FogStart     = Lighting.FogStart,
    }
end
SaveLighting()

local lightingDayOn  = false
local lightingNightOn = false

local function ApplyDaySky(state)
    if state then
        lightingDayOn = true
        if lightingNightOn then return end
        Lighting.ClockTime      = 14
        Lighting.Brightness     = 3
        Lighting.Ambient        = Color3.fromRGB(120, 140, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(130, 160, 200)
        Lighting.FogColor       = Color3.fromRGB(180, 200, 230)
        Lighting.FogEnd         = 300000
        Lighting.FogStart       = 200000
        -- Remove existing sky, add clear day sky
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        local sky = Instance.new("Sky")
        sky.SkyboxBk = "rbxassetid://129462011"
        sky.SkyboxDn = "rbxassetid://129456754"
        sky.SkyboxFt = "rbxassetid://129461087"
        sky.SkyboxLf = "rbxassetid://129461249"
        sky.SkyboxRt = "rbxassetid://129461521"
        sky.SkyboxUp = "rbxassetid://129462237"
        sky.Parent = Lighting
        StarterGui:SetCore("SendNotification", {Title = "KMoney", Text = "Cielo de dia activado", Duration = 3})
    else
        lightingDayOn = false
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        Lighting.ClockTime      = savedLighting.ClockTime
        Lighting.Brightness     = savedLighting.Brightness
        Lighting.Ambient        = savedLighting.Ambient
        Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
        Lighting.FogColor       = savedLighting.FogColor
        Lighting.FogEnd         = savedLighting.FogEnd
        Lighting.FogStart       = savedLighting.FogStart
    end
end

local function ApplyNightSky(state)
    if state then
        lightingNightOn = true
        Lighting.ClockTime      = 0
        Lighting.Brightness     = 0.1
        Lighting.Ambient        = Color3.fromRGB(10, 10, 30)
        Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 40)
        Lighting.FogColor       = Color3.fromRGB(10, 12, 30)
        Lighting.FogEnd         = 100000
        Lighting.FogStart       = 80000
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        local sky = Instance.new("Sky")
        sky.SkyboxBk = "rbxassetid://159454286"
        sky.SkyboxDn = "rbxassetid://159454286"
        sky.SkyboxFt = "rbxassetid://159454286"
        sky.SkyboxLf = "rbxassetid://159454286"
        sky.SkyboxRt = "rbxassetid://159454286"
        sky.SkyboxUp = "rbxassetid://159454286"
        sky.StarCount = 3000
        sky.Parent = Lighting
        StarterGui:SetCore("SendNotification", {Title = "KMoney", Text = "Cielo de noche activado", Duration = 3})
    else
        lightingNightOn = false
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        Lighting.ClockTime      = savedLighting.ClockTime
        Lighting.Brightness     = savedLighting.Brightness
        Lighting.Ambient        = savedLighting.Ambient
        Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
        Lighting.FogColor       = savedLighting.FogColor
        Lighting.FogEnd         = savedLighting.FogEnd
        Lighting.FogStart       = savedLighting.FogStart
    end
end

-- ============================================
--          BUILD TOGGLES
-- ============================================

-- Section label helper
local function SectionLabel(text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 298, 0, 18)
    lbl.Position = UDim2.new(0.5, -149, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(80, 80, 100)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = MainFrame
end

-- Save/load state using writefile/readfile if available
local SAVE_FILE = "kmoney_settings.txt"
local autoLoadEnabled = false
local toggleStates = {fps=false, ping=false, day=false, night=false, brightness=false}
local toggleVisuals = {} -- stores {track, circle, stroke} per key for visual update

local function SaveSettings()
    if not autoLoadEnabled then return end
    local ok = pcall(function()
        local data = ""
        for k, v in pairs(toggleStates) do
            data = data .. k .. "=" .. tostring(v) .. "\n"
        end
        writefile(SAVE_FILE, data)
    end)
end

local function LoadSettings()
    local ok, data = pcall(function() return readfile(SAVE_FILE) end)
    if ok and data and data ~= "" then
        local loaded = {}
        for k, v in string.gmatch(data, "(%a+)=(%a+)") do
            loaded[k] = (v == "true")
        end
        return loaded
    end
    return nil
end

local function ApplyToggleVisual(key, state)
    local v = toggleVisuals[key]
    if not v then return end
    if state then
        TweenService:Create(v.track,  TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play()
        TweenService:Create(v.circle, TweenInfo.new(0.18), {Position = UDim2.new(0, 24, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
        v.stroke.Color = Color3.fromRGB(100, 100, 130)
    else
        TweenService:Create(v.track,  TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(45,45,60)}):Play()
        TweenService:Create(v.circle, TweenInfo.new(0.18), {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(160,160,160)}):Play()
        v.stroke.Color = Color3.fromRGB(35, 35, 50)
    end
end

CreateToggleButton("FPS BOOST",  "", 62,  function(s)
    toggleStates.fps = s
    ApplyFPSBoost(s)
    if autoLoadEnabled then SaveSettings() end
end, 32, "fps")

-- AUTO LOAD toggle
local AutoBox = Instance.new("Frame")
AutoBox.Size = UDim2.new(0, 298, 0, 32)
AutoBox.Position = UDim2.new(0.5, -149, 0, 100)
AutoBox.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
AutoBox.BorderSizePixel = 0
AutoBox.ZIndex = 5
AutoBox.Parent = MainFrame
Instance.new("UICorner", AutoBox).CornerRadius = UDim.new(0, 9)

local AutoStroke = Instance.new("UIStroke")
AutoStroke.Color = Color3.fromRGB(35, 35, 50)
AutoStroke.Thickness = 1
AutoStroke.Parent = AutoBox

local AutoLabel = Instance.new("TextLabel")
AutoLabel.Size = UDim2.new(0.66, 0, 1, 0)
AutoLabel.Position = UDim2.new(0, 12, 0, 0)
AutoLabel.BackgroundTransparency = 1
AutoLabel.Text = "AUTO LOAD"
AutoLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
AutoLabel.Font = Enum.Font.GothamBold
AutoLabel.TextScaled = true
AutoLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoLabel.ZIndex = 6
AutoLabel.Parent = AutoBox

local AutoTrack = Instance.new("Frame")
AutoTrack.Size = UDim2.new(0, 46, 0, 24)
AutoTrack.Position = UDim2.new(1, -56, 0.5, -12)
AutoTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
AutoTrack.BorderSizePixel = 0
AutoTrack.ZIndex = 6
AutoTrack.Parent = AutoBox
Instance.new("UICorner", AutoTrack).CornerRadius = UDim.new(1, 0)

local AutoCircle = Instance.new("Frame")
AutoCircle.Size = UDim2.new(0, 18, 0, 18)
AutoCircle.Position = UDim2.new(0, 3, 0.5, -9)
AutoCircle.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
AutoCircle.BorderSizePixel = 0
AutoCircle.ZIndex = 7
AutoCircle.Parent = AutoTrack
Instance.new("UICorner", AutoCircle).CornerRadius = UDim.new(1, 0)

AutoBox.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        autoLoadEnabled = not autoLoadEnabled
        if autoLoadEnabled then
            TweenService:Create(AutoTrack,  TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play()
            TweenService:Create(AutoCircle, TweenInfo.new(0.18), {Position = UDim2.new(0, 24, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            AutoStroke.Color = Color3.fromRGB(100, 100, 130)
            -- Load saved settings immediately
            local saved = LoadSettings()
            if saved then
                if saved.fps then
                    ApplyFPSBoost(true)
                    toggleStates.fps = true
                    ApplyToggleVisual("fps", true)
                end
                if saved.ping then
                    ApplyPingLow(true)
                    toggleStates.ping = true
                    ApplyToggleVisual("ping", true)
                end
                if saved.day then
                    ApplyDaySky(true)
                    toggleStates.day = true
                    ApplyToggleVisual("day", true)
                end
                if saved.night then
                    ApplyNightSky(true)
                    toggleStates.night = true
                    ApplyToggleVisual("night", true)
                end
                if saved.brightness then
                    Lighting.Brightness = 6
                    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
                    Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
                    toggleStates.brightness = true
                    ApplyToggleVisual("brightness", true)
                end
                StarterGui:SetCore("SendNotification", {Title = "KMoney", Text = "Settings loaded!", Duration = 3})
            else
                StarterGui:SetCore("SendNotification", {Title = "KMoney", Text = "No saved settings found", Duration = 3})
            end
        else
            TweenService:Create(AutoTrack,  TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(45,45,60)}):Play()
            TweenService:Create(AutoCircle, TweenInfo.new(0.18), {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(160,160,160)}):Play()
            AutoStroke.Color = Color3.fromRGB(35, 35, 50)
        end
    end
end)

CreateToggleButton("PING LOW",   "", 138, function(s)
    toggleStates.ping = s
    ApplyPingLow(s)
    if autoLoadEnabled then SaveSettings() end
end, 32, "ping")
CreateToggleButton("DAY SKY",    "", 176, function(s)
    toggleStates.day = s
    ApplyDaySky(s)
    if autoLoadEnabled then SaveSettings() end
end, 36, "day")
CreateToggleButton("NIGHT SKY",  "", 218, function(s)
    toggleStates.night = s
    ApplyNightSky(s)
    if autoLoadEnabled then SaveSettings() end
end, 36, "night")
CreateToggleButton("BRIGHTNESS", "", 260, function(s)
    toggleStates.brightness = s
    if s then
        Lighting.Brightness = 6
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
    else
        Lighting.Brightness = savedLighting.Brightness
        Lighting.Ambient = savedLighting.Ambient
        Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
    end
    if autoLoadEnabled then SaveSettings() end
end, 36, "brightness")

-- ============================================
--           FOV SLIDER
-- ============================================

local FOVBox = Instance.new("Frame")
FOVBox.Size = UDim2.new(0, 298, 0, 56)
FOVBox.Position = UDim2.new(0.5, -149, 0, 306)
FOVBox.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
FOVBox.BorderSizePixel = 0
FOVBox.ZIndex = 5
FOVBox.Parent = MainFrame
Instance.new("UICorner", FOVBox).CornerRadius = UDim.new(0, 9)
local FOVS = Instance.new("UIStroke")
FOVS.Color = Color3.fromRGB(35, 35, 50)
FOVS.Thickness = 1
FOVS.Parent = FOVBox

local FOVTitle = Instance.new("TextLabel")
FOVTitle.Size = UDim2.new(0.6, 0, 0, 22)
FOVTitle.Position = UDim2.new(0, 12, 0, 5)
FOVTitle.BackgroundTransparency = 1
FOVTitle.Text = "FOV"
FOVTitle.TextColor3 = Color3.fromRGB(225, 225, 225)
FOVTitle.Font = Enum.Font.GothamBold
FOVTitle.TextScaled = true
FOVTitle.TextXAlignment = Enum.TextXAlignment.Left
FOVTitle.ZIndex = 6
FOVTitle.Parent = FOVBox

local FOVVal = Instance.new("TextLabel")
FOVVal.Size = UDim2.new(0.36, 0, 0, 22)
FOVVal.Position = UDim2.new(0.62, 0, 0, 5)
FOVVal.BackgroundTransparency = 1
FOVVal.Text = "70"
FOVVal.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVVal.Font = Enum.Font.GothamBold
FOVVal.TextScaled = true
FOVVal.TextXAlignment = Enum.TextXAlignment.Right
FOVVal.ZIndex = 6
FOVVal.Parent = FOVBox

local Track = Instance.new("Frame")
Track.Size = UDim2.new(1, -24, 0, 8)
Track.Position = UDim2.new(0, 12, 0, 34)
Track.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
Track.BorderSizePixel = 0
Track.ZIndex = 6
Track.Parent = FOVBox
Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(0.25, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Fill.BorderSizePixel = 0
Fill.ZIndex = 7
Fill.Parent = Track
Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

local Thumb = Instance.new("TextButton")
Thumb.Size = UDim2.new(0, 20, 0, 20)
Thumb.Position = UDim2.new(0.25, -10, 0.5, -10)
Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Thumb.Text = ""
Thumb.BorderSizePixel = 0
Thumb.ZIndex = 8
Thumb.Parent = Track
Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

local FOV_MIN, FOV_MAX = 40, 160
local draggingFOV = false

local function SetFOV(fov)
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = fov end
    local pct = (fov - FOV_MIN) / (FOV_MAX - FOV_MIN)
    Fill.Size = UDim2.new(pct, 0, 1, 0)
    Thumb.Position = UDim2.new(pct, -10, 0.5, -10)
    FOVVal.Text = math.floor(fov) .. ""
end

Thumb.MouseButton1Down:Connect(function() draggingFOV = true end)
UserInputSvc.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingFOV = false end
end)
RunService.RenderStepped:Connect(function()
    if draggingFOV then
        local mx = UserInputSvc:GetMouseLocation().X
        local pct = math.clamp((mx - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        SetFOV(FOV_MIN + pct * (FOV_MAX - FOV_MIN))
    end
end)
SetFOV(70)

-- ============================================
--           STATS BAR
-- ============================================

local StatsBar = Instance.new("Frame")
StatsBar.Size = UDim2.new(0, 298, 0, 46)
StatsBar.Position = UDim2.new(0.5, -149, 0, 372)
StatsBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatsBar.BorderSizePixel = 0
StatsBar.ZIndex = 5
StatsBar.Parent = MainFrame
Instance.new("UICorner", StatsBar).CornerRadius = UDim.new(0, 9)

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0.5, 0, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextScaled = true
FPSLabel.ZIndex = 6
FPSLabel.Parent = StatsBar

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0.5, 0, 1, 0)
PingLabel.Position = UDim2.new(0.5, 0, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "PING: --"
PingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextScaled = true
PingLabel.ZIndex = 6
PingLabel.Parent = StatsBar

local lastT, fc = tick(), 0
RunService.RenderStepped:Connect(function()
    fc += 1
    local now = tick()
    if now - lastT >= 1 then
        FPSLabel.Text = "FPS: " .. math.floor(fc / (now - lastT))
        fc = 0
        lastT = now
    end
end)
RunService.Heartbeat:Connect(function()
    PingLabel.Text = "PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"
end)

-- ============================================
--           REJOIN BUTTON
-- ============================================

local TeleportSvc = game:GetService("TeleportService")

local RejoinBtn = Instance.new("TextButton")
RejoinBtn.Size = UDim2.new(0, 298, 0, 32)
RejoinBtn.Position = UDim2.new(0.5, -149, 0, 428)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
RejoinBtn.BorderSizePixel = 0
RejoinBtn.Text = ""
RejoinBtn.ZIndex = 5
RejoinBtn.Parent = MainFrame
Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0, 9)

local RejoinStroke = Instance.new("UIStroke")
RejoinStroke.Color = Color3.fromRGB(35, 35, 50)
RejoinStroke.Thickness = 1
RejoinStroke.Parent = RejoinBtn

local RejoinLabel = Instance.new("TextLabel")
RejoinLabel.Size = UDim2.new(1, 0, 1, 0)
RejoinLabel.BackgroundTransparency = 1
RejoinLabel.Text = "REJOIN"
RejoinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinLabel.Font = Enum.Font.GothamBold
RejoinLabel.TextScaled = true
RejoinLabel.ZIndex = 6
RejoinLabel.Parent = RejoinBtn

RejoinBtn.MouseEnter:Connect(function()
    TweenService:Create(RejoinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 35)}):Play()
    RejoinStroke.Color = Color3.fromRGB(80, 80, 100)
end)
RejoinBtn.MouseLeave:Connect(function()
    TweenService:Create(RejoinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(8, 8, 10)}):Play()
    RejoinStroke.Color = Color3.fromRGB(35, 35, 50)
end)

local rejoinDelay = 0.8

RejoinBtn.MouseButton1Click:Connect(function()
    RejoinLabel.Text = "JOINING..."
    task.wait(rejoinDelay)
    local placeId = game.PlaceId
    local success, err = pcall(function()
        TeleportSvc:Teleport(placeId, LocalPlayer)
    end)
    if not success then
        RejoinLabel.Text = "ERROR"
        task.wait(1.5)
        RejoinLabel.Text = "REJOIN"
    end
end)

-- Delay 0.1 toggle
local DelayBox = Instance.new("Frame")
DelayBox.Size = UDim2.new(0, 298, 0, 28)
DelayBox.Position = UDim2.new(0.5, -149, 0, 466)
DelayBox.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
DelayBox.BorderSizePixel = 0
DelayBox.ZIndex = 5
DelayBox.Parent = MainFrame
Instance.new("UICorner", DelayBox).CornerRadius = UDim.new(0, 7)
local DelayStroke = Instance.new("UIStroke")
DelayStroke.Color = Color3.fromRGB(35, 35, 50)
DelayStroke.Thickness = 1
DelayStroke.Parent = DelayBox

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0.65, 0, 1, 0)
DelayLabel.Position = UDim2.new(0, 10, 0, 0)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "DELAY  0.1"
DelayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextSize = 11
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.ZIndex = 6
DelayLabel.Parent = DelayBox

local DelayTrack = Instance.new("Frame")
DelayTrack.Size = UDim2.new(0, 38, 0, 18)
DelayTrack.Position = UDim2.new(1, -48, 0.5, -9)
DelayTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
DelayTrack.BorderSizePixel = 0
DelayTrack.ZIndex = 6
DelayTrack.Parent = DelayBox
Instance.new("UICorner", DelayTrack).CornerRadius = UDim.new(1, 0)

local DelayCircle = Instance.new("Frame")
DelayCircle.Size = UDim2.new(0, 14, 0, 14)
DelayCircle.Position = UDim2.new(0, 2, 0.5, -7)
DelayCircle.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
DelayCircle.BorderSizePixel = 0
DelayCircle.ZIndex = 7
DelayCircle.Parent = DelayTrack
Instance.new("UICorner", DelayCircle).CornerRadius = UDim.new(1, 0)

local delayEnabled = false
DelayBox.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        delayEnabled = not delayEnabled
        if delayEnabled then
            rejoinDelay = 0.1
            TweenService:Create(DelayTrack,  TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play()
            TweenService:Create(DelayCircle, TweenInfo.new(0.18), {Position = UDim2.new(0, 22, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            DelayStroke.Color = Color3.fromRGB(100, 100, 130)
            DelayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            rejoinDelay = 0.8
            TweenService:Create(DelayTrack,  TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(45,45,60)}):Play()
            TweenService:Create(DelayCircle, TweenInfo.new(0.18), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(160,160,160)}):Play()
            DelayStroke.Color = Color3.fromRGB(35, 35, 50)
            DelayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
end)

-- ============================================
--           WELCOME NOTIFICATION
-- ============================================

StarterGui:SetCore("SendNotification", {
    Title  = "KMoney Tweaking",
    Text   = "Hub v3 cargado!",
    Duration = 4
})

print("[KMoney Tweaking v3] Hub cargado!")
