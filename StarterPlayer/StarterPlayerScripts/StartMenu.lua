-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local spawnEvent = ReplicatedStorage:WaitForChild("RequestSpawn")
local submitEvent = ReplicatedStorage:WaitForChild("SubmitCharacter")

local selectedGender = nil
local selectedFaction = nil
local selectedSpawn = nil
local selectedSkinIndex = nil

local SkinColors = {
	Color3.fromRGB(253, 242, 178),
	Color3.fromRGB(245, 214, 151),
	Color3.fromRGB(234, 184, 146),
	Color3.fromRGB(204, 142, 105),
	Color3.fromRGB(124, 92, 70),
	Color3.fromRGB(62, 44, 35)
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenuGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(1, 0, 1, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuFrame.ZIndex = 1
menuFrame.Parent = screenGui

local playButton = Instance.new("TextButton")
playButton.Size = UDim2.new(0, 200, 0, 50)
playButton.Position = UDim2.new(0.5, -100, 0.5, -25)
playButton.Text = "BEGIN"
playButton.Font = Enum.Font.Bodoni
playButton.TextSize = 28
playButton.TextColor3 = Color3.fromRGB(200, 200, 200)
playButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
playButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
playButton.BorderSizePixel = 1
playButton.ZIndex = 2
playButton.Parent = menuFrame

local creationFrame = Instance.new("Frame")
creationFrame.Size = UDim2.new(1, 0, 1, 0)
creationFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
creationFrame.Visible = false
creationFrame.ZIndex = 2
creationFrame.Parent = screenGui

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 0, 100)
titleText.Position = UDim2.new(0, 0, 0.15, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "CHOOSE YOUR PATH"
titleText.TextColor3 = Color3.fromRGB(200, 200, 200)
titleText.Font = Enum.Font.Bodoni
titleText.TextSize = 36
titleText.ZIndex = 3
titleText.Parent = creationFrame

local genderContainer = Instance.new("Frame")
genderContainer.Size = UDim2.new(0, 450, 0, 200)
genderContainer.Position = UDim2.new(0.5, -225, 0.45, 0)
genderContainer.BackgroundTransparency = 1
genderContainer.ZIndex = 3
genderContainer.Parent = creationFrame

local genderLayout = Instance.new("UIListLayout")
genderLayout.FillDirection = Enum.FillDirection.Horizontal
genderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
genderLayout.Padding = UDim.new(0, 40)
genderLayout.Parent = genderContainer

local mascButton = Instance.new("TextButton")
mascButton.Size = UDim2.new(0, 180, 0, 50)
mascButton.Text = "MASCULINE"
mascButton.Font = Enum.Font.Bodoni
mascButton.TextSize = 22
mascButton.TextColor3 = Color3.fromRGB(200, 200, 200)
mascButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mascButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
mascButton.BorderSizePixel = 1
mascButton.ZIndex = 4
mascButton.Parent = genderContainer

local femButton = Instance.new("TextButton")
femButton.Size = UDim2.new(0, 180, 0, 50)
femButton.Text = "FEMININE"
femButton.Font = Enum.Font.Bodoni
femButton.TextSize = 22
femButton.TextColor3 = Color3.fromRGB(200, 200, 200)
femButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
femButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
femButton.BorderSizePixel = 1
femButton.ZIndex = 4
femButton.Parent = genderContainer

local skinContainer = Instance.new("Frame")
skinContainer.Size = UDim2.new(0, 500, 0, 100)
skinContainer.Position = UDim2.new(0.5, -250, 0.45, 0)
skinContainer.BackgroundTransparency = 1
skinContainer.Visible = false
skinContainer.ZIndex = 3
skinContainer.Parent = creationFrame

local skinLayout = Instance.new("UIListLayout")
skinLayout.FillDirection = Enum.FillDirection.Horizontal
skinLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
skinLayout.VerticalAlignment = Enum.VerticalAlignment.Center
skinLayout.Padding = UDim.new(0, 20)
skinLayout.Parent = skinContainer

local factionContainer = Instance.new("Frame")
factionContainer.Size = UDim2.new(0, 600, 0, 100)
factionContainer.Position = UDim2.new(0.5, -300, 0.45, 0)
factionContainer.BackgroundTransparency = 1
factionContainer.Visible = false
factionContainer.ZIndex = 3
factionContainer.Parent = creationFrame

local factionLayout = Instance.new("UIListLayout")
factionLayout.FillDirection = Enum.FillDirection.Horizontal
factionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
factionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
factionLayout.Padding = UDim.new(0, 30)
factionLayout.Parent = factionContainer

local spawnContainer = Instance.new("Frame")
spawnContainer.Size = UDim2.new(0, 300, 0, 400)
spawnContainer.Position = UDim2.new(0.5, -150, 0.45, 0)
spawnContainer.BackgroundTransparency = 1
spawnContainer.Visible = false
spawnContainer.ZIndex = 3
spawnContainer.Parent = creationFrame

local spawnLayout = Instance.new("UIListLayout")
spawnLayout.FillDirection = Enum.FillDirection.Vertical
spawnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
spawnLayout.Padding = UDim.new(0, 15)
spawnLayout.Parent = spawnContainer

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
loadingFrame.ZIndex = 10
loadingFrame.Parent = screenGui

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 1, 0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "LOADING..."
loadingText.TextColor3 = Color3.fromRGB(150, 150, 150)
loadingText.Font = Enum.Font.Bodoni
loadingText.TextSize = 24
loadingText.ZIndex = 11
loadingText.Parent = loadingFrame

local spawnsFolder = workspace:WaitForChild("Spawns")

local function createSpawnButton(spawnPart)
	if spawnPart:IsA("BasePart") then
		local spawnBtn = Instance.new("TextButton")
		spawnBtn.Size = UDim2.new(0, 200, 0, 45)
		spawnBtn.Text = string.upper(spawnPart.Name)
		spawnBtn.Font = Enum.Font.Bodoni
		spawnBtn.TextSize = 20
		spawnBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		spawnBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		spawnBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
		spawnBtn.BorderSizePixel = 1
		spawnBtn.ZIndex = 4
		spawnBtn.Parent = spawnContainer

		spawnBtn.MouseButton1Click:Connect(function()
			selectedSpawn = spawnPart.Name

			creationFrame.Visible = false
			loadingText.Text = "AWAKENING..."
			loadingFrame.Visible = true

			local fadeBgIn = TweenService:Create(loadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0})
			local fadeTextIn = TweenService:Create(loadingText, TweenInfo.new(0.5), {TextTransparency = 0})
			fadeTextIn:Play()
			fadeBgIn:Play()
			fadeBgIn.Completed:Wait()

			submitEvent:FireServer(selectedGender, selectedFaction, selectedSpawn, selectedSkinIndex)
			task.wait(1.5)

			local finalFadeBgOut = TweenService:Create(loadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1})
			local finalFadeTextOut = TweenService:Create(loadingText, TweenInfo.new(1), {TextTransparency = 1})
			finalFadeTextOut:Play()
			finalFadeBgOut:Play()
			finalFadeBgOut.Completed:Wait()

			screenGui:Destroy()
		end)
	end
