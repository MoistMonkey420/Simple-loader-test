local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "BadBusiness", HidePremium = false, SaveConfig = true, ConfigFolder = "Lester", IntroEnabled = true, IntroText = "BadBusiness"})

local camera = workspace.CurrentCamera
local character = Workspace.Characters
local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local runservice = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local mouse = localplayer:GetMouse()

local settings = {
    enabled = true,
    aiming = false,
    aimbot_AimPart = "Head",
    fov_Radius = 150
}

local esp_settings = {
    enabled = true,
    box = true
}

local esp = {}

--Aimbot
local TabAimbot = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
TabAimbot:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        settings.enabled = Value
    end    
})
--ESP
local TabEsp = Window:MakeTab({
    Name = "Esp",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
TabEsp:AddToggle({
    Name = "Box",
    Default = false,
    Callback = function(Value)
        esp_settings.box = Value
    end    
})

-- Create ESP
function createESP(player)
    local outline_square = Drawing.new("Square")
    outline_square.Visible = false
    outline_square.Filled = false
    outline_square.Color = Color3.new(0,0,0)
    outline_square.Thickness = 2

    local square = Drawing.new("Square")
    square.Visible = false
    square.Filled = false
    square.Color = Color3.new(1,1,1)
    square.Thickness = 0
    square.ZIndex = 2

    local playeresp = {
        Player = player,
        Outline_Box = outline_square,
        Box = square
    }

    table.insert(esp, playeresp)

    local c1
    local c2

    local function RemoveTable()
        local index = table.find(esp, playeresp)
        if index then
            table.remove(esp, index)
            --esp[index] = nil
        end

        outline_square:Remove()
        square:Remove()

        if c1 and c2 then
            c1:Disconnect()
            c1 = nil
            c2:Disconnect()
            c2 = nil
        end
    end

    c1 = player.Destroying:Connect(function()
        RemoveTable()
    end)
end

-- Loop
runservice.RenderStepped:Connect(function()
    for i,player in next, esp do

        local aplayer = player.Player
        local outline_Box = player.Outline_Box
        local box = player.Box

        --if aplayer.Character then
            local orien,size = aplayer:GetBoundingBox()
            local height = (camera.CFrame - camera.CFrame.Position) * Vector3.new(0, math.clamp(size.Y, 1, 10) / 2, 0)
            Height = -math.abs(camera:WorldToViewportPoint(orien.Position + height).Y - camera:WorldToViewportPoint(orien.Position - height).Y)
            Size = Vector2.new((Height / 2), Height)

            local hrp = aplayer.PrimaryPart.Position
            local hrp2d, visible = camera:WorldToViewportPoint(hrp)

            if visible then

                outline_Box.Size = Size
                outline_Box.Position = Vector2.new(hrp2d.X - (Size.X / 2), hrp2d.Y - (Size.Y / 2))

                box.Size = Size
                box.Position = outline_Box.Position

                outline_Box.Visible = esp_settings.box
                box.Visible = esp_settings.box
            else
                outline_Box.Visible = false
                box.Visible = false
            end
        --end
    end
end)

local function playeradded(player)
    if player.PrimaryPart then
        createESP(player)
    end
end

for i,v in next, character:GetDescendants() do
    if v.ClassName == "Model" and v.PrimaryPart and v ~= localplayer then
        playeradded(v)
    end
end

character.DescendantAdded:Connect(function(v)
    if v.ClassName == "Model" and v.PrimaryPart and v ~= localplayer then
        playeradded(v)
    end
end)

--Aimbot
uis.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.aiming = true
    end
end)
uis.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.aiming = false
    end
end)

local fov_Circle = Drawing.new("Circle")
fov_Circle.Visible = true
fov_Circle.Radius = settings.fov_Radius
fov_Circle.Color = Color3.new(1,1,1)
fov_Circle.Thickness = 1
fov_Circle.Filled = false
fov_Circle.Transparency = 1
fov_Circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

runservice.RenderStepped:Connect(function()
    local distacne = math.huge
    local closest_Char = nil

    fov_Circle.Visible = settings.enabled
    fov_Circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    if settings.aiming and settings.enabled then
        for i,v in next, character:GetChildren() do
            if v ~= localplayer and v.PrimaryPart then
                local charHRPpos, isVisible = camera:WorldToViewportPoint(v.Body.Head.Position)
                local magDist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(charHRPpos.X, charHRPpos.Y)).Magnitude
                if isVisible and magDist < distacne and magDist <= settings.fov_Radius then
                    distacne = magDist
                    closest_Char = v
                end
            end
        end
        if closest_Char ~= nil then
            camera.CFrame = CFrame.new(camera.CFrame.Position, closest_Char.Body.Head.Position)
        end
    end
end)