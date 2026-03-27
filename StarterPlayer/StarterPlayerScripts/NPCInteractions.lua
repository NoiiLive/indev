-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local barberEvent = ReplicatedStorage:WaitForChild("BarberEvent")

local npcData = {
	Barber = {
		Name = "THE BARBER",
		Text = "Take a seat. What do we need to fix today?",
		Options = {
			{Text = "I want to change my hair.", Action = "OpenBarberMenu"},
			{Text = "I want to change my hair color.", Action = "RandomizeHairColor"},
			{Text = "Leave.", Action = "Close"}
		}
	}
}

local playerGui = player:WaitForChild("PlayerGui")
local activeConversationNPC = nil

local function applyPadding(parent, top, left, right, bottom)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top or 10)
	padding.PaddingLeft = UDim.new(0, left or 15)
	padding.PaddingRight = UDim.new(0, right or 15)
	padding.PaddingBottom = UDim.new(0, bottom or 10)
	padding.Parent = parent
end

local dialogueGui = Instance.new("ScreenGui")
dialogueGui.Name = "DialogueGui"
dialogueGui.ResetOnSpawn = false
dialogueGui.Enabled = false
dialogueGui.Parent = playerGui

local dialogueFrame = Instance.new("Frame")
dialogueFrame.Size = UDim2.new(0, 450, 0, 180)
dialogueFrame.Position = UDim2.new(0.5, -225, 1, -220)
dialogueFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
dialogueFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
dialogueFrame.BorderSizePixel = 1
dialogueFrame.Parent = dialogueGui
applyPadding(dialogueFrame)

local npcNameLabel = Instance.new("TextLabel")
npcNameLabel.Size = UDim2.new(1, 0, 0, 30)
npcNameLabel.BackgroundTransparency = 1
npcNameLabel.Font = Enum.Font.Bodoni
npcNameLabel.TextSize = 22
npcNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
npcNameLabel.TextXAlignment = Enum.TextXAlignment.Left
npcNameLabel.Parent = dialogueFrame

local npcTextLabel = Instance.new("TextLabel")
npcTextLabel.Size = UDim2.new(1, 0, 0, 40)
npcTextLabel.Position = UDim2.new(0, 0, 0, 35)
npcTextLabel.BackgroundTransparency = 1
npcTextLabel.Font = Enum.Font.Bodoni
npcTextLabel.TextSize = 16
npcTextLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
npcTextLabel.TextXAlignment = Enum.TextXAlignment.Left
npcTextLabel.TextYAlignment = Enum.TextYAlignment.Top
npcTextLabel.TextWrapped = true
npcTextLabel.Parent = dialogueFrame

local optionsScroll = Instance.new("ScrollingFrame")
optionsScroll.Size = UDim2.new(1, 0, 1, -85)
optionsScroll.Position = UDim2.new(0, 0, 0, 85)
optionsScroll.BackgroundTransparency = 1
optionsScroll.BorderSizePixel = 0
optionsScroll.ScrollBarThickness = 2
optionsScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
optionsScroll.Parent = dialogueFrame
applyPadding(optionsScroll, 5, 5, 15, 5)

local optionsLayout = Instance.new("UIListLayout")
optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionsLayout.Padding = UDim.new(0, 4)
optionsLayout.Parent = optionsScroll

local barberGui = Instance.new("ScreenGui")
barberGui.Name = "BarberGui"
barberGui.ResetOnSpawn = false
barberGui.Enabled = false
barberGui.Parent = playerGui

local barberFrame = Instance.new("Frame")
barberFrame.Size = UDim2.new(0, 260, 0, 340)
barberFrame.Position = UDim2.new(0.5, -130, 0.5, -170)
barberFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
barberFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
barberFrame.BorderSizePixel = 1
barberFrame.Parent = barberGui
applyPadding(barberFrame)

local barberTitle = Instance.new("TextLabel")
barberTitle.Size = UDim2.new(1, 0, 0, 40)
barberTitle.BackgroundTransparency = 1
barberTitle.Text = "THE BARBER"
barberTitle.Font = Enum.Font.Bodoni
barberTitle.TextSize = 24
barberTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
barberTitle.Parent = barberFrame

local inputs = {}
for i = 1, 3 do
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 35)
	box.Position = UDim2.new(0, 0, 0, 50 + ((i-1) * 45))
	box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	box.BorderColor3 = Color3.fromRGB(80, 80, 80)
	box.BorderSizePixel = 1
	box.Font = Enum.Font.Bodoni
	box.TextSize = 16
	box.TextColor3 = Color3.fromRGB(200, 200, 200)
	box.PlaceholderText = "HAIR ID " .. i
	box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
	box.Text = ""
	box.ClearTextOnFocus = false
	box.Parent = barberFrame
	table.insert(inputs, box)
end

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 35)
saveBtn.Position = UDim2.new(0, 0, 0, 195)
saveBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
saveBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
saveBtn.BorderSizePixel = 1
saveBtn.Text = "APPLY STYLE"
saveBtn.Font = Enum.Font.Bodoni
saveBtn.TextSize = 16
saveBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
saveBtn.Parent = barberFrame

local defaultBtn = Instance.new("TextButton")
defaultBtn.Size = UDim2.new(1, 0, 0, 35)
defaultBtn.Position = UDim2.new(0, 0, 0, 240)
defaultBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
defaultBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
defaultBtn.BorderSizePixel = 1
defaultBtn.Text = "RESET TO DEFAULT"
defaultBtn.Font = Enum.Font.Bodoni
defaultBtn.TextSize = 16
defaultBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
defaultBtn.Parent = barberFrame

