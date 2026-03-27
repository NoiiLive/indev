-- @ScriptType: Script
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

local AvatarDataStore = DataStoreService:GetDataStore("AvatarDataStore")

local spawnEvent = Instance.new("RemoteEvent")
spawnEvent.Name = "RequestSpawn"
spawnEvent.Parent = ReplicatedStorage

local submitEvent = Instance.new("RemoteEvent")
submitEvent.Name = "SubmitCharacter"
submitEvent.Parent = ReplicatedStorage

local rerollEvent = Instance.new("RemoteEvent")
rerollEvent.Name = "RerollAppearance"
rerollEvent.Parent = ReplicatedStorage

local barberEvent = Instance.new("RemoteEvent")
barberEvent.Name = "BarberEvent"
barberEvent.Parent = ReplicatedStorage

local inventoryEvent = Instance.new("RemoteEvent")
inventoryEvent.Name = "InventoryEvent"
inventoryEvent.Parent = ReplicatedStorage

local equipEvent = Instance.new("RemoteEvent")
equipEvent.Name = "EquipEvent"
equipEvent.Parent = ReplicatedStorage

local weaponActionEvent = Instance.new("RemoteEvent")
weaponActionEvent.Name = "WeaponActionEvent"
weaponActionEvent.Parent = ReplicatedStorage

local damageIndicatorEvent = Instance.new("RemoteEvent")
damageIndicatorEvent.Name = "DamageIndicatorEvent"
damageIndicatorEvent.Parent = ReplicatedStorage

local initialInventory = HttpService:JSONEncode({
	Hotbar = {GameData.Items["Smith & Wesson .38"].Name, "", "", "", ""},
	Stored = {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""}
})

local Pools = {
	Masc = {
		FirstNames = {
			"James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph", "Thomas", "Charles", 
			"Christopher", "Daniel", "Matthew", "Anthony", "Mark", "Donald", "Steven", "Paul", "Andrew", "Joshua", 
			"Kenneth", "Kevin", "Brian", "George", "Timothy", "Ronald", "Edward", "Jason", "Jeffrey", "Ryan", 
			"Jacob", "Gary", "Nicholas", "Eric", "Jonathan", "Stephen", "Larry", "Justin", "Scott", "Brandon", 
			"Benjamin", "Samuel", "Gregory", "Alexander", "Frank", "Patrick", "Raymond", "Jack", "Dennis", "Jerry", 
			"Tyler", "Aaron", "Jose", "Adam", "Henry", "Nathan", "Douglas", "Zachary", "Peter", "Kyle", 
			"Walter", "Ethan", "Jeremy", "Christian", "Keith", "Roger", "Terry", "Gerald", "Harold", "Sean", 
			"Austin", "Carl", "Arthur", "Lawrence", "Dylan", "Jesse", "Victor", "Bryan", "Joe", "Noah", "Logan"
		},
		HairIDs = {
			112604007003366, 98528599025378, 80283058937678, 15563758601, 75487563047720, 
			18850865882, 123548189811001, 92061692441841, 75002416629319, 129748819870954, 
			95174346454397, 88539590756497, 139707451231957, 124120228964435, 85073098049802, 
			4773873546, 85552002879927, 73058918882985, 92206421183250, 101006327430632
		},
		Factions = {
			STREETS = {
				ShirtIDs = {6475610218, 11373066002, 6475609454, 6745531820, 10516913453, 2454118359, 113836598447031, 6140709264},
				PantsIDs = {8639706123, 106503910916588, 6363314073, 2231211984}
			},
			MAFIA = {
				ShirtIDs = {6430373850, 87318354793884, 6430378289, 6430388466, 17705703606, 82768729660708},
				PantsIDs = {18845411653}
			},
			POLICE = {
				ShirtIDs = {14864023926, 124432271572433},
				PantsIDs = {104449794109636}
			}
		},
		FaceIDs = {0}
	},
	Fem = {
		FirstNames = {
			"Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica", "Sarah", "Karen", 
			"Lisa", "Nancy", "Betty", "Margaret", "Sandra", "Ashley", "Kimberly", "Emily", "Donna", "Michelle", 
			"Carol", "Amanda", "Dorothy", "Melissa", "Deborah", "Stephanie", "Rebecca", "Sharon", "Laura", "Cynthia", 
			"Kathleen", "Amy", "Angela", "Shirley", "Anna", "Brenda", "Pamela", "Emma", "Nicole", "Helen", 
			"Samantha", "Katherine", "Christine", "Debra", "Rachel", "Carolyn", "Janet", "Catherine", "Maria", "Heather", 
			"Diane", "Ruth", "Julie", "Olivia", "Joyce", "Virginia", "Victoria", "Kelly", "Lauren", "Christina", 
			"Joan", "Evelyn", "Judith", "Megan", "Cheryl", "Andrea", "Hannah", "Martha", "Jacqueline", "Frances", 
			"Gloria", "Ann", "Teresa", "Kathryn", "Sara", "Janice", "Jean", "Alice", "Madison", "Doris", "Abigail", "Julia"
		},
		HairIDs = {
			132239357944331, 16989887978, 17856090938, 13515175239, 17333280320, 13473653900,
			124975286882269, 17583698245, 16317764121, 17583592654, 15848868806, 115301530609250,
			11417078736, 102439036876876, 16138295463, 17235366475, 16138301962, 74442396896368,
			104164430679537, 131060997095972, 15069719768, 129458465295140, 17832723362, 138964634412256
		},
		Factions = {
			STREETS = {
				ShirtIDs = {6475610218, 72887864504813, 12333099286, 2454118359, 16204229076},
				PantsIDs = {7976640793, 6363314073, 8639706123}
			},
			MAFIA = {
				ShirtIDs = {6430373850, 87318354793884, 6430378289},
				PantsIDs = {18845411653}
			},
			POLICE = {
				ShirtIDs = {14864023926, 124432271572433},
				PantsIDs = {104449794109636}
			}
		},
		FaceIDs = {0}
	}
}

