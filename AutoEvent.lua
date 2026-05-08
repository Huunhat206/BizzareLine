return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local AutoEventActive = false
    
    -- Toa do Graveyard goc (Cong them 3 Y de khong lot dat)
    local targetCFrame = CFrame.new(1193.24, 875.01 + 3, -668.33)

    local function ProcessAutoEvent()
        while AutoEventActive do
            task.wait(0.5) -- Tang toc do quet de chong bi day lech
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
                    
                    if string.find(text, "graveyard") then
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChild("Humanoid")
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        
                        -- Kiem tra trang thai chet hoac chua spawn
                        if not char or not root or not hum or hum.Health <= 0 then
                            -- Tu dong Spawn lai
                            pcall(function() ReplicatedStorage.requests.character.spawn:FireServer() end)
                            task.wait(3) 
                            return 
                        end
                        
                        -- Kiem tra neu lech qua 2 stud thi tele ve lai cho cu ngay lap tuc
                        if (root.Position - targetCFrame.Position).Magnitude > 2 then
                            root.CFrame = targetCFrame
                            root.Velocity = Vector3.zero
                        end
                    end
                end
            end)
        end
    end

    Tabs.Event:AddSection("TU DONG THAM GIA WORLD EVENT")

    Tabs.Event:AddToggle("Toggle_AutoGraveyard", {
        Title = "Auto Teleport Graveyard Event",
        Description = "Tu dong giu nhan vat co dinh (Lech 2 stud la tele ve lai)",
        Default = false,
        Callback = function(Value)
            AutoEventActive = Value
            if Value then task.spawn(ProcessAutoEvent) end
        end
    })
    
    Tabs.Event:AddParagraph({
        Title = "Thong Tin He Thong",
        Content = "- He thong co kem Auto Respawn neu chang may bi chet.\n- Quet lien tuc: Neu bi day lech qua 2 stud se lap tuc giat ve vi tri goc."
    })
end
