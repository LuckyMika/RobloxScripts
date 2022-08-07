---------------------------------------------
--             VERSION 1.2.7               --
---------------------------------------------

local LocalPlayer = game.Players.LocalPlayer
local players = game.Players
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
        if type == "table" then
            if (rawget(v, "getbodyparts")) then
                client.replication = v
                client.replication.bodyparts = debug.getupvalue(client.replication.getbodyparts, 1)
            elseif (rawget(v, "updateammo")) then
                client.hud = v
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
    Boxes = {
        Toggled = false,
        Teamcheck = true,
        EnemyColor = Color3.fromRGB(255,0,0),
        TeamColor = Color3.fromRGB(0,0,255),
        Outline = false,
        Thickness = 1,
        Transparency = 1
    },

    Tracers = {
        Toggled = false,
        Teamcheck = true,
        EnemyColor = Color3.fromRGB(255,0,0),
        TeamColor = Color3.fromRGB(0,0,255),
        Thickness = 1,
        Transparency = 0.5,
        Origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
        Part = "head"
    },

    Skeletons = {
        Toggled = false,
        Teamcheck = true,
        EnemyColor = Color3.fromRGB(255,0,0),
        TeamColor = Color3.fromRGB(0,0,255),
        Thickness = 2,
        Transparency = 0.5
    },

    Healthbars = {
        Toggled = false,
        Teamcheck = true,
        FullColor = Color3.fromRGB(0,255,0),
        EmptyColor = Color3.fromRGB(255,0,0),
        Offset = 10
    },

    Names = {
        Toggled = false,
        Teamcheck = true,
        EnemyColor = Color3.fromRGB(255,0,0),
        TeamColor = Color3.fromRGB(0,0,255),
        TextSize = 15,
        TextOutline = false,
        FontFamily = Drawing.Fonts["UI"]
    },

    Distances = {
        Toggled = false,
        Teamcheck = true,
        EnemyColor = Color3.fromRGB(255,0,0),
        TeamColor = Color3.fromRGB(0,0,255),
        TextSize = 15,
        TextOutline = false,
        FontFamily = Drawing.Fonts["UI"]
    },

    Weapons = {
        Toggled = false,
        Color = Color3.fromRGB(0,255,0),
        TextSize = 15,
        TextOutline = false,
        FontFamily = Drawing.Fonts["UI"]
    },

    Crosshair = {
        Toggled = false,
        Color = Color3.fromRGB(255,255,255),
        Size = 10,
        Thickness = 1,
        Transparency = 1,
    },
    Performance = {
        MaxDistance = 1000,
        Refreshtime = 5
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


local drawingshit = {}
local idtable = {}
local weapontable = {}
local counter = 0

function parseOption(option)
    if option:find("Toggled") then
        return option:gsub("Toggled", "Visible")
    elseif option:find("Origin") then
        return option:gsub("Origin", "From")
    elseif option:find("Text.") then
        return option:gsub("Text", "")
    elseif option:find("FontFamily") then
        return option:gsub("FontFamily", "Font")
    else
        return option
    end
end

function updateComponent(component, option, value)
    if component ~= nil and option ~= nil and value ~= nil then
        if component == "Weapons" then
            for i,v in pairs(weapontable) do
                if v[option] then
                    v[option] = value
                end
            end
        else
            for i,v in pairs(drawingshit) do
                if component == "Crosshair" then
                    if option ~= "Size" and v["crosshairvertical"][option] ~= nil then
                        v["crosshairvertical"][option] = value
                        v["crosshairhorizontal"][option] = value
                    end
                elseif component == "Skeletons" and v["headline"][option] ~= nil then
                    v["headline"][option] = value
                    v["torsoline"][option] = value
                    v["leftarmline"][option] = value
                    v["rightarmline"][option] = value
                    v["leftlegline"][option] = value
                    v["rightlegline"][option] = value
                    v["leftupperconnector"][option] = value
                    v["rightupperconnector"][option] = value
                    v["leftlowerconnector"][option] = value
                    v["rightlowerconnector"][option] = value
                else
                    if v[component][option] then
                        v[component][option] = value
                    end
                end
            end
        end
    end
end

function AddToRenderList(plr)

    if plr ~= LocalPlayer and drawingshit[plr] == nil then

        drawingshit[plr.Name] = {}

        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Boxes.TeamColor or esp_settings.Boxes.EnemyColor
        box.Thickness = esp_settings.Boxes.Thickness
        box.Transparency = esp_settings.Boxes.Transparency

        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.From = esp_settings.Tracers.Origin
        tracer.To = Vector2.new(0,0)
        tracer.Thickness = esp_settings.Tracers.Thickness
        tracer.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Tracers.TeamColor or esp_settings.Tracers.EnemyColor
        tracer.Transparency = esp_settings.Tracers.Transparency

        local name = Drawing.new("Text")
        name.Visible = false
        name.Text = plr.Name
        name.Size = esp_settings.Names.TextSize
        name.Center = true
        name.Outline = esp_settings.Names.TextOutline
        name.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Names.TeamColor or esp_settings.Names.EnemyColor
        name.Font = esp_settings.Names.FontFamily



        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Center = true
        distance.Size = esp_settings.Distances.TextSize
        distance.Outline = esp_settings.Distances.TextOutline
        distance.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Distances.TeamColor or esp_settings.Distances.EnemyColor
        distance.Font = esp_settings.Distances.FontFamily

        local healthbar = Drawing.new("Square")
        healthbar.Visible = false
        healthbar.Filled = true
        healthbar.Color = esp_settings.Healthbars.EmptyColor:lerp(esp_settings.Healthbars.FullColor, utility:GetHealth(plr)/100);

        local crosshairvertical = Drawing.new("Line")
        crosshairvertical.Visible = false
        crosshairvertical.Thickness = esp_settings.Crosshair.Thickness
        crosshairvertical.Transparency = esp_settings.Crosshair.Transparency
        crosshairvertical.Color = esp_settings.Crosshair.Color

        local crosshairhorizontal = Drawing.new("Line")
        crosshairhorizontal.Visible = false
        crosshairhorizontal.Thickness = esp_settings.Crosshair.Thickness
        crosshairhorizontal.Transparency = esp_settings.Crosshair.Transparency
        crosshairhorizontal.Color = esp_settings.Crosshair.Color

        local headline = Drawing.new("Line")
        headline.Visible = false
        headline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        headline.Thickness = esp_settings.Skeletons.Thickness
        headline.Transparency = esp_settings.Skeletons.Transparency


        local torsoline = Drawing.new("Line")
        torsoline.Visible = false
        torsoline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        torsoline.Thickness = esp_settings.Skeletons.Thickness
        torsoline.Transparency = esp_settings.Skeletons.Transparency


        local leftarmline = Drawing.new("Line")
        leftarmline.Visible = false
        leftarmline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        leftarmline.Thickness = esp_settings.Skeletons.Thickness
        leftarmline.Transparency = esp_settings.Skeletons.Transparency


        local rightarmline = Drawing.new("Line")
        rightarmline.Visible = false
        rightarmline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        rightarmline.Thickness = esp_settings.Skeletons.Thickness
        rightarmline.Transparency = esp_settings.Skeletons.Transparency


        local leftlegline = Drawing.new("Line")
        leftlegline.Visible = false
        leftlegline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        leftlegline.Thickness = esp_settings.Skeletons.Thickness
        leftlegline.Transparency = esp_settings.Skeletons.Transparency


        local rightlegline = Drawing.new("Line")
        rightlegline.Visible = false
        rightlegline.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        rightlegline.Thickness = esp_settings.Skeletons.Thickness
        rightlegline.Transparency = esp_settings.Skeletons.Transparency

        local leftupperconnector = Drawing.new("Line")
        leftupperconnector.Visible = false
        leftupperconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        leftupperconnector.Thickness = esp_settings.Skeletons.Thickness
        leftupperconnector.Transparency = esp_settings.Skeletons.Transparency

        local rightupperconnector = Drawing.new("Line")
        rightupperconnector.Visible = false
        rightupperconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        rightupperconnector.Thickness = esp_settings.Skeletons.Thickness
        rightupperconnector.Transparency = esp_settings.Skeletons.Transparency

        local leftlowerconnector = Drawing.new("Line")
        leftlowerconnector.Visible = false
        leftlowerconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        leftlowerconnector.Thickness = esp_settings.Skeletons.Thickness
        leftlowerconnector.Transparency = esp_settings.Skeletons.Transparency

        local rightlowerconnector = Drawing.new("Line")
        rightlowerconnector.Visible = false
        rightlowerconnector.Color = plr.TeamColor == LocalPlayer.TeamColor and esp_settings.Skeletons.TeamColor or esp_settings.Skeletons.EnemyColor
        rightlowerconnector.Thickness = esp_settings.Skeletons.Thickness
        rightlowerconnector.Transparency = esp_settings.Skeletons.Transparency

        drawingshit[plr.Name].headline = headline
        drawingshit[plr.Name].torsoline = torsoline
        drawingshit[plr.Name].leftarmline = leftarmline
        drawingshit[plr.Name].rightarmline = rightarmline
        drawingshit[plr.Name].leftlegline = leftlegline
        drawingshit[plr.Name].rightlegline = rightlegline
        drawingshit[plr.Name].leftupperconnector = leftupperconnector
        drawingshit[plr.Name].rightupperconnector = rightupperconnector
        drawingshit[plr.Name].leftlowerconnector = leftlowerconnector
        drawingshit[plr.Name].rightlowerconnector = rightlowerconnector

        drawingshit[plr.Name].Names = name
        drawingshit[plr.Name].Boxes = box
        drawingshit[plr.Name].Tracers = tracer
        drawingshit[plr.Name].Distances = distance
        drawingshit[plr.Name].Healthbars = healthbar
        drawingshit[plr.Name].crosshairvertical = crosshairvertical
        drawingshit[plr.Name].crosshairhorizontal = crosshairhorizontal

        local CanRun = true

        rs:BindToRenderStep(plr.Name .. "Mika Esp", 1, function()

            if (not CanRun) then
                return
            end

            CanRun = false
            if esp_settings.Boxes.Toggled then
                if utility:IsAlive(plr) then
                    if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <=esp_settings.Performance.MaxDistance then
                        local data = utility:GetBoundingBox(utility:GetCharacter(plr))
                        local boxpos = Vector2.new(math.floor(data.pos.bottomRight.X), math.floor(data.pos.bottomRight.Y))
                        local Width, Height = math.floor(data.pos.topLeft.X - data.pos.topRight.X), math.floor(data.pos.topLeft.Y - data.pos.bottomLeft.Y)
                        local boxsize = Vector2.new(Width, Height)
                        local pos, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "torso").Position)
                        if onscreen then
                            box.Size = boxsize
                            box.Position = boxpos
                            if plr.TeamColor == LocalPlayer.TeamColor then
                                if esp_settings.Boxes.Teamcheck then
                                    box.Color = esp_settings.Boxes.TeamColor
                                    box.Visible = true
                                else
                                    box.Visible = false
                                end
                            else
                                box.Color = esp_settings.Boxes.EnemyColor
                                box.Visible = true
                            end
                        else
                            box.Visible = false
                        end
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
            if esp_settings.Tracers.Toggled then
                if utility:IsAlive(plr) then
                    if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <=esp_settings.Performance.MaxDistance then
                        local vec, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, esp_settings.Tracers.Part).Position)
                        if onscreen then
                            if plr.TeamColor == LocalPlayer.TeamColor then
                                tracer.To = Vector2.new(vec.X, vec.Y)
                                if esp_settings.Tracers.Teamcheck then
                                    tracer.Color = esp_settings.Tracers.TeamColor
                                    tracer.Visible = true
                                else
                                    tracer.Visible = false
                                end
                            else
                                tracer.Color = esp_settings.Tracers.EnemyColor
                                tracer.Visible = true
                            end
                        else
                            tracer.Visible = false
                        end
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end


        if esp_settings.Skeletons.Toggled then
            if utility:IsAlive(plr) then
                if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <= esp_settings.Performance.MaxDistance then
                    local Vector, onScreen = Camera:worldToViewportPoint(utility:GetBodypart(plr, "torso").Position)


                    if onScreen then
                        headline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Head").Position)) -- Head
                        torsoline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- Upper Torso
                        leftarmline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "larm").Position + Vector3.new(0,-1,0))) -- LowerLeftArm
                        rightarmline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rarm").Position + Vector3.new(0,-1,0))) -- LowerRightarm
                        leftlegline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "lleg").Position + Vector3.new(0,-1,0))) -- LowerLeftLeg
                        rightlegline.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rleg").Position + Vector3.new(0,-1,0))) -- LowerRightLeg
                        leftupperconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "larm").Position + Vector3.new(0,1,0))) -- UpperLeftArm
                        rightupperconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rarm").Position + Vector3.new(0,1,0))) -- UpperRightArm
                        leftlowerconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "lleg").Position + Vector3.new(0,1,0))) -- UpperLeftLeg
                        rightlowerconnector.From = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rleg").Position + Vector3.new(0,1,0))) -- UpperRightLeg

                        headline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- Upper Torso
                        torsoline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0))) -- Lower Torso
                        leftarmline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "larm").Position + Vector3.new(0,1,0))) -- UpperLeftArm
                        rightarmline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rarm").Position + Vector3.new(0,1,0))) -- UpperRightArm
                        leftlegline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "lleg").Position + Vector3.new(0,1,0))) -- UpperLeftLeg
                        rightlegline.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "rleg").Position + Vector3.new(0,1,0))) -- UpperRightLeg
                        rightupperconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- UpperTorso
                        rightlowerconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0))) -- LowerTorso
                        leftupperconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,1,0))) -- UpperTorso
                        leftlowerconnector.To = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0))) -- LowerTorso
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Skeletons.Teamcheck then
                                leftupperconnector.Color = esp_settings.Skeletons.TeamColor
                                rightupperconnector.Color = esp_settings.Skeletons.TeamColor
                                leftlowerconnector.Color = esp_settings.Skeletons.TeamColor
                                rightlowerconnector.Color = esp_settings.Skeletons.TeamColor
                                headline.Color = esp_settings.Skeletons.TeamColor
                                torsoline.Color = esp_settings.Skeletons.TeamColor
                                leftarmline.Color = esp_settings.Skeletons.TeamColor
                                rightarmline.Color = esp_settings.Skeletons.TeamColor
                                leftlegline.Color = esp_settings.Skeletons.TeamColor
                                rightlegline.Color = esp_settings.Skeletons.TeamColor
                                rightlegline.Visible = true
                                leftarmline.Visible = true
                                torsoline.Visible = true
                                rightarmline.Visible = true
                                leftlegline.Visible = true
                                headline.Visible = true
                                leftupperconnector.Visible = true
                                rightupperconnector.Visible = true
                                leftlowerconnector.Visible = true
                                rightlowerconnector.Visible = true
                            else
                                headline.Visible = false
                                torsoline.Visible = false
                                leftarmline.Visible = false
                                rightarmline.Visible = false
                                leftlegline.Visible = false
                                rightlegline.Visible = false
                                leftupperconnector.Visible = false
                                rightupperconnector.Visible = false
                                leftlowerconnector.Visible = false
                                rightlowerconnector.Visible = false
                            end
                        else
                            headline.Color = esp_settings.Skeletons.EnemyColor
                            torsoline.Color = esp_settings.Skeletons.EnemyColor
                            rightlegline.Color = esp_settings.Skeletons.EnemyColor
                            leftupperconnector.Color = esp_settings.Skeletons.EnemyColor
                            rightupperconnector.Color = esp_settings.Skeletons.EnemyColor
                            leftlowerconnector.Color = esp_settings.Skeletons.EnemyColor
                            rightlowerconnector.Color = esp_settings.Skeletons.EnemyColor
                            leftarmline.Color = esp_settings.Skeletons.EnemyColor
                            rightarmline.Color = esp_settings.Skeletons.EnemyColor
                            leftlegline.Color = esp_settings.Skeletons.EnemyColor
                            torsoline.Visible = true
                            leftarmline.Visible = true
                            rightarmline.Visible = true
                            leftlegline.Visible = true
                            rightlegline.Visible = true
                            leftlowerconnector.Visible = true
                            leftupperconnector.Visible = true
                            rightupperconnector.Visible = true
                            headline.Visible = true
                            rightlowerconnector.Visible = true
                        end
                    else
                        headline.Visible = false
                        torsoline.Visible = false
                        leftarmline.Visible = false
                        rightarmline.Visible = false
                        leftlegline.Visible = false
                        rightlegline.Visible = false
                        leftupperconnector.Visible = false
                        rightupperconnector.Visible = false
                        leftlowerconnector.Visible = false
                        rightlowerconnector.Visible = false
                    end
                else
                    headline.Visible = false
                    torsoline.Visible = false
                    leftarmline.Visible = false
                    rightarmline.Visible = false
                    leftlegline.Visible = false
                    rightlegline.Visible = false
                    leftupperconnector.Visible = false
                    rightupperconnector.Visible = false
                    leftlowerconnector.Visible = false
                    rightlowerconnector.Visible = false
                end
            else
                headline.Visible = false
                torsoline.Visible = false
                leftarmline.Visible = false
                rightarmline.Visible = false
                leftlegline.Visible = false
                rightlegline.Visible = false
                leftupperconnector.Visible = false
                rightupperconnector.Visible = false
                leftlowerconnector.Visible = false
                rightlowerconnector.Visible = false
            end
        else
            headline.Visible = false
            torsoline.Visible = false
            leftarmline.Visible = false
            rightarmline.Visible = false
            leftlegline.Visible = false
            rightlegline.Visible = false

            leftupperconnector.Visible = false
            rightupperconnector.Visible = false
            leftlowerconnector.Visible = false
            rightlowerconnector.Visible = false
        end

        if esp_settings.Names.Toggled then
            if utility:IsAlive(plr) then
                if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <=esp_settings.Performance.MaxDistance then
                    local vec, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "head").Position)
                    if onscreen then
                        name.Position = Vector2.new(vec.X, vec.Y)
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Names.Teamcheck then
                                name.Color = esp_settings.Names.TeamColor
                                name.Visible = true
                            else
                                name.Visible = false
                            end
                        else
                            name.Color = esp_settings.Names.EnemyColor
                            name.Visible = true
                        end
                    else
                        name.Visible = false
                    end
                else
                    name.Visible = false
                end
            else
                name.Visible = false
            end
        else
            name.Visible = false
        end

        if esp_settings.Distances.Toggled then
            if utility:IsAlive(plr) then
                if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <=esp_settings.Performance.MaxDistance then
                    local vec, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "head").Position)
                    if onscreen then
                        distance.Position = getpos(Camera:WorldToViewportPoint(utility:GetBodypart(plr, "Torso").Position + Vector3.new(0,-1,0)))
                        distance.Text = tostring(round((LocalPlayer.Character.Head.Position - utility:GetBodypart(plr, "head").Position).magnitude)) .. "Studs"
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Distances.Teamcheck then
                                distance.Color = esp_settings.Distances.TeamColor
                                distance.Visible = true
                            else
                                distance.Visible = false
                            end
                        else
                            distance.Color = esp_settings.Distances.EnemyColor
                            distance.Visible = true
                    end
                    else
                        distance.Visible = false
                    end
                else
                    distance.Visible = false
                end
            else
                distance.Visible = false
            end
        else
            distance.Visible = false
        end

        if esp_settings.Healthbars.Toggled then
            if utility:IsAlive(plr) and utility:GetBodypart(plr, "torso") ~= nil then
                if LocalPlayer.Character and (utility:GetBodypart(plr, "torso").Position - LocalPlayer.Character.Torso.Position).Magnitude <=esp_settings.Performance.MaxDistance then

                    local pos, onscreen = Camera:WorldToViewportPoint(utility:GetBodypart(plr, "torso").Position)
                    if onscreen then
                        local Health, MaxHealth = utility:GetHealth(plr)
                        local data = utility:GetBoundingBox(utility:GetCharacter(plr))
                        local Width, Height = math.floor(data.pos.topLeft.X - data.pos.topRight.X), math.floor(data.pos.topLeft.Y - data.pos.bottomLeft.Y)

                        local BoxSize = Vector2.new(Width, Height)

                        local healthsize = Vector2.new(2, math.floor(BoxSize.Y * (Health / MaxHealth)))
                        local healthpos = Vector2.new(math.floor(data.pos.topLeft.X - ((4 + esp_settings.Healthbars.Offset))), math.floor(data.pos.bottomLeft.Y))
                        healthbar.Size = healthsize
                        healthbar.Position = healthpos
                        if plr.TeamColor == LocalPlayer.TeamColor then
                            if esp_settings.Healthbars.Teamcheck then
                                healthbar.Color = esp_settings.Healthbars.EmptyColor:Lerp(esp_settings.Healthbars.FullColor, utility:GetHealth(plr)/100);
                                healthbar.Visible = true
                            else
                                healthbar.Visible = false
                            end
                        else
                            healthbar.Color = esp_settings.Healthbars.EmptyColor:Lerp(esp_settings.Healthbars.FullColor, utility:GetHealth(plr)/100);
                            healthbar.Visible = true
                        end

                    else
                        healthbar.Visible = false
                    end
                else
                    healthbar.Visible = false
                end
            else
                healthbar.Visible = false
            end
        else
            healthbar.Visible = false
        end

        if esp_settings.Crosshair.Toggled then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

            crosshairvertical.From = Vector2.new(center.X - esp_settings.Crosshair.Size, center.Y)
            crosshairvertical.To = Vector2.new(center.X + esp_settings.Crosshair.Size, center.Y)

            crosshairvertical.Thickness = esp_settings.Crosshair.Thickness
            crosshairvertical.Transparency = esp_settings.Crosshair.Transparency
            crosshairvertical.Color = esp_settings.Crosshair.Color


            crosshairhorizontal.From = Vector2.new(center.X, center.Y - esp_settings.Crosshair.Size)
            crosshairhorizontal.To = Vector2.new(center.X, center.Y + esp_settings.Crosshair.Size)

            crosshairhorizontal.Thickness = esp_settings.Crosshair.Thickness
            crosshairhorizontal.Transparency = esp_settings.Crosshair.Transparency
            crosshairhorizontal.Color = esp_settings.Crosshair.Color

            crosshairvertical.Visible = true
            crosshairhorizontal.Visible = true
        else
            crosshairhorizontal.Visible = false
            crosshairvertical.Visible = false
        end

        task.wait(math.clamp(esp_settings.Performance.Refreshtime / 1000, 0, 9e9))

        CanRun = true
    end)
