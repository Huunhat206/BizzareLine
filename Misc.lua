return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local TitleLoopActive = false
    local TitleLoopSpeed = 0.1 -- Toc do mac dinh la 1.5 giay

    local function ProcessTitleLoop()
        local currentIndex = 1
        
        while TitleLoopActive do
            pcall(function()
                local pData = LocalPlayer:FindFirstChild("PlayerData")
                if not pData then return end
                
                local titlesObj = pData:FindFirstChild("Titles")
                -- Kiem tra xem titlesObj co thuoc tinh Value khong
                if titlesObj and titlesObj.Value then
                    -- Giai ma chuoi JSON thanh mang (table)
                    local success, decodedTitles = pcall(HttpService.JSONDecode, HttpService, tostring(titlesObj.Value))
                    
                    if success and type(decodedTitles) == "table" and #decodedTitles > 0 then
                        -- Chong vuot qua so luong neu danh sach title bi thay doi
                        if currentIndex > #decodedTitles then
                            currentIndex = 1
                        end
                        
                        local currentTitle = decodedTitles[currentIndex]
                        
                        -- Gui lenh Equip Title len Server
                        local requests = ReplicatedStorage:FindFirstChild("requests")
                        if requests and requests:FindFirstChild("character") then
                            local showTitles = requests.character:FindFirstChild("ShowTitles")
                            if showTitles then
                                showTitles:FireServer(currentTitle)
                            end
                        end
                        
                        -- Tang index len 1 cho lan lap tiep theo
                        currentIndex = currentIndex + 1
                    end
                end
            end)
            
            -- Nghi 1 khoang thoi gian de tranh lag va chong Remote Spam
            task.wait(TitleLoopSpeed)
        end
    end

    Tabs.Misc:AddSection("TU DONG DOI DANH HIEU (TITLE LOOP)")

    Tabs.Misc:AddToggle("Toggle_TitleLoop", {
        Title = "Kich hoat Title Loop",
        Description = "Tu dong xoay vong cac danh hieu ban dang so huu tren dau",
        Default = false,
        Callback = function(Value)
            TitleLoopActive = Value
            if Value then
                task.spawn(ProcessTitleLoop)
            end
        end
    })

    Tabs.Misc:AddSlider("Slider_TitleSpeed", {
        Title = "Toc do doi danh hieu (Giay)",
        Description = "Khoang thoi gian cho giua 2 lan doi (Khuyen nghi: 1- 2s)",
        Min = 0.1,
        Max = 5.0,
        Default = 1.5,
        Rounding = 1,
        Callback = function(Value)
            TitleLoopSpeed = Value
        end
    })
end
