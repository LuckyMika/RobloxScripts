--[[
    Simple Tower of Hell script
    Author: <@387344884559773699>
]]--

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("TITLE", "Synapse")
local Tab = Window:NewTab("Teleportation")
local Section = Tab:NewSection("Wanna see the end?")

Section:NewButton("Teleport", "Teleports you to the end", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").tower.sections.finish.exit.carpet.CFrame * CFrame.new(0,3,0)
end)

Section:NewKeybind("Toggle GUI", "Shows/Hides the GUI", Enum.KeyCode.RightShift, function()
	Library:ToggleUI()
end)
