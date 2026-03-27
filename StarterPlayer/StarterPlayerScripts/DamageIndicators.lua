-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local damageEvent = ReplicatedStorage:WaitForChild("DamageIndicatorEvent")

damageEvent.OnClientEvent:Connect(function(damageAmount, hitPosition, isHeadshot)
	local part = Instance.new("Part")
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Size = Vector3.new(1, 1, 1)

	part.Position = hitPosition + Vector3.new(math.random(-15, 15)/10, math.random(0, 15)/10, math.random(-15, 15)/10)
	part.Parent = workspace

	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(0, 150, 0, 50)
	bg.StudsOffset = Vector3.new(0, 1, 0)
	bg.AlwaysOnTop = true
	bg.Parent = part

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.Text = tostring(math.floor(damageAmount))
	txt.Font = Enum.Font.Bodoni
	txt.TextScaled = true

	if isHeadshot then
		txt.TextColor3 = Color3.fromRGB(255, 50, 50)
		txt.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
		txt.TextStrokeTransparency = 0
	else
		txt.TextColor3 = Color3.fromRGB(255, 255, 255)
		txt.TextStrokeColor3 = Color3.fromRGB(50, 50, 50)
		txt.TextStrokeTransparency = 0
	end
	txt.Parent = bg

	Debris:AddItem(part, 1)

	local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local moveTween = TweenService:Create(bg, tweenInfo, {StudsOffset = Vector3.new(0, 4, 0)})
	local fadeTween = TweenService:Create(txt, tweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1})

	moveTween:Play()
	fadeTween:Play()
end)