end
end

function library:RefreshESP()
    for i,v in pairs(game:GetService("Players"):GetPlayers()) do
        RemoveFromRenderList(v)
        AddToRenderList(v)
    end
    for i,v in pairs(weapontable) do
        if v then
            v.Size = esp_settings.Weapons.TextSize
            v.Font = esp_settings.Weapons.FontFamily
            v.Outline = esp_settings.Weapons.TextOutline
            v.Color = esp_settings.Weapons.Color
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
    text.Text = gun:FindFirstChild("Gun") and gun.Gun.Value or "Error getting weapon name"
    text.Size = esp_settings.Weapons.TextSize
    text.Font = esp_settings.Weapons.FontFamily
    text.Outline = esp_settings.Weapons.TextOutline
    text.Color = esp_settings.Weapons.Color

    weapontable[gun] = text


    rs:BindToRenderStep(tostring(counter) .. "WeaponEsp", Enum.RenderPriority.Last.Value, function()
        if esp_settings.Weapons.Toggled then
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

function library:Init(options)
    assert(initialized == false, "You can't initialize twice!")
    esp_settings = defaultsettings
    initialized = true
end

function library:UpdateVisual(visual, option, value)
    assert(esp_settings[visual][option] ~= nil, "This option doesn't exist!")
    esp_settings[visual][option] = value
    updateComponent(visual, parseOption(option), value)
end

return library
