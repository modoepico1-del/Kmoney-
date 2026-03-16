-- ══════════════════════════════════════
--  TOP BAR (FPS + PING)
-- ══════════════════════════════════════

local Stats = game:GetService("Stats")

local topBar = Instance.new("Frame")
topBar.Size                   = UDim2.new(0, 240, 0, 32)
topBar.Position               = UDim2.new(0.5, -120, 0, 15)
topBar.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
topBar.BackgroundTransparency = 0
topBar.Parent                 = ScreenGui
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)
local strokeTop = Instance.new("UIStroke", topBar)
strokeTop.Color     = Color3.fromRGB(255, 0, 0)
strokeTop.Thickness = 1.2

local topLabel = Instance.new("TextLabel")
topLabel.Size                 = UDim2.new(1, 0, 1, 0)
topLabel.BackgroundTransparency = 1
topLabel.Font                 = Enum.Font.GothamBlack
topLabel.TextSize             = 13
topLabel.TextColor3           = Color3.fromRGB(255, 0, 0)
topLabel.Parent               = topBar

local fps, framesCount, last = 60, 0, tick()

RunService.RenderStepped:Connect(function()
    framesCount += 1
    if tick() - last >= 1 then
        fps = framesCount
        framesCount = 0
        last = tick()
    end
    local ping = 0
    local network = Stats:FindFirstChild("Network")
    if network and network:FindFirstChild("ServerStatsItem") then
        local dataPing = network.ServerStatsItem:FindFirstChild("Data Ping")
        if dataPing then ping = math.floor(dataPing:GetValue()) end
    end
    topLabel.Text = "$KMONEY HUB  |  " .. fps .. " FPS  |  " .. ping .. " ms"
end)

RS.Heartbeat:Connect(function()
    topBar.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    topBar.BackgroundTransparency = 0
end)
