getgenv().isSynapseV3 = not not gethui;

getgenv().disableenvprotection = function() end;
getgenv().enableenvprotection = function() end;

getgenv().SX_VM_CNONE = function() end;

local __scripts = {};
getgenv().__scripts = __scripts;

local debugInfo = debug.info;

local HttpService = game:GetService('HttpService');
local GameScripts
local info = debugInfo(1, 's');
__scripts[info] = 'require-loader';

local cachedRequires = {};
_G.cachedRequires = cachedRequires;

local originalRequire = require

local function QueryGame(query)
    GameScripts = game:HttpGet("https://api.github.com/repos/tenvo/pancakes/contents/aztup/files/games")
    GameScripts = HttpService:JSONDecode(GameScripts)

    if typeof(GameScripts) ~= "table" then return warn('[ERROR] couldn\'t load games directory') end
    local search = {query:split(".lua")[1],query}
    
    for i,v in pairs(GameScripts) do
        local name = v["name"]
        
        if (table.find(search,name)) then
            local extension = v["name"]:match("^.+(%..+)$")

            if extension ~= nil then
                return v["download_url"]
            else
                local download_url = string.format("%sgames/%s/main.lua",shared.aztuppy.root,query:split(".lua")[1])
                return download_url
            end
        end
    end

    return warn(string.format('[ERROR] didn\'t find a script for the game: ', query))
end

local function GetHost(url)
    local lhost,newUrl

    if url:find("/") then
        local ah_dir = {"classes","games","utils"}

        for _,v in pairs(ah_dir) do
            if url:find(tostring(v).."/") then
                lhost = shared.aztuppy[tostring(v)]
                newUrl = url:split(tostring(v).."/")[2]
                return lhost,newUrl
            end
        end
        
        if (shared.aztuppy["payload"]) then
            if (shared.aztuppy["payload"]._root ~= nil) then
                lhost = shared.aztuppy["payload"]._root
                newUrl = url
                return lhost,newUrl
            end
        end
    end

    return lhost,newUrl
end

local function customRequire(url, useHigherLevel)
    if (typeof(url) ~= 'string' or not checkcaller()) then
        return originalRequire(url);
    end;

    local rawurl = url
    local lhost,url = GetHost(url)
    if (not lhost and not url) then lhost = shared.aztuppy.root url = rawurl end
    local requirerScriptId = debugInfo(useHigherLevel and 3 or 2, 's');
    local requirerScript = __scripts[requirerScriptId];
    local requestData
    
    if (lhost ~= shared.aztuppy.root and not shared.aztuppy["payload"]) then
        requestData = httpRequest({
            Url = lhost..url
        });
    elseif (not table.find({"source.lua","UILibrary.lua","metadata.json"},url) and not shared.aztuppy["payload"]) then
        requestData = httpRequest({
            Url = QueryGame(url)
        });
    else
        if (lhost == shared.aztuppy.root and shared.aztuppy["payload"]) then
            if (not table.find({"source.lua","UILibrary.lua","metadata.json"},url) and shared.aztuppy["payload"]._root ~= nil) then
                lhost = shared.aztuppy["payload"]._root
            end
        end

        requestData = httpRequest({
            Url = lhost..url
        });
    end
 
    if (not requestData.Success) then
        warn(string.format('[ERROR] Script bundler couldn\'t find %s', url));
        return task.wait(9e9);
    end;

    local scriptContent = requestData.Body;
    local extension = url:match('.+%w+%p(%w+)');

    if (extension ~= 'lua') then
        return scriptContent;
    end;

    local scriptName = url;
    local scriptFunction, syntaxError = loadstring(scriptContent);
    --print(rawurl, scriptFunction, "requiring")

    if (not scriptFunction) then
        warn(string.format('[ERROR] Detected syntax error for %s', url));
        warn(syntaxError);
        return task.wait(9e9);
    end;

    local scriptId = debugInfo(scriptFunction, 's');
    __scripts[scriptId] = scriptName;

    return scriptFunction();
end;

local function customRequireShared(url)
    local fileName = url:match('%w+%.lua') or url:match('%w+%.json');

    if (not cachedRequires[fileName]) then
        cachedRequires[fileName] = customRequire(url, true);
    end;

    return cachedRequires[fileName];
end;

local gameList = ah_metadata--HttpService:JSONDecode(sharedRequire('metadata.json'));

getgenv().require = customRequire;
getgenv().sharedRequire = customRequireShared;

getgenv().aztupHubV3Ran = false;
getgenv().aztupHubV3RanReal = false;
-- getgenv().scriptKey,getgenv().websiteKey='29be76a3-ad9f-4c27-aa3a-e78590f61971','8b21dab5-1432-4620-bf61-735fcfd240df';

local function GAMES_SETUP()
    local gameName = gameList[tostring(game.GameId)];
    local aztuppy = shared.aztuppy
    if (not gameName and not aztuppy["payload"]) then return warn('no custom game for this game'); end;
    if (aztuppy["payload"]) then aztuppy.payload(); return print('[Payload] Finished Call'); end;

    require(string.format('games/%s.lua', gameName:gsub('%s', '')));
end;

getgenv().GAMES_SETUP = GAMES_SETUP;
getgenv().getServerConstant = function(...) return ... end;
customRequire('source.lua');