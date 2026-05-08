return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local AutoEventActive = false
    
    local currentPosMode = "Behind"
    local currentDistance = 5
    local selectedSkills = {}
    local eventsJoinedCount = 0
    local lastJoinTime = 0

    local currentTargetNPC = nil
    local targetWaitingCFrame = CFrame.new(1193.24, 875.01 + 3, -668.33)

    local StatusPara
    local noclipConn = nil
    local lockConn = nil

    local function UpdateStats()
        if StatusPara then
            StatusPara:SetDesc(string.format("So lan tham gia Event: %d", eventsJoinedCount))
        end
    end

    local function IsTargetColor(color3)
        local r = math.floor(color3.R * 255 + 0.5)
        local g = math.floor(color3.G * 255 + 0.5)
        local b = math.floor(color3.B * 255 + 0.5)
        return (r == 255 and g == 0 and b == 25)
    end

    -- Toi uu hoa thuat toan tim quai (Giam giat lag)
    local function FindNewHighlightNPC()
        local liveFolder = workspace:FindFirstChild("Live")
        if not liveFolder then return nil end

        for _, obj in ipairs(liveFolder:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local hum = obj:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    -- Tim Highlight o lop ngoai cung truoc cho nhe, neu khong co moi quet sau
                    local highlight = obj:FindFirstChildOfClass("Highlight") or obj:FindFirstChildWhichIsA("Highlight", true)
                    
                    if highlight and highlight.Enabled then
                        if IsTargetColor(highlight.OutlineColor) or IsTargetColor(highlight.FillColor) then
                            return obj
                        end
                    end
                end
            end
        end
        return nil
    end

    local function IsCurrentTargetValid(npcModel)
        if not npcModel or not npcModel.Parent or not npcModel:FindFirstChild("HumanoidRootPart") then return false end
        local hum = npcModel:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        
        local highlight = npcModel:FindFirstChildOfClass("Highlight") or npcModel:FindFirstChildWhichIsA("Highlight", true)
        if highlight and highlight.Enabled then
            if IsTargetColor(highlight.OutlineColor) or IsTargetColor(highlight.FillColor) then
                return true
            end
        end
        return false
    end

    -- Xoa bo cac vong lap vat ly khi tat Auto
    local function CleanUpPhysics()
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if lockConn then lockConn:Disconnect() lockConn = nil end
        
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.AutoRotate = true end
        end
    end

    -- Khoi tao luong vat ly rieng biet (Sieu nhe, khong anh huong FPS)
    local function StartPhysicsLocks()
        CleanUpPhysics()

        -- Luong Noclip (Toi uu: Chi lay BasePart o lop ngoai cung)
        noclipConn = RunService.Stepped:Connect(function()
            if not AutoEventActive then return end
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetChildren()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        p.CanCollide = false
                    end
                end
            end
        end)

        -- Luong khoa CFrame (Chay o Heartbeat de dong bo voi game engine)
        lockConn = RunService.Heartbeat:Connect(function()
            if not AutoEventActive then return end
            
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local root = char.HumanoidRootPart
            local hum = char:FindFirstChild("Humanoid")

            if currentTargetNPC then
                local targetRoot = currentTargetNPC:FindFirstChild("HumanoidRootPart")
                if targetRoot and hum then
                    hum.AutoRotate = false

                    local targetPos = targetRoot.Position
                    local finalPosition

                    if currentPosMode == "Behind" then
                        finalPosition = targetPos - (targetRoot.CFrame.LookVector * currentDistance)
                    elseif currentPosMode == "Above" then
                        finalPosition = targetPos + Vector3.new(0.01, currentDistance, 0.01)
                    elseif currentPosMode == "Under" then
                        finalPosition = targetPos + Vector3.new(0.01, -currentDistance, 0.01)
                    end

                    root.CFrame = CFrame.lookAt(finalPosition, targetPos)
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                end
            else
                -- Khi chua co quai ma dang trong phong cho
                if hum then hum.AutoRotate = true end
                if tick() - lastJoinTime < 60 then
                    if (root.Position - targetWaitingCFrame.Position).Magnitude > 2 then
                        root.CFrame = targetWaitingCFrame
                        root.Velocity = Vector3.zero
                        root.RotVelocity = Vector3.zero
                    end
                end
            end
        end)
    end

    local function ProcessAutoEvent()
        StartPhysicsLocks()

        while AutoEventActive do
            task.wait(0.2) -- Giam tan suat quet Event/Skill de tiet kiem CPU
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local ccc = char:FindFirstChild("client_character_controller")

                -- 1. KIEM TRA THONG BAO WORLD EVENT
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                local mainHud = pGui and pGui:FindFirstChild("MainHud")
                local worldEvent = mainHud and mainHud:FindFirstChild("worldevent")
                local modeLbl = worldEvent and worldEvent:FindFirstChild("mode")

                if modeLbl and modeLbl:IsA("TextLabel") then
                    local text = string.lower(modeLbl.Text)
                    if string.find(text, "graveyard") then
                        if tick() - lastJoinTime > 60 then
                            lastJoinTime = tick()
                            eventsJoinedCount = eventsJoinedCount + 1
                            UpdateStats()
                        end
                    end
                end

                -- 2. AUTO SUMMON STAND NEU CHUA CO
                local effects = workspace:FindFirstChild("Effects")
                if effects and ccc then
                    local standModelName = "." .. LocalPlayer.Name .. "'s Stand"
                    if not effects:FindFirstChild(standModelName) then
                        local summonRemote = ccc:FindFirstChild("SummonStand")
                        if summonRemote then
                            pcall(function() summonRemote:FireServer() end)
                        end
                    end
                end

                -- 3. LOGIC CHONG TELE LOAN (Quet quai moi neu can)
                if not IsCurrentTargetValid(currentTargetNPC) then
                    currentTargetNPC = FindNewHighlightNPC()
                end

                -- 4. FIRE SKILL & M1 (Vi tri da duoc lock o Heartbeat)
                if currentTargetNPC and ccc then
                    local m1 = ccc:FindFirstChild("M1")
                    if m1 then pcall(function() m1:FireServer(true, false) end) end

                    local skillRemote = ccc:FindFirstChild("Skill")
                    if skillRemote then
                        for skillName, isEnabled in pairs(selectedSkills) do
                            if isEnabled then
                                pcall(function() skillRemote:FireServer(skillName, true) end)
                            end
                        end
                    end
                end

            end)
        end
        
        CleanUpPhysics()
    end

    Tabs.Event:AddSection("THONG KE SU KIEN")
    
    StatusPara = Tabs.Event:AddParagraph({
        Title = "Thong Ke World Event",
        Content = "So lan tham gia Event: 0"
    })

    Tabs.Event:AddSection("CAI DAT VI TRI & KHOANG CACH DO THANH")

    Tabs.Event:AddDropdown("Drop_EventPos", {
        Title = "Vi tri dung danh (Position)",
        Values = {"Behind", "Above", "Under"},
        Multi = false,
        Default = 1,
        Callback = function(Value)
            currentPosMode = Value
        end
    })

    Tabs.Event:AddSlider("Slider_EventDist", {
        Title = "Khoang cach (Distance)",
        Description = "Khoang cach tu ban den quai vat",
        Min = 1,
        Max = 20,
        Default = 5,
        Rounding = 1,
        Callback = function(Value)
            currentDistance = Value
        end
    })

    Tabs.Event:AddSection("CAI DAT SKILL & STAND")

    Tabs.Event:AddDropdown("Drop_EventSkills", {
        Title = "Chon Skill su dung (Multi-select)",
        Description = "Tu dong Spam cac skill nay kem M1",
        Values = {"E", "R", "S", "X", "C", "V"},
        Multi = true,
        Default = {},
        Callback = function(Value)
            selectedSkills = Value
        end
    })

    Tabs.Event:AddSection("KHOI DONG HE THONG")

    Tabs.Event:AddToggle("Toggle_AutoGraveyard", {
        Title = "Kich Hoat Auto World Event",
        Description = "Tele vao phong cho, farm chết từng con quai Highlight Do",
        Default = false,
        Callback = function(Value)
            AutoEventActive = Value
            if Value then
                currentTargetNPC = nil
                task.spawn(ProcessAutoEvent)
            else
                CleanUpPhysics()
            end
        end
    })
end
