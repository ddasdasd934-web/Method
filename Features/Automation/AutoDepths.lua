local AutoDepths = {}

---@module Utility.PersistentData
local PersistentData = require("Utility/PersistentData")

---@module Game.AntiAFK
local AntiAFK = require("Game/AntiAFK")

---@module Utility.Finder
local Finder = require("Utility/Finder")

---@module Features.Game.Tweening
local Tweening = require("Features/Game/Tweening")

---@module Utility.Configuration
local Configuration = require("Utility/Configuration")

---@module Game.ServerHop
local ServerHop = require("Game/ServerHop")

---@module Utility.TaskSpawner
local TaskSpawner = require("Utility/TaskSpawner")

---@module Utility.Maid
local Maid = require("Utility/Maid")

---@module Utility.Logger
local Logger = require("Utility/Logger")

---@module Features.Game.Movement
local Movement = require("Features/Game/Movement")

---@module Game.InputClient
local InputClient = require("Game/InputClient")

---@module Features.Exploits.Exploits
local Exploits = require("Features/Exploits/Exploits")

-- Services.
local playersService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Constants.
local DEPTHS_PLACE_ID = 5735553160
local TRIAL_PLACE_ID = 8668476218
local DEBUGGING_MODE = true

-- Maid.
local escapeDepthsMaid = Maid.new()

-- Currently running?
local running = false

---Telemetry log.
local function telemetryLog(...)
	if not DEBUGGING_MODE then
		return
	end

	Logger.warn(...)
end

-- Entities and are they low level? (This helps to know if a simple tween to back + pfBreaker is enough.)
local entities = {
	["knight"] = true,
	["angel"] = true,
	["megalodaunt"] = true,
	["enforcer"] = true,
	["bone"] = false,
	["thresher"] = false
}

-- Go to the trial.
function AutoDepths.gtrial()
	-- Request start.
	local requests = replicatedStorage:WaitForChild("Requests", 5)
	local startMenu = requests:WaitForChild("StartMenu", 5)
	local start = startMenu:WaitForChild("Start", 5)

	telemetryLog("(AutoEscape) Requesting start.")

	start:FireServer()

    local data = PersistentData.get("esdata")

    local localPlayer = playersService.LocalPlayer
	local localCharacter = localPlayer.Character
	local localRootPart = localCharacter and localCharacter:WaitForChild("HumanoidRootPart")

    telemetryLog("(AutoEscape) Checking for players nearby.")

    if Finder.pnear(localRootPart.Position, 70) then
        return ServerHop.hop(data.slot, true)
    end

    Tweening.goal("AD_TweenToAboveTrial", CFrame.new(2958.92, -1004.72, 1598.34), true)
    Tweening.wait("AD_TweenToAboveTrial")

    if Finder.pnear(Vector3.new(2987.92, -2264.34, 1583.09), 80) then
        return ServerHop.hop(data.slot, true)
    end

    localPlayer:RequestStreamAroundAsync(Vector3.new(2990.36, -2264.34, 1583.68), 0.1)
    local switch = workspace:WaitForChild("TrialElevator"):WaitForChild("Switch")

    Tweening.goal("AD_TweenToTrial", CFrame.new(2990.36, -2264.34, 1583.68), false)
    Tweening.wait("AD_TweenToTrial")

    local prompt = switch:WaitForChild("InteractPrompt")
    prompt.MaxActivationDistance = 16

    telemetryLog("(AutoEscape) Checking for players nearby and interacting with the switch.")

    while task.wait(0.1) do
        fireproximityprompt(prompt)

        if Finder.pnear(localRootPart.Position, 70) then
            return ServerHop.hop(data.slot, true)
        end
    end
end

-- Check to know if we should use pfBreaker and ATB.
local function lowLvl(entity)
    for n, v in next, entities do
        if v and entity:match(n) then
            return true
        end
    end
    return false
end

