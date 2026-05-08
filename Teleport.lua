return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Danh sach ten de hien thi tren Dropdown theo thu tu
    local locationsOrder = {
        "World Event",
        "Bus Stop 1", "Bus Stop 2", "Bus Stop 3", "Bus Stop 4", "Bus Stop 5",
        "Bus Stop 6", "Bus Stop 7", "Bus Stop 8", "Bus Stop 9", "Bus Stop 10",
        "Bus Stop 11", "Bus Stop 12", "Bus Stop 13", "Bus Stop 14", "Bus Stop 15",
        "Bus Stop 16", "Bus Stop 17", "Bus Stop 18", "Bus Stop 19"
    }

    -- Toa do tuong ung voi ten
    local locationCoords = {
        ["World Event"] = Vector3.new(1195.57, 875.01, -658.51),
        ["Bus Stop 1"]  = Vector3.new(1291.87, 875.60, -534.47),
        ["Bus Stop 2"]  = Vector3.new(1217.05, 875.06, -58.02),
        ["Bus Stop 3"]  = Vector3.new(622.32, 887.04, -439.36),
        ["Bus Stop 4"]  = Vector3.new(2218.49, 874.66, -392.95),
        ["Bus Stop 5"]  = Vector3.new(1673.93, 875.81, -214.94),
        ["Bus Stop 6"]  = Vector3.new(2597.35, 874.66, -119.17),
        ["Bus Stop 7"]  = Vector3.new(1266.47, 875.29, -1117.15),
        ["Bus Stop 8"]  = Vector3.new(676.72, 889.99, 144.42),
        ["Bus Stop 9"]  = Vector3.new(2504.05, 874.66, 97.67),
        ["Bus Stop 10"] = Vector3.new(137.92, 892.69, -318.83),
        ["Bus Stop 11"] = Vector3.new(160.29, 892.82, 13.62),
        ["Bus Stop 12"] = Vector3.new(-189.42, 892.86, 43.02),
        ["Bus Stop 13"] = Vector3.new(1642.79, 875.60, 77.07),
        ["Bus Stop 14"] = Vector3.new(655.29, 908.98, 1183.25),
        ["Bus Stop 15"] = Vector3.new(1902.94, 874.51, 170.12),
        ["Bus Stop 16"] = Vector3.new(-1456.29, 910.20, 542.82),
        ["Bus Stop 17"] = Vector3.new(1169.50, 909.80, 1246.85),
        ["Bus Stop 18"] = Vector3.new(1918.50, 933.15, 1439.88),
        ["Bus Stop 19"] = Vector3.new(1323.12, 875.35, 304.28)
    }

    Tabs.Teleport:AddSection("DI CHUYEN NHANH KHOANG CACH XA")

    local selectedLoc = "World Event" -- Gia tri mac dinh ban dau

    Tabs.Teleport:AddDropdown("Drop_Teleport", {
        Title = "Chon Dia Diem",
        Values = locationsOrder,
        Multi = false,
        Default = 1,
        Callback = function(Value)
            selectedLoc = Value
        end
    })

    Tabs.Teleport:AddButton({
        Title = "Dich Chuyen (Teleport)",
        Description = "Nhan de tele toi toa do da chon o tren",
        Callback = function()
            if selectedLoc and locationCoords[selectedLoc] then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    -- Cong them 3 vao truc Y de nhan vat khong bi lot xuong dat
                    local targetPos = locationCoords[selectedLoc] + Vector3.new(0, 3, 0)
                    
                    -- Su dung CFrame de dich chuyen tuc thi
                    char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                    
                    Fluent:Notify({
                        Title = "Thanh Cong",
                        Content = "Da dich chuyen den: " .. selectedLoc,
                        Duration = 3
                    })
                else
                    Fluent:Notify({
                        Title = "Loi",
                        Content = "Khong tim thay nhan vat!",
                        Duration = 3
                    })
                end
            else
                Fluent:Notify({
                    Title = "Loi",
                    Content = "Vui long chon dia diem hop le!",
                    Duration = 3
                })
            end
        end
    })
end
