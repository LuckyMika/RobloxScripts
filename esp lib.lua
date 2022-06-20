local LocalPlayer = game.Players.LocalPlayer
local players = game:GetService("Players")
local rs = game:GetService("RunService")
local Camera = workspace.CurrentCamera
-- Phantom Forces sucks i wanna kms

local utility = {}

animations = {}

-- Framework
getgenv().client = {};
do
    local gc = getgc(true)  
    for i = #gc, 1, -1 do
        local v = gc[i]
        local type = type(v)
        if type == 'function' then
            if debug.getinfo(v).name == "loadmodules" then
                client.loadmodules = v
            end
        end
        if type == "table" then
            if (rawget(v, 'send')) then
                client.network = v
            elseif (rawget(v, 'basecframe')) then
                client.camera = v
            elseif (rawget(v, "gammo")) then
                client.gamelogic = v
            elseif (rawget(v, "getbodyparts")) then
                client.replication = v
                client.replication.bodyparts = debug.getupvalue(client.replication.getbodyparts, 1)
            elseif (rawget(v, "updateammo")) then
                client.hud = v
            elseif (rawget(v, "setbasewalkspeed")) then
                client.char = v
            elseif (rawget(v, "getscale")) then
                client.uiscaler = v
            end
            if rawget(v, 'player') then
                table.insert(animations, v)
            end

            
        end
    end
end


function utility:IsAlive(player)
    if client.replication.bodyparts[player] and client.replication.bodyparts[player].head then
        return true
    end
    return false
end

function utility:GetHealth(Player)
    return client.hud:getplayerhealth(Player)
end

function utility:GetCharacter(Player)
    local Character = client.replication.getbodyparts(Player)

    return Character and Character.torso.Parent, Character and Character.torso
end

function utility:GetBodypart(Player, Part)
    local success, result = pcall(function()
        return client.replication.bodyparts[Player][Part:lower()]
    end)
    if success then
        return result
    else
        return nil
    end
end

function utility:getposlist2(list)
    local top = math.huge
    local bottom = -math.huge
    local right = -math.huge
    local left = math.huge

    for i, v in pairs(list) do
        top = (top > v.Y) and v.Y or top
        bottom = (bottom < v.Y) and v.Y or bottom
        left = (left > v.X) and v.X or left
        right = (right < v.X) and v.X or right
    end

    return {
        pos = {
            topLeft = Vector2.new(left, top),
            topRight = Vector2.new(right, top),
            bottomLeft = Vector2.new(left, bottom),
            middle = Vector2.new((right - left) / 2 + left, (bottom - top) / 2 + top),
            bottomRight = Vector2.new(right, bottom)
        },
        quad = {
            PointA = Vector2.new(right, top),
            PointB = Vector2.new(left, top),
            PointC = Vector2.new(left, bottom),
            PointD = Vector2.new(right, bottom)
        }
    }
end

function utility:wtvp(p) -- vector
    p = workspace.CurrentCamera:WorldToViewportPoint(p)
    return Vector2.new(p.X, p.Y), p.Z
end 

function utility:get2dcorner(cf, s)
    local Top = s.Y / 2
    local Bottom = -s.Y / 2
    local Front = -s.Z / 2
    local Back = s.Z / 2
    local Left = -s.X / 2
    local Right = s.X / 2

    return {
        LeftTopFront = utility:wtvp((cf * CFrame.new(Vector3.new(Left, Top, Front))).Position),
        RightTopFront = utility:wtvp((cf * CFrame.new(Vector3.new(Right, Top, Front))).Position),
        LeftBottomFront = utility:wtvp((cf * CFrame.new(Vector3.new(Left, Bottom, Front))).Position),
        RightBottomFront = utility:wtvp((cf * CFrame.new(Vector3.new(Right, Bottom, Front))).Position),
        LeftTopBack = utility:wtvp((cf * CFrame.new(Vector3.new(Left, Top, Back))).Position),
        RightTopBack = utility:wtvp((cf * CFrame.new(Vector3.new(Right, Top, Back))).Position),
        LeftBottomBack = utility:wtvp((cf * CFrame.new(Vector3.new(Left, Bottom, Back))).Position),
        RightBottomBack = utility:wtvp((cf * CFrame.new(Vector3.new(Right, Bottom, Back))).Position)
    }
