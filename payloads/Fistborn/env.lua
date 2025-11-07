local env = {} --// storing data that will probably be constantly edited

env[#env+1] = {
    ["Moderator"] = true;
    ["Developer"] = true;
    ["TC Developer"] = true;
    ["Owner"] = true;
};

env[#env+1] =  {
    "rbxassetid://80146038830009",
    "rbxassetid://114896260981699",
    "rbxassetid://96000445844253",
    "rbxassetid://110502064346065",
    "rbxassetid://95382080116553",
    "rbxassetid://74546349999073",
    "rbxassetid://74546349999073",
    "rbxassetid://82242712231915",
}

env[#env+1] = {
    "Strength",
    "Durability",
    "Agility",
    "Dexterity",
    "MaxStamina",
    "Muscle",
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

env[#env+1] = {
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

env[#env+1] = {
    "rbxassetid://87610934490695",
    "rbxassetid://90974810727103",
    "rbxassetid://129262933835957",
    "rbxassetid://139786248064389",
}

env[#env+1] = {
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

env[#env+1] = {
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
    }
}

env[#env+1] = {
    "Taekwondo",
    "Gym",
    "Bank",
    "DexDaily",
    "Hospital",
    "24/7",
    "DineNDash",
    "Neighborhood",
    "BrokenHouse",
}

return env
