local cpFolder = game.Workspace.Checkpoints
local level = game.Players.LocalPlayer.leaderstats.Stage


local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Obby Gui", "Sentinel")
local Tab = Window:NewTab("Teleportation")
local Section = Tab:NewSection("Wanna see the end?")


getgenv().autoFarm = false

Section:NewButton("Next Level", "Teleports you to the next level", function ()
    print(level.Value)
    if level.Value == "200" then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").RestartPortal.Portal.CFrame
        wait()
        local Event = game:GetService("ReplicatedStorage").Remotes.ToServer.RestartPlayer
        Event:FireServer()
    else
        local newLevel = level.Value + 1
        local cp = cpFolder[newLevel]
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0,3,0)
    end
end)

Section:NewToggle("Auto Farm", "Auto completes all the levels", function (b)
    getgenv().autoFarm = b
    spawn(autoFarm)
end)

function autoFarm()
    while getgenv().autoFarm do
        if level.Value == "200" then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").RestartPortal.Portal.CFrame
            wait()
            local Event = game:GetService("ReplicatedStorage").Remotes.ToServer.RestartPlayer
            Event:FireServer()
        else
            local newLevel = level.Value + 1
            local cp = cpFolder[newLevel]
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0,3,0)
            wait(0.5)
        end
    end
end
