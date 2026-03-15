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

local CONFIG_FILE = "DEMONTIME_config.json"

local function saveConfig()
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            Unwalk      = unwalkOn,
            Xray        = xrayOn,
            ESP         = espOn,
            AntiRagdoll = antiRagdollEnabled,
            FOV         = fovValue,
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

-- ══════════════════════════════════════
--  TITULO FLOTANTE (reemplaza ToggleBtn)
-- ══════════════════════════════════════

local TitleTag = Instance.new("TextLabel")
TitleTag.Text             = "✦ DEMONTIME ✦"
TitleTag.Size             = UDim2.new(0, 130, 0, 28)
TitleTag.Position         = UDim2.new(0, 10, 0, 10)
TitleTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleTag.TextColor3       = Color3.fromRGB(255, 40, 40)
TitleTag.TextSize         = 12
TitleTag.Font             = Enum.Font.GothamBlack
TitleTag.BorderSizePixel  = 0
TitleTag.ZIndex           = 10
TitleTag.Parent           = ScreenGui
Instance.new("UICorner", TitleTag).CornerRadius = UDim.new(0, 6)

local TitleTagStroke = Instance.new("UIStroke")
TitleTagStroke.Color        = Color3.fromRGB(255, 0, 0)
TitleTagStroke.Thickness    = 1.5
TitleTagStroke.Transparency = 0.0
TitleTagStroke.Parent       = TitleTag

local TitleTagTextStroke = Instance.new("UIStroke")
TitleTagTextStroke.Color        = Color3.fromRGB(0, 0, 0)
TitleTagTextStroke.Thickness    = 3
TitleTagTextStroke.Transparency = 0.0
TitleTagTextStroke.Parent       = TitleTag

-- Glow negro neon
local TitleTagGlow1 = Instance.new("Frame")
TitleTagGlow1.Size                   = UDim2.new(1, 14, 1, 14)
TitleTagGlow1.Position               = UDim2.new(0, -7, 0, -7)
TitleTagGlow1.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
TitleTagGlow1.BackgroundTransparency = 0.35
TitleTagGlow1.BorderSizePixel        = 0
TitleTagGlow1.ZIndex                 = 9
TitleTagGlow1.Parent                 = TitleTag
Instance.new("UICorner", TitleTagGlow1).CornerRadius = UDim.new(0, 10)

local TitleTagGlow2 = Instance.new("Frame")
TitleTagGlow2.Size                   = UDim2.new(1, 8, 1, 8)
TitleTagGlow2.Position               = UDim2.new(0, -4, 0, -4)
TitleTagGlow2.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
TitleTagGlow2.BackgroundTransparency = 0.55
TitleTagGlow2.BorderSizePixel        = 0
TitleTagGlow2.ZIndex                 = 9
TitleTagGlow2.Parent                 = TitleTag
Instance.new("UICorner", TitleTagGlow2).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame")
MainFrame.Size               = UDim2.new(0, 300, 0, 680)
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

local function addNeonBorder(parent, thickness, color)
    local glow = Instance.new("Frame")
    glow.Size                   = UDim2.new(1, thickness*6, 1, thickness*6)
    glow.Position               = UDim2.new(0, -thickness*3, 0, -thickness*3)
    glow.BackgroundColor3       = color
    glow.BackgroundTransparency = 0.72
    glow.BorderSizePixel        = 0
    glow.ZIndex                 = parent.ZIndex - 1
    glow.Parent                 = parent
    Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 14)
    local mid = Instance.new("Frame")
    mid.Size                   = UDim2.new(1, thickness*3, 1, thickness*3)
    mid.Position               = UDim2.new(0, -thickness*1.5, 0, -thickness*1.5)
    mid.BackgroundColor3       = color
    mid.BackgroundTransparency = 0.50
    mid.BorderSizePixel        = 0
    mid.ZIndex                 = parent.ZIndex - 1
    mid.Parent                 = parent
    Instance.new("UICorner", mid).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke")
    stroke.Color           = color
    stroke.Thickness       = thickness
    stroke.Transparency    = 0.0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent          = parent
