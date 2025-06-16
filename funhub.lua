--! lz -- This line might be used by some executors to indicate LuaZ (bytecode) obfuscation, often just a comment.

--[[
    Enhanced Fun Multi-Feature Script with Rayfield UI
    Version 2.2 - Incorporating User Feedback and Robustness

    Disclaimer:
    This script is designed to work with the Rayfield UI library.
    It is NOT a fully functional, bug-free, or directly executable script
    without the Rayfield library being loaded and without a compatible exploit.
    
    IMPORTANT PREREQUISITE:
    - This script REQUIRES the Rayfield UI library to be loaded and functional
      in your exploit environment. If it's not loaded, this script WILL NOT WORK.
    - You MUST run a separate, official Rayfield loader script (usually a
      `loadstring` from their official sources like 'https://sirius.menu/rayfield')
      BEFORE running this script.

    - Many features are client-sided and will only appear to you, the player.
    - Roblox updates can break script functionality.
    - Use responsibly and understand the terms of service of the games you play.
    - No aimbot features are included as per your request.
    - I cannot guarantee 100% bug-free operation or prevent all callback errors
      without an actual Roblox environment for testing and debugging.

    Line Count Goal: ~900+ lines (This version is very detailed and should easily meet it)
]]

-- ============================================================================
-- 1. Initial Setup: Rayfield UI Loader Check & Services
-- ============================================================================

-- Check if Rayfield is available. This is crucial.
-- IMPORTANT: This block explicitly tells the user to load Rayfield FIRST.
-- The commented-out line below is an EXAMPLE of how Rayfield might be loaded.
-- You MUST get the official, latest Rayfield loader from their official sources.
if not Rayfield then
    warn("Rayfield UI library not found!")
    -- Example of how to load Rayfield (GET OFFICIAL URL FROM RAYFIELD SOURCES):
    -- local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    error("Rayfield UI library is required but not loaded. Please load Rayfield FIRST (e.g., via their official loadstring), then re-execute this script.")
    return -- Exit if Rayfield is not available.
end

