return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

    -- Ham tim quai moi (Chi goi khi currentTargetNPC chet/invalid)
    local function FindNewHighlightNPC()
        local liveFolder = workspace:FindFirstChild("Live")
        if not liveFolder then return nil end

        for _, obj in ipairs(liveFolder:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local hum = obj:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    -- Quet tim object Highlight nam bat ky dau ben trong NPC
                    local highlight = obj:FindFirstChildWhichIsA("Highlight", true)
                    
                    if highlight and highlight.Enabled then
                        -- Kiem tra xem mau co phai la [255, 0, 25] khong
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
        
        -- Kiem tra lai Highlight de safe
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

    local function ProcessAutoEvent()
        while AutoEventActive do
            task.wait(0.1) -- Toc do quet nhanh de combat muot ma
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart

                -- 1. KIEM TRA THONG BAO WORLD EVENT (Chi tele khi bat Toggle)
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                local mainHud = pGui and pGui:FindFirstChild("MainHud")
                local worldEvent = mainHud and mainHud:FindFirstChild("worldevent")
                local modeLbl = worldEvent and worldEvent:FindFirstChild("mode")

                if modeLbl and modeLbl:IsA("TextLabel") then
                    local text = string.lower(modeLbl.Text)
                    if string.find(text, "graveyard") then
                        -- Chi tele 1 lan moi 60 giay
                        if tick() - lastJoinTime > 60 then
                            lastJoinTime = tick()
                            eventsJoinedCount = eventsJoinedCount + 1
                            UpdateStats()
                            root.CFrame = targetWaitingCFrame
                            root.Velocity = Vector3.zero
                        end
                    end
                end

                -- 2. LOGIC CHONG TELE LOAN: Kiem tra muc tieu hien tai truoc
                if not IsCurrentTargetValid(currentTargetNPC) then
                    -- Neu muc tieu cu da chet/invalid, tim con moi
                    currentTargetNPC = FindNewHighlightNPC()
                end

                -- 3. LOGIC AUTO KILL (Chi hoat dong neu co muc tieu valid)
                if currentTargetNPC then
                    local targetRoot = currentTargetNPC:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        -- HE THONG DINH VI THONG NHAT (Unified Positioning)
                        local finalPosition
                        local targetPos = targetRoot.Position

                        if currentPosMode == "Behind" then
                            -- Dung sau lung, chĩa vao quai
                            finalPosition = targetPos - (targetRoot.CFrame.LookVector * currentDistance)
                        elseif currentPosMode == "Above" then
                            -- Dung tren dau
                            finalPosition = targetPos + Vector3.new(0, currentDistance, 0)
                        elseif currentPosMode == "Under" then
                            -- Dung duoi chan
                            finalPosition = targetPos + Vector3.new(0, -currentDistance, 0)
                        end

                        -- XU LY GIMBAL LOCK KHI DUNG VERTICAL (Above/Under)
                        -- Dung referenceUp tu con quai de luon chia vao tam
                        if currentPosMode == "Above" or currentPosMode == "Under" then
                            -- Hướng nhìn
                            local lookDirection = targetPos - finalPosition
                            -- Trục xoay tham chiếu từ con quái (LookVector) để định vị
                            local referenceUp = targetRoot.CFrame.LookVector 
                            root.CFrame = CFrame.lookAt(finalPosition, targetPos, referenceUp)
                        else
                            -- Dung Behind chuan lam viec tot ma khong can referenceUp dac biet
                            root.CFrame = CFrame.lookAt(finalPosition, targetPos)
                        end

                        root.Velocity = Vector3.zero

                        -- Thuc hien M1
                        local ccc = char:FindFirstChild("client_character_controller")
                        if ccc then
                            local m1 = ccc:FindFirstChild("M1")
                            if m1 then
                                pcall(function() m1:FireServer(true, false) end)
                            end

                            -- Thuc hien Skill
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
                end

            end)
        end
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

    Tabs.Event:AddSection("CAI DAT SKILL")

    Tabs.Event:AddDropdown("Drop_EventSkills", {
        Title = "Chon Skill su dung (Multi-select)",
        Description = "Tu dong Spam cac skill nay kem M1",
        Values = {"E", "R", "Z", "X", "C", "V"},
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
                -- Reset muc tieu khi bat Toggle
                currentTargetNPC = nil
                task.spawn(ProcessAutoEvent)
            end
        end
    })
end
