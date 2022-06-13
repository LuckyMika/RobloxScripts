local client = game.Players.LocalPlayer
local players = game:GetService("Players")
local rs = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera

local library = {}
settings = {}

defaultsettings = {
    Visuals = {
        Boxes = false,
        Tracers = false,
        Skeletons = false,
        Healthbars = false,
        Outlines = false,
        Chams = false,
        Names = false,
        Distances = false,
        EquippedWeapons = false
    },
    Colors = {
        BoxEnemyColor = Color3.fromRGB(255,0,0),
        BoxTeamColor = Color3.fromRGB(0,0,255),

        TracersEnemyColor = Color3.fromRGB(255,0,0),
        TracersTeamColor = Color3.fromRGB(0,0,255),

        SkeletonEnemyColor = Color3.fromRGB(255,0,0),
        SkeletonTeamColor = Color3.fromRGB(0,0,255),

        OutlinesEnemyColor = Color3.fromRGB(255,0,0),
        OutlinesTeamColor = Color3.fromRGB(0,0,255),

        ChamsEnemyColor = Color3.fromRGB(255,0,0),
        ChamsTeamColor = Color3.fromRGB(0,0,255),

        NameEnemyColor = Color3.fromRGB(255,0,0),
        NameTeamColor = Color3.fromRGB(0,0,255),

        DistanceEnemyColor = Color3.fromRGB(255,0,0),
        DistanceTeamColor = Color3.fromRGB(0,0,255),

        EquippedWeaponColor = Color3.fromRGB(0,255,0)
    },
    Other = {
        BoxesOutline = false,
        BoxesThickness = 2,
        BoxesTransparency = 1,

        TracerThickness = 1,

        NameTextSize = 10,
        NameTextOutline = false,
        NameFontFamily = Drawing.Fonts["UI"],

        WeaponTextSize = 10,
        WeaponTextOutline = false,
        WeaponFamily = Drawing.Fonts["UI"],
        
        DistanceTextSize = 10,
        DistanceTextOutline = false,
        DistanceFontFamily = Drawing.Fonts["UI"],

        ChamsTransparency = 0
    }
}

function library:Init(options)
    settings = options or library.defaultsettings
end

function library:UpdateSetting(option, value)
    settings.Other[option] = value
    UpdateSettings()
end

function library:UpdateColor(option, value)
    settings.Colors[option] = value
    UpdateSettings()
end

function library:Toggle(option)
    assert(option ~= nil, "This option doesn't exist!")
    settings.Visuals[option] = not settings.Visuals[option]
    UpdateSettings()

end

local drawingshit = {}

function chams(character, friendly)
    if settings.Visuals.Chams then
        local model = Instance.new("Model")
        model.Name = character.Name
        model.Parent = workspace
        local cham = Instance.new("Highlight",model)
        cham.Name = "cham"
        cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        cham.OutlineColor = Color3.fromRGB(0,0,0)
        cham.FillColor = if friendly then settings.Colors.ChamsTeamColor else settings.Colors.ChamsEnemyColor
        cham.FillTransparency = settings.Other.ChamsTransparency
        cham.OutlineTransparency = 1
        local new = cham:Clone()
        new.Parent = character
    
        table.insert(drawingshit[character.Name], cham)
    end

end


local function Dist(pointA, pointB)
    return math.sqrt(math.pow(pointA.X - pointB.X, 2) + math.pow(pointA.Y - pointB.Y, 2))
end

local function GetClosest(points, dest)
    local min  = math.huge
    local closest = nil
    for _,v in pairs(points) do
        local dist = Dist(v, dest)
        if dist < min then
            min = dist
            closest = v
        end
    end
    return closest
end

