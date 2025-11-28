local statusEvent = getgenv().ah_statusEvent

local function setStatus(...)
	if not statusEvent then
		return
	end
	statusEvent:Fire(...)
end

if debugMode then
	getgenv().aztupHubV3Ran = false
	getgenv().aztupHubV3RanReal = false
end
if getgenv().aztupHubV3Ran or getgenv().aztupHubV3RanReal then
	return setStatus("Script already ran", true)
end
getgenv().aztupHubV3Ran = true
getgenv().aztupHubV3RanReal = true

if typeof(game) ~= "Instance" then
	return SX_CRASH()
end
--if (typeof(websiteKey) ~= 'string' or typeof(scriptKey) ~= 'string') then return SX_CRASH() end;

local originalFunctions = {}
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local aztuppyFile, loaderHash = unpack({ ... })
local executor

xpcall(function()
	executor = {
		env = {},
		debug_getproto = debug.getproto,
		makefolder = makefolder,
		getscriptclosure = getscriptclosure,
		clonefunction = clonefunction,
		getconnections = getconnections,
		checkcaller = checkcaller,
		crypt_base64encode = crypt.base64encode,
		rconsoledestroy = rconsoledestroy,
		rconsolesettitle = rconsolesettitle,
		hookmetamethod = hookmetamethod,
		queue_on_teleport = queue_on_teleport or queueonteleport,
		rconsoleprint = rconsoleprint,
		getrawmetatable = (typeof(getrawmetatable) ~= "nil" and getrawmetatable) or nil,
		setrenderproperty = setrenderproperty,
		WebSocket = WebSocket,
		crypt_hash = crypt.hash,
		getinstances = getinstances,
		getcallingscript = getcallingscript,
		getloadedmodules = getloadedmodules,
		debug_getinfo = debug.getinfo,
		mouse1press = mouse1press,
		crypt_decrypt = crypt.decrypt,
		compareinstances = compareinstances,
		newcclosure = newcclosure,
		delfile = delfile,
		request = request or http.request or http_request,
		getrenderproperty = getrenderproperty,
		readfile = readfile,
		gethui = gethui,
		debug_getupvalues = debug.getupvalues,
		crypt_base64decode = crypt.base64decode,
		debug_setstack = debug.setstack,
		setscriptable = setscriptable,
		getthreadidentity = getthreadidentity or getidentity or getthreadcontext,
		loadstring = loadstring,
		WebSocket_connect = (typeof(WebSocket) ~= "nil" and WebSocket and WebSocket.connect) or nil,
		cleardrawcache = cleardrawcache,
		debug_getconstants = debug.getconstants,
		isexecutorclosure = isexecutorclosure,
		getnamecallmethod = getnamecallmethod,
		isrenderobj = isrenderobj,
		Drawing_Fonts = Drawing.Fonts,
		hookfunction = hookfunction,
		Drawing_new = Drawing.new,
		Drawing = Drawing,
		isfile = isfile,
		mouse2release = mouse2release,
		setthreadidentity = setthreadidentity or setidentity or setthreadcontext,
		debug_getupvalue = debug.getupvalue,
		getsenv = getsenv,
		isscriptable = isscriptable,
		setfpscap = setfpscap,
		debug_setconstant = debug.setconstant,
		mousemoverel = mousemoverel,
		mousescroll = mousescroll,
		mousemoveabs = mousemoveabs,
		messagebox = messagebox,
		islclosure = islclosure,
		lz4decompress = lz4decompress,
		mouse1click = mouse1click,
		mouse2press = mouse2press,
		lz4compress = lz4compress,
		isfolder = isfolder,
		setreadonly = setreadonly,
		getnilinstances = getnilinstances,
		getgc = getgc,
		delfolder = delfolder,
		iscclosure = iscclosure,
		getcustomasset = getcustomasset,
		cache_iscached = (typeof(cache) ~= "nil" and cache.iscached) or nil, --// Solara fix for cache functions
		cache_replace = (typeof(cache) ~= "nil" and cache.replace) or nil,
		cache_invalidate = (typeof(cache) ~= "nil" and cache.invalidate) or nil,
		setrawmetatable = setrawmetatable,
		isreadonly = isreadonly,
		getrunningscripts = getrunningscripts,
		getscriptbytecode = getscriptbytecode or dumpstring,
		crypt_encrypt = crypt.encrypt,
		getrenv = getrenv,
		getgenv = getgenv,
		identifyexecutor = identifyexecutor or getexecutorname,
		setrbxclipboard = setrbxclipboard,
		appendfile = appendfile,
		debug_getconstant = debug.getconstant,
		mouse2click = mouse2click,
		dofile = dofile,
		sethiddenproperty = sethiddenproperty,
		writefile = writefile,
		cloneref = cloneref,
		loadfile = loadfile,
		isrbxactive = isrbxactive or isgameactive,
	}

	setmetatable(executor, {
		__index = function(tbl, k)
			if k == "getrawmetatable" then
				return function()
					return { __index = nil }
				end
			else
				local ExecutorName = tbl.env.UA or "This Executor"
				warn(string.format("[ERROR] %s does not support %s", ExecutorName, k))
				return nil
			end
		end,
	})
end, function(err)
	messagebox("Aztuppy UNC Env Initializer Failed\n\n" .. err, "pancake fan club UNCEnv", 0)
	return SX_CRASH()
end)

