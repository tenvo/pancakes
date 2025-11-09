if debugMode then
    getgenv().ah_loaderRan = false;
end
if (ah_loaderRan) then return end;
getgenv().ah_loaderRan = true;

local HttpService = game:GetService('HttpService');
local TweenService = game:GetService('TweenService');
local RunService = game:GetService('RunService');
local CoreGui = game:GetService('CoreGui');

local function setStatus() end;
local function destroyUI() end;


local http = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local oldRequest = clonefunction(http);

local function isRequestValid(req)
    if (not req.Headers) then return false end;
    return req.StatusCode < 500 and req.StatusCode ~= 0;
end;

local function httpRequest(...)
    local reqData = oldRequest(...);
    local attempts = 0;

    if (not isRequestValid(reqData)) then
        repeat
            reqData = oldRequest(...);
            attempts += 1;
            task.wait(1);
        until isRequestValid(reqData) or attempts > 30;
    end;

    return reqData;
end;

local CanvasGroup = {}; do
    CanvasGroup.__index = CanvasGroup;

    function CanvasGroup.new(gui)
        local self = setmetatable({}, CanvasGroup);

        self._gui = gui;
        self._value = 1;

        self._objects = {};

        local function onDescendantAdded(child)
            table.insert(self._objects, {
                instance = child,
                properties = self:_getInstanceProperties(child)
            });
        end;

        for _, child in next, self._gui:GetDescendants() do
            onDescendantAdded(child);
        end;

        self._gui.DescendantAdded:Connect(onDescendantAdded);

        onDescendantAdded(self._gui);

        self.ValueObject = Instance.new('NumberValue');
        self.ValueObject:GetPropertyChangedSignal('Value'):Connect(function()
            self:_setValue(self.ValueObject.Value);
        end);

        return self;
    end;

    function CanvasGroup:_getInstanceProperties(object)
        local properties = {};

        if (object:IsA('Frame') or object:IsA('ViewportFrame')) then
            properties.BackgroundTransparency = object.BackgroundTransparency;
        end;

        if (object:IsA('UIStroke')) then
            properties.Transparency = object.Transparency;
        end;

        if (object:IsA('TextLabel') or object:IsA('TextBox') or object:IsA('TextButton')) then
            properties.BackgroundTransparency = object.BackgroundTransparency;

            properties.TextTransparency = object.TextTransparency;
            properties.TextStrokeTransparency = object.TextStrokeTransparency;
        end;

        if (object:IsA('ImageButton') or object:IsA('ImageLabel') or object:IsA('ViewportFrame')) then
            properties.ImageTransparency = object.ImageTransparency;
        end;

        return properties;
    end;

    function CanvasGroup:_setValue(value)
        value = math.clamp(value, 0, 1);
        self._value = value;

        for _, objectObject in next, self._objects do
            for propertyName, propertyValue in next, objectObject.properties do
                if (propertyValue == 1) then continue end;
                objectObject.instance[propertyName] = (propertyValue + (1 - propertyValue)) * self._value;
            end;
        end;
    end;
end;

local Children = {};
local refs = {};

local oldGethui = gethui;

local function gethui(ui)
    if (oldGethui ~= nil) then
        return oldGethui();
    end;

    return CoreGui;
end;

local function c(instanceType, props)
    local i = Instance.new(instanceType);
    local ref = props.ref;
    props.ref = nil;

    for propName, propValue in next, props do
        if (propName == Children) then
            for _, child in next, propValue do
                child.Parent = i;
            end;
        else
            i[propName] = propValue;
        end;
    end;

    if (ref) then
        refs[ref] = i;
    end;

    return i;
end;

local function corner(cornerSize)
    return c('UICorner', {
        CornerRadius = UDim.new(0, cornerSize),
    });
end;

local function padding(paddingSize)
    return c('UIPadding', {
        PaddingBottom = UDim.new(0, paddingSize),
        PaddingLeft = UDim.new(0, paddingSize),
        PaddingRight = UDim.new(0, paddingSize),
        PaddingTop = UDim.new(0, paddingSize),
    });
end;