-- Services (Defined as in user's example, plus others)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui") -- Often used for local scripts
local HttpService = game:GetService("HttpService") -- For utility, e.g., generating unique IDs

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character -- Will be updated by CharacterAdded
local Humanoid = nil -- Will be updated by CharacterAdded
local RootPart = nil -- Will be updated by CharacterAdded

-- Function to update character references safely
local function UpdateCharacterReferences()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:WaitForChild("Humanoid", 5) -- Wait up to 5 seconds
        RootPart = Character:WaitForChild("HumanoidRootPart", 5) -- Wait up to 5 seconds
    else
        warn("Character not found for updating references.")
    end
end

-- Call initially to set up references if character already exists
UpdateCharacterReferences()

-- Feature States (Based on user's example)
local Features = {
    Speed = {Enabled = false, Value = 16},
    JumpPower = {Enabled = false, Value = 50},
    Fly = {Enabled = false, Speed = 16},
    Noclip = {Enabled = false},
    InfiniteJump = {Enabled = false},
    WalkOnWater = {Enabled = false},
    Rainbow = {Enabled = false},
    Fullbright = {Enabled = false},
    XRay = {Enabled = false},
    ClickTeleport = {Enabled = false},
    AntiAFK = {Enabled = false},
    AutoSit = {Enabled = false}, -- Placeholder, not implemented in this version
    AutoSpin = {Enabled = false, Speed = 1},
    Parkour = {Enabled = false}, -- Placeholder, not implemented in this version
    BigHead = {Enabled = false}, -- Placeholder, not implemented in this version
    Invisible = {Enabled = false}, -- Placeholder, not implemented in this version
    PlatformOnDeath = {Enabled = false}, -- Placeholder, not implemented in this version
    AutoRespawn = {Enabled = false} -- Placeholder, not implemented in this version
}

-- Original Values Storage (For resetting game properties/character stats)
local OriginalValues = {
    WalkSpeed = Humanoid and Humanoid.WalkSpeed or 16,
    JumpPower = Humanoid and Humanoid.JumpPower or 50,
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    OutdoorAmbient = Lighting.OutdoorAmbient -- Added for rainbow lighting reset
}

-- Connections Storage (To manage and disconnect active feature connections)
local Connections = {}

-- ============================================================================
-- 2. Utility Functions
-- ============================================================================

-- Safely executes a function, catching any errors
local function SafeExecute(func, errorMsg)
    local success, err = pcall(func)
    if not success then
        warn(errorMsg or "Error occurred during SafeExecute: " .. tostring(err))
        Rayfield:Notify({
            Title = "Script Error",
            Content = errorMsg or "An unknown error occurred.",
            Duration = 5,
            Image = "rbxassetid://6253457193" -- Generic error icon
        })
    end
    return success
end

-- Custom notification wrapper (using Rayfield's Notify)
local function CreateNotification(title, content, duration, imageId)
    SafeExecute(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
            Image = imageId or 4483362458 -- Default icon from user's example
        })
    end, "Failed to create Rayfield notification")
end

-- Disconnects a stored connection
local function DisconnectConnection(name)
    if Connections[name] and Connections[name].Connected then
        Connections[name]:Disconnect()
        Connections[name] = nil
    end
end

-- ============================================================================
-- 3. Feature Functions (Core Logic for each cheat)
-- ============================================================================

-- Speed modification
local function ToggleSpeed(enabled, value)
    SafeExecute(function()
        if not Humanoid then
            CreateNotification("Error", "Humanoid not found for Speed.", 2)
            return
        end
        if enabled then
            Humanoid.WalkSpeed = value
            Features.Speed.Enabled = true
            CreateNotification("Speed", "Enabled: " .. value, 2)
        else
            Humanoid.WalkSpeed = OriginalValues.WalkSpeed
            Features.Speed.Enabled = false
            CreateNotification("Speed", "Disabled", 2)
        end
    end, "Failed to toggle speed")
end

-- Jump Power modification
local function ToggleJumpPower(enabled, value)
    SafeExecute(function()
        if not Humanoid then
            CreateNotification("Error", "Humanoid not found for Jump Power.", 2)
            return
        end
        if enabled then
            Humanoid.JumpPower = value
            Features.JumpPower.Enabled = true
            CreateNotification("Jump Power", "Enabled: " .. value, 2)
        else
            Humanoid.JumpPower = OriginalValues.JumpPower
            Features.JumpPower.Enabled = false
            CreateNotification("Jump Power", "Disabled", 2)
        end
    end, "Failed to toggle jump power")
end

-- Fly feature
local function ToggleFly(enabled, speed)
    SafeExecute(function()
        if not RootPart then
            CreateNotification("Error", "HumanoidRootPart not found for Fly.", 2)
            return
        end
        local BodyVelocity = RootPart:FindFirstChild("BodyVelocity")

        if enabled then
            if not BodyVelocity then
                BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.Parent = RootPart
            end

            DisconnectConnection("Fly") -- Ensure old connection is gone
            Connections.Fly = RunService.Heartbeat:Connect(function()
                if RootPart and BodyVelocity and Features.Fly.Enabled then
                    local Camera = Workspace.CurrentCamera
                    local MoveVector = Vector3.new(0, 0, 0)

                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        MoveVector = MoveVector + Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        MoveVector = MoveVector - Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        MoveVector = MoveVector - Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        MoveVector = MoveVector + Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        MoveVector = MoveVector + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        MoveVector = MoveVector - Vector3.new(0, 1, 0)
                    end
                    
                    -- Normalize move vector if magnitude is greater than 1 to prevent super speed diagonal movement
                    if MoveVector.Magnitude > 1 then
                        MoveVector = MoveVector.Unit
                    end

                    BodyVelocity.Velocity = MoveVector * speed
                    Humanoid.PlatformStand = true -- Keep character from falling/walking
                else
                    -- Cleanup if feature disabled or parts missing during heartbeat
                    if BodyVelocity then BodyVelocity:Destroy() end
                    if Humanoid then Humanoid.PlatformStand = false end
                    DisconnectConnection("Fly")
                end
            end)
            Features.Fly.Enabled = true
            CreateNotification("Fly", "Enabled - Use WASD + Space/Shift", 3)
        else
            DisconnectConnection("Fly")
            if BodyVelocity then BodyVelocity:Destroy() end
            if Humanoid then Humanoid.PlatformStand = false end
            Features.Fly.Enabled = false
            CreateNotification("Fly", "Disabled", 2)
        end
    end, "Failed to toggle fly")
end

-- Noclip feature
local function ToggleNoclip(enabled)
    SafeExecute(function()
        if not Character then
            CreateNotification("Error", "Character not found for Noclip.", 2)
            return
        end
        if enabled then
            DisconnectConnection("Noclip") -- Ensure old connection is gone
            Connections.Noclip = RunService.Stepped:Connect(function()
                if Character and Features.Noclip.Enabled then
                    for _, part in pairs(Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    if Humanoid then Humanoid.PlatformStand = true end -- Often needed for Noclip
                else
                    -- Cleanup if feature disabled or character missing during stepped
                    if Humanoid then Humanoid.PlatformStand = false end
                    for _, part in pairs(Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then -- Don't mess with RootPart
                            part.CanCollide = true
                        end
                    end
                    DisconnectConnection("Noclip")
                end
            end)
            Features.Noclip.Enabled = true
            CreateNotification("Noclip", "Enabled", 2)
        else
            DisconnectConnection("Noclip")
            if Character then
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
            if Humanoid then Humanoid.PlatformStand = false end
            Features.Noclip.Enabled = false
            CreateNotification("Noclip", "Disabled", 2)
        end
    end, "Failed to toggle noclip")
end

-- Infinite Jump feature
local function ToggleInfiniteJump(enabled)
    SafeExecute(function()
        if not Humanoid then
            CreateNotification("Error", "Humanoid not found for Infinite Jump.", 2)
            return
        end
        if enabled then
            DisconnectConnection("InfiniteJump") -- Ensure old connection is gone
            Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
                if Humanoid and Features.InfiniteJump.Enabled then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            Features.InfiniteJump.Enabled = true
            CreateNotification("Infinite Jump", "Enabled", 2)
        else
            DisconnectConnection("InfiniteJump")
            Features.InfiniteJump.Enabled = false
            CreateNotification("Infinite Jump", "Disabled", 2)
        end
    end, "Failed to toggle infinite jump")
end

-- Walk on Water feature (simplified, creates temporary platforms)
local function ToggleWalkOnWater(enabled)
    SafeExecute(function()
        if not RootPart then
            CreateNotification("Error", "HumanoidRootPart not found for Walk on Water.", 2)
            return
        end
        if enabled then
            DisconnectConnection("WalkOnWater") -- Ensure old connection is gone
            Connections.WalkOnWater = RunService.Heartbeat:Connect(function()
                if RootPart and Features.WalkOnWater.Enabled then
                    -- Cast a ray downwards from the player's root part
                    local rayOrigin = RootPart.Position
                    local rayDirection = Vector3.new(0, -10, 0)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    raycastParams.FilterDescendantsInstances = {Character} -- Don't hit self
                    
                    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    
                    if raycastResult and raycastResult.Material == Enum.Material.Water then
                        local part = Instance.new("Part")
                        part.Name = "WaterPlatform"
                        part.Size = Vector3.new(10, 1, 10)
                        part.Position = Vector3.new(RootPart.Position.X, raycastResult.Position.Y + 0.5, RootPart.Position.Z)
                        part.Anchored = true
                        part.CanCollide = true
                        part.Transparency = 0.8
                        part.BrickColor = BrickColor.new("Bright blue")
                        part.Parent = Workspace
                        game:GetService("Debris"):AddItem(part, 2) -- Destroy after 2 seconds
                    end
                end
            end)
            Features.WalkOnWater.Enabled = true
            CreateNotification("Walk on Water", "Enabled", 2)
        else
            DisconnectConnection("WalkOnWater")
            Features.WalkOnWater.Enabled = false
            CreateNotification("Walk on Water", "Disabled", 2)
        end
    end, "Failed to toggle walk on water")
end

-- Rainbow Character feature
local function ToggleRainbow(enabled)
    SafeExecute(function()
        if not Character then
            CreateNotification("Error", "Character not found for Rainbow.", 2)
            return
        end
        if enabled then
            DisconnectConnection("Rainbow") -- Ensure old connection is gone
            Connections.Rainbow = RunService.Heartbeat:Connect(function()
                if Character and Features.Rainbow.Enabled then
                    local hue = (tick() * 0.1) % 1 -- Slower rainbow
                    local color = Color3.fromHSV(hue, 1, 1)

                    for _, part in pairs(Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Color = color
                        end
                    end
                end
            end)
            Features.Rainbow.Enabled = true
            CreateNotification("Rainbow", "Enabled", 2)
        else
            DisconnectConnection("Rainbow")
            -- Restore original character colors (might be complex to store all, so just set to default white)
            if Character then
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        -- A more robust solution would save each part's original color.
                        -- For simplicity, setting to default Roblox player color (white/greyish)
                        if part.Name == "Head" then
                            part.Color = Color3.fromRGB(255, 255, 255)
                        elseif part.Name == "Torso" or part.Name == "RightArm" or part.Name == "LeftArm" then
                             part.Color = Color3.fromRGB(105, 105, 105) -- Default Roblox grey
                        elseif part.Name == "RightLeg" or part.Name == "LeftLeg" then
                            part.Color = Color3.fromRGB(80, 80, 80) -- Slightly darker grey
                        else
                            part.Color = Color3.fromRGB(200, 200, 200)
                        end
                    end
                end
            end
            Features.Rainbow.Enabled = false
            CreateNotification("Rainbow", "Disabled", 2)
        end
    end, "Failed to toggle rainbow")
end

-- Fullbright feature
local function ToggleFullbright(enabled)
    SafeExecute(function()
        if enabled then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            -- Also set outdoor ambient to full white for full effect
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Features.Fullbright.Enabled = true
            CreateNotification("Fullbright", "Enabled", 2)
        else
            Lighting.Ambient = OriginalValues.Ambient
            Lighting.Brightness = OriginalValues.Brightness
            Lighting.FogEnd = OriginalValues.FogEnd
            Lighting.OutdoorAmbient = OriginalValues.OutdoorAmbient -- Restore outdoor ambient too
            Features.Fullbright.Enabled = false
            CreateNotification("Fullbright", "Disabled", 2)
        end
    end, "Failed to toggle fullbright")
end

-- X-Ray Vision feature (transparency for parts)
local function ToggleXRay(enabled)
    SafeExecute(function()
        if enabled then
            -- Store original transparencies for restoration (basic approach, could be more robust)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Parent ~= Character and obj.Transparency == 0 then
                    -- Only modify opaque parts not part of player's character
                    obj.Transparency = 0.5
                end
            end
            Features.XRay.Enabled = true
            CreateNotification("X-Ray", "Enabled", 2)
        else
            -- Restoring could be problematic if other scripts changed transparency
            -- This is a basic restore, may not perfectly revert complex scenes
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Parent ~= Character and obj.Transparency == 0.5 then
                    obj.Transparency = 0 -- Reset to opaque
                end
            end
            Features.XRay.Enabled = false
            CreateNotification("X-Ray", "Disabled", 2)
        end
    end, "Failed to toggle x-ray")
end

-- Click Teleport feature
local function ToggleClickTeleport(enabled)
    SafeExecute(function()
        if not RootPart then
            CreateNotification("Error", "HumanoidRootPart not found for Click Teleport.", 2)
            return
        end
        if enabled then
            DisconnectConnection("ClickTeleport") -- Ensure old connection is gone
            Connections.ClickTeleport = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    local Mouse = LocalPlayer:GetMouse()
                    if Mouse.Hit then
                        RootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
                        CreateNotification("Click Teleport", "Teleported!", 1)
                    end
                end
            end)
            Features.ClickTeleport.Enabled = true
            CreateNotification("Click Teleport", "Enabled - Hold Ctrl + Click", 3)
        else
            DisconnectConnection("ClickTeleport")
            Features.ClickTeleport.Enabled = false
            CreateNotification("Click Teleport", "Disabled", 2)
        end
    end, "Failed to toggle click teleport")
end

-- Anti-AFK feature
local function ToggleAntiAFK(enabled)
    SafeExecute(function()
        if not RootPart then
            CreateNotification("Error", "HumanoidRootPart not found for Anti-AFK.", 2)
            return
        end
        if enabled then
            DisconnectConnection("AntiAFK") -- Ensure old connection is gone
            Connections.AntiAFK = RunService.Heartbeat:Connect(function()
                if RootPart and Features.AntiAFK.Enabled then
                    local randomOffset = Vector3.new(
                        math.random() * 0.02 - 0.01, -- Small random X between -0.01 and 0.01
                        0,
                        math.random() * 0.02 - 0.01  -- Small random Z between -0.01 and 0.01
                    )
                    RootPart.CFrame = RootPart.CFrame * CFrame.new(randomOffset)
                end
            end)
            Features.AntiAFK.Enabled = true
            CreateNotification("Anti-AFK", "Enabled", 2)
        else
            DisconnectConnection("AntiAFK")
            Features.AntiAFK.Enabled = false
            CreateNotification("Anti-AFK", "Disabled", 2)
        end
    end, "Failed to toggle anti-afk")
end

-- Auto Spin feature
local function ToggleAutoSpin(enabled, speed)
    SafeExecute(function()
        if not RootPart then
            CreateNotification("Error", "HumanoidRootPart not found for Auto Spin.", 2)
            return
        end
        local BodyAngularVelocity = RootPart:FindFirstChild("BodyAngularVelocity")
        if enabled then
            if not BodyAngularVelocity then
                BodyAngularVelocity = Instance.new("BodyAngularVelocity")
                BodyAngularVelocity.AngularVelocity = Vector3.new(0, speed * 10, 0)
                BodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                BodyAngularVelocity.Parent = RootPart
            else
                BodyAngularVelocity.AngularVelocity = Vector3.new(0, speed * 10, 0)
            end
            Features.AutoSpin.Enabled = true
            CreateNotification("Auto Spin", "Enabled", 2)
        else
            if BodyAngularVelocity then
                BodyAngularVelocity:Destroy()
            end
            Features.AutoSpin.Enabled = false
            CreateNotification("Auto Spin", "Disabled", 2)
        end
    end, "Failed to toggle auto spin")
end

-- Teleport to specific player
local function TeleportToPlayer(playerName)
    SafeExecute(function()
        if not RootPart then
            CreateNotification("Error", "HumanoidRootPart not found for Teleport.", 2)
            return
        end
        local targetPlayer = Players:FindFirstChild(playerName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            RootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            CreateNotification("Teleport", "Teleported to " .. playerName, 2)
        else
            CreateNotification("Teleport", "Player not found or invalid", 2)
        end
    end, "Failed to teleport to player")
end

-- Play Dance Animation
local function PlayDanceAnimation()
    SafeExecute(function()
        if Humanoid then
            local danceId = "507770677" -- Dance animation ID from example
            local Animation = Instance.new("Animation")
            Animation.AnimationId = "rbxassetid://" .. danceId
            local AnimationTrack = Humanoid:LoadAnimation(Animation)
            AnimationTrack:Play()
            -- Optional: Stop after a few seconds if you don't want it looping indefinitely
            -- task.delay(AnimationTrack.Length or 5, function() AnimationTrack:Stop() end)
            CreateNotification("Fun", "Dancing! 💃", 2)
        else
            CreateNotification("Error", "Humanoid not found to play dance.", 2)
        end
    end, "Failed to play dance animation")
end

-- Play Jump Scare Sound
local function PlayJumpScareSound()
    SafeExecute(function()
        local Sound = Instance.new("Sound")
        Sound.SoundId = "rbxassetid://131961136" -- Jump scare sound ID from example
        Sound.Volume = 0.5
        Sound.Parent = Workspace -- Parent to workspace so it's audible
        Sound:Play()
        Sound.Ended:Connect(function()
            Sound:Destroy()
        end)
        CreateNotification("Fun", "BOO! 👻", 2)
    end, "Failed to play jump scare sound")
end

-- Random Teleport
local function RandomTeleport()
    SafeExecute(function()
        if RootPart then
            local randomX = math.random(-2000, 2000) -- Increased range for more random teleports
            local randomZ = math.random(-2000, 2000)
            local randomY = math.random(50, 500) -- High enough to not fall through floor immediately

            RootPart.CFrame = CFrame.new(randomX, randomY, randomZ)
            CreateNotification("Fun", "Teleported randomly! 🎲", 2)
        else
            CreateNotification("Error", "HumanoidRootPart not found for Random Teleport.", 2)
        end
    end, "Failed to random teleport")
end

-- Rainbow Lighting (temporary)
local function ToggleRainbowLightingTemporarily()
    SafeExecute(function()
        local originalAmbient = Lighting.Ambient
        local originalOutdoorAmbient = Lighting.OutdoorAmbient
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local hue = (tick() * 0.3) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            Lighting.Ambient = color
            Lighting.OutdoorAmbient = color
        end)

        -- Temporarily activate, then disconnect and reset
        task.delay(10, function() -- Rainbow for 10 seconds
            if connection and connection.Connected then
                connection:Disconnect()
            end
            -- Reset lighting
            Lighting.Ambient = originalAmbient
            Lighting.OutdoorAmbient = originalOutdoorAmbient
            CreateNotification("Fun", "Rainbow lighting finished! 🌈", 2)
        end)
        CreateNotification("Fun", "Rainbow lighting active! 🌈", 2)
    end, "Failed to activate rainbow lighting")
end

-- Reset All Features
local function ResetAllFeatures()
    SafeExecute(function()
        -- Disconnect all active connections
        for name, connection in pairs(Connections) do
            DisconnectConnection(name)
        end

        -- Reset all feature states and toggle them off
        ToggleSpeed(false)
        ToggleJumpPower(false)
        ToggleFly(false)
        ToggleNoclip(false)
        ToggleInfiniteJump(false)
        ToggleWalkOnWater(false)
        ToggleRainbow(false)
        ToggleFullbright(false)
        ToggleXRay(false)
        ToggleClickTeleport(false)
        ToggleAntiAFK(false)
        ToggleAutoSpin(false)

        -- Reset any Rayfield UI toggles/sliders to their default 'off' state if they were on
        -- This part needs to interact with Rayfield's internal state directly or simulate clicks
        -- For simplicity, rely on the feature functions to update the UI elements.
        -- If Rayfield allows direct setting of UI element states, that would be better here.

        CreateNotification("Settings", "All features reset! ✅", 3)
    end, "Failed to reset all features")
end

-- ============================================================================
-- 4. Character & Player Event Handling
-- ============================================================================

-- Restore active features when character respawns/loads
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    -- Wait a bit to ensure the character is fully loaded client-side
    task.wait(1)
    UpdateCharacterReferences() -- Update Humanoid and RootPart references

    -- Re-apply features that should persist across deaths
    if Features.Speed.Enabled then
        ToggleSpeed(true, Features.Speed.Value)
    end
    if Features.JumpPower.Enabled then
        ToggleJumpPower(true, Features.JumpPower.Value)
    end
    if Features.Fly.Enabled then
        ToggleFly(true, Features.Fly.Speed)
    end
    if Features.Noclip.Enabled then
        ToggleNoclip(true)
    end
    if Features.InfiniteJump.Enabled then
        ToggleInfiniteJump(true)
    end
    if Features.AntiAFK.Enabled then
        ToggleAntiAFK(true)
    end
    if Features.AutoSpin.Enabled then
        ToggleAutoSpin(true, Features.AutoSpin.Speed)
    end
    if Features.Rainbow.Enabled then
        ToggleRainbow(true)
    end
    if Features.Fullbright.Enabled then
        ToggleFullbright(true)
    end
    if Features.XRay.Enabled then
        ToggleXRay(true)
    end
end)

-- Cleanup connections when player leaves (important to prevent memory leaks/errors)
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for name, connection in pairs(Connections) do
            if connection then
                connection:Disconnect()
            end
        end
        -- Destroy UI on local player leave (optional, some prefer it to stay)
        if Window then
            Window:Destroy()
        end
    end
end)

-- ============================================================================
-- 5. Create GUI (Rayfield UI elements)
-- ============================================================================

-- Create the main Rayfield window
local Window = Rayfield:CreateWindow({
    Name = "🎮 Fun Multi-Feature Hub 🎮",
    LoadingTitle = "Loading Awesome Features...",
    LoadingSubtitle = "by ScriptMaster",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FunScript", -- Folder to save config in
        FileName = "Config" -- File name for the config
    },
    Discord = {
        Enabled = false, -- Set to false as you provided "noinvitelink"
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false -- No key system required
})

-- Movement Tab
local MovementTab = Window:CreateTab("🏃 Movement", 4483362458) -- Icon ID from example

local SpeedSlider = MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = Features.Speed.Value,
    Flag = "WalkSpeed", -- Rayfield flag for saving state
    Callback = function(Value)
        Features.Speed.Value = Value
        if Features.Speed.Enabled then
            ToggleSpeed(true, Value)
        end
    end
})