local closeBarberBtn = Instance.new("TextButton")
closeBarberBtn.Size = UDim2.new(1, 0, 0, 35)
closeBarberBtn.Position = UDim2.new(0, 0, 0, 285)
closeBarberBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
closeBarberBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
closeBarberBtn.BorderSizePixel = 1
closeBarberBtn.Text = "CLOSE"
closeBarberBtn.Font = Enum.Font.Bodoni
closeBarberBtn.TextSize = 16
closeBarberBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBarberBtn.Parent = barberFrame

local promptGui = Instance.new("ScreenGui")
promptGui.Name = "PromptGui"
promptGui.ResetOnSpawn = false
promptGui.Parent = playerGui

local promptFrame = Instance.new("Frame")
promptFrame.Size = UDim2.new(0, 160, 0, 35)
promptFrame.Position = UDim2.new(0.5, -80, 1, -100)
promptFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
promptFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
promptFrame.BorderSizePixel = 1
promptFrame.Visible = false
promptFrame.Parent = promptGui

local promptText = Instance.new("TextLabel")
promptText.Size = UDim2.new(1, 0, 1, 0)
promptText.BackgroundTransparency = 1
promptText.Text = "INTERACT [E]"
promptText.Font = Enum.Font.Bodoni
promptText.TextSize = 16
promptText.TextColor3 = Color3.fromRGB(200, 200, 200)
promptText.Parent = promptFrame

local function closeDialogue()
	dialogueGui.Enabled = false
	barberGui.Enabled = false
	activeConversationNPC = nil
	for _, child in ipairs(optionsScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
end

local function handleAction(actionId)
	if actionId == "Close" then 
		closeDialogue()
	elseif actionId == "OpenBarberMenu" then 
		dialogueGui.Enabled = false
		barberGui.Enabled = true 
	elseif actionId == "RandomizeHairColor" then
		barberEvent:FireServer("RandomColor")
	end
end

local function openDialogue(npcId, npcPart)
	local data = npcData[npcId]
	if not data then return end
	closeDialogue()
	activeConversationNPC = npcPart
	npcNameLabel.Text = data.Name
	npcTextLabel.Text = data.Text
	local totalY = 0
	for i, option in ipairs(data.Options) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -5, 0, 30)
		btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		btn.BorderColor3 = Color3.fromRGB(80, 80, 80)
		btn.BorderSizePixel = 1
		btn.Text = " > " .. option.Text
		btn.Font = Enum.Font.Bodoni
		btn.TextSize = 14
		btn.TextColor3 = Color3.fromRGB(180, 180, 180)
		btn.TextXAlignment = Enum.TextXAlignment.Left
		local btnPadding = Instance.new("UIPadding")
		btnPadding.PaddingLeft = UDim.new(0, 10)
		btnPadding.Parent = btn
		btn.LayoutOrder = i
		btn.Parent = optionsScroll
		btn.MouseButton1Click:Connect(function() handleAction(option.Action) end)
		totalY = totalY + 34
	end
	optionsScroll.CanvasSize = UDim2.new(0, 0, 0, totalY)
	dialogueGui.Enabled = true
end

closeBarberBtn.MouseButton1Click:Connect(function() barberGui.Enabled = false; activeConversationNPC = nil end)
saveBtn.MouseButton1Click:Connect(function()
	local ids = {}
	for _, box in ipairs(inputs) do
		local text = box.Text:gsub("%s+", "") 
		if text ~= "" and tonumber(text) then table.insert(ids, text) end
	end
	barberEvent:FireServer("Custom", table.concat(ids, ","))
	barberGui.Enabled = false
	activeConversationNPC = nil
end)
defaultBtn.MouseButton1Click:Connect(function() 
	barberEvent:FireServer("Default")
	barberGui.Enabled = false 
	activeConversationNPC = nil
end)

local currentTarget = nil
local interactRadius = 8
local autoCloseRadius = 12

RunService.RenderStepped:Connect(function()
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		promptFrame.Visible = false
		currentTarget = nil
		return
	end

	local hrp = player.Character.HumanoidRootPart

	if activeConversationNPC then
		local dist = (hrp.Position - activeConversationNPC.Position).Magnitude
		if dist > autoCloseRadius then
			closeDialogue()
		end
	end

	if dialogueGui.Enabled or barberGui.Enabled then
		promptFrame.Visible = false
		return
	end

	local npcsFolder = workspace:FindFirstChild("NPCs")
	if not npcsFolder then return end

	local closestNPC = nil
	local shortestDistance = interactRadius

	for _, npc in ipairs(npcsFolder:GetChildren()) do
		if npc:IsA("BasePart") then
			local dist = (hrp.Position - npc.Position).Magnitude
			if dist <= shortestDistance and npcData[npc.Name] then 
				shortestDistance = dist; closestNPC = npc 
			end
		end
	end

	if closestNPC then
		if currentTarget ~= closestNPC then currentTarget = closestNPC; promptFrame.Visible = true end
	else
		if currentTarget ~= nil then currentTarget = nil; promptFrame.Visible = false end
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.E and currentTarget then
		if not dialogueGui.Enabled and not barberGui.Enabled then 
			openDialogue(currentTarget.Name, currentTarget) 
		end
	end
end)