end

addNeonBorder(MainFrame, 2, Color3.fromRGB(255, 0, 0))

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
TitleLine.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleLine.BorderSizePixel  = 0
TitleLine.ZIndex           = 4
TitleLine.Parent           = TitleBar

local lineGlow = Instance.new("Frame")
lineGlow.Size                   = UDim2.new(1, 0, 0, 8)
lineGlow.Position               = UDim2.new(0, 0, 1, -5)
lineGlow.BackgroundColor3       = Color3.fromRGB(30, 30, 30)
lineGlow.BackgroundTransparency = 0.6
lineGlow.BorderSizePixel        = 0
lineGlow.ZIndex                 = 3
lineGlow.Parent                 = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text                   = "DEMONTIME"
TitleLabel.Size                   = UDim2.new(1, -50, 1, 0)
TitleLabel.Position               = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize               = 17
TitleLabel.Font                   = Enum.Font.GothamBlack
TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
TitleLabel.ZIndex                 = 5
TitleLabel.Parent                 = TitleBar

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color        = Color3.fromRGB(20, 20, 20)
TitleStroke.Thickness    = 4
TitleStroke.Transparency = 0.0
TitleStroke.Parent       = TitleLabel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text              = "X"
CloseBtn.Size              = UDim2.new(0, 28, 0, 28)
CloseBtn.Position          = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
CloseBtn.TextColor3        = Color3.fromRGB(255, 0, 0)
CloseBtn.TextSize          = 13
CloseBtn.Font              = Enum.Font.GothamBlack
CloseBtn.BorderSizePixel   = 0
CloseBtn.ZIndex            = 6
CloseBtn.Parent            = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local CloseBtnStroke = Instance.new("UIStroke")
CloseBtnStroke.Color        = Color3.fromRGB(255, 0, 0)
CloseBtnStroke.Thickness    = 1.2
CloseBtnStroke.Transparency = 0.1
CloseBtnStroke.Parent       = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180,0,0), TextColor3 = Color3.fromRGB(255,255,255)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0,0,0), TextColor3 = Color3.fromRGB(255,0,0)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,300,0,0)}):Play()
    task.delay(0.27, function()
        MainFrame.Visible = false
        MainFrame.Size    = UDim2.new(0,300,0,680)
    end)
end)

local ContentArea = Instance.new("Frame")
ContentArea.Size                   = UDim2.new(1, 0, 1, -170)
ContentArea.Position               = UDim2.new(0, 0, 0, 42)
ContentArea.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
ContentArea.BackgroundTransparency = 0
ContentArea.BorderSizePixel        = 0
ContentArea.ZIndex                 = 3
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
    TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200,0,0)}):Play()
    TweenService:Create(thumb, TweenInfo.new(0.2), {Position = UDim2.new(0,23,0.5,-9), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
    TweenService:Create(lbl,   TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,80,80)}):Play()
end
local function toggleOff(lbl, track, thumb)
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
        Lighting.GlobalShadows = false; Lighting.Brightness = 3; Lighting.FogEnd = 9e9
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false; obj.Material = Enum.Material.Plastic
                end
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
local darkModeObjects = {}
local function startDarkMode()
    darkModeObjects = {}
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            table.insert(darkModeObjects, {removed=true, instance=child, parent=Lighting})
            child.Parent = nil
        end
    end
    local sky = Instance.new("Sky")
    sky.SkyboxBk="rbxassetid://2013298"; sky.SkyboxDn="rbxassetid://2013298"
    sky.SkyboxFt="rbxassetid://2013298"; sky.SkyboxLf="rbxassetid://2013298"
    sky.SkyboxRt="rbxassetid://2013298"; sky.SkyboxUp="rbxassetid://2013298"
    sky.StarCount=0; sky.CelestialBodiesShown=false; sky.Parent=Lighting
    table.insert(darkModeObjects, sky)
    Lighting.FogStart = 10000