end

function utility:GetBoundingBox(Character)
    local Data = {}

    for i,v in pairs(Character:GetChildren()) do
        if (v:IsA("BasePart") and v.Name ~= "HumanoidRootPart") then
            for i2, v2 in pairs(utility:get2dcorner(v.CFrame, v.Size)) do
                table.insert(Data, v2)
            end
        end
    end

    return utility:getposlist2(Data)
end

local library = {}
esp_settings = {}
initialized = false
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
        Weapons = false
    },
    Teams = {
        Boxes = true,
        Tracers = true,
        Skeletons = true,
        Healthbars = true,
        Outlines = true,
        Chams = true,
        Names = true,
        Distances = true
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
        
        WeaponColor = Color3.fromRGB(0,255,0),
        HealthbarFullColor = Color3.fromRGB(0,255,0),
        HealthbarEmptyColor = Color3.fromRGB(255,0,0)
    },
    Other = {
        BoxesOutline = false,
        BoxesThickness = 1,
        BoxesTransparency = 1,
        
        TracerThickness = 1,
        TracerTransparency = 0.5,
        TracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
        TracerPart = "head",
        
        NameTextSize = 15,
        NameTextOutline = false,
        NameFontFamily = Drawing.Fonts["UI"],
        
        WeaponTextSize = 15,
        WeaponTextOutline = false,
        WeaponFontFamily = Drawing.Fonts["UI"],
        
        SkeletonThickness = 1,
        SkeletonTransparency = 0,

        DistanceTextSize = 15,
        DistanceTextOutline = false,
        DistanceFontFamily = Drawing.Fonts["UI"],
        
        ChamsTransparency = 0,
        
        OutlinesTransparency = 0,

        HealthbarOffset = 10
    }
}

function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end
function find2d(table, result)
    for i,v in pairs(table) do
        if v == result then
            return i
        end
    end
end

function getpos(pos)
    return Vector2.new(pos.X, pos.Y)
end

function removekey(t, key)
    local element = t[key]
    t[key] = nil
    return element
end

function library:Init(options)
    assert(initialized == false, "You can't initialize twice!")
    esp_settings = defaultsettings
    initialized = true
end

function library:UpdateSetting(option, value)
    assert(esp_settings.Other[option] ~= nil, "This option doesn't exist!")
    esp_settings.Other[option] = value
    UpdateSettings()
end

function library:UpdateColor(option, value)
    assert(esp_settings.Colors[option] ~= nil, "This option doesn't exist!")
    esp_settings.Colors[option] = value
    UpdateSettings()
end

function library:ToggleTeamcheck(option, value)
    assert(esp_settings.Teams[option] ~= nil, "This option doesn't exist!")
    assert(typeof(value) == "boolean", tostring(value) .. " is not a boolean!")
    esp_settings.Teams[option] = value
    UpdateSettings()
end

function library:Toggle(option, value)
    assert(esp_settings.Visuals[option] ~= nil, "This option doesn't exist!")
    assert(typeof(value) == "boolean", tostring(value) .. " is not a boolean!")
    esp_settings.Visuals[option] = value
    UpdateSettings()
end

local drawingshit = {}

function chams(plr, friendly)
    local character = utility:GetCharacter(plr)
    local cham = Instance.new("Highlight",character)
    cham.Enabled = false
    cham.Name = "cham"
    cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    cham.OutlineColor = Color3.fromRGB(0,0,0)
    cham.FillColor = friendly and esp_settings.Colors.ChamsTeamColor or esp_settings.Colors.ChamsEnemyColor
    cham.FillTransparency = esp_settings.Other.ChamsTransparency
    cham.OutlineTransparency = 1

    table.insert(drawingshit[plr.Name], cham)

end

