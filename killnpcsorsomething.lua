# kill-npcs-or-something-script
Idk
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source/Rayfield.lua"))()

local aimbotEnabled = false
local reloadEnabled = false
local killBotsEnabled = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
   Name = "NPC Control Panel",
   LoadingTitle = "Chargement...",
   LoadingSubtitle = "by rlstbrxs",
   ConfigurationSaving = {
      Enabled = false
   }
})

local MainTab = Window:CreateTab("Fonctions")

MainTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(state)
       aimbotEnabled = state
   end,
})

MainTab:CreateToggle({
   Name = "Auto Reload",
   CurrentValue = false,
   Callback = function(state)
       reloadEnabled = state
   end,
})

MainTab:CreateToggle({
   Name = "Kill All Bots",
   CurrentValue = false,
   Callback = function(state)
       killBotsEnabled = state
   end,
})

local currentTarget = nil
local maxDistance = 1000

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        if currentTarget and currentTarget.Parent and currentTarget.Parent:FindFirstChild("Humanoid") and currentTarget.Parent.Humanoid.Health > 0 then
            local head = currentTarget.Parent:FindFirstChild("Head")
            if head then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
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
    if reloadEnabled then
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

task.spawn(function()
    while true do
        task.wait(0.1)
        if killBotsEnabled then
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local root = character:FindFirstChild("HumanoidRootPart")
            local tool = character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if root and tool then
                for _, npc in ipairs(workspace:GetDescendants()) do
                    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") and npc:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(npc) then
                        local humanoid = npc.Humanoid
                        if humanoid.Health > 0 then
                            root.CFrame = CFrame.new(npc.HumanoidRootPart.Position - npc.HumanoidRootPart.CFrame.LookVector * 2)
                            tool:Activate()
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
    end
end)