local ui = c('ScreenGui', {
    Name = 'Loader',
    ref = 'gui',
    Enabled = not getgenv().silentLaunch,
    DisplayOrder = 9,
    IgnoreGuiInset = true,
    OnTopOfCoreBlur = true,
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

    [Children] = {
        -- // Container
        c('Frame', {
            Name = 'Frame',
            ref = 'container',
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.8),
            Size = UDim2.fromOffset(250, 0),
            ZIndex = 2,

            [Children] = {
                padding(20),

                c('Frame', {
                    Name = 'LoadingCircle',
                    ref = 'loadingCircle',
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    LayoutOrder = 2,
                    Size = UDim2.fromOffset(15, 15),

                    [Children] = {
                        c('UIStroke', {
                            Name = 'UIStroke',
                            Color = Color3.fromRGB(255, 255, 255),
                            Thickness = 4,

                            [Children] = {
                                c('UIGradient', {
                                    ref = 'loadingCircleGrad',
                                    Name = 'UIGradient',
                                    Transparency = NumberSequence.new({
                                        NumberSequenceKeypoint.new(0, 1),
                                        NumberSequenceKeypoint.new(0.217, 1),
                                        NumberSequenceKeypoint.new(1, 0),
                                    }),
                                }),
                            }
                        }),

                        c('UICorner', {
                            CornerRadius = UDim.new(1, 0)
                        })
                    }
                }),

                c('UIListLayout', {
                    Name = 'UIListLayout',
                    ref = 'uiListLayout',
                    Padding = UDim.new(0, 15),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }),

                c('UIStroke', {
                    Name = 'UIStroke',
                    Color = Color3.fromRGB(66, 66, 66),
                    Thickness = 3,
                }),

                c('UIGradient', {
                    Name = 'UIGradient',
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
                    }),
                }),

                corner(4),

                c('TextLabel', {
                    Name = 'Title',
                    ref = 'title',
                    FontFace = Font.new(
                        'rbxasset://fonts/families/SourceSansPro.json',
                        Enum.FontWeight.Bold,
                        Enum.FontStyle.Normal
                    ),
                    Text = "AZTUP UI LOADER",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 25,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                }),

                c('TextBox', {
                    Name = 'Reason',
                    ref = 'reason',
                    FontFace = Font.new('rbxasset://fonts/families/Roboto.json'),
                    Text = '',
                    ClearTextOnFocus = false,
                    TextEditable = false,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    PlaceholderColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 20,
                    TextStrokeTransparency = 0.7,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(57, 57, 57),
                    BorderSizePixel = 0,
                    LayoutOrder = 3,
                    Size = UDim2.fromScale(1, 0),
                    Visible = false,

                    [Children] = {
                        corner(4),
                        padding(10)
                    }
                }),

                c('TextButton', {
                    Name = 'Button',
                    ref = 'button',
                    FontFace = Font.new(
                        'rbxasset://fonts/families/SourceSansPro.json',
                        Enum.FontWeight.Bold,
                        Enum.FontStyle.Normal
                    ),
                    Text = 'I UNDERSTAND, REACTIVATE MY ACCOUNT',
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 20,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(231, 76, 60),
                    LayoutOrder = 10,
                    Size = UDim2.fromScale(1, 0),
                    Visible = false,

                    [Children] = {
                        corner(4),
                        padding(10)
                    }
                }),

                c('TextButton', {
                    Name = 'Button',
                    ref = 'secondButton',
                    FontFace = Font.new(
                        'rbxasset://fonts/families/SourceSansPro.json',
                        Enum.FontWeight.Bold,
                        Enum.FontStyle.Normal
                    ),
                    Text = 'I UNDERSTAND, REACTIVATE MY ACCOUNT',
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 20,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(231, 76, 60),
                    LayoutOrder = 10,
                    Size = UDim2.fromScale(1, 0),
                    Visible = false,

                    [Children] = {
                        corner(4),
                        padding(10)
                    }
                }),

                c('TextButton', {
                    Name = 'Button',
                    ref = 'thirdButton',
                    FontFace = Font.new(
                        'rbxasset://fonts/families/SourceSansPro.json',
                        Enum.FontWeight.Bold,
                        Enum.FontStyle.Normal
                    ),
                    Text = 'I UNDERSTAND, REACTIVATE MY ACCOUNT',
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 20,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(57, 57, 57),
                    LayoutOrder = 10,
                    Size = UDim2.fromScale(1, 0),
                    Visible = false,

                    [Children] = {
                        corner(4),
                        padding(10)
                    }
                }),

                c('TextLabel', {
                    Name = 'Status',
                    FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json'),
                    Text = 'NO STATUS',
                    ref = 'status',
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 25,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    LayoutOrder = 2,
                    Size = UDim2.new(1, 0, 0, 20),
                }),
            }
        }),
    }
});

ui.Parent = gethui(ui);

local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad);

local loaderGUICanvas = CanvasGroup.new(ui);
loaderGUICanvas.ValueObject.Value = 1;
refs.container.Position = UDim2.new(0.5, 0, 0.8, 20);

TweenService:Create(loaderGUICanvas.ValueObject, tweenInfo, {Value = 0}):Play();
TweenService:Create(refs.container, tweenInfo, {Position = UDim2.fromScale(0.5, 0.85)}):Play();

local loadingCircleGrad = refs.loadingCircleGrad;
local loaderAnimTime = 0.6;
local ran = false;

local con;
con = RunService.Heartbeat:Connect(function(dt)
    local rot = dt * 360 / loaderAnimTime;
    local newRot = (loadingCircleGrad.Rotation + rot) % 360;
    loadingCircleGrad.Rotation = newRot;
end);

local statusEvent = Instance.new('BindableEvent');
getgenv().ah_statusEvent = statusEvent;

