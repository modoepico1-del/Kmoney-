-- Script Hub
-- Empty Template

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Colors
local bgColor = Color3.fromRGB(0, 0, 0)
local accentColor = Color3.fromRGB(10, 10, 10)
local barColor = Color3.fromRGB(5, 5, 5)

-- ScreenGui
local ScriptHubGUI = Instance.new('ScreenGui')
ScriptHubGUI.Name = 'ScriptHubGUI'
ScriptHubGUI.ResetOnSpawn = false
ScriptHubGUI.Parent = LocalPlayer:WaitForChild('PlayerGui')

-- Main Frame
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
Main.Parent = ScriptHubGUI

-- Corner radius
local UICorner = Instance.new('UICorner')
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

-- Title Bar
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

-- Fix bottom corners of title bar
local TitleFix = Instance.new('Frame')
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = barColor
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Title Label
local TitleLabel = Instance.new('TextLabel')
TitleLabel.Name = 'TitleLabel'
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = 'Hub'
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Content area (empty, ready for scripts)
local Content = Instance.new('Frame')
Content.Name = 'Content'
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- Layout for future buttons/toggles
local UIListLayout = Instance.new('UIListLayout')
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Content

-- Empty label placeholder
local EmptyLabel = Instance.new('TextLabel')
EmptyLabel.Size = UDim2.new(1, 0, 0, 30)
EmptyLabel.BackgroundTransparency = 1
EmptyLabel.Text = '-- no scripts loaded --'
EmptyLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
EmptyLabel.TextSize = 13
EmptyLabel.Font = Enum.Font.Gotham
EmptyLabel.Parent = Content
