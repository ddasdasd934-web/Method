local AuthorityFarm = { pfBreaker = false, noFall = false }

---@module Features.Game.Tweening
local Tweening = require("Features/Game/Tweening")

---@module Utility.TaskSpawner
local TaskSpawner = require("Utility/TaskSpawner")

---@module Utility.Finder
local Finder = require("Utility/Finder")

---@module Utility.Maid
local Maid = require("Utility/Maid")

---@module Features.Game.Interactions
local Interactions = require("Features/Game/Interactions")

---@module Utility.Logger
local Logger = require("Utility/Logger")

---@module Game.InputClient
local InputClient = require("Game/InputClient")

-- Maid.
local authorityFarmMaid = Maid.new()

-- Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local plr = players.LocalPlayer

local function toCaptain(dialogue)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    hrp.CFrame = CFrame.new(hrp.Position.X, 25000, hrp.Position.Z)

    Tweening.goal("AF_TweenToCaptain", CFrame.new(-7038.2333984375, 25000, 2736.71044921875), true) 
    Tweening.wait("AF_TweenToCaptain")

    while Finder.pnear(Vector3.new(-7038.2333984375, 502.98504638671875, 2736.71044921875), 50) do
        hrp.CFrame = CFrame.new(hrp.Position.X, 25000, hrp.Position.Z)
        task.wait()
    end

    plr:RequestStreamAroundAsync(Vector3.new(-7038.2333984375, 502.98504638671875, 2736.71044921875), 0.1)
    task.wait(0.5)

    hrp.CFrame = CFrame.new(hrp.Position.X, 502.98504638671875, hrp.Position.Z)
    task.wait(0.5)

    local captain = workspace:WaitForChild("NPCs"):WaitForChild("Captain Trist")
    Interactions.interact(captain, dialogue, false)
end

local function hostage(region, name, folder)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local pos = folder:WaitForChild(region):WaitForChild(name):WaitForChild("Spawns"):WaitForChild("Hostage").Position

    Tweening.goal("AF_TweenToObjective", CFrame.new(pos.X, 25000, (pos.Z - 2)), true) 
    Tweening.wait("AF_TweenToObjective")

    plr:RequestStreamAroundAsync(pos, 0.1)
    task.wait(0.5)

    hrp.CFrame = CFrame.new(hrp.Position.X, pos.Y, hrp.Position.Z)

    repeat task.wait() until Finder.entity("hostage") and Finder.entity("hostage"):FindFirstChild("Left Leg") and math.abs(Finder.entity("hostage"):FindFirstChild("Left Leg").Orientation.X) > 45

    char.CharacterHandler.Requests.Carry:FireServer(true)
    hrp.CFrame = CFrame.new(hrp.Position.X, 50000, hrp.Position.Z)

    task.wait(2)

    char.CharacterHandler.Requests.Carry:FireServer(false)
end

local function perimeter(region, name, folder)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local pos = folder:WaitForChild(region):WaitForChild(name):WaitForChild("Center").Position

    Tweening.goal("AF_TweenToObjective", CFrame.new(pos.X, 25000, pos.Z), true) 
    Tweening.wait("AF_TweenToObjective")

    plr:RequestStreamAroundAsync(pos, 0.1)

    task.wait(1)

    hrp.CFrame = CFrame.new(hrp.Position.X, pos.Y, hrp.Position.Z)

    task.wait(1)

    repeat task.wait() until Finder.entity("bandit")

    hrp.CFrame = CFrame.new(hrp.Position.X, 50000, hrp.Position.Z)

    local txt = plr.PlayerGui:WaitForChild("SplashGui"):WaitForChild("TimeFrame"):WaitForChild("TimeText")
    repeat task.wait() until txt.Text:match("REPORT BACK")
end

local function sabotage(region, name, folder)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    AuthorityFarm.pfBreaker = true

    local pos = folder:WaitForChild(region):WaitForChild(name):WaitForChild("Center").Position

    Tweening.goal("AF_TweenToObjective", CFrame.new(pos.X, 25000, pos.Z), true)
    Tweening.wait("AF_TweenToObjective")

    plr:RequestStreamAroundAsync(pos, 0.1)
    task.wait(0.5)

    hrp.CFrame = CFrame.new(hrp.Position.X, pos.Y, hrp.Position.Z)

    char.CharacterHandler.Requests.DrawWeapon:FireServer(true)
    repeat task.wait() until Finder.destructible("KhanCrate") and Finder.destructible("KhanCrate"):GetAttribute("StructureHealth")

    task.wait(2)

    for _, crate in next, workspace:WaitForChild("Destructibles"):GetChildren() do
        if crate.Name:match("KhanCrate") and crate:GetAttribute("StructureHealth") and tonumber(crate:GetAttribute("StructureHealth")) > 0 then
            local target = crate:GetPivot().Position
            if (target - hrp.Position).Magnitude < 200 then
                Tweening.goal("AF_TweenToCrate", CFrame.new(target), false)
                while tonumber(crate:GetAttribute("StructureHealth")) > 0 do
                    InputClient.left(CFrame.new(), true)
                    task.wait(0.5)
                end
                Tweening.stop("AF_TweenToCrate")
            end
        end
    end
    task.wait(1)

    AuthorityFarm.pfBreaker = false

    char.CharacterHandler.Requests.DrawWeapon:FireServer(false)
end

local function grabMission()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    AuthorityFarm.noFall = true

    while task.wait() do
        toCaptain({{choice = "Yes, Sir."}})
        task.wait(0.5)
        replicatedStorage.Requests.SendDialogue:FireServer({["exit"] = true})

        task.wait(1)

        local tasks = replicatedStorage.Requests.GetTasks:InvokeServer()
        if not tasks then return Logger.warn("Failed to get player's missions.") end

        local mission
        for _, task in next, tasks do
            if task.data and task.task_type == "Mission" then
                mission = task
                break
            end
        end
        if not mission then return Logger.warn("Failed to get mission's data.") end

        local folder = workspace:WaitForChild("AuthorityMissionSpots")
        local name, region = mission.name, mission.data.region

        hrp.CFrame = CFrame.new(hrp.Position.X, 25000, hrp.Position.Z)

        plr:RequestStreamAroundAsync(mission.pos, 0.1)

        task.wait(0.5)

        if name == "Hostage" then
            hostage(region, name, folder)
        elseif name == "Secure Perimeter" then
            perimeter(region, name, folder)
        elseif name == "Armanent Sabotage" then
            sabotage(region, name, folder)
        end

        toCaptain({{exit = true}})
    end
end

AuthorityFarm.start = function()
    authorityFarmMaid:add(TaskSpawner.spawn("AutoAuthority", grabMission))
end

AuthorityFarm.stop = function()
	for _, data in next, Tweening.queue do
		if not data.identifier:match("AF") then
			continue
		end

		Tweening.stop(data.identifier)
	end

    AuthorityFarm.noFall = falses
    AuthorityFarm.pfBreaker = false

    authorityFarmMaid:clean()
end

return AuthorityFarm