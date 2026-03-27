-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local inventoryGui = Instance.new("ScreenGui")
inventoryGui.Name = "CustomInventory"
inventoryGui.ResetOnSpawn = false
inventoryGui.IgnoreGuiInset = true
inventoryGui.Enabled = false
inventoryGui.Parent = playerGui

task.spawn(function()
	local mainMenu = playerGui:WaitForChild("MainMenuGui", 10)
	if mainMenu then
		mainMenu.Destroying:Wait()
	end
	inventoryGui.Enabled = true
end)

local hotbarFrame = Instance.new("Frame")
hotbarFrame.Size = UDim2.new(0, 350, 0, 70)
hotbarFrame.Position = UDim2.new(0.5, -175, 1, -80)
hotbarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
hotbarFrame.BackgroundTransparency = 0.2
hotbarFrame.BorderSizePixel = 0
hotbarFrame.Parent = inventoryGui

local hotbarLayout = Instance.new("UIListLayout")
hotbarLayout.FillDirection = Enum.FillDirection.Horizontal
hotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hotbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
hotbarLayout.Padding = UDim.new(0, 10)
hotbarLayout.Parent = hotbarFrame

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 500, 0, 400)
menuFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
menuFrame.BorderSizePixel = 1
menuFrame.Visible = false
menuFrame.Parent = inventoryGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "INVENTORY"
titleLabel.Font = Enum.Font.Bodoni
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.Parent = menuFrame

local gridScroll = Instance.new("ScrollingFrame")
gridScroll.Size = UDim2.new(1, -20, 1, -60)
gridScroll.Position = UDim2.new(0, 10, 0, 50)
gridScroll.BackgroundTransparency = 1
gridScroll.BorderSizePixel = 0
gridScroll.ScrollBarThickness = 4
gridScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
gridScroll.Parent = menuFrame

local gridPadding = Instance.new("UIPadding")
gridPadding.PaddingTop = UDim.new(0, 5)
gridPadding.PaddingBottom = UDim.new(0, 5)
gridPadding.Parent = gridScroll

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 80, 0, 80)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.Parent = gridScroll

local hotbarFrames = {}
local hotbarLabels = {}
local storedFrames = {}
local storedLabels = {}

local isDragging = false
local dragData = nil
local dragGhost = nil
local hoverData = nil
local selectedHotbarSlot = nil

local defaultAnimations = {Idle = {}, Walk = nil, Run = nil}
local defaultAnimsSaved = false

local function saveDefaultAnimations(character)
	local animate = character:WaitForChild("Animate", 5)
	if not animate then return end

	if animate:FindFirstChild("idle") then
		defaultAnimations.Idle = {}
		for _, child in ipairs(animate.idle:GetChildren()) do
			if child:IsA("Animation") then
				table.insert(defaultAnimations.Idle, {obj = child, id = child.AnimationId})
			end
		end
	end
	if animate:FindFirstChild("walk") and animate.walk:FindFirstChildWhichIsA("Animation") then
		local anim = animate.walk:FindFirstChildWhichIsA("Animation")
		defaultAnimations.Walk = {obj = anim, id = anim.AnimationId}
	end
	if animate:FindFirstChild("run") and animate.run:FindFirstChildWhichIsA("Animation") then
		local anim = animate.run:FindFirstChildWhichIsA("Animation")
		defaultAnimations.Run = {obj = anim, id = anim.AnimationId}
	end
	defaultAnimsSaved = true
end

local function applyAnimations(itemName)
	local character = player.Character
	if not character then return end
	local animate = character:FindFirstChild("Animate")
	if not animate or not defaultAnimsSaved then return end

	local itemData = nil
	if itemName then
		itemData = GameData.Items[itemName]
	end

	local function setAnim(path, newId)
		if path then
			if newId and newId ~= 0 then
				path.obj.AnimationId = "rbxassetid://" .. tostring(newId)
			else
				path.obj.AnimationId = path.id
			end
		end
	end

	if itemData and itemData.Animations then
		for _, idleData in ipairs(defaultAnimations.Idle) do
			if itemData.Animations.Idle and itemData.Animations.Idle ~= 0 then
				idleData.obj.AnimationId = "rbxassetid://" .. tostring(itemData.Animations.Idle)
			else
				idleData.obj.AnimationId = idleData.id
			end
		end
		setAnim(defaultAnimations.Walk, itemData.Animations.Walk)
		setAnim(defaultAnimations.Run, itemData.Animations.Run)
	else
		for _, idleData in ipairs(defaultAnimations.Idle) do
			idleData.obj.AnimationId = idleData.id
		end
		setAnim(defaultAnimations.Walk, nil)
		setAnim(defaultAnimations.Run, nil)
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local currentState = humanoid:GetState()
		if currentState ~= Enum.HumanoidStateType.Dead then
			humanoid:ChangeState(Enum.HumanoidStateType.None)
			humanoid:ChangeState(currentState)
		end
	end