function setStatus(text, close, context)
    refs.status.Text = text;
    if (not close) then return end;

    if (typeof(close) ~= 'boolean') then
        refs.gui.Enabled = true;
        refs.title.TextXAlignment = Enum.TextXAlignment.Left;

        refs.reason.Visible = true;
        refs.reason.Text = text;
        refs.reason.Font = Enum.Font.SourceSans;

        refs.status.RichText = true;
        refs.status.TextXAlignment = Enum.TextXAlignment.Left;

        refs.uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
        refs.loadingCircle.Visible = false;
        refs.button.Visible = true;
        refs.button.Text = 'CLOSE MENU';

        refs.container.Size = UDim2.fromOffset(450, 0);
        refs.container.Position = UDim2.fromScale(0.5, 0.5);
    end;

    if (close == 'blacklist') then
        refs.title.Text = 'Your license has been revoked.';
        refs.status.Text = 'Your aztup hub license has been revoked for violating our terms of services. Continuous violations of our terms of services, could result in you not being allowed to purchase Aztup Hub. The reason of this decision can be found below. If you think this is a mistake please do not hesitate to contact the support. If you think this decision was fair you can re-purchase a license on the website dashboard by clicking on re-purchase.'

        refs.button.MouseButton1Click:Connect(function()
            if (destroyUI()) then
                statusEvent:Destroy();
                getgenv().ah_statusEvent = nil;
            end;
        end);
    elseif (close == 'hwid') then
        refs.title.Text = 'Hwid mismatch';
        refs.status.Text = string.format('This hwid has changed from the one we have in our records, to continue to use the script and confirm that you are owning the script, please input the 6 digits code that we\'ve just sent to you to your email %s (make sure to check your spams).', context.email);
        refs.reason.PlaceholderText = '6 Digits Code Here';
        refs.reason.TextEditable = true;

        refs.button.Text = 'Submit Code';

        refs.button.MouseButton1Click:Connect(function()
            local req = httpRequest({
                Method = 'POST',
                Url = 'https://aztupscripts.xyz/api/v1/whitelist/resetHwid',
                Body = HttpService:JSONEncode({code = refs.reason.Text}),
                Headers = {Authorization = websiteKey, ['Content-Type'] = 'application/json'}
            });

            refs.reason.Visible = false;
            refs.button.Visible = false;

            if (req.Success) then
                refs.button.Visible = false;
                return setStatus('Success! Please rejoin and re-execute the script.', true);
            else
                local errorMessage = 'Internal Server Error';
                pcall(function() errorMessage = HttpService:JSONDecode(req.Body).message;end);
                return setStatus(errorMessage, true);
            end;
        end);
    elseif (close == 'tos') then
        refs.title.Text = 'Please agree to the following';
        refs.status.Text = 'This script is in no way the successor to Aztup Hub, this is purely made for fun and the UI library is open to use for all individuals. No new games will be added to this main aztup hub archive script.';
        refs.reason.Visible = false;

        refs.secondButton.Visible = true;
        refs.secondButton.Text = 'I don\'t agree, close the script.';

        refs.thirdButton.Visible = true;
        refs.thirdButton.Text = 'Copy terms of services link to clipboard.';

        refs.button.Visible = true;
        refs.button.BackgroundColor3 = Color3.fromHex('#16a085');
        refs.button.Text = 'I understand';

        refs.secondButton.MouseButton1Click:Connect(function()
            refs.button.Visible = false;
            refs.secondButton.Visible = false;
            refs.thirdButton.Visible = false;

            setStatus('Thank you!', true);
        end);

        refs.thirdButton.MouseButton1Click:Connect(function()
            --setclipboard('https://aztupscripts.xyz/terms-of-services');
            refs.thirdButton.Text = 'There is no terms of service idot';
            task.wait(1);
            refs.thirdButton.Text = 'Copy terms of services link to clipboard.';
        end);

        refs.button.MouseButton1Click:Connect(function()
            -- local req = httpRequest({
            --     Method = 'PATCH',
            --     Url = 'https://aztupscripts.xyz/api/v1/user',
            --     Body = HttpService:JSONEncode({tosAccepted = true}),
            --     Headers = {Authorization = websiteKey, ['Content-Type'] = 'application/json'}
            -- });

            refs.reason.Visible = false;
            refs.secondButton.Visible = false;
            refs.thirdButton.Visible = false;
            refs.button.Visible = false;

            -- req.Success = true
            -- req.Body = "Lol"

            --if (req.Success) then
                statusEvent:Fire('tosAccepted');
                return setStatus('Success!', true);
            --else
                --local errorMessage = 'Internal Server Error';
                --pcall(function() errorMessage = HttpService:JSONDecode(req.Body).message; end);
                --return setStatus(errorMessage, true);
            --end;
        end);
    elseif (close == 'error') then
        refs.reason.Visible = false;
        refs.title.Text = 'Failed to launch script.';

        refs.button.MouseButton1Click:Connect(function()
            if (destroyUI()) then
                statusEvent:Destroy();
                getgenv().ah_statusEvent = nil;
            end;
        end);
    else
        task.delay((text == 'Script already ran' or text == 'All done' or text == 'Thank you!') and 1 or 8, function()
            if (destroyUI()) then
                statusEvent:Destroy();
                getgenv().ah_statusEvent = nil;
            end;
        end);
    end;
end;

function destroyUI()
    if (ran) then return end;
    ran = true;

    TweenService:Create(loaderGUICanvas.ValueObject, tweenInfo, {Value = 1}):Play();
    TweenService:Create(refs.container, tweenInfo, {Position = UDim2.new(0.5, 0, 0.5, 20)}):Play();

    task.delay(1, function()
        con:Disconnect();
        ui:Destroy();
    end);

    return true;
end;

statusEvent.Event:Connect(setStatus);
setStatus('Checking data');

local function logError(msg)
    msg = msg or '';

    setStatus('There was an error.\n\n' .. tostring(msg) .. '\n\n');
    task.delay(8, destroyUI);
end;