end
task.defer(function() task.wait(0.5); startDarkMode() end)
me.CharacterAdded:Connect(function() task.wait(1); startDarkMode() end)

-- ANTI RAGDOLL
local ragdollLabel, ragdollTrack, ragdollThumb = makeOptionRow(ContentArea, "ANTI RAGDOLL", 172)
local RAGDOLL_SPEED           = 16
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
        elseif obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end)
end
local function enableFPSBoost()
    pcall(function()
        Lighting.GlobalShadows=false; Lighting.FogEnd=1000000; Lighting.FogStart=0
        Lighting.EnvironmentDiffuseScale=0; Lighting.EnvironmentSpecularScale=0
    end)
    pcall(function()
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect")
            or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
                v:Destroy()
            end
        end
    end)
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do stripVisuals(obj) end
    end)
    if fpsDescConn then fpsDescConn:Disconnect() end
    fpsDescConn = workspace.DescendantAdded:Connect(stripVisuals)
end
task.defer(function() task.wait(1); enableFPSBoost() end)

-- FOV SLIDER
local FOV_MIN, FOV_MAX = 70, 120

local fovRow = Instance.new("Frame")
fovRow.Size                   = UDim2.new(1, -20, 0, 54)
fovRow.Position               = UDim2.new(0, 10, 1, -118)
fovRow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
fovRow.BackgroundTransparency = 0
fovRow.BorderSizePixel        = 0
fovRow.ZIndex                 = 4
fovRow.Parent                 = MainFrame
Instance.new("UICorner", fovRow).CornerRadius = UDim.new(0, 7)
local fovStroke = Instance.new("UIStroke", fovRow)
fovStroke.Color = Color3.fromRGB(0,0,0); fovStroke.Thickness = 1.5

local SaveFrame = Instance.new("Frame")
SaveFrame.Size=UDim2.new(1,-24,0,40); SaveFrame.Position=UDim2.new(0,12,1,-52)
SaveFrame.BackgroundColor3=Color3.fromRGB(0,0,0); SaveFrame.BackgroundTransparency=0
SaveFrame.BorderSizePixel=0; SaveFrame.ZIndex=6; SaveFrame.Parent=MainFrame
Instance.new("UICorner", SaveFrame).CornerRadius = UDim.new(0,7)
local sfStroke = Instance.new("UIStroke", SaveFrame)
sfStroke.Color=Color3.fromRGB(0,0,0); sfStroke.Thickness=1.5

-- Forzar negro siempre
RS.Heartbeat:Connect(function()
    fovRow.BackgroundColor3            = Color3.fromRGB(0,0,0)
    fovRow.BackgroundTransparency      = 0
    SaveFrame.BackgroundColor3         = Color3.fromRGB(0,0,0)
    SaveFrame.BackgroundTransparency   = 0
    MainFrame.BackgroundColor3         = Color3.fromRGB(0,0,0)
    MainFrame.BackgroundTransparency   = 0
    ContentArea.BackgroundColor3       = Color3.fromRGB(0,0,0)
    ContentArea.BackgroundTransparency = 0
end)

local fovTitleLabel = Instance.new("TextLabel")
fovTitleLabel.Text="FOV"; fovTitleLabel.Size=UDim2.new(0,80,0,20); fovTitleLabel.Position=UDim2.new(0,4,0,2)
fovTitleLabel.BackgroundTransparency=1; fovTitleLabel.TextColor3=Color3.fromRGB(220,220,220)
fovTitleLabel.TextSize=13; fovTitleLabel.Font=Enum.Font.GothamBlack
fovTitleLabel.TextXAlignment=Enum.TextXAlignment.Left; fovTitleLabel.ZIndex=5; fovTitleLabel.Parent=fovRow

