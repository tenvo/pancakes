getgenv().isSynapseV3 = not not gethui;

getgenv().disableenvprotection = function() end;
getgenv().enableenvprotection = function() end;

getgenv().SX_VM_CNONE = function() end;

local __scripts = {};
getgenv().__scripts = __scripts;

local debugInfo = debug.info;

local HttpService = game:GetService('HttpService');
local GameScripts = game:HttpGet(HttpService:JSONDecode("https://api.github.com/repos/tenvo/pancakes/contents/aztup/files/games"))
local info = debugInfo(1, 's');
__scripts[info] = 'require-loader';

local cachedRequires = {};
_G.cachedRequires = cachedRequires;

local originalRequire = require

local function QueryGame(query)
    if typeof(GameScripts) ~= "table" then return print("[ERROR] couldn't load games directory") end
    
    for i,v in pairs(GameScripts) do
        local name = v["name"]
        local search = {query..".lua",query}
        
        if (table.find(search,name)) then
            local extension = filename:match("^.+(%..+)$")

            if extension ~= nil then
                return v["download_url"]
            else
                local download_url = string.format("https://raw.githubusercontent.com/tenvo/pancakes/main/aztup/files/games/%s/main.lua",query)
                return download_url
            end
        end
    end

    return print("[ERROR] didn't find a script for the game: "..query)
end

local function customRequire(url, useHigherLevel)
    if (typeof(url) ~= 'string' or not checkcaller()) then
        return originalRequire(url);
    end;

    print("requiring .. "..url)
    local lhost = shared.aztuppy.root

    for i,_ in pairs(shared.aztuppy) do
        if url:find(tostring(i).."/") then
            lhost = shared.aztuppy[tostring(i)]
            url = url:split(tostring(i).."/")[2]
        end
    end

    local requirerScriptId = debugInfo(useHigherLevel and 3 or 2, 's');
    local requirerScript = __scripts[requirerScriptId];
    
    local requestData = httpRequest({
        Url = lhost..url
    });

    if (not requestData.Success and url:find("games/")) then
        requestData = httpRequest({
            Url = QueryGame(url:split("games/")[2])
        });
    elseif (not requestData.Success) then
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
    print(scriptFunction)

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

local gameList = HttpService:JSONDecode(customRequireShared('gameList.json'));

getgenv().require = customRequire;
getgenv().sharedRequire = customRequireShared;

getgenv().aztupHubV3Ran = false;
getgenv().aztupHubV3RanReal = false;
-- getgenv().scriptKey,getgenv().websiteKey='29be76a3-ad9f-4c27-aa3a-e78590f61971','8b21dab5-1432-4620-bf61-735fcfd240df';

local function GAMES_SETUP()
    local gameName = gameList[tostring(game.GameId)];
    print("GAME SETUP",gameName)
    if (not gameName) then return warn('no custom game for this game'); end;
    require(string.format('games/%s.lua', gameName:gsub('%s', '')));
end;

getgenv().GAMES_SETUP = GAMES_SETUP;
getgenv().getServerConstant = function(...) return ... end;
customRequire('source.lua');