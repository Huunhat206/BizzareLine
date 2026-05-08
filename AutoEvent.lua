return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local AutoEventActive = false
    
    -- Variables cho Auto Farm Event
    local currentPosMode = "Behind"
    local currentDistance = 5
    local selectedSkills = {}
    local eventsJoinedCount = 0
    local lastJoinTime = 0

    -- Bien luu muc tieu hien tai de chong tele loan
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

    -- Ham kiem tra mau chinh xac tranh sai so thap phan
    local function IsTargetColor(color3)
        local r = math.floor(color3.R * 255 + 0.5)
        local g = math.floor(color3.G * 255 + 0.5)
        local b = math.floor(color3.B * 255 + 0.5)
        return (r == 255 and g == 0 and b == 25)
    end

    -- Ham tim quai moi
    local function FindNewHighlightNPC()
        local liveFolder = workspace:FindFirstChild("Live")
        if not liveFolder then return nil end

        for _, obj in ipairs(liveFolder:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local hum = obj:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local highlight = obj:FindFirstChildWhichIsA("Highlight", true)
                    if highlight and highlight.Enabled then
                        local matchOutline = IsTargetColor(highlight.OutlineColor)
                        local matchFill = IsTargetColor(highlight.FillColor)
                        if matchOutline or matchFill then
                            return obj
                        end
                    end
                end
            end
        end
        return nil
    end

    -- Ham kiem tra currentTargetNPC con song va valid khong
    local function IsCurrentTargetValid(npcModel)
        if not npcModel or not npcModel.Parent or not npcModel:FindFirstChild("HumanoidRootPart") then return false end
        local hum = npcModel:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        
        local highlight = npcModel:FindFirstChildWhichIsA("Highlight", true)
        if highlight and highlight.Enabled then
            local matchOutline = IsTargetColor(highlight.OutlineColor)
            local matchFill = IsTargetColor(highlight.FillColor)
            if matchOutline or matchFill then
                return true
            end
        end
        return false
    end

    -- Tat cac vong lap vat ly
    local function CleanUpPhysics()
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if lockConn then lockConn:Disconnect() lockConn = nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.AutoRotate = true end
        end
    end

    -- Bat cac vong lap vat ly khung hinh cao (Sieu muot, chong giat)
    local function StartPhysicsLocks()
        CleanUpPhysics()

        -- 1. Noclip: Xuyen thau hitbox cua quai de khong bi day ra
        noclipConn = RunService.Stepped:Connect(function()
            if AutoEventActive and currentTargetNPC then
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then
                            p.CanCollide = false
                        end
                    end
                end
            end
        end)

        -- 2. CFrame Lock: Khoa cung vi tri va huong nhin vao quai o moi frame
        lockConn = RunService.Heartbeat:Connect(function()
            if AutoEventActive and currentTargetNPC then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local hum = char:FindFirstChild("Humanoid")
                    local targetRoot = currentTargetNPC:FindFirstChild("HumanoidRootPart")

                    if targetRoot and hum then
                        -- Vo hieu hoa AutoRotate de nhan vat bi lock theo dung y muon
                        hum.AutoRotate = false

                        local finalPosition
                        local targetPos = targetRoot.Position

                        if currentPosMode == "Behind" then
                            finalPosition = targetPos - (targetRoot.CFrame.LookVector * currentDistance)
                        elseif currentPosMode == "Above" then
                            finalPosition = targetPos + Vector3.new(0.01, currentDistance, 0.01)
                        elseif currentPosMode == "Under" then
                            finalPosition = targetPos + Vector3.new(0.01, -currentDistance, 0.01)
                        end

                        -- Lock truc tiep vao quai (lookAt tao ra goc xoay chia thang mat vao Target)
                        root.CFrame = CFrame.lookAt(finalPosition, targetPos)
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
            task.wait(0.1) 
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart
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
                            root.CFrame = targetWaitingCFrame
                            root.Velocity = Vector3.zero
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
                            task.wait(0.5)
                        end
                    end
                end

                -- 3. LOGIC CHONG TELE LOAN
                if not IsCurrentTargetValid(currentTargetNPC) then
                    currentTargetNPC = FindNewHighlightNPC()
                    if not currentTargetNPC then
                        -- Tra lai quyen xoay nguoi neu khong co quai
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then hum.AutoRotate = true end
                    end
                end

                -- 4. LOGIC DANH KHI DA BI LOCK (Vi tri da duoc Heartbeat lo)
                if currentTargetNPC then
                    if ccc then
                        local m1 = ccc:FindFirstChild("M1")
                        if m1 then
                            pcall(function() m1:FireServer(true, false) end)
                        end

                        local skillRemote = ccc:FindFirstChild("Skill")
                        if skillRemote then
                            for skillName, isEnabled in pairs(selectedSkills) do
                                if isEnabled then
                                    pcall(function() skillRemote:FireServer(skillName, true) end)
                                end
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
