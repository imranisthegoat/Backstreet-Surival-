local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Window = Rayfield:CreateWindow({
name = "Immie Hub",
subtitle = "Backstreet Survival",
sidebarLayout = true,
})

local Tab = Window:CreateTab({
name = "Players",
icon = 93364949241311,
})

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "_ImmieHubESP"
ESPFolder.Parent = Camera

local ESPEnabled = false
local selectedIndex = 1
local players = {}

local function refreshPlayers()
players = Players:GetPlayers()


if #players == 0 then
    selectedIndex = 1
else
    selectedIndex = math.clamp(selectedIndex, 1, #players)
end


end

local function getSelectedPlayer()
refreshPlayers()
return players[selectedIndex]
end

local function clearESP()
ESPFolder:ClearAllChildren()
end

local function createESP(player)
if not ESPEnabled then
return
end


local character = player.Character
if not character then
    return
end

local root = character:FindFirstChild("HumanoidRootPart")
if not root then
    return
end

local old = ESPFolder:FindFirstChild(tostring(player.UserId))
if old then
    old:Destroy()
end

local container = Instance.new("Folder")
container.Name = tostring(player.UserId)
container.Parent = ESPFolder

local highlight = Instance.new("Highlight")
highlight.Adornee = character
highlight.FillColor = player.AccountAge < 14
    and Color3.fromRGB(255, 0, 0)
    or Color3.fromRGB(0, 170, 255)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.65
highlight.OutlineTransparency = 0
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Parent = container

local billboard = Instance.new("BillboardGui")
billboard.Name = "Info"
billboard.Adornee = root
billboard.Size = UDim2.fromOffset(190, 55)
billboard.StudsOffset = Vector3.new(0, 3.5, 0)
billboard.AlwaysOnTop = true
billboard.Parent = container

local label = Instance.new("TextLabel")
label.Name = "Label"
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 0.35
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Text = player.Name .. "\nSpeed: 0 | Age: " .. player.AccountAge .. "d"
label.Parent = billboard


end

local function refreshESP()
clearESP()


if not ESPEnabled then
    return
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end


end

local function spectate(player)
if not player or not player.Character then
return
end


local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

if humanoid then
    Camera.CameraSubject = humanoid
end


end

local function stopSpectating()
if not LocalPlayer.Character then
return
end


local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

if humanoid then
    Camera.CameraSubject = humanoid
end


end

local function nextPlayer()
refreshPlayers()


if #players == 0 then
    return
end

selectedIndex += 1

if selectedIndex > #players then
    selectedIndex = 1
end

spectate(getSelectedPlayer())


end

local function previousPlayer()
refreshPlayers()


if #players == 0 then
    return
end

selectedIndex -= 1

if selectedIndex < 1 then
    selectedIndex = #players
end

spectate(getSelectedPlayer())


end

Tab:CreateSection({
name = "Player ESP"
})

Tab:CreateToggle({
name = "Player ESP",
flag = "PlayerESP",


callback = function(value)
    ESPEnabled = value
    refreshESP()
end,


})

Tab:CreateSection({
name = "Player Navigation"
})

Tab:CreateButton({
name = "Next Player",
callback = nextPlayer,
})

Tab:CreateButton({
name = "Previous Player",
callback = previousPlayer,
})

Tab:CreateButton({
name = "Spectate Selected",


callback = function()
    spectate(getSelectedPlayer())
end,


})

Tab:CreateButton({
name = "Stop Spectating",
callback = stopSpectating,
})

RunService.RenderStepped:Connect(function()
if not ESPEnabled then
return
end


for _, player in ipairs(Players:GetPlayers()) do
    local container = ESPFolder:FindFirstChild(tostring(player.UserId))

    if container then
        local billboard = container:FindFirstChild("Info")
        local label = billboard and billboard:FindFirstChild("Label")
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if label and root then
            local velocity = root.AssemblyLinearVelocity

            local speed = Vector3.new(
                velocity.X,
                0,
                velocity.Z
            ).Magnitude

            label.Text =
                player.Name ..
                "\nSpeed: " ..
                math.floor(speed + 0.5) ..
                " | Age: " ..
                player.AccountAge ..
                "d"
        elseif character then
            createESP(player)
        end
    elseif player.Character then
        createESP(player)
    end
end


end)

Players.PlayerAdded:Connect(function(player)
player.CharacterAdded:Connect(function()
task.wait(0.5)


    if ESPEnabled then
        createESP(player)
    end
end)

refreshPlayers()


end)

Players.PlayerRemoving:Connect(function(player)
local esp = ESPFolder:FindFirstChild(tostring(player.UserId))


if esp then
    esp:Destroy()
end

refreshPlayers()


end)

for _, player in ipairs(Players:GetPlayers()) do
player.CharacterAdded:Connect(function()
task.wait(0.5)


    if ESPEnabled then
        createESP(player)
    end
end)


end

refreshPlayers()

local MovementTab = Window:CreateTab({
name = "Movement",
icon = 6031075938,
})

local currentWalkSpeed = 16

MovementTab:CreateSlider({
name = "WalkSpeed",
range = {16, 200},
increment = 1,
suffix = " Speed",
currentValue = 16,


callback = function(value)
    currentWalkSpeed = value

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = value
    end
end,


})

LocalPlayer.CharacterAdded:Connect(function(character)
local humanoid = character:WaitForChild("Humanoid")
task.wait(0.1)
humanoid.WalkSpeed = currentWalkSpeed
end)

local noclipEnabled = false

MovementTab:CreateToggle({
name = "Noclip",
currentValue = false,


callback = function(value)
    noclipEnabled = value
end,


})

RunService.Stepped:Connect(function()
local character = LocalPlayer.Character


if not character then
    return
end

for _, part in ipairs(character:GetDescendants()) do
    if part:IsA("BasePart") then
        part.CanCollide = not noclipEnabled
    end
end


end)

local function getPlayerNames()
local names = {}


for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(names, player.Name)
    end
end

return names


end

MovementTab:CreateDropdown({
name = "Teleport to Player",
options = getPlayerNames(),


callback = function(playerName)
    local target = Players:FindFirstChild(playerName)

    if not target or not target.Character then
        return
    end

    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if targetRoot and root then
        root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
    end
end,


})

local DeleteTab = Window:CreateTab({
    name = "Delete",
    icon = 6031075938
})

DeleteTab:CreateButton({
    name = "Delete Beach Guard",
    callback = function()
        local npc = workspace.Map.NPC
        local spawnpoints = workspace.Map.ScriptObjects.NPC.Beach_Spawnpoints

        local guard = npc:FindFirstChild("Guard")
        if guard then
            guard:Destroy()
        end

        for _, name in ipairs({"Guard1", "Guard2", "Shark1", "Shark2"}) do
            local object = spawnpoints:FindFirstChild(name)
            if object then
                object:Destroy()
            end
        end
    end
})

DeleteTab:CreateButton({
    name = "Delete Cars",
    callback = function()
        local cars = workspace.Map.ScriptObjects:FindFirstChild("Cars")

        if cars then
            cars:Destroy()
        end
    end
})

DeleteTab:CreateButton({
    name = "Delete Sharks",
    callback = function()
        local npc = workspace.Map.NPC

        local shark = npc:FindFirstChild("Shark")
        if shark then
            shark:Destroy()
        end

        local children = npc:GetChildren()
        local target = children[20]

        if target then
            target:Destroy()
        end

        local water = workspace.Map.ScriptObjects:FindFirstChild("Water")
        if water then
            water:Destroy()
        end
    end
})

local GodmodeConnection

DeleteTab:CreateButton({
    name = "Godmode",
    callback = function()
        local function removeHealthScript()
            local playerScript = workspace:FindFirstChild("playerusingscript")

            if playerScript then
                local healthScript = playerScript:FindFirstChild("Health")

                if healthScript then
                    healthScript:Destroy()
                end
            end
        end

        -- Remove it immediately
        removeHealthScript()

        -- Remove it again whenever you respawn
        if GodmodeConnection then
            GodmodeConnection:Disconnect()
        end

        GodmodeConnection = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            removeHealthScript()
        end)
    end
})