local LastNames = {
	"Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Wilson", "Anderson", "Thomas", 
	"Taylor", "Moore", "Jackson", "Martin", "Lee", "Thompson", "White", "Harris", "Clark", "Lewis", 
	"Robinson", "Walker", "Young", "Allen", "King", "Wright", "Scott", "Hill", "Green", "Adams", 
	"Nelson", "Baker", "Hall", "Campbell", "Mitchell", "Carter", "Roberts", "Phillips", "Evans", "Turner", 
	"Parker", "Edwards", "Collins", "Stewart", "Morris", "Murphy", "Cook", "Rogers", "Morgan", "Cooper", 
	"Peterson", "Bailey", "Reed", "Kelly", "Howard", "Cox", "Ward", "Richardson", "Watson", "Brooks", 
	"Wood", "James", "Bennett", "Gray", "Hughes", "Price", "Sanders", "Myers", "Long", "Ross", 
	"Foster", "Powell", "Sullivan", "Russell", "Henderson", "Coleman", "Jenkins", "Perry", "Patterson", "Washington", 
	"Butler", "Simmons", "Bryant", "Alexander", "Griffin", "Hayes", "Harrison", "Gibson", "McDonald", "Woods", 
	"Kennedy", "Tucker", "Hoffman", "Mason", "Dixon", "Hunt", "Palmer", "Holmes", "Stone", "Hawkins"
}

local SkinColors = {
	Color3.fromRGB(253, 242, 178),
	Color3.fromRGB(245, 214, 151),
	Color3.fromRGB(234, 184, 146),
	Color3.fromRGB(204, 142, 105),
	Color3.fromRGB(124, 92, 70),
	Color3.fromRGB(62, 44, 35)
}

local sessionData = {}

