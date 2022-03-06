-- Author: Me (ShortMika)
-- Game Link: https://www.roblox.com/games/5276547532/Hard-Obby-320-Levels

local cpFolder = game.Workspace.Checkpoints
local level = game.Players.LocalPlayer.leaderstats.Level
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Indicator = Instance.new("TextButton", ScreenGui)
local Indicator2 = Instance.new("TextButton", ScreenGui)
local loop = false

Indicator.Text = "Next Level"
Indicator.AnchorPoint = Vector2.new(0, 1)
Indicator.Position = UDim2.new(0, 0, 1, 0)
Indicator.Size = UDim2.new(0, 200, 0, 50)
Indicator.BackgroundTransparency = 1
Indicator.TextScaled = true
Indicator.TextStrokeTransparency = 0
Indicator.TextColor3 = Color3.new(0, 0, 0)
Indicator.TextStrokeColor3 = Color3.new(1, 1, 1)

Indicator2.Text = "Loop: OFF"
Indicator2.AnchorPoint = Vector2.new(0, 1)
Indicator2.Position = UDim2.new(0, 0, 0.9, 0)
Indicator2.Size = UDim2.new(0, 200, 0, 50)
Indicator2.BackgroundTransparency = 1
Indicator2.TextScaled = true
Indicator2.TextStrokeTransparency = 0
Indicator2.TextColor3 = Color3.new(0, 0, 0)
Indicator2.TextStrokeColor3 = Color3.new(1, 1, 1)

Indicator.Activated:Connect(
function()

local newLevel = level.Value + 1
local cp = cpFolder[newLevel]

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0,3,0)

end)

Indicator2.Activated:Connect(
function()
loop = not loop
while loop do
        
    local newLevel = level.Value + 1
    local cp = cpFolder[newLevel]
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0,3,0)
    wait(3)
end




end)
