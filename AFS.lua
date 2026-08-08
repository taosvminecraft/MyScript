--[[
    Anime Fighters Simulator - Auto Farm Script
    Executor: Delta / Hỗ trợ các executor phổ biến
    ⚠️ Sử dụng có rủi ro bị ban tài khoản
]]

-- ===== CÀI ĐẶT (SETTINGS) =====
local Settings = {
    AutoFarm = true,           -- Tự động đánh mob
    AutoQuest = true,          -- Tự động nhận nhiệm vụ
    FastAttack = true,         -- Tăng tốc độ đánh
    SpinSpeed = 5,             -- Tốc độ quay (mặc định 1, tăng lên 5)
    AutoCollect = true,        -- Tự động nhặt đồ
    TeleportToMob = true,      -- Dịch chuyển đến mob
    AttackRange = 50,          -- Phạm vi tấn công
    AttackDelay = 0.05,        -- Độ trễ giữa các đòn (giây)
}

-- ===== BIẾN HỆ THỐNG =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local IsRunning = true

-- Cập nhật character khi respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
end)

-- ===== HÀM TIỆN ÍCH =====

-- Tìm mob gần nhất
local function GetNearestMob()
    local nearestMob = nil
    local nearestDist = math.huge

    local mobFolder = workspace:FindFirstChild("Mobs")
        or workspace:FindFirstChild("Enemies")
        or workspace:FindFirstChild("NPCs")

    if not mobFolder then return nil end

    for _, mob in pairs(mobFolder:GetChildren()) do
        if mob:FindFirstChild("HumanoidRootPart")
            and mob:FindFirstChild("Humanoid")
            and mob.Humanoid.Health > 0 then

            local dist = (HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
            if dist < nearestDist and dist <= Settings.AttackRange then
                nearestMob = mob
                nearestDist = dist
            end
        end
    end
    return nearestMob
end

-- Teleport đến vị trí
local function TeleportTo(position)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- ===== TĂNG TỐC ĐỘ QUAY (SPIN SPEED) =====
local function BoostSpinSpeed()
    print("[AFS] Đang tăng tốc độ quay x" .. Settings.SpinSpeed)

    -- Tìm và tăng tốc spin
    pcall(function()
        -- Cách 1: Thông qua RemoteEvent
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            or ReplicatedStorage:FindFirstChild("Events")

        if remotes then
            local spinRemote = remotes:FindFirstChild("Spin")
                or remotes:FindFirstChild("OpenYen")
                or remotes:FindFirstChild("SpinCharacter")

            if spinRemote then
                for i = 1, Settings.SpinSpeed do
                    spinRemote:FireServer()
                    task.wait(0.1)
                end
            end
        end

        -- Cách 2: Tăng tốc animation quay
        if Humanoid then
            for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
                if track.Name:lower():find("spin") then
                    track:AdjustSpeed(Settings.SpinSpeed)
                end
            end
        end
    end)
end

-- ===== TỰ ĐỘNG NHẬN NHIỆM VỤ (AUTO QUEST) =====
local function AutoQuest()
    if not Settings.AutoQuest then return end

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            or ReplicatedStorage:FindFirstChild("Events")

        if remotes then
            -- Nhận quest
            local questRemote = remotes:FindFirstChild("AcceptQuest")
                or remotes:FindFirstChild("StartQuest")
                or remotes:FindFirstChild("Quest")

            if questRemote then
                print("[AFS] Đang nhận nhiệm vụ...")
                questRemote:FireServer()
            end

            -- Hoàn thành quest
            local completeRemote = remotes:FindFirstChild("CompleteQuest")
                or remotes:FindFirstChild("ClaimQuest")
                or remotes:FindFirstChild("FinishQuest")

            if completeRemote then
                completeRemote:FireServer()
                print("[AFS] Đã hoàn thành nhiệm vụ!")
            end
        end
    end)
end

-- ===== TỰ ĐỘNG TẤN CÔNG (AUTO ATTACK) =====
local function AutoAttack()
    if not Settings.AutoFarm then return end

    pcall(function()
        local mob = GetNearestMob()
        if mob and mob:FindFirstChild("HumanoidRootPart") then

            -- Teleport đến mob
            if Settings.TeleportToMob then
                local mobPos = mob.HumanoidRootPart.Position
                TeleportTo(mobPos + Vector3.new(0, 3, 0))
            end

            -- Tấn công
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                or ReplicatedStorage:FindFirstChild("Events")

            if remotes then
                local attackRemote = remotes:FindFirstChild("Attack")
                    or remotes:FindFirstChild("DealDamage")
                    or remotes:FindFirstChild("Combat")

                if attackRemote then
                    attackRemote:FireServer(mob)
                end
            end

            -- Click để đánh (mô phỏng)
            if Settings.FastAttack then
                local VirtualInputManager = game:GetService("VirtualInputManager")
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end)
            end
        end
    end)
end

-- ===== TỰ ĐỘNG NHẶT ĐỒ (AUTO COLLECT) =====
local function AutoCollect()
    if not Settings.AutoCollect then return end

    pcall(function()
        local drops = workspace:FindFirstChild("Drops")
            or workspace:FindFirstChild("Items")
            or workspace:FindFirstChild("Collectibles")

        if drops then
            for _, item in pairs(drops:GetChildren()) do
                if item:IsA("BasePart") or item:FindFirstChild("HumanoidRootPart") then
                    local itemPos = item:IsA("BasePart") and item.Position
                        or item.HumanoidRootPart.Position
                    TeleportTo(itemPos)
                    task.wait(0.05)
                end
            end
        end
    end)
end

-- ===== VÒNG LẶP CHÍNH =====
print("========================================")
print("  Anime Fighters Simulator - Auto Farm")
print("  Executor: Delta")
print("  Trạng thái: ĐANG CHẠY")
print("========================================")

-- Tăng tốc quay ban đầu
if Settings.FastAttack then
    BoostSpinSpeed()
end

-- Nhận quest ban đầu
AutoQuest()

-- Loop chính
local questTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not IsRunning then return end

    pcall(function()
        -- Kiểm tra character còn sống
        if not Character or not Character.Parent then return end
        if not Humanoid or Humanoid.Health <= 0 then return end

        -- Auto Attack
        AutoAttack()

        -- Auto Quest (mỗi 30 giây kiểm tra lại)
        questTimer = questTimer + dt
        if questTimer >= 30 then
            questTimer = 0
            AutoQuest()
        end

        -- Auto Collect (sau mỗi lần đánh)
        if Settings.AutoCollect then
            AutoCollect()
        end
    end)

    task.wait(Settings.AttackDelay)
end)

-- ===== DỪNG SCRIPT =====
-- Gõ lệnh dưới đây vào console để dừng:
-- IsRunning = false
print("[AFS] Script đã được kích hoạt thành công!")
print("[AFS] Để dừng script, đặt IsRunning = false")