local function generateRandomData(gender, faction, spawnName, skinColorIndex)
	local pool = Pools[gender] or Pools.Masc
	local fac = faction or "STREETS"
	local factionPool = pool.Factions[fac] or pool.Factions.STREETS

	return {
		Gender = gender,
		Faction = fac,
		SpawnName = spawnName,
		FirstName = pool.FirstNames[math.random(1, #pool.FirstNames)],
		LastName = LastNames[math.random(1, #LastNames)],
		Hair = tostring(pool.HairIDs[math.random(1, #pool.HairIDs)]),
		Shirt = factionPool.ShirtIDs[math.random(1, #factionPool.ShirtIDs)],
		Pants = factionPool.PantsIDs[math.random(1, #factionPool.PantsIDs)],
		Face = pool.FaceIDs[math.random(1, #pool.FaceIDs)],
		SkinColorIndex = skinColorIndex or math.random(1, #SkinColors),
		HairR = math.random(0, 255),
		HairG = math.random(0, 255),
		HairB = math.random(0, 255),
		InventoryData = initialInventory,
		ClipAmmo = 6,
		ReserveAmmo = 40
	}
end

local function reconcileData(savedData)
	local freshData = generateRandomData(savedData.Gender or "Masc", savedData.Faction or "STREETS", savedData.SpawnName or "Spawn1", savedData.SkinColorIndex)
	for key, value in pairs(freshData) do
		if savedData[key] == nil then
			savedData[key] = value
		end
	end
	return savedData
end

local function applyAvatar(character, data)
	local humanoid = character:WaitForChild("Humanoid")

	local description = Instance.new("HumanoidDescription")
	description.HairAccessory = tostring(data.Hair)
	description.Shirt = data.Shirt
	description.Pants = data.Pants
	description.Face = data.Face

	local color = SkinColors[data.SkinColorIndex]
	description.HeadColor = color
	description.LeftArmColor = color
	description.RightArmColor = color
	description.LeftLegColor = color
	description.RightLegColor = color
	description.TorsoColor = color

	humanoid:ApplyDescription(description)

	local hairColor = Color3.fromRGB(data.HairR, data.HairG, data.HairB)
	for _, acc in ipairs(character:GetChildren()) do
		if acc:IsA("Accessory") then
			local handle = acc:FindFirstChild("Handle")
			if handle then
				local hairAttachment = handle:FindFirstChild("HairAttachment")
				if hairAttachment then

					for _, obj in ipairs(handle:GetChildren()) do
						if obj:IsA("SurfaceAppearance") then
							obj:Destroy()
						end
					end

					if handle:IsA("MeshPart") then
						handle.TextureID = ""
						handle.Color = hairColor
						handle.UsePartColor = true 
					else
						local mesh = handle:FindFirstChildOfClass("SpecialMesh")
						if mesh then
							mesh.TextureId = ""
						end
						handle.Color = hairColor
					end
				end
			end
		end
	end
end

local function createHitbox(character)
	local rootPart = character:WaitForChild("HumanoidRootPart", 5)
	local head = character:WaitForChild("Head", 5)
	if not rootPart or not head then return end

	local hitbox = Instance.new("Part")
	hitbox.Name = "Hitbox"
	hitbox.Size = Vector3.new(4, 4.5, 2.5) 
	hitbox.BrickColor = BrickColor.new("Really red")
	hitbox.Material = Enum.Material.Neon
	hitbox.Transparency = 0.8
	hitbox.CanCollide = false
	hitbox.Massless = true
	hitbox.CFrame = rootPart.CFrame * CFrame.new(0, -0.75, 0)
	hitbox.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = rootPart
	weld.Part1 = hitbox
	weld.Parent = hitbox

	local headHitbox = Instance.new("Part")
	headHitbox.Name = "HeadHitbox"
	headHitbox.Size = Vector3.new(2, 2, 2)
	headHitbox.BrickColor = BrickColor.new("New Yeller")
	headHitbox.Material = Enum.Material.Neon
	headHitbox.Transparency = 0.8
	headHitbox.CanCollide = false
	headHitbox.Massless = true
	headHitbox.CFrame = head.CFrame
	headHitbox.Parent = character

	local headWeld = Instance.new("WeldConstraint")
	headWeld.Part0 = head
	headWeld.Part1 = headHitbox
	headWeld.Parent = headHitbox
end

local function teleportToSpawn(character, factionName, spawnName)
	local spawnsFolder = workspace:FindFirstChild("Spawns")
	if spawnsFolder then
		local factionFolder = spawnsFolder:FindFirstChild(factionName)
		if factionFolder then
			local targetSpawn = factionFolder:FindFirstChild(spawnName)
			if targetSpawn and targetSpawn:IsA("BasePart") and character:FindFirstChild("HumanoidRootPart") then
				character.HumanoidRootPart.CFrame = targetSpawn.CFrame + Vector3.new(0, 5, 0)
			end
		end
	end
end

spawnEvent.OnServerEvent:Connect(function(player)
	local data = sessionData[player.UserId]
	if data and data.Faction and data.SpawnName and player.Character then
		teleportToSpawn(player.Character, data.Faction, data.SpawnName)
	end
end)

submitEvent.OnServerEvent:Connect(function(player, gender, faction, spawnName, skinColorIndex)
	if type(gender) ~= "string" or type(faction) ~= "string" or type(spawnName) ~= "string" or type(skinColorIndex) ~= "number" then return end

	local newData = generateRandomData(gender, faction, spawnName, skinColorIndex)
	sessionData[player.UserId] = newData

	local playerFolder = player:FindFirstChild("AvatarData")
	if playerFolder then
		local isNewTag = playerFolder:FindFirstChild("IsNewPlayer")
		if isNewTag then isNewTag:Destroy() end

		for key, value in pairs(newData) do
			local valObj = playerFolder:FindFirstChild(key)
			if not valObj then
				valObj = type(value) == "number" and Instance.new("NumberValue") or Instance.new("StringValue")
				valObj.Name = key
				valObj.Parent = playerFolder
			end
			valObj.Value = value
		end
	end

	if player.Character then
		applyAvatar(player.Character, newData)
		teleportToSpawn(player.Character, faction, spawnName)
	end
end)

rerollEvent.OnServerEvent:Connect(function(player)
	if not RunService:IsStudio() then return end
	local oldData = sessionData[player.UserId]
	if not oldData then return end
	local newData = generateRandomData(oldData.Gender, oldData.Faction, oldData.SpawnName, oldData.SkinColorIndex)
	sessionData[player.UserId] = newData
	local playerFolder = player:FindFirstChild("AvatarData")
	if playerFolder then
		for key, value in pairs(newData) do
			local valObj = playerFolder:FindFirstChild(key)
			if valObj then valObj.Value = value end
		end
	end
	if player.Character then applyAvatar(player.Character, newData) end
end)

barberEvent.OnServerEvent:Connect(function(player, action, payload)
	local data = sessionData[player.UserId]
	if not data then return end

	if action == "Custom" then
		data.Hair = tostring(payload)
	elseif action == "Default" then
		local success, desc = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(player.UserId)
		end)
		if success and desc then
			local hairs = desc.HairAccessory
			if hairs == "" then
				for _, acc in ipairs(desc:GetAccessories(true)) do
					if acc.AccessoryType == Enum.AccessoryType.Hair then
						hairs = hairs .. (hairs == "" and "" or ",") .. tostring(acc.AssetId)
					end
				end
			end
			data.Hair = hairs
		end
	elseif action == "RandomColor" then
		data.HairR = math.random(0, 255)
		data.HairG = math.random(0, 255)
		data.HairB = math.random(0, 255)
	end

	local playerFolder = player:FindFirstChild("AvatarData")
	if playerFolder then
		local hVal = playerFolder:FindFirstChild("Hair")
		if hVal then hVal.Value = data.Hair end
		local rVal = playerFolder:FindFirstChild("HairR")
		if rVal then rVal.Value = data.HairR end
		local gVal = playerFolder:FindFirstChild("HairG")
		if gVal then gVal.Value = data.HairG end
		local bVal = playerFolder:FindFirstChild("HairB")
		if bVal then bVal.Value = data.HairB end
	end

	if player.Character then
		applyAvatar(player.Character, data)
	end
end)

inventoryEvent.OnServerEvent:Connect(function(player, invData)
	if type(invData) == "string" then
		local data = sessionData[player.UserId]
		if data then
			data.InventoryData = invData
			local playerFolder = player:FindFirstChild("AvatarData")
			if playerFolder then
				local invVal = playerFolder:FindFirstChild("InventoryData")
				if invVal then
					invVal.Value = invData
				end
			end
		end
	end
end)

equipEvent.OnServerEvent:Connect(function(player, itemName)
	local character = player.Character
	if not character then return end

	local oldEquip = character:FindFirstChild("EquippedItem")
	if oldEquip then
		oldEquip:Destroy()
	end

	if type(itemName) ~= "string" or itemName == "" then return end

	local itemData = GameData.Items[itemName]
	if itemData and itemData.Model and itemData.Model ~= "" then
		local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
		if itemsFolder then
			local modelTemplate = itemsFolder:FindFirstChild(itemData.Model)
			if modelTemplate then
				local newModel = modelTemplate:Clone()
				newModel.Name = "EquippedItem"

				local rightArm = character:FindFirstChild("Right Arm")
				local primaryPart = newModel.PrimaryPart or newModel:FindFirstChildWhichIsA("BasePart")

				if rightArm and primaryPart then
					newModel.Parent = character

					for _, desc in ipairs(newModel:GetDescendants()) do
						if desc:IsA("BasePart") and desc ~= primaryPart then
							desc.Anchored = false
							local internalWeld = Instance.new("WeldConstraint")
							internalWeld.Part0 = primaryPart
							internalWeld.Part1 = desc
							internalWeld.Parent = desc
						end
					end
					primaryPart.Anchored = false

					local equipWeld = Instance.new("Weld")
					equipWeld.Name = "EquipWeld"
					equipWeld.Part0 = rightArm
					equipWeld.Part1 = primaryPart

					equipWeld.C0 = CFrame.new(0, -1, 0)

					local grip = primaryPart:FindFirstChild("Grip")
					if grip and grip:IsA("Attachment") then
						equipWeld.C1 = grip.CFrame
					end

					equipWeld.Parent = primaryPart
				end
			end
		end
	end
end)

weaponActionEvent.OnServerEvent:Connect(function(player, action, weaponName, targetPos)
	local data = sessionData[player.UserId]
	local playerFolder = player:FindFirstChild("AvatarData")
	if not data or not playerFolder then return end

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
		local rightArm = character:FindFirstChild("Right Arm")
		local startPos = rightArm and rightArm.Position or (rootPart and rootPart.Position)
		if not startPos then return end

		local direction = (targetPos - startPos).Unit
		local bulletSpeed = itemData.BulletSpeed or 500

		local bullet = Instance.new("Part")
		bullet.Name = "Bullet"
		bullet.Size = Vector3.new(0.5, 0.5, 1.5)
		bullet.Transparency = 1
		bullet.CanCollide = false
		bullet.Massless = true
		bullet.CFrame = CFrame.lookAt(startPos + direction * 4, startPos + direction * 5)

		local visual = Instance.new("Part")
		visual.Name = "VisualBullet"
		visual.Size = Vector3.new(0.1, 0.1, 1.2)
		visual.BrickColor = BrickColor.new("New Yeller")
		visual.Material = Enum.Material.Neon
		visual.CanCollide = false
		visual.Massless = true
		visual.CFrame = bullet.CFrame
		visual.Parent = bullet

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = bullet
		weld.Part1 = visual
		weld.Parent = visual

		local att0 = Instance.new("Attachment", visual)
		att0.Position = Vector3.new(0, 0, -visual.Size.Z / 2)
		local att1 = Instance.new("Attachment", visual)
		att1.Position = Vector3.new(0, 0, visual.Size.Z / 2)

		local trail = Instance.new("Trail")
		trail.Attachment0 = att0
		trail.Attachment1 = att1
		trail.Color = ColorSequence.new(Color3.new(1, 0.8, 0))
		trail.Lifetime = 0.15
		trail.MinLength = 0
		trail.Parent = visual

		local bv = Instance.new("BodyVelocity")
		bv.Velocity = direction * bulletSpeed
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Parent = bullet

		bullet.Parent = workspace

		bullet:SetNetworkOwner(nil)

		Debris:AddItem(bullet, 3)

		local hitConnection
		hitConnection = bullet.Touched:Connect(function(hit)
			if hit:IsDescendantOf(character) then return end
			if hit.Name == "VisualBullet" then return end

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
		if itemData.MaxClip then
			local clipVal = playerFolder:FindFirstChild("ClipAmmo")
			if clipVal and clipVal.Value > 0 then
				clipVal.Value = clipVal.Value - 1
				data.ClipAmmo = clipVal.Value
				if itemData.UseSound then play3DSound(itemData.UseSound) end
				spawnBullet()
			end
		else
			if itemData.UseSound then play3DSound(itemData.UseSound) end
			spawnBullet()
		end
	elseif action == "Reload" then
		if itemData.MaxClip then
			local clipVal = playerFolder:FindFirstChild("ClipAmmo")
			local reserveVal = playerFolder:FindFirstChild("ReserveAmmo")
			if clipVal and reserveVal then
				local needed = itemData.MaxClip - clipVal.Value
				if needed > 0 and reserveVal.Value > 0 then
					local taken = math.min(needed, reserveVal.Value)
					clipVal.Value = clipVal.Value + taken
					reserveVal.Value = reserveVal.Value - taken
					data.ClipAmmo = clipVal.Value
					data.ReserveAmmo = reserveVal.Value
					if itemData.ReloadSound then play3DSound(itemData.ReloadSound) end
				end
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	local isNew = false
	local savedData = nil
	if RunService:IsStudio() then isNew = true
	else
		local success, result = pcall(function() return AvatarDataStore:GetAsync(player.UserId) end)
		if success and result then savedData = reconcileData(result) else isNew = true end
	end
	local playerFolder = Instance.new("Folder")
	playerFolder.Name = "AvatarData"
	if isNew then
		local newTag = Instance.new("BoolValue")
		newTag.Name = "IsNewPlayer"
		newTag.Value = true
		newTag.Parent = playerFolder
		sessionData[player.UserId] = {IsNew = true}
	else
		sessionData[player.UserId] = savedData
		for key, value in pairs(savedData) do
			local valObj = type(value) == "number" and Instance.new("NumberValue") or Instance.new("StringValue")
			valObj.Name = key
			valObj.Value = value
			valObj.Parent = playerFolder
		end
	end
	playerFolder.Parent = player
	player.CharacterAppearanceLoaded:Connect(function(character)
		local data = sessionData[player.UserId]
		if data and data.Gender then applyAvatar(character, data) end
		createHitbox(character)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local data = sessionData[player.UserId]
	if data and not data.IsNew and not RunService:IsStudio() then
		pcall(function() AvatarDataStore:SetAsync(player.UserId, data) end)
	end
	sessionData[player.UserId] = nil
end)

game:BindToClose(function()
	if RunService:IsStudio() then return end
	for _, player in ipairs(Players:GetPlayers()) do
		local data = sessionData[player.UserId]
		if data and not data.IsNew then pcall(function() AvatarDataStore:SetAsync(player.UserId, data) end) end
	end
end)