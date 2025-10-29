local Services = sharedRequire('@utils/Services.lua');
local library = sharedRequire('UILibrary.lua');
local HttpService = Services:Get('HttpService');

local Webhook = {};
Webhook.__index = Webhook;

function Webhook.new(url)
    local self = setmetatable({}, Webhook);

    self._url = url or "";
    self._gameName = library.gameName
    self._ping = nil
    self._preset = {
        ["content"] = "",
        ["username"] = "pancake fan club",
        ["avatar_url"] = "https://github.com/tenvo/pancakes/blob/main/assets/pancakefanclub.webp?raw=true",
        ["embeds"] = {
            {
                ["author"] = {
                    ["name"] = self._gameName.." | Aztup Hub (tenvo Overhaul)",
                },
                ["description"] = "",
            },
        },
    }

    return self;
end;

function Webhook:SetUrl(url)
    self._url = url or "";
end

function Webhook:SetPing(arg)
    if arg == nil then self._preset["content"] = "" end

    if tonumber(arg) then
        self._ping = string.format("<@%s>",arg) --// UserID
    else
        self._ping = string.format("@%s",arg) --// Username
    end
end

function Webhook:Send(data, yields)
    if (self._url == "") then return; end;

    if (typeof(data) == 'table') then
        data = data
    elseif (typeof(data) == 'string') then
        local presetClone = self._preset

        if (data:find("@everyone") and self._ping == nil) then
            presetClone["content"] = "@everyone"
            data = data:gsub("@everyone","")
        elseif(self._ping ~= nil) then
            presetClone["content"] = self._ping
        end
        
        presetClone["embeds"][1]["description"] = data
        data = presetClone

        print(self._preset["content"],self._preset["embeds"][1]["description"],"Checking if it clones")
    end;

    local function send()
        local http = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if not http then return end

        http({
            Url = self._url:gsub(" ",""),
            Method = 'POST',
            Headers = {['Content-Type'] = 'application/json'},
            Body = originalFunctions.jsonEncode(HttpService, data)
        });
    end;

    if (yields) then
        pcall(send);
    else
        task.spawn(send);
    end;
end;

return Webhook;