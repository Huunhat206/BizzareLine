return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local AutoEventActive = false
    -- Toa do Graveyard (Cong them 3 Y de khong lot dat)
    local targetCFrame = CFrame.new(1193.24, 875.01 + 3, -668.33)

    local function ProcessAutoEvent()
        while AutoEventActive do
            task.wait(1)
            pcall(function()
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if not pGui then return end
                
                local mainHud = pGui:FindFirstChild("MainHud")
                if not mainHud then return end
                
                local worldEvent = mainHud:FindFirstChild("worldevent")
                if not worldEvent then return end
                
                local modeLbl = worldEvent:FindFirstChild("mode")
                if modeLbl and modeLbl:IsA("TextLabel") then
                    local text = string.lower(modeLbl.Text)
                    
                    -- Kiem tra neu Text co chu "graveyard"
                    if string.find(text, "graveyard") then
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local root = char.HumanoidRootPart
                            
                            -- Kiem tra khoang cach, neu chech ra xa qua thi tele ve lai cho cu
                            if (root.Position - targetCFrame.Position).Magnitude > 15 then
                                root.CFrame = targetCFrame
                                root.Velocity = Vector3.zero
                            end
                        end
                    end
                end
            end)
        end
    end

    Tabs.Event:AddSection("TU DONG THAM GIA WORLD EVENT")

    Tabs.Event:AddToggle("Toggle_AutoGraveyard", {
        Title = "Auto Teleport Graveyard Event",
        Description = "Tu dong tele va giu nhan vat dung yen khi co Event Graveyard",
        Default = false,
        Callback = function(Value)
            AutoEventActive = Value
            if Value then
                task.spawn(ProcessAutoEvent)
            end
        end
    })
    
    Tabs.Event:AddParagraph({
        Title = "Thong Tin He Thong",
        Content = "He thong se bo qua che do Deathmatch. Chi hoat dong voi che do Graveyard."
    })
end