local SpeedToggle = MovementTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = Features.Speed.Enabled,
    Flag = "SpeedToggle",
    Callback = function(Value)
        ToggleSpeed(Value, Features.Speed.Value)
    end
})

local JumpPowerSlider = MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 1,
    Suffix = " Power",
    CurrentValue = Features.JumpPower.Value,
    Flag = "JumpPower",
    Callback = function(Value)
        Features.JumpPower.Value = Value
        if Features.JumpPower.Enabled then
            ToggleJumpPower(true, Value)
        end
    end
})

local JumpPowerToggle = MovementTab:CreateToggle({
    Name = "Enable Jump Power",
    CurrentValue = Features.JumpPower.Enabled,
    Flag = "JumpPowerToggle",
    Callback = function(Value)
        ToggleJumpPower(Value, Features.JumpPower.Value)
    end
})

local FlySpeedSlider = MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 100},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = Features.Fly.Speed,
    Flag = "FlySpeed",
    Callback = function(Value)
        Features.Fly.Speed = Value
        if Features.Fly.Enabled then
            -- Re-toggle fly to apply new speed
            ToggleFly(false)
            task.wait(0.1) -- Small delay
            ToggleFly(true, Value)
        end
    end
})

local FlyToggle = MovementTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = Features.Fly.Enabled,
    Flag = "FlyToggle",
    Callback = function(Value)
        ToggleFly(Value, Features.Fly.Speed)
    end
})

