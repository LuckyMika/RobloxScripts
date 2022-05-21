local char = game.Players.LocalPlayer.Character
local uis = game:GetService("UserInputService")
local flying = false
local cam = workspace.CurrentCamera

local w_pressed = false
local a_pressed = false
local s_pressed = false
local d_pressed = false
local space_pressed = false
local shift_pressed = false

uis.InputBegan:Connect(function (key, chat)
    if chat then return end
    if key.KeyCode == Enum.KeyCode.F then
        if flying then
           flying = false
        else
            flying = true

            local bv = Instance.new("BodyVelocity", char.PrimaryPart)
            bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            bv.Velocity = Vector3.new(0,0,0)
            bv.Name = "FlightVelocity"
            
            repeat task.wait(0.1) until flying == false
            bv:Destroy()
        end
    end

    if key.KeyCode == Enum.KeyCode.W then
        w_pressed = true
    elseif key.KeyCode == Enum.KeyCode.A then
        a_pressed = true
    elseif key.KeyCode == Enum.KeyCode.S then
        s_pressed = true
    elseif key.KeyCode == Enum.KeyCode.D then
        d_pressed = true
    elseif key.KeyCode == Enum.KeyCode.Space then
        space_pressed = true
    elseif key.KeyCode == Enum.KeyCode.LeftShift then
        shift_pressed = true
    end

end)

uis.InputEnded:Connect(function (key)
    if key.KeyCode == Enum.KeyCode.W then
        w_pressed = false
    elseif key.KeyCode == Enum.KeyCode.A then
        a_pressed = false
    elseif key.KeyCode == Enum.KeyCode.S then
        s_pressed = false
    elseif key.KeyCode == Enum.KeyCode.D then
        d_pressed = false
    elseif key.KeyCode == Enum.KeyCode.Space then
        space_pressed = false
    elseif key.KeyCode == Enum.KeyCode.LeftShift then
        shift_pressed = false
    end
end)

while task.wait() do
    if flying then
        char.PrimaryPart:FindFirstChild("FlightVelocity").Velocity = Vector3.new(0,0,0)

        if w_pressed then
            char.PrimaryPart:FindFirstChild("FlightVelocity").Velocity = cam.CFrame.LookVector * Vector3.new(100,0,100)
        end
        if a_pressed then
            char.PrimaryPart:FindFirstChild("FlightVelocity").Velocity = cam.CFrame.RightVector * -100
        end
        if s_pressed then
            char.PrimaryPart:FindFirstChild("FlightVelocity").Velocity = cam.CFrame.LookVector * Vector3.new(-100,0,-100)
        end
        if d_pressed then
            char.PrimaryPart:FindFirstChild("FlightVelocity").Velocity = cam.CFrame.RightVector * 100
        end
        if space_pressed then
            char.PrimaryPart:FindFirstChild("FlightVelocity").Velocity = Vector3.new(0,100,0)
        end
        if shift_pressed then
            char.PrimaryPart:FindFirstChild("FlightVelocity").Velocity = Vector3.new(0,-100,0)
        end

    else
        wait(0.5)
    end

end