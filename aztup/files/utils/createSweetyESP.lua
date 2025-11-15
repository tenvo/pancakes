--// W sweety for making this esp for deepwoken dev, your service to the umarcorp wont be forgotten
local Maid = sharedRequire('utils/Maid.lua');
local Utility = sharedRequire('utils/Utility.lua')
local Services = sharedRequire('utils/Services.lua');
local Players,RunService = Services:Get('Players','RunService');


local function createSweetyEsp()
    local sweetyEsp = {}

    sweetyEsp.plr = Players.LocalPlayer
    sweetyEsp.char = sweetyEsp.plr.Character
    sweetyEsp._maid = Maid.new()
    sweetyEsp._objs = {}

    sweetyEsp.plr.CharacterAdded:Connect(function(char)
        sweetyEsp.char = char
    end)

    function sweetyEsp.new(cr,flag)
        local espClass = {}

        espClass.flag = flag
        espClass.dist = 0
        espClass.state = true
        espClass.display = {"%s [%s]",{"flag","dist"}}
        espClass.showDistance = true
        espClass.maid = Maid.new()


        if sweetyEsp._objs[flag] then return warn('Already an ESP Active of that Flag') end

        local c = workspace.Camera
        local h = cr:WaitForChild("Humanoid")
        local hrp = cr:WaitForChild("HumanoidRootPart")

        local text = Drawing.new("Text")
        text.Visible = false
        text.Center = true
        text.Outline = true 
        text.Font = 2
        text.Color = Color3.fromRGB(255,255,255)
        text.Size = 13

        --// Health not workin ATM but we dont need it for now
        -- local healthText = Drawing.new("Text")  
        -- healthText.Visible = false
        -- healthText.Center = true
        -- healthText.Outline = true 
        -- healthText.Font = 2
        -- healthText.Color = Color3.fromRGB(255,255,255)
        -- healthText.Size = 13

        espClass.maid:GiveTask(cr.AncestryChanged:Connect(function()
            if cr:IsDescendantOf(game) then return; end

            espClass:Destroy()
        end))

        --espClass.maid:AddTask(h.HealthChanged:Connect(function(v)
        --     if (v<=0) or (h:GetState() == Enum.HumanoidStateType.Dead) then
        --         dc()
        --     else
        --         healthText.Text = "Health: "..math.floor(h.Health)
        --         healthText.Visible = true
        --     end
        -- end))

        local function getRoot(char)
            local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso') or {Position = Vector3.new(0,0,0)}
            return rootPart
        end

        espClass.maid:GiveTask(RunService.RenderStepped:Connect(function()
            if espClass.flag then
                local hrp_pos,hrp_onscreen = c:WorldToViewportPoint(hrp.Position)
                if hrp_onscreen then
                    if espClass.showDistance then
                        espClass.dist = math.floor((getRoot(sweetyEsp.char).Position - getRoot(cr).Position).magnitude)
                    end

                    text.Position = Vector2.new(hrp_pos.X, hrp_pos.Y - 30)
                    text.Text = string.format(espClass.display[1],espClass.flag,espClass.dist)
                    text.Visible = true

                    -- local health_pos = Vector2.new(hrp_pos.X, hrp_pos.Y + 15)
                    -- healthText.Position = health_pos
                    -- healthText.Visible = true
                else
                    text.Visible = false
                    --healthText.Visible = false
                end
            else
                return
            end
        end))

        function espClass:Toggle(s)
            if typeof(s) ~= 'boolean' then return end
            espClass.state = s
        end

        function espClass:Destroy()
            text:Remove()
            --healthText:Remove()
            espClass.maid:Destroy()

            sweetyEsp._objs[flag] = nil
        end
        
        sweetyEsp._objs[flag] = espClass

        return espClass
    end

    function sweetyEsp:Get(flag)
        if typeof("flag") ~= 'string' then return end

        if sweetyEsp._objs[flag] then
            return true
        end

        return false
    end

    function sweetyEsp:Clear()
        for i,v in pairs(sweetyEsp._objs) do
            v:Destroy()
        end
    end

    return sweetyEsp
end

return createSweetyEsp