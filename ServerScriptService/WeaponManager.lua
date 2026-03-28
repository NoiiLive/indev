-- @ScriptType: Script
-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
local weaponActionEvent = ReplicatedStorage:WaitForChild("WeaponActionEvent")
local damageIndicatorEvent = ReplicatedStorage:WaitForChild("DamageIndicatorEvent")
local renderBulletEvent = ReplicatedStorage:WaitForChild("RenderBulletEvent")

weaponActionEvent.OnServerEvent:Connect(function(player, action, weaponName, targetPos, slotIndex)
	local playerFolder = player:FindFirstChild("AvatarData")
	if not playerFolder then return end

	local itemData = GameData.Items[weaponName]
	if not itemData then return end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	local function play3DSound(soundName)
		if not rootPart then return end
		local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
		if soundsFolder then
			local s = soundsFolder:FindFirstChild(soundName)
			if s and s:IsA("Sound") then
				local sClone = s:Clone()
				sClone.Parent = rootPart
				sClone:Play()
				Debris:AddItem(sClone, sClone.TimeLength > 0 and sClone.TimeLength + 0.5 or 2)
			end
		end
	end

	local function spawnBullet()
		if typeof(targetPos) ~= "Vector3" then return end

		local weapon = character:FindFirstChild("EquippedItem")
		local rightArm = character:FindFirstChild("Right Arm")
		local startPos = weapon and weapon.PrimaryPart and weapon.PrimaryPart.Position or (rightArm and rightArm.Position) or (rootPart and rootPart.Position)
		if not startPos then return end

		local direction = (targetPos - startPos).Unit
		local bulletSpeed = itemData.BulletSpeed or 500

		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player then
				renderBulletEvent:FireClient(p, startPos, direction, bulletSpeed, character)
			end
		end

		local bullet = Instance.new("Part")
		bullet.Name = "Bullet"
		bullet.Size = Vector3.new(0.5, 0.5, 1.5)
		bullet.Transparency = 1
		bullet.CanCollide = false
		bullet.Massless = true
		bullet.CFrame = CFrame.lookAt(startPos + direction * 4, startPos + direction * 5)

		local bv = Instance.new("BodyVelocity")
		bv.Velocity = direction * bulletSpeed
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Parent = bullet

		bullet.Parent = workspace

		bullet:SetNetworkOwner(nil)
		bullet.AssemblyLinearVelocity = direction * bulletSpeed

		Debris:AddItem(bullet, 3)

		local hitConnection
		hitConnection = bullet.Touched:Connect(function(hit)
			if hit:IsDescendantOf(character) then return end
			if hit.Name == "VisualBullet" then return end

			local hitName = string.lower(hit.Name)
			if hitName == "fence" or hitName == "water" then return end

			if hitName == "window" and hit.CanCollide then
				local parent = hit.Parent
				local brokenWindows = {}

				if parent and parent ~= workspace then
					for _, child in ipairs(parent:GetChildren()) do
						if child:IsA("BasePart") and string.lower(child.Name) == "window" and child.CanCollide then
							brokenWindows[child] = child.Transparency
							child.Transparency = 1
							child.CanCollide = false
						end
					end
				else
					brokenWindows[hit] = hit.Transparency
					hit.Transparency = 1
					hit.CanCollide = false
				end

				task.delay(10, function()
					for win, origTrans in pairs(brokenWindows) do
						if win and win.Parent then
							win.Transparency = origTrans
							win.CanCollide = true
						end
					end
				end)

				if hitConnection then hitConnection:Disconnect() end
				bullet:Destroy()
				return
			end

			local hitChar = hit.Parent
			local humanoid = hitChar:FindFirstChildOfClass("Humanoid")

			if not humanoid and hitChar.Parent:IsA("Model") then
				hitChar = hitChar.Parent
				humanoid = hitChar:FindFirstChildOfClass("Humanoid")
			end

			if humanoid and humanoid.Health > 0 then
				local isHead = (hit.Name == "Head" or hit.Name == "HeadHitbox")
				local dmg = itemData.Damage or 25
				if isHead then dmg = dmg * 1.5 end
				humanoid:TakeDamage(dmg)

				damageIndicatorEvent:FireClient(player, dmg, hit.Position, isHead)

				if hitConnection then hitConnection:Disconnect() end
				bullet:Destroy()
				return
			end

			if not hit.CanCollide then
				return 
			end

			if hitConnection then hitConnection:Disconnect() end
			bullet:Destroy()
		end)
	end

	if action == "Empty" then
		play3DSound("fire_empty")
	elseif action == "Fire" then
		if itemData.Type == "Consumable" then
			if weaponName == "Ammo Pack" then
				local reserveVal = playerFolder:FindFirstChild("ReserveAmmo")
				if reserveVal then
					reserveVal.Value = reserveVal.Value + 10
					if itemData.UseSound then play3DSound(itemData.UseSound) end

					local invVal = playerFolder:FindFirstChild("InventoryData")
					if invVal then
						local success, inv = pcall(function() return HttpService:JSONDecode(invVal.Value) end)
						if success and inv then
							local consumed = false

							if slotIndex and typeof(slotIndex) == "number" and string.split(inv.Hotbar[slotIndex] or "", "_")[1] == weaponName then
								inv.Hotbar[slotIndex] = ""
								consumed = true
							end

							if not consumed then
								for i=1, 5 do
									if string.split(inv.Hotbar[i] or "", "_")[1] == weaponName then
										inv.Hotbar[i] = ""
										consumed = true
										break
									end
								end
								if not consumed then
									for i=1, 20 do
										if string.split(inv.Stored[i] or "", "_")[1] == weaponName then
											inv.Stored[i] = ""
											break
										end
									end
								end
							end

							if consumed then
								invVal.Value = HttpService:JSONEncode(inv)
							end
						end
					end
				end
			end
		elseif itemData.MaxClip then
			local invVal = playerFolder:FindFirstChild("InventoryData")
			if invVal then
				local success, inv = pcall(function() return HttpService:JSONDecode(invVal.Value) end)
				if success and inv and slotIndex and inv.Hotbar[slotIndex] then
					local rawString = inv.Hotbar[slotIndex]
					local name = string.split(rawString, "_")[1]
					local currentAmmo = tonumber(string.split(rawString, "_")[2]) or 0

					if name == weaponName and currentAmmo > 0 then
						currentAmmo = currentAmmo - 1
						inv.Hotbar[slotIndex] = name .. "_" .. currentAmmo
						invVal.Value = HttpService:JSONEncode(inv)

						if itemData.UseSound then play3DSound(itemData.UseSound) end
						spawnBullet()
					end
				end
			end
		else
			if itemData.UseSound then play3DSound(itemData.UseSound) end
			spawnBullet()
		end
	elseif action == "Reload" then
		if itemData.MaxClip then
			local reserveVal = playerFolder:FindFirstChild("ReserveAmmo")
			local invVal = playerFolder:FindFirstChild("InventoryData")
			if reserveVal and invVal then
				local success, inv = pcall(function() return HttpService:JSONDecode(invVal.Value) end)
				if success and inv and slotIndex and inv.Hotbar[slotIndex] then
					local rawString = inv.Hotbar[slotIndex]
					local name = string.split(rawString, "_")[1]
					local currentAmmo = tonumber(string.split(rawString, "_")[2]) or 0

					if name == weaponName then
						local needed = itemData.MaxClip - currentAmmo
						if needed > 0 and reserveVal.Value > 0 then
							local taken = math.min(needed, reserveVal.Value)
							currentAmmo = currentAmmo + taken
							reserveVal.Value = reserveVal.Value - taken

							inv.Hotbar[slotIndex] = name .. "_" .. currentAmmo
							invVal.Value = HttpService:JSONEncode(inv)

							if itemData.ReloadSound then play3DSound(itemData.ReloadSound) end
						end
					end
				end
			end
		end
	end
end)