Config = {}

Config.Resource = GetCurrentResourceName()
Config.GetSharedObject = "esx:getSharedObject"
Config.UseCustomFont = false -- enable or disable use your custom font
Config.FontId = 4 -- set your font id
Config.FontName = "Fire Sans" -- set your custom font name
Config.Locale = "en" -- set your locale | en, cs, other
Config.DiscordWebhook = "discord_webhook_here"
Config.ServiceExtensionOnEscape = 2 -- how many penalty points will be extended if the player tries to escape
Config.ServiceLocation = {x =  -2168.57, y = 5197.93, z = 17.02} -- the spawn point on the island
Config.ReleaseLocation = {x = -1605.54, y = 5258.72, z = 2.68} -- instead of spawning after completing penalty points
Config.ServiceLocations = {
	{ type = "cleaning", coords = vector3(-2168.7763671875, 5275.2568359375, 18.405973434448) },
	{ type = "cleaning", coords = vector3(-2169.4523925781, 5275.0698242188, 18.457084655762) },
	{ type = "cleaning", coords = vector3(-2169.177734375, 5273.8940429688, 18.503856658936) },
	{ type = "cleaning", coords = vector3(-2167.3146972656, 5274.0556640625, 17.941902160645) },
	--
	{ type = "cleaning", coords = vector3(-2170.6, 5186.7, 16.22) },
	{ type = "cleaning", coords = vector3(-2175.1, 5189.8, 16.85) },
	{ type = "gardening", coords = vector3(-2172.1, 5192.7, 16.76) },
	{ type = "gardening", coords = vector3(-2163.7, 5192.7, 16.09) },
	{ type = "gardening", coords = vector3(-2181.1, 5183.3, 16.58) },
	{ type = "gardening", coords = vector3(-2185.4, 5196.8, 18.82) },
	{ type = "gardening", coords = vector3(-2156.7, 5177.1, 14.01) }
}


Config.Uniforms = {
	prison_wear = {
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1']  = 65, ['torso_2']  = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms']     = 68, ['pants_1']  = 0,
			['pants_2']  = 35,   ['shoes_1']  = 0,
			['shoes_2']  = 19,  ['chain_1']  = 0,
			['chain_2']  = 0
		},
		female = {
			['tshirt_1'] = 3,   ['tshirt_2'] = 0,
			['torso_1']  = 38,  ['torso_2']  = 3,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms']     = 120, ['pants_1'] = 3,
			['pants_2']  = 15,  ['shoes_1']  = 66,
			['shoes_2']  = 5,   ['chain_1']  = 0,
			['chain_2']  = 0
		}
	}
}