if not game:IsLoaded() then
	setStatus("Waiting for game to load")
	game.Loaded:Wait()
end

local http = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local oldRequest = clonefunction(http)
local gameId = game.GameId

local function ExecutorEnvFinalize(ExecutorName)
	--// Changing Shitexcutors Functions

	if ExecutorName == "Solara" then
		executor.checkcaller = function()
			return not checkcaller()
		end
	end
end

local function isRequestValid(req)
	if not req.Headers then
		return false
	end
	return req.StatusCode < 500 and req.StatusCode ~= 0
end

local function httpRequest(...)
	local reqData = oldRequest(...)
	local attempts = 0

	if not isRequestValid(reqData) then
		repeat
			reqData = oldRequest(...)
			attempts += 1
			task.wait(1)
		until isRequestValid(reqData) or attempts > 30
	end

	return reqData
end

local LocalPlayer = game:GetService("Players").LocalPlayer

local websiteKey, scriptKey = getgenv().websiteKey, getgenv().scriptKey
local jobId, placeId = game.JobId, game.PlaceId

local userId = LocalPlayer.UserId
local isUserTrolled = false
local isMobile = false
local accountData
local scriptVersion

do -- //Hook print debug
	if not debugMode then
		function print() end
		function warn() end
		function printf() end
	end
end

setStatus("Setting Aztuppy Env")

getgenv().aztuppySave = function(new)
	writefile("Aztup Hub V3/aztuppy.json", HttpService:JSONEncode(new))
	shared.aztuppy["sharedFile"] = new
end
getgenv().aztuppyLoad = function()
	return HttpService:JSONDecode(readfile("Aztup Hub V3/aztuppy.json"))
end

do -- // Aztuppy Core Init
	START_AZTUPPY = tick()

	local pushUpdate = false

	if isfile("Aztup Hub V3/compiled.lua") then
		delfile("Aztup Hub V3/compiled.lua")
	end

	if typeof(aztuppyFile) == "boolean" then
		if aztuppyFile then
			aztuppyFile = aztuppyLoad()
		else
			aztuppyFile = {}
		end

		pushUpdate = true
	end

	if UserInputService.TouchEnabled and typeof(aztuppyFile["isMobile"]) ~= "boolean" then
		-- Possible Emulator/Phone
		local UserAgent = HttpService:JSONDecode(game:HttpGet("https://httpbin.org/get"))["headers"]["User-Agent"]

		if typeof(UserAgent) == "string" then
			for _, v in
				next,
				{ "Tablet", "Phone", "ROBLOX Android App", "Android", "GooglePlayStore", "iPhone", "iPad" }
			do
				if UserAgent:find(v) then
					isMobile = true
					break
				end
			end

			aztuppyFile["isMobile"] = isMobile
			pushUpdate = true
		end
	end

	if aztuppyFile["loaderHash"] ~= loaderHash then
		aztuppyFile["loaderHash"] = loaderHash
		pushUpdate = true
	end

	--// I wonder if this can add support for low UNC executors
	if executor then
		if not aztuppyFile["UNCEnv"] then
			aztuppyFile.UNCEnv = {}
			local newEnv, failedFunctions = loadstring(
				game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/aztup/UNCEnv.lua")
			)(executor)

			executor = newEnv
			aztuppyFile.UNCEnv.UNC = executor.env.UNC
			aztuppyFile.UNCEnv.UA = executor.env.UA
			aztuppyFile.UNCEnv.failedFunctions = failedFunctions
			pushUpdate = true
		else
			executor.env.UNC = aztuppyFile.UNCEnv.UNC
			executor.env.UA = aztuppyFile.UNCEnv.UA

			for _, v in next, aztuppyFile.UNCEnv.failedFunctions do
				executor[v] = nil
			end
		end

		if executor.Drawing_new ~= nil and executor.Drawing_Fonts ~= nil then
			executor.Drawing_Fonts = nil
			executor.Drawing_new = nil
		else
			executor.Drawing = nil
			executor.Drawing_Fonts = nil
			executor.Drawing_new = nil
		end
	end

	if pushUpdate then
		aztuppySave(aztuppyFile)
	end

	--// Globals
	shared.aztuppy.scriptVersion = ah_metadata["version"]
	getgenv().aztuppyFile = aztuppyFile
	getgenv().executor = executor
	shared.aztuppy["sharedFile"] = aztuppyFile

	ExecutorEnvFinalize(executor.env.UA)

	print(
		string.format(
			"Aztuppy Env Init in %.02fs\n\nExecutor: %s\nUNC: %s",
			tick() - START_AZTUPPY,
			executor.env.UA,
			executor.env.UNC
		)
	)
end

if aztuppyFile["umarlib"] == nil then
	setStatus("", "confirmUISelection")

	local data = statusEvent.Event:Wait()
	if data == "Umarlib" then
		aztuppyFile["umarlib"] = true
	elseif data == "Aztup" then
		aztuppyFile["umarlib"] = false
	end

	aztuppySave(aztuppyFile)
end

setStatus("All done", true)
task.wait(1)
