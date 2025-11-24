local env = {} --// storing data that will probably be constantly edited

env[#env + 1] = {
	["Moderator"] = true,
	["Developer"] = true,
	["TC Developer"] = true,
	["Owner"] = true,
}

env[#env + 1] = {
	"rbxassetid://80146038830009",
	"rbxassetid://114896260981699",
	"rbxassetid://96000445844253",
	"rbxassetid://110502064346065",
	"rbxassetid://95382080116553",
	"rbxassetid://74546349999073",
	"rbxassetid://74546349999073",
	"rbxassetid://82242712231915",
}

env[#env + 1] = {
	"Strength",
	"Durability",
	"Agility",
	"Dexterity",
	"MaxStamina",
	"Muscle",
	"Fat",
	"TotalPower",
	"--Other--",
	"Bank",
	"Wallet",
	"Style",
	"GlowingEyes",
	"GlowingMarking",
	"--Bones--",
	"Head",
	"Torso",
	"Left_Arm",
	"Right_Arm",
	"Left_Leg",
	"Right_Leg",
}

env[#env + 1] = {
	-- "Energy Drink",
	-- "Soda",
	"Pizza",
	"Cheese Bites",
	"Hotdog",
	"Burger",
	"Cream Cheese Bagel",
	"Bacon Egg & Cheese",
	"Cheesecake",
	"Donut",
}

env[#env + 1] = {
	"rbxassetid://87610934490695",
	"rbxassetid://90974810727103",
	"rbxassetid://129262933835957",
	"rbxassetid://139786248064389",
}

env[#env + 1] = {
	"Accountant",
	"Big Al",
	"Dome Ringa",
	"HospitalNPC",
	"Rukio",
	"TalentDeckNPC",
	"Yuki Mura",
	"Bing",
}

local IT = workspace.InanimateTargets
local Mac = workspace.Machines
local GB = workspace.Gangbase

env[#env + 1] = {
	beds = {
		workspace.BedParts,
		GB.Upgrades["Rest Area"],
	},
	bags = {
		IT.WoodPost,
		IT.StandingBag,
		IT.PunchingBag,
		GB.Upgrades["Punching Bag"],
	},
	machines = {
		Mac.Treadmill,
		Mac.Squats,
		Mac.Pullups,
		Mac.Curls,
		Mac.Benchpress,
		GB.Upgrades.Treadmill,
		GB.Upgrades.Squats,
		GB.Upgrades["Pullup Bar"],
		GB.Upgrades["Curl-Up"],
		GB.Upgrades.Benchpress,
	},
}

env[#env + 1] = {
	sleepTween = CFrame.new(-560.4, 15, -1308.4),
	foodTween = {
		["24/7"] = CFrame.new(-1059, 15, -999),
		["Deli"] = CFrame.new(-374, 15, -1129),
	},
	itemOffsets = {
		["default"] = CFrame.new(0, -4.5, 0),
		["Fat_Burner"] = (CFrame.new(0.5, -4.5, 0) * CFrame.Angles(0, math.rad(45), 0)),
		["Protein_Shake"] = (CFrame.new(0.7, -4.7, -0.4) * CFrame.Angles(0, math.rad(115), 0)),
		["Muscle_Burner"] = (CFrame.new(0.15, -4.7, 0) * CFrame.Angles(0, math.rad(127), 0)),
		["BCAA"] = (CFrame.new(0.15, -4.7, 0) * CFrame.Angles(0, math.rad(127), 0)),
		["Pizza"] = CFrame.new(0, -4.7, 0.6),
		["Cheese_Bites"] = CFrame.new(0, -4.7, 0.6),
		["Soda"] = CFrame.new(0, -4.5, 2),
		["Donut"] = CFrame.new(0.1, -4.3, 2),
		["Cheesecake"] = CFrame.new(-1, -4.5, 0),
	},
}

env[#env + 1] = {
	"Pizza",
	"Cheese Bites",
	"Hotdog",
	"Burger",
	"Cream Cheese Bagel",
	"Bacon Egg & Cheese",
	"Cheesecake",
	"Donut",
	"Fat_Burner",
	"Protein_Shake",
	"Muscle_Burner",
	"BCAA",
}

return env