local NoclipToggle = MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = Features.Noclip.Enabled,
    Flag = "NoclipToggle",
    Callback = function(Value)
        ToggleNoclip(Value)
    end
})

local InfiniteJumpToggle = MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = Features.InfiniteJump.Enabled,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        ToggleInfiniteJump(Value)
    end
})

local WalkOnWaterToggle = MovementTab:CreateToggle({
    Name = "Walk on Water",
    CurrentValue = Features.WalkOnWater.Enabled,
    Flag = "WalkOnWaterToggle",
    Callback = function(Value)
        ToggleWalkOnWater(Value)
    end
})

-- Visual Tab
local VisualTab = Window:CreateTab("👁️ Visual", 4483362458) -- Icon ID from example

local RainbowToggle = VisualTab:CreateToggle({
    Name = "Rainbow Character",
    CurrentValue = Features.Rainbow.Enabled,
    Flag = "RainbowToggle",
    Callback = function(Value)
        ToggleRainbow(Value)
    end
})

local FullbrightToggle = VisualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = Features.Fullbright.Enabled,
    Flag = "FullbrightToggle",
    Callback = function(Value)
        ToggleFullbright(Value)
    end
})

local XRayToggle = VisualTab:CreateToggle({
    Name = "X-Ray Vision",
    CurrentValue = Features.XRay.Enabled,
    Flag = "XRayToggle",
    Callback = function(Value)
        ToggleXRay(Value)
    end
})

