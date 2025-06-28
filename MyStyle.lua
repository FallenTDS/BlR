local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://83474010887370"
local track = humanoid:LoadAnimation(animation)

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://411274847"
sound.Volume = 3
sound.Name = "KickSound"
sound.Parent = character:WaitForChild("HumanoidRootPart")

local shootRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("BallService")
    :WaitForChild("RE")
    :WaitForChild("Shoot")

local function doShoot()
    track:Play()
    task.delay(0.5, function()
        sound:Play()
        local args = {
            200,
            [500] = Vector3.new(-0.8686492443084717, 0.20258301615715027, 0.5732067942619324)
        }
        shootRemote:FireServer(unpack(args))
    end)
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local inGameUI = playerGui:WaitForChild("InGameUI")
local bottom = inGameUI:WaitForChild("Bottom")
local abilities = bottom:WaitForChild("Abilities")

local shootButton = Instance.new("ImageButton")
shootButton.Name = "ShootButton"
shootButton.Size = UDim2.new(0, 74, 0, 74)
shootButton.BackgroundTransparency = 1
shootButton.Image = "rbxassetid://94420981449604"
shootButton.ZIndex = 1
shootButton.Parent = abilities

local godShotText = Instance.new("TextLabel")
godShotText.Name = "GodShotText"
godShotText.Size = UDim2.new(1, -10, 1, -10)
godShotText.Position = UDim2.new(0, 5, 0, 5)
godShotText.BackgroundTransparency = 1
godShotText.Text = "GOD SHOT"
godShotText.TextColor3 = Color3.new(1, 1, 1)
godShotText.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
godShotText.TextScaled = true
godShotText.TextWrapped = true
godShotText.ZIndex = 2
godShotText.Parent = shootButton

local function createOutlineLabel(offsetX, offsetY, parent, text)
    local outline = Instance.new("TextLabel")
    outline.Name = "Outline"
    outline.Size = UDim2.new(0, 22, 0, 22)
    outline.Position = UDim2.new(0, offsetX, 0, 3 + offsetY)
    outline.AnchorPoint = Vector2.new(0, 0.5)
    outline.BackgroundTransparency = 1
    outline.Text = text
    outline.TextColor3 = Color3.new(0, 0, 0)
    outline.FontFace = Font.new(
        "rbxasset://fonts/families/GothamSSm.json",
        Enum.FontWeight.ExtraBold,
        Enum.FontStyle.Normal
    )
    outline.TextScaled = true
    outline.ZIndex = 2
    outline.Parent = parent
end

createOutlineLabel(-1, 0, shootButton, "Z")
createOutlineLabel(1, 0, shootButton, "Z")
createOutlineLabel(0, -1, shootButton, "Z")
createOutlineLabel(0, 1, shootButton, "Z")

local keyLabel = Instance.new("TextLabel")
keyLabel.Name = "KeyLabel"
keyLabel.Size = UDim2.new(0, 22, 0, 22)
keyLabel.Position = UDim2.new(0, 0, 0, 3)
keyLabel.AnchorPoint = Vector2.new(0, 0.5)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Z"
keyLabel.TextColor3 = Color3.new(1, 1, 1)
keyLabel.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
keyLabel.TextScaled = true
keyLabel.ZIndex = 3
keyLabel.Parent = shootButton

shootButton.MouseButton1Click:Connect(doShoot)

local flashButton = Instance.new("ImageButton")
flashButton.Name = "FlashButton"
flashButton.Size = UDim2.new(0, 74, 0, 74)
flashButton.BackgroundTransparency = 1
flashButton.Image = "rbxassetid://94420981449604"
flashButton.ZIndex = 1
flashButton.Parent = abilities

local flashText = Instance.new("TextLabel")
flashText.Name = "FlashText"
flashText.Size = UDim2.new(1, -10, 1, -10)
flashText.Position = UDim2.new(0, 5, 0, 5)
flashText.BackgroundTransparency = 1
flashText.Text = "Godspeed Flash"
flashText.TextColor3 = Color3.new(1, 1, 1)
flashText.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
flashText.TextScaled = true
flashText.TextWrapped = true
flashText.ZIndex = 2
flashText.Parent = flashButton

createOutlineLabel(-1, 0, flashButton, "N")
createOutlineLabel(1, 0, flashButton, "N")
createOutlineLabel(0, -1, flashButton, "N")
createOutlineLabel(0, 1, flashButton, "N")

local flashKeyLabel = Instance.new("TextLabel")
flashKeyLabel.Name = "KeyLabel"
flashKeyLabel.Size = UDim2.new(0, 22, 0, 22)
flashKeyLabel.Position = UDim2.new(0, 0, 0, 3)
flashKeyLabel.AnchorPoint = Vector2.new(0, 0.5)
flashKeyLabel.BackgroundTransparency = 1
flashKeyLabel.Text = "N"
flashKeyLabel.TextColor3 = Color3.new(1, 1, 1)
flashKeyLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
flashKeyLabel.TextScaled = true
flashKeyLabel.ZIndex = 3
flashKeyLabel.Parent = flashButton

local function createElectricFlash(root)
    local flashPart = Instance.new("Part")
    flashPart.Shape = Enum.PartType.Ball
    flashPart.Material = Enum.Material.Neon
    flashPart.Color = Color3.fromRGB(0, 170, 255)
    flashPart.Transparency = 0.3
    flashPart.Anchored = true
    flashPart.CanCollide = false
    flashPart.Size = Vector3.new(4, 4, 4)
    flashPart.CFrame = root.CFrame
    flashPart.Parent = workspace

    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(flashPart, tweenInfo, {Transparency = 1})
    tween:Play()

    tween.Completed:Connect(function()
        flashPart:Destroy()
    end)
end

local function flashTeleport()
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local flashSound = Instance.new("Sound")
    flashSound.SoundId = "rbxassetid://81593441952462"
    flashSound.Volume = 2
    flashSound.Parent = root
    flashSound:Play()
    Debris:AddItem(flashSound, 2)

    createElectricFlash(root)

    local forward = root.CFrame.LookVector * 7.5
    root.CFrame = root.CFrame + forward
end

flashButton.MouseButton1Click:Connect(flashTeleport)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.N then
            flashTeleport()
        elseif input.KeyCode == Enum.KeyCode.Z then
            doShoot()
        end
    end
end)
