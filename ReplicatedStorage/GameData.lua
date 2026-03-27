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
		ReloadSound = "reload_default"
		
	}
}

return GameData