local function killMob()
	local localCharacter = playersService.LocalPlayer.Character
	local localRootPart = localCharacter:WaitForChild("HumanoidRootPart")
	local entity;
	local humanoid;

	while task.wait() do
		entity = Finder.enear(localRootPart.Position, 200)
		humanoid = entity and entity:FindFirstChild("Humanoid")

		if entity and humanoid and humanoid.Health > 0 then
			break
		end
	end

	Movement.ATB = true
	localCharacter.CharacterHandler.Requests.DrawWeapon:FireServer(true)

	if not Configuration.expectToggleValue("EnableAutoDefense") then
		Toggles["EnableAutoDefense"] = true
	end

	if lowLvl(entity.Name:lower()) then
		Exploits.pfBreaker = true

		if not entity.Name:lower():match("megalodaunt") then
			Movement.HeightOffset = 0
			Movement.BackOffset = 4

			-- To avoid flinging the mob. (sometimes is inevitable cuz of humanoids tho)
			repeat task.wait() until localRootPart.CFrame.LookVector:Dot(entity.HumanoidRootPart.CFrame.LookVector) > 0 and (localRootPart.Position - entity.HumanoidRootPart.Position).Magnitude < 5
		else
			-- Lowest weapon range in the game is 5.8 besides the handcuffs (afaik).
			Movement.HeightOffset = 5.8
			Movement.BackOffset = 5.8
		end

		while humanoid.Health > 0 do
			InputClient.left(CFrame.new(), true)
			task.wait(0.5)
		end
		localCharacter.CharacterHandler.Requests.DrawWeapon:FireServer(false)
	else
		print("I cba to get 20 drowns, omg.")
	end

	Movement.ATB = false
	Exploits.pfBreaker = false
end

function AutoDepths.ctrial()
	-- Request start.
	local requests = replicatedStorage:WaitForChild("Requests", 5)
	local startMenu = requests:WaitForChild("StartMenu", 5)
	local start = startMenu:WaitForChild("Start", 5)

	telemetryLog("(AutoEscape) Checking if players joined with us.")

	local data = PersistentData.get("esdata")

	if #playersService:GetPlayers() > 1 then
		return ServerHop.hop(data.slot, false)
	end

	telemetryLog("(AutoEscape) Requesting start.")

	repeat
		-- Fire server.
		start:FireServer()

		-- Wait.
		task.wait()
	until #workspace:WaitForChild("Live"):GetChildren() > 0


	local trial = workspace:WaitForChild("DepthsTrial"):WaitForChild("CircularPlatform")
	local lever = trial:WaitForChild("DepthsTrialDungeonLever")
	local pos = lever:GetPivot().Position

	local localPlayer = playersService.LocalPlayer
	local localCharacter = localPlayer.Character
	local localRootPart = localCharacter and localCharacter:WaitForChild("HumanoidRootPart")

	-- Interact with the lever if we are near it to intialize the trial.
	if (pos - localRootPart.Position).Magnitude < 200 then
		Tweening.goal("AD_InteractLever", CFrame.new(pos), true)

		local prompt = lever:WaitForChild("InteractPrompt")
		prompt.MaxActivationDistance = 16

		while (pos - localRootPart.Position).Magnitude < 200 do
			fireproximityprompt(prompt)

			task.wait(0.1)
		end
	end

	killMob()

	AutoDepths.stop()
end

---Start the AutoDepths module
function AutoDepths.start()
	local localPlayer = playersService.LocalPlayer
	if not localPlayer then
		return
	end

	local data = PersistentData.get("esdata")
	if not data then
		return warn("No AutoEscape data found in PersistentData.")
	end

	if not data.slot then
		return warn("No data slot found for AutoEscape.")
	end

	if running then
		return
	end

	running = true

	PersistentData.set("esdata", data)

	AntiAFK.start("AutoDepths")

	if game.PlaceId == DEPTHS_PLACE_ID then
		return escapeDepthsMaid:mark(TaskSpawner.spawn("AD_GoToTrial", AutoDepths.gtrial))
	end

	if game.PlaceId == TRIAL_PLACE_ID then
		return escapeDepthsMaid:mark(TaskSpawner.spawn("AD_CompleteTrial", AutoDepths.ctrial))
	end
end

---Invoke the AutoDepths module.
function AutoDepths.invoke()
	PersistentData.set("esdata", {

		-- What is the current slot that we are trying to escape on?
		slot = playersService.LocalPlayer:GetAttribute("DataSlot"),
	})

	AutoDepths.start()
end

---Stop the AutoDepths module.
function AutoDepths.stop()
	if not running then
		return
	end

	running = false

	-- Stop AntiAFK.
	AntiAFK.stop("AutoDepths")

	-- Clear persistent data.
	PersistentData.set("esdata", nil)

	-- Cancel all tweens related to AutoDepths.
	for _, data in next, Tweening.queue do
		if not data.identifier:match("AD") then
			continue
		end

		Tweening.cancel(data.identifier)
	end

	-- Stop all tasks.
	escapeDepthsMaid:clean()
end

return AutoDepths