local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local aimbotEnabled = false
local instantReloadEnabled = false

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 110)
frame.Position = UDim2.new(0.5, -125, 0.1, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0.1, 0)
uicorner.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 25, 0, 25)
toggleButton.Position = UDim2.new(1, -30, 0, 5)
toggleButton.Text = "-"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = frame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -10, 1, -35)
content.Position = UDim2.new(0, 5, 0, 30)
content.BackgroundTransparency = 1
content.Parent = frame

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 10)
layout.Parent = content

local function createButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 40)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = content
    return btn
end

local aimbotButton = createButton("Aimbot: OFF")
local reloadButton = createButton("Reload: OFF")
local killButton = createButton("Kill Bots")

aimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotButton.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

reloadButton.MouseButton1Click:Connect(function()
    instantReloadEnabled = not instantReloadEnabled
    reloadButton.Text = "Reload: " .. (instantReloadEnabled and "ON" or "OFF")
end)

killButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local tool = character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") and not Players:GetPlayerFromCharacter(npc) then
            local humanoid = npc:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and npc:FindFirstChild("HumanoidRootPart") then
                local target = npc:FindFirstChild("HumanoidRootPart")
                root.CFrame = CFrame.new(target.Position - target.CFrame.LookVector * 2)
                tool:Activate()
                task.wait(0.1)
            end
        end
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    local collapsed = content.Visible
    content.Visible = not collapsed
    toggleButton.Text = collapsed and "-" or "+"
    frame.Size = collapsed and UDim2.new(0, 250, 0, 110) or UDim2.new(0, 250, 0, 35)
end)

local currentTarget = nil
local maxDistance = 1000

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        if currentTarget and currentTarget.Parent and currentTarget.Parent:FindFirstChild("Humanoid") and currentTarget.Parent.Humanoid.Health > 0 then
            if currentTarget.Parent:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Parent.Head.Position)
            end
        else
            local closest
            local shortest = maxDistance
            for _, model in ipairs(workspace:GetDescendants()) do
                if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("Head") and not Players:GetPlayerFromCharacter(model) then
                    local h = model:FindFirstChild("Humanoid")
                    if h and h.Health > 0 then
                        local head = model:FindFirstChild("Head")
                        local dist = (Camera.CFrame.Position - head.Position).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = model
                        end
                    end
                end
            end
            if closest then
                currentTarget = closest:FindFirstChild("Head")
            end
        end
        if currentTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if instantReloadEnabled then
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:FindFirstChild("Ammo") then
                tool.Ammo.Value = 999999
            end
        end
        if LocalPlayer.Character then
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if tool:FindFirstChild("Ammo") then
                    tool.Ammo.Value = 999999
                end
            end
        end
    end
end)