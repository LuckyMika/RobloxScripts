-- Author: LuckyMika#6727
-- Usage: place:
--
--              local cpFolder = game.Workspace.Checkpoints
--              local level = game.Players.LocalPlayer.leaderstats.Stage
--
-- in your script and then load the following code with loadstring.
--
-- If you need more help, message me on discord.

local cpFolder = game.Workspace.Checkpoints
local level = game.Players.LocalPlayer.leaderstats.Stage
if cpFolder == nil and level == nil then
    game.Players.LocalPlayer:Kick("You didn't provide the Checkpoint Folder or Level")
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Obby Gui", "Sentinel")
local Tab = Window:NewTab("Teleportation")
local Section = Tab:NewSection("Wanna see the end?")

getgenv().autoFarm = false

Section:NewButton("Next Level", "Teleports you to the next level", function ()
        local newLevel = level.Value + 1
        local cp = cpFolder[newLevel]
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0,3,0)
end)

Section:NewToggle("Auto Complete", "Auto completes all the levels for you", function (b)
    getgenv().autoFarm = b
    spawn(autoFarm)
end)

function autoFarm()
    while getgenv().autoFarm do
            local newLevel = level.Value + 1
            local cp = cpFolder[newLevel]
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0,3,0)
            wait(0.5)
    end
end