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
        ["embeds"] = {
            {
                ["author"] = {
                    ["name"] = self._gameName.." | Aztup Hub Overhaul [PFC]",
                },
                ["footer"] = {
                    ["text"] = "pancake fan club: discord.gg/QrJV3HcJDP",
                },
                ["description"] = "",
            },
        },
    }

    function self:meow()
        local umars = {"Senior Umar","Cool Umar","Lady Umar","Rogue Umar","Stronk Umar"}
        local meow = math.random(1,#umars)

        self._preset["username"] = umars[meow]
        self._preset["avatar_url"] = string.format("https://raw.githubusercontent.com/tenvo/pancakes/refs/heads/main/assets/%s.png",umars[meow]:gsub(" ",""):lower())
    end

    return self;
end;

function Webhook:SetUrl(url)
    self._url = url or "";
end

function Webhook:SetPing(arg)
    if tonumber(arg) then
        self._ping = string.format("<@%s>",arg) --// UserID
        return;
    else
        self._ping = nil
    end
end

function Webhook:Send(data, yields)
    if (self._url == "") then return; end;

    if (typeof(data) == 'table') then
        data = data
    elseif (typeof(data) == 'string') then
        if (data:find("@everyone") and self._ping == nil) then
            self._preset["content"] = "@everyone"
            data = data:gsub("@everyone","")
        elseif(self._ping ~= nil) then
            self._preset["content"] = self._ping
        end
        
        self._preset["embeds"][1]["description"] = data
        self:meow()
        data = self._preset
    end;

    local function send()
        local http = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if not http then return end

        http({
            Url = self._url:gsub(" ",""),
            Method = 'POST',
            Headers = {['Content-Type'] = 'application/json'},
            Body = HttpService:JSONEncode(data)
        });
    end;

    if (yields) then
        pcall(send);
    else
        task.spawn(send);
    end;
end;

return Webhook;