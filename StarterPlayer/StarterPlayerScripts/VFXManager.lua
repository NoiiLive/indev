-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
local VFXManager = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

local function getCharacterIgnoreList(extraObjects)
	local list = {}
	if extraObjects then
		for _, obj in ipairs(extraObjects) do
			if obj then table.insert(list, obj) end
		end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then table.insert(list, p.Character) end
	end
	return list
end

local function playHitSound(position, soundName)
	local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
	if soundsFolder then
		local s = soundsFolder:FindFirstChild(soundName)
		if s and s:IsA("Sound") then
			local soundPart = Instance.new("Part")
			soundPart.Name = "HitSoundEmitter"
			soundPart.Size = Vector3.new(0.1, 0.1, 0.1)
			soundPart.Transparency = 1
			soundPart.CanCollide = false
			soundPart.Anchored = true
			soundPart.Position = position
			soundPart.Parent = workspace

			local sClone = s:Clone()
			sClone.PlaybackSpeed = sClone.PlaybackSpeed * (math.random(85, 115) / 100)
			sClone.Parent = soundPart
			sClone:Play()

			Debris:AddItem(soundPart, sClone.TimeLength > 0 and (sClone.TimeLength / sClone.PlaybackSpeed) + 0.5 or 2)
		end
	end
end

local function spawnHitParticles(position, bulletDirection, hitPart, isBlood, ignoreCharacter)
	local numParticles = math.random(3, 5)

	for i = 1, numParticles do
		local p = Instance.new("Part")

		if isBlood then
			p.Size = Vector3.new(0.2, 0.2, 0.2) 
			p.Color = Color3.fromRGB(130, 0, 0)
			p.Material = Enum.Material.Plastic 
		else
			p.Size = Vector3.new(0.4, 0.4, 0.4)
			p.Color = hitPart.Color
			p.Material = hitPart.Material
		end

		p.CanCollide = false
		p.Massless = true
		p.Position = position

		local att0 = Instance.new("Attachment", p)
		att0.Position = Vector3.new(0, 0.075, 0)
		local att1 = Instance.new("Attachment", p)
		att1.Position = Vector3.new(0, -0.075, 0)

		local trail = Instance.new("Trail")
		trail.Attachment0 = att0
		trail.Attachment1 = att1
		trail.Color = ColorSequence.new(p.Color)
		trail.Lifetime = 0.15
		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
		trail.Parent = p

		p.Parent = workspace

		local scatterDir = (-bulletDirection + Vector3.new(math.random(-15, 15)/10, math.random(5, 20)/10, math.random(-15, 15)/10)).Unit
		local scatterSpeed = math.random(15, 35)

		p.AssemblyLinearVelocity = scatterDir * scatterSpeed
		p.AssemblyAngularVelocity = Vector3.new(math.random(-30, 30), math.random(-30, 30), math.random(-30, 30))

		if isBlood then
			local hitConn
			hitConn = p.Touched:Connect(function(hitObj)
				local hitName = string.lower(hitObj.Name)
				if hitName == "hitbox" or hitName == "headhitbox" or hitName == "visualbullet" or hitName == "visualbullethitbox" or hitName == "bullet" or hitName == "fence" or hitName == "water" then return end

				if hitObj.Parent and hitObj.Parent:FindFirstChildOfClass("Humanoid") then return end
				if not hitObj.CanCollide then return end

				if hitConn then hitConn:Disconnect() end

				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = getCharacterIgnoreList({p, ignoreCharacter})
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
				rayParams.RespectCanCollide = true 

				local moveDir = p.AssemblyLinearVelocity.Magnitude > 0.1 and p.AssemblyLinearVelocity.Unit or Vector3.new(0, -1, 0)
				local ray = workspace:Raycast(p.Position - moveDir, moveDir * 3, rayParams)

				if ray and ray.Normal.Y > 0.7 then
					local puddle = Instance.new("Part")
					puddle.Size = Vector3.new(math.random(10, 15)/10, math.random(10, 15)/10, 0.02)
					puddle.Color = Color3.fromRGB(130, 0, 0)
					puddle.Material = Enum.Material.Plastic 
					puddle.Anchored = true
					puddle.CanCollide = false
					puddle.Massless = true
					puddle.CFrame = CFrame.lookAt(ray.Position + ray.Normal * 0.01, ray.Position + ray.Normal) * CFrame.Angles(0, 0, math.random() * math.pi * 2)
					puddle.Parent = workspace
					Debris:AddItem(puddle, 15)
				end

				p:Destroy()
			end)
		end

		Debris:AddItem(p, isBlood and 5 or math.random(8, 15)/10)
	end
end