function outlines(plr, friendly)
    local character = utility:GetCharacter(plr)
    local outline = Instance.new("Highlight",character)
    outline.Enabled = false
    outline.Name = "outline"
    outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    outline.FillColor = Color3.fromRGB(0,0,0)
    outline.OutlineColor = friendly and esp_settings.Colors.OutlinesTeamColor or esp_settings.Colors.OutlinesEnemyColor
    outline.OutlineTransparency = esp_settings.Other.OutlinesTransparency
    outline.FillTransparency = 1
    
    table.insert(drawingshit[plr.Name], outline)
end

function AddToRenderList(plr)

    if plr ~= LocalPlayer then

        drawingshit[plr.Name] = {}

        local name = Drawing.new("Text")
        name.Visible = false
        name.Text = plr.Name
        name.Size = esp_settings.Other.NameTextSize
        name.Center = true
        name.Outline = esp_settings.Other.NameTextOutline
        name.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.NameTeamColor or esp_settings.Colors.NameEnemyColor
        name.Font = esp_settings.Other.NameFontFamily

        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.BoxTeamColor or esp_settings.Colors.BoxEnemyColor
        box.Thickness = esp_settings.Other.BoxesThickness
        box.Transparency = esp_settings.Other.BoxesTransparency

        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.From = esp_settings.Other.TracerOrigin
        tracer.To = Vector2.new(0,0)
        tracer.Thickness = esp_settings.Other.TracerThickness
        tracer.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.TracersTeamColor or esp_settings.Colors.TracersEnemyColor
        tracer.Transparency = esp_settings.Other.TracerTransparency

        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Size = esp_settings.Other.DistanceTextSize
        distance.Center = true
        distance.Outline = esp_settings.Other.DistanceTextOutline
        distance.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.DistanceTeamColor or esp_settings.Colors.DistanceEnemyColor
        distance.Font = esp_settings.Other.DistanceFontFamily

        local healthbar = Drawing.new("Square")
        healthbar.Visible = false
        healthbar.Filled = true
        healthbar.Color = esp_settings.Colors.HealthbarEmptyColor:lerp(esp_settings.Colors.HealthbarFullColor, utility:GetHealth(plr)/100);

        local drawtable = {}

            drawtable.headline = Drawing.new("Line")
            drawtable.headline.Visible = false
            drawtable.headline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.headline.Thickness = 1.5
            drawtable.headline.Transparency = 1


            drawtable.torsoline = Drawing.new("Line")
            drawtable.torsoline.Visible = false
            drawtable.torsoline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.torsoline.Thickness = 1.5
            drawtable.torsoline.Transparency = 1


            drawtable.leftarmline = Drawing.new("Line")
            drawtable.leftarmline.Visible = false
            drawtable.leftarmline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.leftarmline.Thickness = 1.5
            drawtable.leftarmline.Transparency = 1


            drawtable.rightarmline = Drawing.new("Line")
            drawtable.rightarmline.Visible = false
            drawtable.rightarmline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.rightarmline.Thickness = 1.5
            drawtable.rightarmline.Transparency = 1


            drawtable.leftlegline = Drawing.new("Line")
            drawtable.leftlegline.Visible = false
            drawtable.leftlegline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.leftlegline.Thickness = 1.5
            drawtable.leftlegline.Transparency = 1


            drawtable.rightlegline = Drawing.new("Line")
            drawtable.rightlegline.Visible = false
            drawtable.rightlegline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.rightlegline.Thickness = 1.5
            drawtable.rightlegline.Transparency = 1

            drawtable.leftupperconnector = Drawing.new("Line")
            drawtable.leftupperconnector.Visible = false
            drawtable.leftupperconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.leftupperconnector.Thickness = 1.5
            drawtable.leftupperconnector.Transparency = 1

            drawtable.rightupperconnector = Drawing.new("Line")
            drawtable.rightupperconnector.Visible = false
            drawtable.rightupperconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.rightupperconnector.Thickness = 1.5
            drawtable.rightupperconnector.Transparency = 1

            drawtable.leftlowerconnector = Drawing.new("Line")
            drawtable.leftlowerconnector.Visible = false
            drawtable.leftlowerconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.leftlowerconnector.Thickness = 1.5
            drawtable.leftlowerconnector.Transparency = 1
            
            drawtable.rightlowerconnector = Drawing.new("Line")
            drawtable.rightlowerconnector.Visible = false
            drawtable.rightlowerconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Colors.SkeletonTeamColor or esp_settings.Colors.SkeletonEnemyColor
            drawtable.rightlowerconnector.Thickness = 1.5
            drawtable.rightlowerconnector.Transparency = 1

            table.insert(drawingshit[plr.Name], drawtable.headline)
            table.insert(drawingshit[plr.Name], drawtable.torsoline)
            table.insert(drawingshit[plr.Name], drawtable.leftarmline)
            table.insert(drawingshit[plr.Name], drawtable.rightarmline)
            table.insert(drawingshit[plr.Name], drawtable.leftlegline)
            table.insert(drawingshit[plr.Name], drawtable.rightlegline)
            table.insert(drawingshit[plr.Name], drawtable.leftupperconnector)
            table.insert(drawingshit[plr.Name], drawtable.rightupperconnector)
            table.insert(drawingshit[plr.Name], drawtable.leftlowerconnector)
            table.insert(drawingshit[plr.Name], drawtable.rightlowerconnector)
        --end

        table.insert(drawingshit[plr.Name], name)
        table.insert(drawingshit[plr.Name], box)
        table.insert(drawingshit[plr.Name], tracer)
        table.insert(drawingshit[plr.Name], distance)
        table.insert(drawingshit[plr.Name], healthbar)

        rs:BindToRenderStep(plr.Name .. "Mika Esp", Enum.RenderPriority.Last.Value, function()

            if esp_settings.Visuals.Tracers then
                if utility:IsAlive(plr) then
                    assert(utility:GetBodypart(plr, esp_settings.Other.TracerPart) ~= nil, "`" .. esp_settings.Other.TracerPart .. "` Doesn't exist in `" .. plr.Name .. ".Character`!")
                    local vec, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, esp_settings.Other.TracerPart).Position)
                    if onscreen then
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Tracers then
                                tracer.To = Vector2.new(vec.X, vec.Y)
                                tracer.Color = esp_settings.Colors.TracersTeamColor
                                tracer.Visible = true
                            end
                        else
                            tracer.To = Vector2.new(vec.X, vec.Y)
                            tracer.Color = esp_settings.Colors.TracersEnemyColor
                            tracer.Visible = true
                        end
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            end

            if esp_settings.Visuals.Boxes then
                if utility:IsAlive(plr) then
                    local data = utility:GetBoundingBox(utility:GetCharacter(plr))
                    local boxpos = Vector2.new(math.floor(data.pos.bottomRight.X), math.floor(data.pos.bottomRight.Y))
                    local Width, Height = math.floor(data.pos.topLeft.X - data.pos.topRight.X), math.floor(data.pos.topLeft.Y - data.pos.bottomLeft.Y)
                    local boxsize = Vector2.new(Width, Height)
                    local pos, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "torso").Position)
                    if onscreen then
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Boxes then
                                box.Size = boxsize
                                box.Position = boxpos
                                box.Color = esp_settings.Colors.BoxTeamColor
                                box.Visible = true
                            end
                        else
                            box.Size = boxsize
                            box.Position = boxpos
                            box.Color = esp_settings.Colors.BoxEnemyColor
                            box.Visible = true
                        end
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            end

            if esp_settings.Visuals.Skeletons then
                if utility:IsAlive(plr) then
                    local Vector, onScreen = Camera:worldToViewportPoint(utility:GetBodypart(plr, "torso").Position)
    
                    drawtable.headline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Head").Position)) -- Head
                    drawtable.torsoline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- Upper Torso
                    drawtable.leftarmline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "larm").Position + Vector3.new(0,-1,0))) -- LowerLeftArm
                    drawtable.rightarmline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rarm").Position + Vector3.new(0,-1,0))) -- LowerRightarm
                    drawtable.leftlegline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "lleg").Position + Vector3.new(0,-1,0))) -- LowerLeftLeg
                    drawtable.rightlegline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rleg").Position + Vector3.new(0,-1,0))) -- LowerRightLeg

                    drawtable.leftupperconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "larm").Position + Vector3.new(0,1,0))) -- UpperLeftArm
                    drawtable.rightupperconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rarm").Position + Vector3.new(0,1,0))) -- UpperRightArm

                    drawtable.leftlowerconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "lleg").Position + Vector3.new(0,1,0))) -- UpperLeftLeg
                    drawtable.rightlowerconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rleg").Position + Vector3.new(0,1,0))) -- UpperRightLeg

                    drawtable.headline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- Upper Torso
                    drawtable.torsoline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0))) -- Lower Torso
                    drawtable.leftarmline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "larm").Position + Vector3.new(0,1,0))) -- UpperLeftArm
                    drawtable.rightarmline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rarm").Position + Vector3.new(0,1,0))) -- UpperRightArm
                    drawtable.leftlegline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "lleg").Position + Vector3.new(0,1,0))) -- UpperLeftLeg
                    drawtable.rightlegline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rleg").Position + Vector3.new(0,1,0))) -- UpperRightLeg

                    drawtable.leftupperconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- UpperTorso
                    drawtable.rightupperconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- UpperTorso

                    drawtable.leftlowerconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0))) -- LowerTorso
                    drawtable.rightlowerconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0))) -- LowerTorso

                    if onScreen then
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Skeletons then
                                drawtable.headline.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.headline.Visible = true

                                drawtable.torsoline.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.torsoline.Visible = true

                                drawtable.leftarmline.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.leftarmline.Visible = true

                                drawtable.rightarmline.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.rightarmline.Visible = true

                                drawtable.leftlegline.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.leftlegline.Visible = true

                                drawtable.rightlegline.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.rightlegline.Visible = true

                                drawtable.leftupperconnector.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.leftupperconnector.Visible = true

                                drawtable.rightupperconnector.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.rightupperconnector.Visible = true

                                drawtable.leftlowerconnector.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.leftlowerconnector.Visible = true

                                drawtable.rightlowerconnector.Color = esp_settings.Colors.SkeletonTeamColor
                                drawtable.rightlowerconnector.Visible = true
                            end
                        else
                            drawtable.headline.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.headline.Visible = true

                                drawtable.torsoline.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.torsoline.Visible = true

                                drawtable.leftarmline.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.leftarmline.Visible = true

                                drawtable.rightarmline.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.rightarmline.Visible = true

                                drawtable.leftlegline.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.leftlegline.Visible = true

                                drawtable.rightlegline.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.rightlegline.Visible = true

                                drawtable.leftupperconnector.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.leftupperconnector.Visible = true

                                drawtable.rightupperconnector.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.rightupperconnector.Visible = true

                                drawtable.leftlowerconnector.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.leftlowerconnector.Visible = true

                                drawtable.rightlowerconnector.Color = esp_settings.Colors.SkeletonEnemyColor
                                drawtable.rightlowerconnector.Visible = true
                        end

                    else
                        drawtable.headline.Visible = false
                        drawtable.torsoline.Visible = false
                        drawtable.leftarmline.Visible = false
                        drawtable.rightarmline.Visible = false
                        drawtable.leftlegline.Visible = false
                        drawtable.rightlegline.Visible = false

                        drawtable.leftupperconnector.Visible = false
                        drawtable.rightupperconnector.Visible = false
                        drawtable.leftlowerconnector.Visible = false
                        drawtable.rightlowerconnector.Visible = false
                    end
                else
                    drawtable.headline.Visible = false
                    drawtable.torsoline.Visible = false
                    drawtable.leftarmline.Visible = false
                    drawtable.rightarmline.Visible = false
                    drawtable.leftlegline.Visible = false
                    drawtable.rightlegline.Visible = false

                    drawtable.leftupperconnector.Visible = false
                    drawtable.rightupperconnector.Visible = false
                    drawtable.leftlowerconnector.Visible = false
                    drawtable.rightlowerconnector.Visible = false
                end
            else
                drawtable.headline.Visible = false
                drawtable.torsoline.Visible = false
                drawtable.leftarmline.Visible = false
                drawtable.rightarmline.Visible = false
                drawtable.leftlegline.Visible = false
                drawtable.rightlegline.Visible = false

                drawtable.leftupperconnector.Visible = false
                drawtable.rightupperconnector.Visible = false
                drawtable.leftlowerconnector.Visible = false
                drawtable.rightlowerconnector.Visible = false
            end
            --end

            if esp_settings.Visuals.Names then
                if utility:IsAlive(plr) then
                    local vec, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "head").Position)
                    if onscreen then
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Names then
                                name.Position = Vector2.new(vec.X, vec.Y)
                                name.Color = esp_settings.Colors.NameTeamColor
                                name.Visible = true
                            end
                        else
                            name.Position = Vector2.new(vec.X, vec.Y)
                            name.Color = esp_settings.Colors.NameEnemyColor
                            name.Visible = true
                        end
                        
                    else
                        name.Visible = false
                    end
                else
                    name.Visible = false
                end
            end

            if esp_settings.Visuals.Distances then
                if utility:IsAlive(plr) then
                    local vec, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "head").Position)
                    if onscreen then
                        distance.Position = Vector2.new(vec.X, vec.Y)
                        while LocalPlayer.Character == nil do
                            task.wait(0.5)
                        end

                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Distances then
                                distance.Text = tostring(round((LocalPlayer.Character.Head.Position - utility:GetBodypart(plr, "head").Position).magnitude)) .. "Studs"
                                distance.Color = esp_settings.Colors.DistanceTeamColor
                                distance.Visible = true
                            end
                        else
                            distance.Text = tostring(round((LocalPlayer.Character.Head.Position - utility:GetBodypart(plr, "head").Position).magnitude)) .. "Studs"
                            distance.Color = esp_settings.Colors.DistanceEnemyColor
                            distance.Visible = true
                        end
                    else
                        distance.Visible = false
                    end
                else
                    distance.Visible = false
                end
            end

            if esp_settings.Visuals.Healthbars then
                if utility:IsAlive(plr) and utility:GetBodypart(plr, "torso") ~= nil then

                    local Health, MaxHealth = utility:GetHealth(plr)
                    local data = utility:GetBoundingBox(utility:GetCharacter(plr))
                    local Width, Height = math.floor(data.pos.topLeft.X - data.pos.topRight.X), math.floor(data.pos.topLeft.Y - data.pos.bottomLeft.Y)
                
                    local BoxSize = Vector2.new(Width, Height)

                    local healthsize = Vector2.new(2, math.floor(BoxSize.Y * (Health / MaxHealth)))
                    local healthpos = Vector2.new(math.floor(data.pos.topLeft.X - ((4 + esp_settings.Other.HealthbarOffset))), math.floor(data.pos.bottomLeft.Y))
                
                    local pos, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "torso").Position)
                    if onscreen then

                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Healthbars then
                                healthbar.Size = healthsize
                                healthbar.Position = healthpos
                                healthbar.Color = esp_settings.Colors.HealthbarEmptyColor:lerp(esp_settings.Colors.HealthbarFullColor, utility:GetHealth(plr)/100);
                                healthbar.Visible = true
                            end
                        else
                            healthbar.Size = healthsize
                            healthbar.Position = healthpos
                            healthbar.Color = esp_settings.Colors.HealthbarEmptyColor:lerp(esp_settings.Colors.HealthbarFullColor, utility:GetHealth(plr)/100);
                            healthbar.Visible = true
                        end
                    else
                        healthbar.Visible = false
                    end
                else
                    healthbar.Visible = false
                end
            end

            if esp_settings.Visuals.Chams then
                if utility:IsAlive(plr) then
                    local character = utility:GetCharacter(plr)
                    if character:FindFirstChild("cham") then
                        if character:FindFirstChild("outline") then
                            character:FindFirstChild("outline"):Destroy()
                        end
                        character:FindFirstChild("cham").Enabled = true
                    else
                        if character:FindFirstChild("outline") then
                            character:FindFirstChild("outline"):Destroy()
                        end

                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Chams then
                                chams(plr, plr.TeamColor == LocalPlayer.TeamColor)
                            end
                        else
                            chams(plr, false)
                        end
                    end
                end
            end

            if esp_settings.Visuals.Outlines then
                if utility:IsAlive(plr) then
                    local character = utility:GetCharacter(plr)
                    if character:FindFirstChild("outline") then
                        if character:FindFirstChild("cham") then
                            character:FindFirstChild("cham"):Destroy()
                        end
                        character:FindFirstChild("outline").Enabled = true
                    else
                        if character:FindFirstChild("cham") then
                            character:FindFirstChild("cham"):Destroy()
                        end
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Teams.Outlines then
                                outlines(plr, plr.TeamColor == LocalPlayer.TeamColor)
                            end
                        else
                            outlines(plr, false)
                        end
                    end
                end
            end

        end)
    end
