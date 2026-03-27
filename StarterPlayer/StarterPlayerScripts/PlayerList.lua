-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
end)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local listGui = Instance.new("ScreenGui")
listGui.Name = "CustomLeaderboard"
listGui.ResetOnSpawn = false
listGui.Enabled = true
listGui.IgnoreGuiInset = true
listGui.Parent = playerGui

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0, 300, 0, 400)
scrollFrame.AnchorPoint = Vector2.new(1, 0)
scrollFrame.Position = UDim2.new(1, -10, 0, 10)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrollFrame.Parent = listGui

local uiScale = Instance.new("UIScale")
uiScale.Scale = 0
uiScale.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

local isListOpen = false
local popIn = TweenService:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
local popOut = TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})

local function refreshLeaderboard()
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local players = Players:GetPlayers()
	local totalY = 0

	for _, p in ipairs(players) do
		local entryBox = Instance.new("Frame")
		entryBox.Size = UDim2.new(1, -10, 0, 40)
		entryBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		entryBox.BackgroundTransparency = 0.2
		entryBox.BorderColor3 = Color3.fromRGB(80, 80, 80)
		entryBox.BorderSizePixel = 1
		entryBox.Name = p.Name
		entryBox.Parent = scrollFrame

		local entryText = Instance.new("TextLabel")
		entryText.Size = UDim2.new(1, 0, 1, 0)
		entryText.BackgroundTransparency = 1
		entryText.Font = Enum.Font.Bodoni
		entryText.TextSize = 18
		entryText.TextColor3 = Color3.fromRGB(200, 200, 200)
		entryText.TextXAlignment = Enum.TextXAlignment.Right

		local padding = Instance.new("UIPadding")
		padding.PaddingRight = UDim.new(0, 15)
		padding.Parent = entryText

		local displayName = p.Name
		local avatarData = p:FindFirstChild("AvatarData")
		if avatarData then
			local fName = avatarData:FindFirstChild("FirstName")
			local lName = avatarData:FindFirstChild("LastName")
			if fName and lName then
				displayName = fName.Value .. " " .. lName.Value .. " (" .. p.Name .. ")"
			else
				displayName = "UNKNOWN (" .. p.Name .. ")"
			end
		end

		entryText.Text = displayName
		entryText.Parent = entryBox

		totalY = totalY + 45
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalY)
end

Players.PlayerAdded:Connect(function(newPlayer)
	refreshLeaderboard()
	newPlayer.ChildAdded:Connect(function(child)
		if child.Name == "AvatarData" then
			refreshLeaderboard()
			child.ChildAdded:Connect(function(val)
				refreshLeaderboard()
				val.Changed:Connect(refreshLeaderboard)
			end)
			for _, val in ipairs(child:GetChildren()) do
				val.Changed:Connect(refreshLeaderboard)
			end
		end
	end)
end)

Players.PlayerRemoving:Connect(refreshLeaderboard)

for _, p in ipairs(Players:GetPlayers()) do
	p.ChildAdded:Connect(function(child)
		if child.Name == "AvatarData" then
			refreshLeaderboard()
			child.ChildAdded:Connect(function(val)
				refreshLeaderboard()
				val.Changed:Connect(refreshLeaderboard)
			end)
			for _, val in ipairs(child:GetChildren()) do
				val.Changed:Connect(refreshLeaderboard)
			end
		end
	end)

	local existingData = p:FindFirstChild("AvatarData")
	if existingData then
		existingData.ChildAdded:Connect(function(val)
			refreshLeaderboard()
			val.Changed:Connect(refreshLeaderboard)
		end)
		for _, val in ipairs(existingData:GetChildren()) do
			val.Changed:Connect(refreshLeaderboard)
		end
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Tab then
		isListOpen = not isListOpen
		if isListOpen then
			popOut:Cancel()
			popIn:Play()
		else
			popIn:Cancel()
			popOut:Play()
		end
	end
end)

task.spawn(function()
	while playerGui:FindFirstChild("MainMenuGui") do
		task.wait(0.5)
	end
	isListOpen = true
	popIn:Play()
	refreshLeaderboard()
end)