-- Utility Tab
local UtilityTab = Window:CreateTab("🔧 Utility", 4483362458) -- Icon ID from example (reused)

local ClickTeleportToggle = UtilityTab:CreateToggle({
    Name = "Click Teleport (Ctrl+Click)",
    CurrentValue = Features.ClickTeleport.Enabled,
    Flag = "ClickTeleportToggle",
    Callback = function(Value)
        ToggleClickTeleport(Value)
    end
})

local AntiAFKToggle = UtilityTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = Features.AntiAFK.Enabled,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        ToggleAntiAFK(Value)
    end
})

local AutoSpinSlider = UtilityTab:CreateSlider({
    Name = "Auto Spin Speed",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "x Speed",
    CurrentValue = Features.AutoSpin.Speed,
    Flag = "AutoSpinSpeed",
    Callback = function(Value)
        Features.AutoSpin.Speed = Value
        if Features.AutoSpin.Enabled then
            -- Re-toggle to apply new speed
            ToggleAutoSpin(false)
            task.wait(0.1) -- Small delay
            ToggleAutoSpin(true, Value)
        end
    end
})

local AutoSpinToggle = UtilityTab:CreateToggle({
    Name = "Auto Spin",
    CurrentValue = Features.AutoSpin.Enabled,
    Flag = "AutoSpinToggle",
    Callback = function(Value)
        ToggleAutoSpin(Value, Features.AutoSpin.Speed)
    end
})

