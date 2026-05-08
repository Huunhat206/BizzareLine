return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local TitleLoopActive = false
    local TitleLoopSpeed = 1.5 

    local function ProcessTitleLoop()
        local currentIndex = 1
        
        -- TOI UU 1: Tim RemoteEvent mot lan duy nhat truoc khi vao vong lap
        local requests = ReplicatedStorage:FindFirstChild("requests")
        local showTitles = requests and requests:FindFirstChild("character") and requests.character:FindFirstChild("ShowTitles")
        
        -- TOI UU 2: Bien luu tru de chong Decode JSON lien tuc
        local lastJsonString = ""
        local cachedTitles = {}
        
        while TitleLoopActive do
            pcall(function()
                local pData = LocalPlayer:FindFirstChild("PlayerData")
                if not pData then return end
                
                local titlesObj = pData:FindFirstChild("Titles")
                if titlesObj and titlesObj.Value then
                    local currentJson = tostring(titlesObj.Value)
                    
                    -- Chi Decode lai neu chuoi du lieu bi thay doi (VD: Ban vua nhan title moi)
                    if currentJson ~= lastJsonString then
                        local success, decodedTitles = pcall(HttpService.JSONDecode, HttpService, currentJson)
                        if success and type(decodedTitles) == "table" and #decodedTitles > 0 then
                            cachedTitles = decodedTitles
                            lastJsonString = currentJson -- Luu lai de so sanh cho lan sau
                        end
                    end
                    
                    -- Su dung danh sach da Cache de chay Loop (Sieu nhe, khong lag)
                    if #cachedTitles > 0 then
                        if currentIndex > #cachedTitles then
                            currentIndex = 1
                        end
                        
                        local currentTitle = cachedTitles[currentIndex]
                        
                        -- Gui lenh len Server
                        if showTitles then
                            showTitles:FireServer(currentTitle)
                        end
                        
                        currentIndex = currentIndex + 1
                    end
                end
            end)
            
            -- Nghi 1 khoang thoi gian (dam bao khong bao gio duoi 0.05 de tranh crash)
            task.wait(math.max(TitleLoopSpeed, 0.05))
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
        Description = "Khoang thoi gian giua 2 lan doi (Khuyen nghi: 1.5s - 2s)",
        Min = 0.1,
        Max = 5.0,
        Default = 1.5,
        Rounding = 1,
        Callback = function(Value)
            TitleLoopSpeed = Value
        end
    })
end
