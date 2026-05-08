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
    local lastSummonTime = 0 -- Bien chong spam goi Stand

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

    -- Tim quai gan nhat co highlight do trong pham vi 200 stud
    local function FindNewHighlightNPC()
        local liveFolder = workspace:FindFirstChild("Live")
        if not liveFolder then return nil end

        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return nil end

        local playerPos = rootPart.Position
        local closestNPC = nil
        local shortestDist = 200 -- Gioi han quet 200 stud

        for _, obj in ipairs(liveFolder:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local hum = obj:FindFirstChild("Humanoid")
                local targetRoot = obj:FindFirstChild("HumanoidRootPart")

                if hum and hum.Health > 0 and targetRoot then
                    local dist = (playerPos - targetRoot.Position).Magnitude
                    
                    if dist <= shortestDist then
                        local highlight = obj:FindFirstChildOfClass("Highlight") or obj:FindFirstChildWhichIsA("Highlight", true)
                        
                        if highlight and highlight.Enabled then
                            if IsTargetColor(highlight.OutlineColor) or IsTargetColor(highlight.FillColor) then
                                closestNPC = obj
                                shortestDist = dist
                            end
                        end
                    end
                end
            end
        end
        return closestNPC
    end

    -- Kiem tra muc tieu hien tai con song, con highlight va nam trong 200 stud khong
    local function IsCurrentTargetValid(npcModel)
        if not npcModel or not npcModel.Parent or not npcModel:FindFirstChild("HumanoidRootPart") then return false end
        local hum = npcModel:FindFirstChild("Humanoid")
        local targetRoot = npcModel:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not targetRoot then return false end
        
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Neu bi vang ra xa khoi 200 stud thi huy muc tieu
            if (rootPart.Position - targetRoot.Position).Magnitude > 200 then
                return false
            end
        end

        local highlight = npcModel:FindFirstChildOfClass("Highlight") or npcModel:FindFirstChildWhichIsA("Highlight", true)
        if highlight and highlight.Enabled then
            if IsTargetColor(highlight.OutlineColor) or IsTargetColor(highlight.FillColor) then
                return true
            end
        end
        return false
    end

    local function CleanUpPhysics()
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if lockConn then lockConn:Disconnect() lockConn = nil end
        
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.AutoRotate = true end
        end
    end

    local function StartPhysicsLocks()
        CleanUpPhysics()

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
            task.wait(0.2) 
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

                -- 2. AUTO SUMMON STAND (Chong spam bang cooldown & tim kiem thong minh)
                local effects = workspace:FindFirstChild("Effects")
                if effects and ccc then
                    local hasStand = false
                    local pName = LocalPlayer.Name
                    local dName = LocalPlayer.DisplayName
                    
                    -- Quet toan bo thu muc Effects de tim Stand
                    for _, effect in ipairs(effects:GetChildren()) do
                        if (string.find(effect.Name, pName) or string.find(effect.Name, dName)) and string.find(effect.Name, "Stand") then
                            hasStand = true
                            break
                        end
                    end

                    if not hasStand then
                        -- Cooldown 5 giay de game kip load Stand ra, tranh goi chong cheo
                        if tick() - lastSummonTime > 5 then
                            lastSummonTime = tick()
                            local summonRemote = ccc:FindFirstChild("SummonStand")
                            if summonRemote then
                                pcall(function() summonRemote:FireServer() end)
                            end
                        end
                    end
                end

                -- 3. LOGIC CHONG TELE LOAN
                if not IsCurrentTargetValid(currentTargetNPC) then
                    currentTargetNPC = FindNewHighlightNPC()
                end

                -- 4. FIRE SKILL & M1
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
        Description = "Tele vao phong cho, farm quai Highlight Do (Quet < 200 stud)",
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