-- Teleport Tab
local TeleportTab = Window:CreateTab("🌐 Teleport", 4483362458) -- Icon ID from example (reused)

local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = {}, -- Will be dynamically populated
    CurrentOption = "None",
    Flag = "PlayerDropdown",
    Callback = function(Option)
        -- Option selected, nothing to do here directly for teleport button
        -- The TeleportButton's callback will read this dropdown's CurrentOption
    end
})

-- Update player list for the dropdown dynamically
SafeExecute(function()
    Connections.PlayerListUpdater = task.spawn(function()
        while task.wait(5) do -- Update every 5 seconds
            local playerNames = {"None"} -- Always include "None" option
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    table.insert(playerNames, player.Name)
                end
            end
            -- Check if PlayerDropdown exists before refreshing
            if PlayerDropdown then
                PlayerDropdown:Refresh(playerNames, true) -- true to keep current selection if it still exists
            else
                warn("PlayerDropdown is nil, cannot refresh player list.")
                break -- Exit loop if dropdown is destroyed
            end
        end
    end)
end, "Failed to start player list updater.")


local TeleportButton = TeleportTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        -- Access the current selected option directly from the dropdown instance
        local selectedPlayer = PlayerDropdown.CurrentOption
        if selectedPlayer and selectedPlayer ~= "None" then
            TeleportToPlayer(selectedPlayer)
        else
            CreateNotification("Teleport", "Please select a player first", 2)
        end
    end
})