end

for index, color in ipairs(SkinColors) do
	local skinBtn = Instance.new("TextButton")
	skinBtn.Size = UDim2.new(0, 60, 0, 60)
	skinBtn.Text = ""
	skinBtn.BackgroundColor3 = color
	skinBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
	skinBtn.BorderSizePixel = 1
	skinBtn.ZIndex = 4
	skinBtn.Parent = skinContainer

	skinBtn.MouseButton1Click:Connect(function()
		selectedSkinIndex = index
		skinContainer.Visible = false
		titleText.Text = "CHOOSE YOUR ALLEGIANCE"
		factionContainer.Visible = true
	end)
end

local factions = {"STREETS", "MAFIA", "POLICE"}
for _, factionName in ipairs(factions) do
	local facBtn = Instance.new("TextButton")
	facBtn.Size = UDim2.new(0, 150, 0, 50)
	facBtn.Text = factionName
	facBtn.Font = Enum.Font.Bodoni
	facBtn.TextSize = 22
	facBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	facBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	facBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
	facBtn.BorderSizePixel = 1
	facBtn.ZIndex = 4
	facBtn.Parent = factionContainer

	facBtn.MouseButton1Click:Connect(function()
		selectedFaction = factionName
		factionContainer.Visible = false
		titleText.Text = "WHERE WILL YOU BEGIN?"

		for _, child in ipairs(spawnContainer:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local factionFolder = spawnsFolder:FindFirstChild(factionName)
		if factionFolder then
			for _, spawnPart in ipairs(factionFolder:GetChildren()) do
				createSpawnButton(spawnPart)
			end
		end

		spawnContainer.Visible = true
	end)
end

local avatarDataFolder = player:WaitForChild("AvatarData")
task.wait(1)

local fadeBgOut = TweenService:Create(loadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1})
local fadeTextOut = TweenService:Create(loadingText, TweenInfo.new(1), {TextTransparency = 1})
fadeTextOut:Play()
fadeBgOut:Play()
fadeBgOut.Completed:Wait()
loadingFrame.Visible = false

mascButton.MouseButton1Click:Connect(function()
	selectedGender = "Masc"
	genderContainer.Visible = false
	titleText.Text = "SELECT YOUR COMPLEXION"
	skinContainer.Visible = true
end)

femButton.MouseButton1Click:Connect(function()
	selectedGender = "Fem"
	genderContainer.Visible = false
	titleText.Text = "SELECT YOUR COMPLEXION"
	skinContainer.Visible = true
end)

playButton.MouseButton1Click:Connect(function()
	loadingFrame.BackgroundTransparency = 1
	loadingText.TextTransparency = 1
	loadingText.Text = "PREPARING..."
	loadingFrame.Visible = true

	local fadeBgIn = TweenService:Create(loadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0})
	local fadeTextIn = TweenService:Create(loadingText, TweenInfo.new(0.5), {TextTransparency = 0})
	fadeTextIn:Play()
	fadeBgIn:Play()
	fadeBgIn.Completed:Wait()

	menuFrame.Visible = false

	if avatarDataFolder:FindFirstChild("IsNewPlayer") then
		creationFrame.Visible = true

		local outBg = TweenService:Create(loadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
		local outText = TweenService:Create(loadingText, TweenInfo.new(0.5), {TextTransparency = 1})
		outText:Play()
		outBg:Play()
		outBg.Completed:Wait()
		loadingFrame.Visible = false
	else
		loadingText.Text = "ENTERING..."
		spawnEvent:FireServer()

		task.wait(1.5)

		local finalFadeBgOut = TweenService:Create(loadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1})
		local finalFadeTextOut = TweenService:Create(loadingText, TweenInfo.new(1), {TextTransparency = 1})
		finalFadeTextOut:Play()
		finalFadeBgOut:Play()
		finalFadeBgOut.Completed:Wait()

		screenGui:Destroy()
	end
end)