end

local function updateEquippedItem()
	local selectedItemName = nil
	if selectedHotbarSlot and hotbarLabels[selectedHotbarSlot] then
		selectedItemName = hotbarLabels[selectedHotbarSlot].Text
	end

	if selectedItemName and selectedItemName ~= "" then
		applyAnimations(selectedItemName)
	else
		applyAnimations(nil)
	end
end

local function selectSlot(index)
	if selectedHotbarSlot == index then
		selectedHotbarSlot = nil
	else
		selectedHotbarSlot = index
	end

	for i, frame in ipairs(hotbarFrames) do
		if i == selectedHotbarSlot then
			frame.BorderColor3 = Color3.fromRGB(200, 200, 200)
			frame.BorderSizePixel = 2
		else
			frame.BorderColor3 = Color3.fromRGB(80, 80, 80)
			frame.BorderSizePixel = 1
		end
	end

	updateEquippedItem()
end

local function startDrag(slotType, index, itemName)
	if isDragging then return end
	isDragging = true
	dragData = {Type = slotType, Index = index, Item = itemName}

	dragGhost = Instance.new("TextLabel")
	dragGhost.Size = UDim2.new(0, 60, 0, 60)
	dragGhost.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	dragGhost.BorderColor3 = Color3.fromRGB(200, 200, 200)
	dragGhost.BorderSizePixel = 2
	dragGhost.Text = itemName
	dragGhost.Font = Enum.Font.Bodoni
	dragGhost.TextSize = 10
	dragGhost.TextColor3 = Color3.fromRGB(200, 200, 200)
	dragGhost.TextWrapped = true
	dragGhost.ZIndex = 100
	dragGhost.Active = false
	dragGhost.Parent = inventoryGui

	local mousePos = UserInputService:GetMouseLocation()
	dragGhost.Position = UDim2.new(0, mousePos.X + 5, 0, mousePos.Y + 5)

	if slotType == "Hotbar" then
		hotbarLabels[index].Text = ""
	else
		storedLabels[index].Text = ""
	end
end

for i = 1, 5 do
	local slot = Instance.new("Frame")
	slot.Size = UDim2.new(0, 60, 0, 60)
	slot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	slot.BorderColor3 = Color3.fromRGB(80, 80, 80)
	slot.BorderSizePixel = 1
	slot.Parent = hotbarFrame

	local numberLabel = Instance.new("TextLabel")
	numberLabel.Size = UDim2.new(0, 15, 0, 15)
	numberLabel.Position = UDim2.new(0, 2, 0, 2)
	numberLabel.BackgroundTransparency = 1
	numberLabel.Text = tostring(i)
	numberLabel.Font = Enum.Font.Bodoni
	numberLabel.TextSize = 14
	numberLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	numberLabel.Parent = slot

	local itemLabel = Instance.new("TextLabel")
	itemLabel.Size = UDim2.new(1, -10, 1, -20)
	itemLabel.Position = UDim2.new(0, 5, 0, 15)
	itemLabel.BackgroundTransparency = 1
	itemLabel.Text = ""
	itemLabel.Font = Enum.Font.Bodoni
	itemLabel.TextSize = 10
	itemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	itemLabel.TextWrapped = true
	itemLabel.Parent = slot

	slot.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			selectSlot(i)
			if itemLabel.Text ~= "" and menuFrame.Visible then
				startDrag("Hotbar", i, itemLabel.Text)
			end
		end
	end)

	slot.MouseEnter:Connect(function() hoverData = {Type = "Hotbar", Index = i} end)
	slot.MouseLeave:Connect(function()
		if hoverData and hoverData.Type == "Hotbar" and hoverData.Index == i then hoverData = nil end
	end)

	hotbarFrames[i] = slot
	hotbarLabels[i] = itemLabel
end