-- Fun Tab
local FunTab = Window:CreateTab("🎉 Fun", 4483362458) -- Icon ID from example (reused)

local DanceButton = FunTab:CreateButton({
    Name = "Dance Animation",
    Callback = function()
        PlayDanceAnimation()
    end
})

local JumpScareButton = FunTab:CreateButton({
    Name = "Jump Scare Sound",
    Callback = function()
        PlayJumpScareSound()
    end
})

local RandomTeleportButton = FunTab:CreateButton({
    Name = "Random Teleport",
    Callback = function()
        RandomTeleport()
    end
})

local RainbowLightingButton = FunTab:CreateButton({
    Name = "Rainbow Lighting (10s)",
    Callback = function()
        ToggleRainbowLightingTemporarily()
    end
})

-- Settings Tab
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458) -- Icon ID from example (reused)

local ResetAllButton = SettingsTab:CreateButton({
    Name = "Reset All Features",
    Callback = function()
        ResetAllFeatures()
    end
})

local InfoLabel = SettingsTab:CreateLabel("Script Version: " .. script_version .. " | Made with ❤️")

-- ============================================================================
-- 6. Final Initialization & Notifications
-- ============================================================================

-- Initial notification that the script is loaded
CreateNotification("Fun Script", "Successfully loaded! Enjoy! 🎉", 5)

-- This is the end of the script.
