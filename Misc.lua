return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local TitleLoopActive = false
    local TitleLoopSpeed = 1.0 

    local function ProcessTitleLoop()
        local currentIndex = 1
        
        while TitleLoopActive do
            pcall(function()
                local pData = LocalPlayer:FindFirstChild("PlayerData")
                if not pData then return end
                
                local titlesObj = pData:FindFirstChild("Titles")
                if titlesObj and titlesObj.Value then
                    local success, decodedTitles = pcall(HttpService.JSONDecode, HttpService, tostring(titlesObj.Value))
                    
                    if success and type(decodedTitles) == "table" and #decodedTitles > 0 then
                        if currentIndex > #decodedTitles then
                            currentIndex = 1
                        end
                        
                        local currentTitle = decodedTitles[currentIndex]
                        
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
            
            -- Đảm bảo task.wait không bao giờ nhỏ hơn 0.05 để tránh crash game
            task.wait(math.max(TitleLoopSpeed, 0.05))
        end
    end

    Tabs.Misc:AddSection("TU DONG DOI DANH HIEU (TITLE LOOP)")

    Tabs.Misc:AddToggle("Toggle_TitleLoop", {
        Title = "Kich hoat Title Loop",
        Description = "Tu dong xoay vong cac danh hieu ban dang so huu",
        Default = false,
        Callback = function(Value)
            TitleLoopActive = Value
            if Value then
                task.spawn(ProcessTitleLoop)
            end
        end
    })

    -- FIX: Thay đổi Rounding để nhận diện số thập phân 0.1
    Tabs.Misc:AddSlider("Slider_TitleSpeed", {
        Title = "Toc do doi (Giay)",
        Description = "Keo thap de doi nhanh, cao de doi cham",
        Min = 0.1,
        Max = 5.0,
        Default = 1.0,
        Rounding = 1, -- Fluent se hien thi 1 chu so thap phan (0.1)
        Callback = function(Value)
            TitleLoopSpeed = Value
        end
    })
end