end
local idtable = {}
local weapontable = {}
local counter = 0

function UpdateSettings()
    for i,v in pairs(players:GetPlayers()) do
        RemoveFromRenderList(v)
        AddToRenderList(v)
    end
    for i,v in pairs(weapontable) do
        if v then
            v.Size = esp_settings.Other.WeaponTextSize
            v.Font = esp_settings.Other.WeaponFontFamily
            v.Outline = esp_settings.Other.WeaponTextOutline
            v.Color = esp_settings.Colors.WeaponColor
        end
    end
end

function RemoveFromRenderList(plr)
    if plr ~= LocalPlayer then
        rs:UnbindFromRenderStep(plr.Name .. "Mika Esp")
        if drawingshit[plr.Name] ~= nil then
            for i,v in pairs(drawingshit[plr.Name]) do
                removekey(drawingshit[plr.Name], find2d(drawingshit[plr.Name], v))
                if typeof(v) == "Instance" and v.ClassName == "Highlight" then
                    v:Destroy()
                else
                    v:Remove()
                end
            end
        end
    end
end



function AddWeaponsToRenderList(gun)
    counter += 1
    idtable[gun] = tostring(counter)

    local text = Drawing.new("Text")
    text.Visible = false
    text.Text = gun.Gun.Value
    text.Color = esp_settings.Colors.WeaponColor
    text.Size = esp_settings.Other.WeaponTextSize
    text.Font = esp_settings.Other.WeaponFontFamily
    text.Outline = esp_settings.Other.WeaponTextOutline

    weapontable[gun] = text


    rs:BindToRenderStep(tostring(counter) .. "WeaponEsp", Enum.RenderPriority.Last.Value, function()
        if esp_settings.Visuals.Weapons then
            local pos, onscreen = Camera:WorldToViewportPoint(gun.Slot1.Position)
            if onscreen then
                text.Position = Vector2.new(pos.X, pos.Y)
                text.Visible = true
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end)
end


function RemoveWeaponFromRenderList(gun)
    rs:UnbindFromRenderStep(tostring(idtable[gun]) .. "WeaponEsp")
    if weapontable[gun] ~= nil then
        weapontable[gun]:Remove()
        weapontable[gun] = nil
    end
end





task.spawn(function()
    while not initialized do
        task.wait(0.5)
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

    for i,v in pairs(game:GetService("Workspace").Ignore.GunDrop:GetChildren()) do
        if v.Name == "Dropped" and v:FindFirstChild("Gun") then
            AddWeaponsToRenderList(v)
        end
    end
    game:GetService("Workspace").Ignore.GunDrop.ChildAdded:Connect(function(gun)
        if gun.Name == "Dropped" and gun:WaitForChild("Gun", 5) then
            AddWeaponsToRenderList(gun)
        end
    end)
    
    game:GetService("Workspace").Ignore.GunDrop.ChildRemoved:Connect(function(gun)
        RemoveWeaponFromRenderList(gun)
    end)
end)

return library
