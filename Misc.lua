return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local TitleLoopActive = false
    local TitleLoopSpeed = 1.0 -- Mac dinh 1 giay

    local function ProcessTitleLoop()
        local currentIndex = 1
        
        while TitleLoopActive do
            pcall(function()
                local pData = LocalPlayer:FindFirstChild("PlayerData")
                if not pData then return end
                
                local titlesObj = pData:FindFirstChild("Titles")
                if titlesObj and titlesObj.Value then
                    -- Giai ma chuoi JSON thanh mang titles
                    local success, decodedTitles = pcall(HttpService.JSONDecode, HttpService, tostring(titlesObj.Value))
                    
                    if success and type(decodedTitles) == "table" and #decodedTitles > 0 then
                        -- Dam bao index luon nam trong pham vi mang
                        if currentIndex > #decodedTitles then
                            currentIndex = 1
                        end
                        
                        local currentTitle = decodedTitles[currentIndex]
                        
                        -- Gui lenh doi Title
                        local requests = ReplicatedStorage:FindFirstChild("requests")
                        if requests and requests:FindFirstChild("character") then
                            local showTitles = requests.character:FindFirstChild("ShowTitles")
                            if showTitles then
                                showTitles:FireServer(currentTitle)
                            end
                        end
                        
                        currentIndex = currentIndex + 1
                    end
                end
            end)
            
            -- Su dung toc do tu Slider (co the xuong toi 0.1s)
            task.wait(TitleLoopSpeed)
        end
    end

    Tabs.Misc:AddSection("TU DONG DOI DANH HIEU (TITLE LOOP)")

    Tabs.Misc:AddToggle("Toggle_TitleLoop", {
        Title = "Kich hoat Title Loop",
        Description = "Tu dong xoay vong cac danh hieu ban dang so hữu",
        Default = false,
        Callback = function(Value)
            TitleLoopActive = Value
            if Value then
                task.spawn(ProcessTitleLoop)
            end
        end
    })

    Tabs.Misc:AddSlider("Slider_TitleSpeed", {
        Title = "Toc do doi (Giay)",
        Description = "Chinh tu 0.1s (nhanh) den 5s (cham)",
        Min = 0.1,
        Max = 5.0,
        Default = 1.0,
        Rounding = 1, -- Cho phep chinh so thap phan (0.1, 0.2...)
        Callback = function(Value)
            TitleLoopSpeed = Value
        end
    })
end