function VFXManager.renderVisualBullet(startPos, direction, speed, ignoreCharacter)
	local visualHitbox = Instance.new("Part")
	visualHitbox.Name = "VisualBulletHitbox"
	visualHitbox.Size = Vector3.new(0.5, 0.5, 1.5)
	visualHitbox.Transparency = 1
	visualHitbox.CanCollide = false
	visualHitbox.Massless = true
	visualHitbox.CFrame = CFrame.lookAt(startPos + direction * 4, startPos + direction * 5)

	local visual = Instance.new("Part")
	visual.Name = "VisualBullet"
	visual.Shape = Enum.PartType.Ball
	visual.Size = Vector3.new(0.2, 0.2, 0.2)
	visual.BrickColor = BrickColor.new("New Yeller")
	visual.Material = Enum.Material.Neon
	visual.CanCollide = false
	visual.Massless = true
	visual.CFrame = visualHitbox.CFrame
	visual.Parent = visualHitbox

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = visualHitbox
	weld.Part1 = visual
	weld.Parent = visual

	local att0 = Instance.new("Attachment", visual)
	att0.Position = Vector3.new(0, 0.1, 0)
	local att1 = Instance.new("Attachment", visual)
	att1.Position = Vector3.new(0, -0.1, 0)

	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = ColorSequence.new(Color3.new(1, 0.8, 0))
	trail.Lifetime = 0.15
	trail.MinLength = 0

	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

	trail.Parent = visual

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = direction * speed
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Parent = visualHitbox

	visualHitbox.Parent = workspace
	Debris:AddItem(visualHitbox, 3)

	local hitConnection
	hitConnection = visualHitbox.Touched:Connect(function(hit)
		if ignoreCharacter and hit:IsDescendantOf(ignoreCharacter) then return end
		if hit.Name == "VisualBullet" or hit.Name == "VisualBulletHitbox" or hit.Name == "Bullet" or hit.Name == "BulletHitbox" then return end

		local hitName = string.lower(hit.Name)
		if hitName == "fence" or hitName == "water" then return end

		if hitName == "window" and hit.CanCollide then
			local parent = hit.Parent
			if parent and parent ~= workspace then
				for _, child in ipairs(parent:GetChildren()) do
					if child:IsA("BasePart") and string.lower(child.Name) == "window" and child.CanCollide then
						child.Transparency = 1
						child.CanCollide = false
					end
				end
			else
				hit.Transparency = 1
				hit.CanCollide = false
			end
			playHitSound(visualHitbox.Position, "hit_glass")
			spawnHitParticles(visualHitbox.Position, direction, hit, false, ignoreCharacter)
			if hitConnection then hitConnection:Disconnect() end
			visualHitbox:Destroy()
			return
		end

		local hitChar = hit.Parent
		local humanoid = hitChar:FindFirstChildOfClass("Humanoid")

		if not humanoid and hitChar.Parent:IsA("Model") then
			hitChar = hitChar.Parent
			humanoid = hitChar:FindFirstChildOfClass("Humanoid")
		end

		if humanoid then
			playHitSound(visualHitbox.Position, "hit_person")
			spawnHitParticles(visualHitbox.Position, direction, hit, true, ignoreCharacter)
			if hitConnection then hitConnection:Disconnect() end
			visualHitbox:Destroy()
			return
		end

		if not hit.CanCollide then return end

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = getCharacterIgnoreList({visualHitbox, ignoreCharacter})
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.RespectCanCollide = true 

		local dist = (visualHitbox.Position - startPos).Magnitude
		local ray = workspace:Raycast(startPos, direction * (dist + 5), rayParams)

		if ray then
			local hole = Instance.new("Part")
			hole.Size = Vector3.new(0.25, 0.25, 0.02)
			hole.Color = Color3.new(0, 0, 0)
			hole.Material = Enum.Material.Neon
			hole.Anchored = true
			hole.CanCollide = false
			hole.Massless = true
			hole.CFrame = CFrame.lookAt(ray.Position + ray.Normal * 0.01, ray.Position + ray.Normal) * CFrame.Angles(0, 0, math.random() * math.pi * 2)
			hole.Parent = workspace
			Debris:AddItem(hole, 15)
		end

		playHitSound(visualHitbox.Position, "hit_ground")
		spawnHitParticles(visualHitbox.Position, direction, hit, false, ignoreCharacter)
		if hitConnection then hitConnection:Disconnect() end
		visualHitbox:Destroy()
	end)
end

-- Hook up the server event directly inside the module so InventoryManager doesn't have to!
local renderBulletEvent = ReplicatedStorage:WaitForChild("RenderBulletEvent")
renderBulletEvent.OnClientEvent:Connect(function(startPos, direction, speed, ignoreCharacter)
	VFXManager.renderVisualBullet(startPos, direction, speed, ignoreCharacter)
end)

return VFXManager