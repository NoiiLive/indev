-- @ScriptType: ModuleScript
local GameData = {}

GameData.Items = {
	["Smith & Wesson .38"] = {
		Name = "Smith & Wesson .38",
		Type = "Weapon",
		Description = "A standard issue .38 caliber revolver.",
		Model = "sw38",
		Animations = {
			Idle = 140360516572974,
			Walk = 140360516572974,
			Run = 140360516572974,
			Use = {123297753579035},
			Reload = 109778916509963
		},
		MaxClip = 6,
		FireRate = 0.4,
		ReloadTime = 1.1,
		UseSound = "fire_default",
		ReloadSound = "reload_default",
		Damage = 10,
		BulletSpread = 1,
		BulletSpeed = 300,
		Spawnable = false,
		Rarity = 0,
		Automatic = false
	},
	["Tommy Gun"] = {
		Name = "Tommy Gun",
		Type = "Weapon",
		Description = "A fast-firing submachine gun.",
		Model = "tommy",
		Animations = {
			Idle = 140360516572974,
			Walk = 140360516572974,
			Run = 140360516572974,
			Use = {123297753579035},
			Reload = 109778916509963
		},
		MaxClip = 30,
		FireRate = 0.1,
		ReloadTime = 2.5,
		UseSound = "fire_default",
		ReloadSound = "reload_default",
		Damage = 3,
		BulletSpread = 5,
		BulletSpeed = 300,
		Spawnable = true,
		Rarity = 10,
		Automatic = true
	},
	["Ammo Pack"] = {
		Name = "Ammo Pack",
		Type = "Consumable",
		Description = "Restores 10 reserve ammo.",
		Model = "ammo", 
		Animations = {
			Idle = 140360516572974,
			Walk = 140360516572974,
			Run = 140360516572974,
			Use = {123297753579035}
		},
		FireRate = 0.5,
		UseSound = "refill_ammo",
		Spawnable = true,
		Rarity = 80
	}
}

return GameData