for i = 1, 20 do
	local slot = Instance.new("Frame")
	slot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	slot.BorderColor3 = Color3.fromRGB(80, 80, 80)
	slot.BorderSizePixel = 1
	slot.Parent = gridScroll

	local itemLabel = Instance.new("TextLabel")
	itemLabel.Size = UDim2.new(1, -10, 1, -10)
	itemLabel.Position = UDim2.new(0, 5, 0, 5)
	itemLabel.BackgroundTransparency = 1
	itemLabel.Text = ""
	itemLabel.Font = Enum.Font.Bodoni
	itemLabel.TextSize = 12
	itemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	itemLabel.TextWrapped = true
	itemLabel.Parent = slot

	slot.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if itemLabel.Text ~= "" and menuFrame.Visible then
				startDrag("Stored", i, itemLabel.Text)
			end
		end
	end)

	slot.MouseEnter:Connect(function() hoverData = {Type = "Stored", Index = i} end)
	slot.MouseLeave:Connect(function()
		if hoverData and hoverData.Type == "Stored" and hoverData.Index == i then hoverData = nil end
	end)

	storedFrames[i] = slot
	storedLabels[i] = itemLabel
end

local function refreshInventory()
	if isDragging then return end
	local avatarData = player:FindFirstChild("AvatarData")
	if not avatarData then return end

	local invVal = avatarData:FindFirstChild("InventoryData")
	if not invVal or invVal.Value == "" then return end

	local success, data = pcall(function() return HttpService:JSONDecode(invVal.Value) end)

	if success and data then
		for i = 1, 5 do
			hotbarLabels[i].Text = data.Hotbar[i] or ""
		end
		for i = 1, 20 do
			storedLabels[i].Text = data.Stored[i] or ""
		end
		updateEquippedItem()
	end
end

UserInputService.InputChanged:Connect(function(input)
	if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		if dragGhost then
			local mousePos = UserInputService:GetMouseLocation()
			dragGhost.Position = UDim2.new(0, mousePos.X + 5, 0, mousePos.Y + 5)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
		isDragging = false
		if dragGhost then dragGhost:Destroy() dragGhost = nil end

		if hoverData then
			local avatarData = player:FindFirstChild("AvatarData")
			local invVal = avatarData and avatarData:FindFirstChild("InventoryData")
			if invVal then
				local data = HttpService:JSONDecode(invVal.Value)
				for i=1, 5 do data.Hotbar[i] = data.Hotbar[i] or "" end
				for i=1, 20 do data.Stored[i] = data.Stored[i] or "" end

				local targetItem = ""
				if hoverData.Type == "Hotbar" then targetItem = data.Hotbar[hoverData.Index] else targetItem = data.Stored[hoverData.Index] end

				if hoverData.Type == "Hotbar" then data.Hotbar[hoverData.Index] = dragData.Item else data.Stored[hoverData.Index] = dragData.Item end
				if dragData.Type == "Hotbar" then data.Hotbar[dragData.Index] = targetItem else data.Stored[dragData.Index] = targetItem end

				ReplicatedStorage:WaitForChild("InventoryEvent"):FireServer(HttpService:JSONEncode(data))
			end
		else
			refreshInventory() 
		end
		dragData = nil
	end
end)

player.ChildAdded:Connect(function(child)
	if child.Name == "AvatarData" then
		refreshInventory()
		child.ChildAdded:Connect(function(val)
			if val.Name == "InventoryData" then
				refreshInventory()
				val.Changed:Connect(refreshInventory)
			end
		end)
	end
end)

player.CharacterAdded:Connect(function(char)
	defaultAnimsSaved = false
	saveDefaultAnimations(char)
	updateEquippedItem()
end)

if player.Character then
	saveDefaultAnimations(player.Character)
end

local existingData = player:FindFirstChild("AvatarData")
if existingData then
	local invVal = existingData:FindFirstChild("InventoryData")
	if invVal then
		invVal.Changed:Connect(refreshInventory)
	end
	existingData.ChildAdded:Connect(function(val)
		if val.Name == "InventoryData" then
			refreshInventory()
			val.Changed:Connect(refreshInventory)
		end
	end)
	refreshInventory()
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.B or input.KeyCode == Enum.KeyCode.Backquote then
		menuFrame.Visible = not menuFrame.Visible
	elseif input.KeyCode == Enum.KeyCode.One then
		selectSlot(1)
	elseif input.KeyCode == Enum.KeyCode.Two then
		selectSlot(2)
	elseif input.KeyCode == Enum.KeyCode.Three then
		selectSlot(3)
	elseif input.KeyCode == Enum.KeyCode.Four then
		selectSlot(4)
	elseif input.KeyCode == Enum.KeyCode.Five then
		selectSlot(5)
	end
end)