function AddToRenderList(plr)

    if plr.Character and plr.Character.Head and plr.TeamColor then

        local text = Drawing.new("Text")
        text.Visible = false
        text.Text = plr.Name
        text.Size = settings.Other.NameTextSize
        text.Center = true
        text.Outline = settings.Other.NameTextOutline
        text.Color = if plr.TeamColor == client.TeamColor then settings.Colors.NameTeamColor else settings.Colors.NameEnemyColor
        text.Font = Drawing.Fonts["UI"]

        local Box = Drawing.new("Quad")
        Box.Visible = false
        Box.PointA = Vector2.new(0, 0)
        Box.PointB = Vector2.new(0, 0)
        Box.PointC = Vector2.new(0, 0)
        Box.PointD = Vector2.new(0, 0)
        Box.Color = if plr.TeamColor == client.TeamColor then settings.Colors.BoxTeamColor else settings.Colors.BoxEnemyColor
        Box.Thickness = settings.BoxesThickness
        Box.Transparency = settings.BoxesTransparency

        drawingshit[plr.Name] = {}
        table.insert(drawingshit[plr.Name], text)
        table.insert(drawingshit[plr.Name], Box)
        
        rs:BindToRenderStep(plr.Name .. "Mika Esp", Enum.RenderPriority.Last.Value, function()
            if settings.Visuals.Names then
                local vec, onscreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
                if onscreen then
                    text.Position = Vector2.new(vec.X, vec.Y)
                    text.Visible = true
                end
            else
                text.Visible = false
            end

            if settings.Visuals.Boxes then
                local pos, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    local points = {}
                    local c = 0
                    for _,v in pairs(plr.Character:GetChildren()) do
                        if v:IsA("BasePart") then
                            c = c + 1
                            local p = Camera:WorldToViewportPoint(v.Position)
                            if v.Name == "HumanoidRootPart" then
                                p = Camera:WorldToViewportPoint((v.CFrame * CFrame.new(0, 0, -v.Size.Z)).p)
                            elseif v.Name == "Head" then
                                p = Camera:WorldToViewportPoint((v.CFrame * CFrame.new(0, v.Size.Y/2, v.Size.Z/1.25)).p)
                            elseif string.match(v.Name, "Left") then
                                p = Camera:WorldToViewportPoint((v.CFrame * CFrame.new(-v.Size.X/2, 0, 0)).p)
                            elseif string.match(v.Name, "Right") then
                                p = Camera:WorldToViewportPoint((v.CFrame * CFrame.new(v.Size.X/2, 0, 0)).p)
                            end
                            points[c] = p
                        end
                    end
                    local Left = GetClosest(points, Vector2.new(0, pos.Y))
                    local Right = GetClosest(points, Vector2.new(Camera.ViewportSize.X, pos.Y))
                    local Top = GetClosest(points, Vector2.new(pos.X, 0))
                    local Bottom = GetClosest(points, Vector2.new(pos.X, Camera.ViewportSize.Y))

                    if Left ~= nil and Right ~= nil and Top ~= nil and Bottom ~= nil then
                        Box.PointA = Vector2.new(Right.X, Top.Y)
                        Box.PointB = Vector2.new(Left.X, Top.Y)
                        Box.PointC = Vector2.new(Left.X, Bottom.Y)
                        Box.PointD = Vector2.new(Right.X, Bottom.Y)

                        Box.Visible = true
                    else
                        Box.Visible = false
                    end
                else
                    Box.Visible = false
                end
            end

            for i,v in pairs(drawingshit[plr.Name]) do
                if v:IsA("Highlight") then
                    v.Enabled = settings.Visuals.Chams
                end
            end

        end)
    end
end

function UpdateSettings()
    for i,v in pairs(players:GetPlayers()) do
        RemoveFromRenderList(v)
        AddToRenderList(v)
    end
end

function RemoveFromRenderList(plr)
    rs:UnbindFromRenderStep(plr.Name .. "Mika Esp")

    for i,v in pairs(drawingshit[plr.Name]) do
        if v:IsA("Highlight") then
            v:Destroy()
        else
            v:Remove()
        end
    end
end

for i,v in pairs(players:GetPlayers()) do
    AddToRenderList(v)
end

players.PlayerAdded:Connect(function(player)
    AddToRenderList(player)
end)

players.PlayerRemoving:Connect(function(player)
    RemoveFromRenderList(player)
end)

for i,v in ipairs(players:GetPlayers()) do
    if v~= client then
        if v["Character"] then
            chams(v.Character)
        end
    end
    v.CharacterAdded:Connect(function()
         task.wait(0.1)
         chams(v.Character)
     end)
end
players.PlayerAdded:Connect(function(v)
    if v ~= client then
        if v["Character"] then
            chams(v.Character)
        end
    end
    v.CharacterAdded:Connect(function()
         task.wait(0.1)
         chams(v.Character)
     end)
 end)

return library

