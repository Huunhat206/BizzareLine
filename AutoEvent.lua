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

    local targetWaitingCFrame = CFrame.new(1193.24, 875.01 + 3, -668.33)

    local StatusPara

    local function UpdateStats()
        if StatusPara then
            StatusPara:SetDesc(string.format("So lan tham gia Event: %d", eventsJoinedCount))
        end
    end

    local function GetHighlightNPC()
        local liveFolder = workspace:FindFirstChild("Live")
        if not liveFolder then return nil end

        for _, obj in ipairs(liveFolder:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local hum = obj:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    -- Quet tim object Highlight nam bat ky dau ben trong NPC
                    if obj:FindFirstChildWhichIsA("Highlight", true) then
                        return obj
                    end
                end
            end
        end
        return nil
    end

    local function ProcessAutoEvent()
        while AutoEventActive do
            task.wait(0.1) -- Toc do quet nhanh de combat muot ma
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart

                -- 1. KIEM TRA THONG BAO WORLD EVENT
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                local mainHud = pGui and pGui:FindFirstChild("MainHud")
                local worldEvent = mainHud and mainHud:FindFirstChild("worldevent")
                local modeLbl = worldEvent and worldEvent:FindFirstChild("mode")

                if modeLbl and modeLbl:IsA("TextLabel") then
                    local text = string.lower(modeLbl.Text)
                    if string.find(text, "graveyard") then
                        -- Chi tele 1 lan moi 60 giay de tranh viec bi giat nguoc lai phong cho lien tuc
                        if tick() - lastJoinTime > 60 then
                            lastJoinTime = tick()
                            eventsJoinedCount = eventsJoinedCount + 1
                            UpdateStats()
                            root.CFrame = targetWaitingCFrame
                            root.Velocity = Vector3.zero
                        end
                    end
                end

                -- 2. LOGIC AUTO KILL QUAI CO HIGHLIGHT
                local targetNPC = GetHighlightNPC()
                if targetNPC then
                    local targetRoot = targetNPC:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        -- Tinh toan vi tri dua tren Dropdown va Slider
                        local tCF = targetRoot.CFrame
                        if currentPosMode == "Behind" then
                            root.CFrame = tCF * CFrame.new(0, 0, currentDistance)
                        elseif currentPosMode == "Above" then
                            root.CFrame = tCF * CFrame.new(0, currentDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        elseif currentPosMode == "Under" then
                            root.CFrame = tCF * CFrame.new(0, -currentDistance, 0) * CFrame.Angles(math.rad(90), 0, 0)
                        else
                            root.CFrame = tCF * CFrame.new(0, 0, currentDistance)
                        end

                        root.Velocity = Vector3.zero

                        -- Thuc hien M1
                        local ccc = char:FindFirstChild("client_character_controller")
                        if ccc then
                            local m1 = ccc:FindFirstChild("M1")
                            if m1 then
                                pcall(function() m1:FireServer(true, false) end)
                            end

                            -- Thuc hien Skill (chi danh cac skill duoc chon)
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
        Description = "Tu tele vao Graveyard, tu tim & danh quai co Highlight",
        Default = false,
        Callback = function(Value)
            AutoEventActive = Value
            if Value then
                task.spawn(ProcessAutoEvent)
            end
        end
    })
end
