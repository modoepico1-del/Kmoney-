local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Evita duplicados
if LocalPlayer:WaitForChild('PlayerGui'):FindFirstChild('DemonTimeGUI') then
    return
end

local bgColor = Color3.fromRGB(0, 0, 0)
local barColor = Color3.fromRGB(5, 5, 5)
local DemonTimeGUI = Instance.new('ScreenGui')
DemonTimeGUI.Name = 'DemonTimeGUI'
DemonTimeGUI.ResetOnSpawn = false
DemonTimeGUI.Parent = LocalPlayer:WaitForChild('PlayerGui')
local Main = Instance.new('Frame')
Main.Name = 'Main'
Main.Size = UDim2.new(0, 300, 0, 680)
Main.Position = UDim2.new(0, 16, 0.5, -340)
Main.BackgroundColor3 = bgColor
Main.BackgroundTransparency = 0
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = DemonTimeGUI
local UICorner = Instance.new('UICorner')
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main
local TitleBar = Instance.new('Frame')
TitleBar.Name = 'TitleBar'
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = barColor
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
local TitleCorner = Instance.new('UICorner')
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar
local TitleFix = Instance.new('Frame')
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = barColor
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar
local TitleLabel = Instance.new('TextLabel')
TitleLabel.Name = 'TitleLabel'
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = 'DemonTime'
TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- 🔴 Rojo
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- ✨ Efecto neón negro
local NeonStroke = Instance.new('UIStroke')
NeonStroke.Color = Color3.fromRGB(0, 0, 0)
NeonStroke.Thickness = 3
NeonStroke.Transparency = 0
NeonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
NeonStroke.Parent = TitleLabel

local Content = Instance.new('Frame')
Content.Name = 'Content'
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = Main
local UIListLayout = Instance.new('UIListLayout')
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Content