local fovValLabel = Instance.new("TextLabel")
fovValLabel.Text=tostring(fovValue); fovValLabel.Size=UDim2.new(0,50,0,20); fovValLabel.Position=UDim2.new(1,-54,0,2)
fovValLabel.BackgroundTransparency=1; fovValLabel.TextColor3=Color3.fromRGB(255,80,80)
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
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size=UDim2.new(1,0,1,0); SaveBtn.BackgroundTransparency=1
SaveBtn.Text="SAVE CONFIG"; SaveBtn.Font=Enum.Font.GothamBlack; SaveBtn.TextSize=13
SaveBtn.TextColor3=Color3.fromRGB(255,80,80); SaveBtn.TextStrokeColor3=Color3.fromRGB(0,0,0)
SaveBtn.TextStrokeTransparency=0; SaveBtn.BorderSizePixel=0; SaveBtn.ZIndex=7; SaveBtn.Parent=SaveFrame
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0,8)
local saveBtnStroke = Instance.new("UIStroke", SaveBtn)
saveBtnStroke.Color=Color3.fromRGB(255,0,0); saveBtnStroke.Thickness=1.5

SaveBtn.MouseEnter:Connect(function() TweenService:Create(SaveBtn,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(255,255,255)}):Play() end)
SaveBtn.MouseLeave:Connect(function() TweenService:Create(SaveBtn,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(255,80,80)}):Play() end)
SaveBtn.MouseButton1Click:Connect(function()
    saveConfig(); SaveBtn.Text="SAVED!"; task.wait(1); SaveBtn.Text="SAVE CONFIG"
end)

-- ANIMACIONES NEON
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(TitleStroke, TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.7}):Play()
        TweenService:Create(TitleLine,   TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0.7}):Play()
        task.wait(1.2)
        TweenService:Create(TitleStroke, TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.0}):Play()
        TweenService:Create(TitleLine,   TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0.0}):Play()
        task.wait(1.2)
    end
end)

-- ANIMACION TITULO FLOTANTE (neon pulsando)
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(TitleTagStroke, TweenInfo.new(1.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Transparency=0.6}):Play()
        TweenService:Create(TitleTag,       TweenInfo.new(1.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {TextColor3=Color3.fromRGB(255,80,80)}):Play()
        TweenService:Create(TitleTagGlow1,  TweenInfo.new(1.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {BackgroundTransparency=0.6}):Play()
        TweenService:Create(TitleTagGlow2,  TweenInfo.new(1.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {BackgroundTransparency=0.75}):Play()
        task.wait(1.0)
        TweenService:Create(TitleTagStroke, TweenInfo.new(1.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Transparency=0.0}):Play()
        TweenService:Create(TitleTag,       TweenInfo.new(1.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {TextColor3=Color3.fromRGB(255,40,40)}):Play()
        TweenService:Create(TitleTagGlow1,  TweenInfo.new(1.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {BackgroundTransparency=0.35}):Play()
        TweenService:Create(TitleTagGlow2,  TweenInfo.new(1.0,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {BackgroundTransparency=0.55}):Play()
        task.wait(1.0)
    end
end)

-- APERTURA
MainFrame.Size = UDim2.new(0,300,0,0)
TweenService:Create(MainFrame, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,300,0,680)}):Play()

-- ANTI LAGBACK
local serverGhosts = {}
local function clearAllGhosts()
    for _, ghost in pairs(serverGhosts) do
        pcall(function() if ghost and ghost.Parent then ghost:Destroy() end end)
    end
    serverGhosts = {}
    pcall(function()
        local pg = me:FindFirstChild("PlayerGui")
        if pg then for _, gui in pairs(pg:GetChildren()) do if gui.Name=="LagbackNotification" then gui:Destroy() end end end
    end)
    pcall(function()
        if workspace.CurrentCamera then
            for _, c in pairs(workspace.CurrentCamera:GetChildren()) do if c.Name=="LagbackGhost" then c:Destroy() end end
        end
        for _, c in pairs(workspace:GetDescendants()) do if c.Name=="LagbackGhost" or c.Name=="LagbackErrorOrb" then c:Destroy() end end
    end)
end
me.CharacterAdded:Connect(function() task.wait(0.5); clearAllGhosts() end)
task.spawn(function() while ScreenGui.Parent do clearAllGhosts(); task.wait(10) end end)

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
end)