xpcall(function()
    --[[
    local websiteKey = getgenv().websiteKey;
    if (typeof(websiteKey) ~= 'string') then return end;
    ]]--

    local function fromHex(str)
        return string.gsub(str, '..', function (cc)
            return string.char(tonumber(cc, 16));
        end);
    end;

    local suc, err = pcall(function()
        if (not isfolder('Aztup Hub V3')) then makefolder('Aztup Hub V3'); end;
        if (not isfolder('Aztup Hub V3/scripts')) then makefolder('Aztup Hub V3/scripts'); end;
    end);

    if (not suc) then
        logError(err);
        setStatus('Failed to create scripts folder, this could be caused by executor not being located in a proper directory.', true);
        return;
    end;

    local universeId;
    local metadataRequest;

    local urlPattern = "https://raw.githubusercontent.com/tenvo/pancakes/%s/aztup/files/"
    local gitBranch = (debugMode and shared["aztuppy"] and shared.aztuppy["branch"]) or 'main'
    local rootUrl = string.format(urlPattern,gitBranch);

    if (not shared.aztuppy) then
        shared.aztuppy = {
            dependencies = true,
            root = rootUrl,
            utils = rootUrl.."utils/",
            classes = rootUrl.."classes/",
            games = rootUrl.."games/",
            branch = gitBranch
        }
    else
        if (shared.aztuppy.dependencies ~= true) then
            shared.aztuppy.root = rootUrl
            shared.aztuppy.utils = rootUrl.."utils/"
            shared.aztuppy.classes = rootUrl.."classes/"
            shared.aztuppy.games = rootUrl.."games/"
            shared.aztuppy.dependencies = true
            shared.aztuppy.branch = gitBranch
        end
    end

    task.spawn(function()
        local localUniverseId;
        local doingRequest;

        repeat
            if (game.GameId ~= 0) then
                localUniverseId = game.GameId;
            elseif (game.PlaceId ~= 0 and not doingRequest) then
                task.spawn(function()
                    doingRequest = true;
                    localUniverseId = HttpService:JSONDecode(httpRequest({
                        Url = string.format('https://apis.roblox.com/universes/v1/places/%s/universe', game.PlaceId)
                    }).Body).universeId;
                    doingRequest = false;
                end);
            end;

            task.wait();
        until localUniverseId;

        universeId = localUniverseId;
    end);

    task.spawn(function()
        metadataRequest = httpRequest({
            Url = rootUrl..'metadata.json'
        });
    end);

    -- // Wait for both requests to finish
    repeat task.wait(); until universeId and metadataRequest;

    if (not isRequestValid(metadataRequest) and not getgenv().ah_metadata) then
        return setStatus('Failed to communicate with the github, please try again later.', true);
    elseif (not metadataRequest.Success and not getgenv().ah_metadata) then
        return setStatus(string.format('%s - %s', tostring(metadataRequest.StatusCode), tostring(metadataRequest.Body)), true);
    end;

    -- if (not string.find(metadataRequest.Headers['Content-Type'], 'application/json')) then
    --     return setStatus('Failed to communicate with the github, please try again later.', true);
    -- end;

    metadataRequest = HttpService:JSONDecode(metadataRequest.Body);
    getgenv().ah_metadata = metadataRequest;
    local fileName = metadataRequest[tostring(universeId)];

    if (not fileName) then
        -- If no file name then we load the smallest file possible which in this case is KAT
        fileName = 'KAT';
    end;

    rootUrl = rootUrl:gsub('files/', '')

    local hash = loadstring("\108\111\99\97\108\32\77\79\68\32\61\32\50\94\51\50\10\108\111\99\97\108\32\77\79\68\77\32\61\32\77\79\68\45\49\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\109\101\109\111\105\122\101\40\102\41\10\9\108\111\99\97\108\32\109\116\32\61\32\123\125\10\9\108\111\99\97\108\32\116\32\61\32\115\101\116\109\101\116\97\116\97\98\108\101\40\123\125\44\32\109\116\41\10\9\102\117\110\99\116\105\111\110\32\109\116\58\95\95\105\110\100\101\120\40\107\41\10\9\9\108\111\99\97\108\32\118\32\61\32\102\40\107\41\10\9\9\116\91\107\93\32\61\32\118\10\9\9\114\101\116\117\114\110\32\118\10\9\101\110\100\10\9\114\101\116\117\114\110\32\116\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\109\97\107\101\95\98\105\116\111\112\95\117\110\99\97\99\104\101\100\40\116\44\32\109\41\10\9\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\98\105\116\111\112\40\97\44\32\98\41\10\9\9\108\111\99\97\108\32\114\101\115\44\112\32\61\32\48\44\49\10\9\9\119\104\105\108\101\32\97\32\126\61\32\48\32\97\110\100\32\98\32\126\61\32\48\32\100\111\10\9\9\9\108\111\99\97\108\32\97\109\44\32\98\109\32\61\32\97\32\37\32\109\44\32\98\32\37\32\109\10\9\9\9\114\101\115\32\61\32\114\101\115\32\43\32\116\91\97\109\93\91\98\109\93\32\42\32\112\10\9\9\9\97\32\61\32\40\97\32\45\32\97\109\41\32\47\32\109\10\9\9\9\98\32\61\32\40\98\32\45\32\98\109\41\32\47\32\109\10\9\9\9\112\32\61\32\112\42\109\10\9\9\101\110\100\10\9\9\114\101\115\32\61\32\114\101\115\32\43\32\40\97\32\43\32\98\41\32\42\32\112\10\9\9\114\101\116\117\114\110\32\114\101\115\10\9\101\110\100\10\9\114\101\116\117\114\110\32\98\105\116\111\112\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\109\97\107\101\95\98\105\116\111\112\40\116\41\10\9\108\111\99\97\108\32\111\112\49\32\61\32\109\97\107\101\95\98\105\116\111\112\95\117\110\99\97\99\104\101\100\40\116\44\50\94\49\41\10\9\108\111\99\97\108\32\111\112\50\32\61\32\109\101\109\111\105\122\101\40\102\117\110\99\116\105\111\110\40\97\41\32\114\101\116\117\114\110\32\109\101\109\111\105\122\101\40\102\117\110\99\116\105\111\110\40\98\41\32\114\101\116\117\114\110\32\111\112\49\40\97\44\32\98\41\32\101\110\100\41\32\101\110\100\41\10\9\114\101\116\117\114\110\32\109\97\107\101\95\98\105\116\111\112\95\117\110\99\97\99\104\101\100\40\111\112\50\44\32\50\32\94\32\40\116\46\110\32\111\114\32\49\41\41\10\101\110\100\10\10\108\111\99\97\108\32\98\120\111\114\49\32\61\32\109\97\107\101\95\98\105\116\111\112\40\123\91\48\93\32\61\32\123\91\48\93\32\61\32\48\44\91\49\93\32\61\32\49\125\44\32\91\49\93\32\61\32\123\91\48\93\32\61\32\49\44\32\91\49\93\32\61\32\48\125\44\32\110\32\61\32\52\125\41\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\98\120\111\114\40\97\44\32\98\44\32\99\44\32\46\46\46\41\10\9\108\111\99\97\108\32\122\32\61\32\110\105\108\10\9\105\102\32\98\32\116\104\101\110\10\9\9\97\32\61\32\97\32\37\32\77\79\68\10\9\9\98\32\61\32\98\32\37\32\77\79\68\10\9\9\122\32\61\32\98\120\111\114\49\40\97\44\32\98\41\10\9\9\105\102\32\99\32\116\104\101\110\32\122\32\61\32\98\120\111\114\40\122\44\32\99\44\32\46\46\46\41\32\101\110\100\10\9\9\114\101\116\117\114\110\32\122\10\9\101\108\115\101\105\102\32\97\32\116\104\101\110\32\114\101\116\117\114\110\32\97\32\37\32\77\79\68\10\9\101\108\115\101\32\114\101\116\117\114\110\32\48\32\101\110\100\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\98\97\110\100\40\97\44\32\98\44\32\99\44\32\46\46\46\41\10\9\108\111\99\97\108\32\122\10\9\105\102\32\98\32\116\104\101\110\10\9\9\97\32\61\32\97\32\37\32\77\79\68\10\9\9\98\32\61\32\98\32\37\32\77\79\68\10\9\9\122\32\61\32\40\40\97\32\43\32\98\41\32\45\32\98\120\111\114\49\40\97\44\98\41\41\32\47\32\50\10\9\9\105\102\32\99\32\116\104\101\110\32\122\32\61\32\98\105\116\51\50\95\98\97\110\100\40\122\44\32\99\44\32\46\46\46\41\32\101\110\100\10\9\9\114\101\116\117\114\110\32\122\10\9\101\108\115\101\105\102\32\97\32\116\104\101\110\32\114\101\116\117\114\110\32\97\32\37\32\77\79\68\10\9\101\108\115\101\32\114\101\116\117\114\110\32\77\79\68\77\32\101\110\100\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\98\110\111\116\40\120\41\32\114\101\116\117\114\110\32\40\45\49\32\45\32\120\41\32\37\32\77\79\68\32\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\114\115\104\105\102\116\49\40\97\44\32\100\105\115\112\41\10\9\105\102\32\100\105\115\112\32\60\32\48\32\116\104\101\110\32\114\101\116\117\114\110\32\108\115\104\105\102\116\40\97\44\45\100\105\115\112\41\32\101\110\100\10\9\114\101\116\117\114\110\32\109\97\116\104\46\102\108\111\111\114\40\97\32\37\32\50\32\94\32\51\50\32\47\32\50\32\94\32\100\105\115\112\41\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\114\115\104\105\102\116\40\120\44\32\100\105\115\112\41\10\9\105\102\32\100\105\115\112\32\62\32\51\49\32\111\114\32\100\105\115\112\32\60\32\45\51\49\32\116\104\101\110\32\114\101\116\117\114\110\32\48\32\101\110\100\10\9\114\101\116\117\114\110\32\114\115\104\105\102\116\49\40\120\32\37\32\77\79\68\44\32\100\105\115\112\41\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\108\115\104\105\102\116\40\97\44\32\100\105\115\112\41\10\9\105\102\32\100\105\115\112\32\60\32\48\32\116\104\101\110\32\114\101\116\117\114\110\32\114\115\104\105\102\116\40\97\44\45\100\105\115\112\41\32\101\110\100\32\10\9\114\101\116\117\114\110\32\40\97\32\42\32\50\32\94\32\100\105\115\112\41\32\37\32\50\32\94\32\51\50\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\114\114\111\116\97\116\101\40\120\44\32\100\105\115\112\41\10\32\32\32\32\120\32\61\32\120\32\37\32\77\79\68\10\32\32\32\32\100\105\115\112\32\61\32\100\105\115\112\32\37\32\51\50\10\32\32\32\32\108\111\99\97\108\32\108\111\119\32\61\32\98\97\110\100\40\120\44\32\50\32\94\32\100\105\115\112\32\45\32\49\41\10\32\32\32\32\114\101\116\117\114\110\32\114\115\104\105\102\116\40\120\44\32\100\105\115\112\41\32\43\32\108\115\104\105\102\116\40\108\111\119\44\32\51\50\32\45\32\100\105\115\112\41\10\101\110\100\10\10\108\111\99\97\108\32\107\32\61\32\123\10\9\48\120\52\50\56\97\50\102\57\56\44\32\48\120\55\49\51\55\52\52\57\49\44\32\48\120\98\53\99\48\102\98\99\102\44\32\48\120\101\57\98\53\100\98\97\53\44\10\9\48\120\51\57\53\54\99\50\53\98\44\32\48\120\53\57\102\49\49\49\102\49\44\32\48\120\57\50\51\102\56\50\97\52\44\32\48\120\97\98\49\99\53\101\100\53\44\10\9\48\120\100\56\48\55\97\97\57\56\44\32\48\120\49\50\56\51\53\98\48\49\44\32\48\120\50\52\51\49\56\53\98\101\44\32\48\120\53\53\48\99\55\100\99\51\44\10\9\48\120\55\50\98\101\53\100\55\52\44\32\48\120\56\48\100\101\98\49\102\101\44\32\48\120\57\98\100\99\48\54\97\55\44\32\48\120\99\49\57\98\102\49\55\52\44\10\9\48\120\101\52\57\98\54\57\99\49\44\32\48\120\101\102\98\101\52\55\56\54\44\32\48\120\48\102\99\49\57\100\99\54\44\32\48\120\50\52\48\99\97\49\99\99\44\10\9\48\120\50\100\101\57\50\99\54\102\44\32\48\120\52\97\55\52\56\52\97\97\44\32\48\120\53\99\98\48\97\57\100\99\44\32\48\120\55\54\102\57\56\56\100\97\44\10\9\48\120\57\56\51\101\53\49\53\50\44\32\48\120\97\56\51\49\99\54\54\100\44\32\48\120\98\48\48\51\50\55\99\56\44\32\48\120\98\102\53\57\55\102\99\55\44\10\9\48\120\99\54\101\48\48\98\102\51\44\32\48\120\100\53\97\55\57\49\52\55\44\32\48\120\48\54\99\97\54\51\53\49\44\32\48\120\49\52\50\57\50\57\54\55\44\10\9\48\120\50\55\98\55\48\97\56\53\44\32\48\120\50\101\49\98\50\49\51\56\44\32\48\120\52\100\50\99\54\100\102\99\44\32\48\120\53\51\51\56\48\100\49\51\44\10\9\48\120\54\53\48\97\55\51\53\52\44\32\48\120\55\54\54\97\48\97\98\98\44\32\48\120\56\49\99\50\99\57\50\101\44\32\48\120\57\50\55\50\50\99\56\53\44\10\9\48\120\97\50\98\102\101\56\97\49\44\32\48\120\97\56\49\97\54\54\52\98\44\32\48\120\99\50\52\98\56\98\55\48\44\32\48\120\99\55\54\99\53\49\97\51\44\10\9\48\120\100\49\57\50\101\56\49\57\44\32\48\120\100\54\57\57\48\54\50\52\44\32\48\120\102\52\48\101\51\53\56\53\44\32\48\120\49\48\54\97\97\48\55\48\44\10\9\48\120\49\57\97\52\99\49\49\54\44\32\48\120\49\101\51\55\54\99\48\56\44\32\48\120\50\55\52\56\55\55\52\99\44\32\48\120\51\52\98\48\98\99\98\53\44\10\9\48\120\51\57\49\99\48\99\98\51\44\32\48\120\52\101\100\56\97\97\52\97\44\32\48\120\53\98\57\99\99\97\52\102\44\32\48\120\54\56\50\101\54\102\102\51\44\10\9\48\120\55\52\56\102\56\50\101\101\44\32\48\120\55\56\97\53\54\51\54\102\44\32\48\120\56\52\99\56\55\56\49\52\44\32\48\120\56\99\99\55\48\50\48\56\44\10\9\48\120\57\48\98\101\102\102\102\97\44\32\48\120\97\52\53\48\54\99\101\98\44\32\48\120\98\101\102\57\97\51\102\55\44\32\48\120\99\54\55\49\55\56\102\50\44\10\125\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\115\116\114\50\104\101\120\97\40\115\41\10\9\114\101\116\117\114\110\32\40\115\116\114\105\110\103\46\103\115\117\98\40\115\44\32\34\46\34\44\32\102\117\110\99\116\105\111\110\40\99\41\32\114\101\116\117\114\110\32\115\116\114\105\110\103\46\102\111\114\109\97\116\40\34\37\48\50\120\34\44\32\115\116\114\105\110\103\46\98\121\116\101\40\99\41\41\32\101\110\100\41\41\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\110\117\109\50\115\40\108\44\32\110\41\10\9\108\111\99\97\108\32\115\32\61\32\34\34\10\9\102\111\114\32\105\32\61\32\49\44\32\110\32\100\111\10\9\9\108\111\99\97\108\32\114\101\109\32\61\32\108\32\37\32\50\53\54\10\9\9\115\32\61\32\115\116\114\105\110\103\46\99\104\97\114\40\114\101\109\41\32\46\46\32\115\10\9\9\108\32\61\32\40\108\32\45\32\114\101\109\41\32\47\32\50\53\54\10\9\101\110\100\10\9\114\101\116\117\114\110\32\115\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\115\50\51\50\110\117\109\40\115\44\32\105\41\10\9\108\111\99\97\108\32\110\32\61\32\48\10\9\102\111\114\32\105\32\61\32\105\44\32\105\32\43\32\51\32\100\111\32\110\32\61\32\110\42\50\53\54\32\43\32\115\116\114\105\110\103\46\98\121\116\101\40\115\44\32\105\41\32\101\110\100\10\9\114\101\116\117\114\110\32\110\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\112\114\101\112\114\111\99\40\109\115\103\44\32\108\101\110\41\10\9\108\111\99\97\108\32\101\120\116\114\97\32\61\32\54\52\32\45\32\40\40\108\101\110\32\43\32\57\41\32\37\32\54\52\41\10\9\108\101\110\32\61\32\110\117\109\50\115\40\56\32\42\32\108\101\110\44\32\56\41\10\9\109\115\103\32\61\32\109\115\103\32\46\46\32\34\92\49\50\56\34\32\46\46\32\115\116\114\105\110\103\46\114\101\112\40\34\92\48\34\44\32\101\120\116\114\97\41\32\46\46\32\108\101\110\10\9\97\115\115\101\114\116\40\35\109\115\103\32\37\32\54\52\32\61\61\32\48\41\10\9\114\101\116\117\114\110\32\109\115\103\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\105\110\105\116\72\50\53\54\40\72\41\10\9\72\91\49\93\32\61\32\48\120\54\97\48\57\101\54\54\55\10\9\72\91\50\93\32\61\32\48\120\98\98\54\55\97\101\56\53\10\9\72\91\51\93\32\61\32\48\120\51\99\54\101\102\51\55\50\10\9\72\91\52\93\32\61\32\48\120\97\53\52\102\102\53\51\97\10\9\72\91\53\93\32\61\32\48\120\53\49\48\101\53\50\55\102\10\9\72\91\54\93\32\61\32\48\120\57\98\48\53\54\56\56\99\10\9\72\91\55\93\32\61\32\48\120\49\102\56\51\100\57\97\98\10\9\72\91\56\93\32\61\32\48\120\53\98\101\48\99\100\49\57\10\9\114\101\116\117\114\110\32\72\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\100\105\103\101\115\116\98\108\111\99\107\40\109\115\103\44\32\105\44\32\72\41\10\9\108\111\99\97\108\32\119\32\61\32\123\125\10\9\102\111\114\32\106\32\61\32\49\44\32\49\54\32\100\111\32\119\91\106\93\32\61\32\115\50\51\50\110\117\109\40\109\115\103\44\32\105\32\43\32\40\106\32\45\32\49\41\42\52\41\32\101\110\100\10\9\102\111\114\32\106\32\61\32\49\55\44\32\54\52\32\100\111\10\9\9\108\111\99\97\108\32\118\32\61\32\119\91\106\32\45\32\49\53\93\10\9\9\108\111\99\97\108\32\115\48\32\61\32\98\120\111\114\40\114\114\111\116\97\116\101\40\118\44\32\55\41\44\32\114\114\111\116\97\116\101\40\118\44\32\49\56\41\44\32\114\115\104\105\102\116\40\118\44\32\51\41\41\10\9\9\118\32\61\32\119\91\106\32\45\32\50\93\10\9\9\119\91\106\93\32\61\32\119\91\106\32\45\32\49\54\93\32\43\32\115\48\32\43\32\119\91\106\32\45\32\55\93\32\43\32\98\120\111\114\40\114\114\111\116\97\116\101\40\118\44\32\49\55\41\44\32\114\114\111\116\97\116\101\40\118\44\32\49\57\41\44\32\114\115\104\105\102\116\40\118\44\32\49\48\41\41\10\9\101\110\100\10\10\9\108\111\99\97\108\32\97\44\32\98\44\32\99\44\32\100\44\32\101\44\32\102\44\32\103\44\32\104\32\61\32\72\91\49\93\44\32\72\91\50\93\44\32\72\91\51\93\44\32\72\91\52\93\44\32\72\91\53\93\44\32\72\91\54\93\44\32\72\91\55\93\44\32\72\91\56\93\10\9\102\111\114\32\105\32\61\32\49\44\32\54\52\32\100\111\10\9\9\108\111\99\97\108\32\115\48\32\61\32\98\120\111\114\40\114\114\111\116\97\116\101\40\97\44\32\50\41\44\32\114\114\111\116\97\116\101\40\97\44\32\49\51\41\44\32\114\114\111\116\97\116\101\40\97\44\32\50\50\41\41\10\9\9\108\111\99\97\108\32\109\97\106\32\61\32\98\120\111\114\40\98\97\110\100\40\97\44\32\98\41\44\32\98\97\110\100\40\97\44\32\99\41\44\32\98\97\110\100\40\98\44\32\99\41\41\10\9\9\108\111\99\97\108\32\116\50\32\61\32\115\48\32\43\32\109\97\106\10\9\9\108\111\99\97\108\32\115\49\32\61\32\98\120\111\114\40\114\114\111\116\97\116\101\40\101\44\32\54\41\44\32\114\114\111\116\97\116\101\40\101\44\32\49\49\41\44\32\114\114\111\116\97\116\101\40\101\44\32\50\53\41\41\10\9\9\108\111\99\97\108\32\99\104\32\61\32\98\120\111\114\32\40\98\97\110\100\40\101\44\32\102\41\44\32\98\97\110\100\40\98\110\111\116\40\101\41\44\32\103\41\41\10\9\9\108\111\99\97\108\32\116\49\32\61\32\104\32\43\32\115\49\32\43\32\99\104\32\43\32\107\91\105\93\32\43\32\119\91\105\93\10\9\9\104\44\32\103\44\32\102\44\32\101\44\32\100\44\32\99\44\32\98\44\32\97\32\61\32\103\44\32\102\44\32\101\44\32\100\32\43\32\116\49\44\32\99\44\32\98\44\32\97\44\32\116\49\32\43\32\116\50\10\9\101\110\100\10\10\9\72\91\49\93\32\61\32\98\97\110\100\40\72\91\49\93\32\43\32\97\41\10\9\72\91\50\93\32\61\32\98\97\110\100\40\72\91\50\93\32\43\32\98\41\10\9\72\91\51\93\32\61\32\98\97\110\100\40\72\91\51\93\32\43\32\99\41\10\9\72\91\52\93\32\61\32\98\97\110\100\40\72\91\52\93\32\43\32\100\41\10\9\72\91\53\93\32\61\32\98\97\110\100\40\72\91\53\93\32\43\32\101\41\10\9\72\91\54\93\32\61\32\98\97\110\100\40\72\91\54\93\32\43\32\102\41\10\9\72\91\55\93\32\61\32\98\97\110\100\40\72\91\55\93\32\43\32\103\41\10\9\72\91\56\93\32\61\32\98\97\110\100\40\72\91\56\93\32\43\32\104\41\10\101\110\100\10\10\108\111\99\97\108\32\102\117\110\99\116\105\111\110\32\104\97\115\104\40\109\115\103\41\10\9\109\115\103\32\61\32\112\114\101\112\114\111\99\40\109\115\103\44\32\35\109\115\103\41\10\9\108\111\99\97\108\32\72\32\61\32\105\110\105\116\72\50\53\54\40\123\125\41\10\9\102\111\114\32\105\32\61\32\49\44\32\35\109\115\103\44\32\54\52\32\100\111\32\100\105\103\101\115\116\98\108\111\99\107\40\109\115\103\44\32\105\44\32\72\41\32\101\110\100\10\9\114\101\116\117\114\110\32\115\116\114\50\104\101\120\97\40\110\117\109\50\115\40\72\91\49\93\44\32\52\41\32\46\46\32\110\117\109\50\115\40\72\91\50\93\44\32\52\41\32\46\46\32\110\117\109\50\115\40\72\91\51\93\44\32\52\41\32\46\46\32\110\117\109\50\115\40\72\91\52\93\44\32\52\41\32\46\46\10\9\9\110\117\109\50\115\40\72\91\53\93\44\32\52\41\32\46\46\32\110\117\109\50\115\40\72\91\54\93\44\32\52\41\32\46\46\32\110\117\109\50\115\40\72\91\55\93\44\32\52\41\32\46\46\32\110\117\109\50\115\40\72\91\56\93\44\32\52\41\41\10\101\110\100\10\114\101\116\117\114\110\32\104\97\115\104\10")()
    local aztuppyFile = isfile("Aztup Hub V3/aztuppy.json")
    local loaderHash,loaderScript,scriptOutdated;

    if isfile("Aztup Hub V3/scripts/loader.lua") then
        if aztuppyFile then
            aztuppyFile = HttpService:JSONDecode(readfile("Aztup Hub V3/aztuppy.json"))

            if aztuppyFile["loaderHash"] then
                loaderHash = aztuppyFile["loaderHash"]
            end
        end
        
        local scriptHash = game:HttpGet("https://e-z.tools/p/raw/a5avpra01t")
        if not loaderHash then loaderHash = hash(readfile("Aztup Hub V3/scripts/loader.lua")) end
        
        if scriptHash ~= loaderHash then
            scriptOutdated = true
        else
            loaderScript = readfile("Aztup Hub V3/scripts/loader.lua")
        end
    else
        scriptOutdated = true
    end

    if scriptOutdated then
        local require_loader
        local base_append

        task.spawn(function()
            require_loader = httpRequest({
                Url = rootUrl.."require-loader.lua"
            }).Body;

            base_append = httpRequest({
                Url = rootUrl.."base-append.lua"
            }).Body;
        end);

        setStatus('Downloading script');
        repeat task.wait(); until base_append and require_loader;

        loaderScript = tostring(base_append).." "..tostring(require_loader)
        writefile("Aztup Hub V3/scripts/loader.lua",loaderScript)
    end

    xpcall(function()
        if typeof(loaderScript) == 'string' then
            local AztupScript = assert(loadstring(loaderScript))

            setStatus('Launching script');
            AztupScript(aztuppyFile,loaderHash)
        else
            setStatus('Failed to get loader script',true)
        end
    end, function(err)
        logError(err);
        local Error = err:split(":")
        local ErrorLine = Error[#Error-1]
        local IntitalLine = Error[2]
        local ErrorMsg = Error[#Error]
        setStatus("AztupScript:("..IntitalLine.."):"..ErrorLine..":"..ErrorMsg, true);
    end);
end, function(err)
    logError(err);
    setStatus(err, true);
end);