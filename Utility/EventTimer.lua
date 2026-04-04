-- Event Timer module for world events countdown.
local EventTimer = {}

-- Timezone offset configurations (UTC offset in hours)
-- NA East is UTC-5 (Eastern Time) - this is the base
local TIMEZONES = {
    ["NA East (EST)"] = 0, -- UTC-5
    ["NA Central (CST)"] = 1, -- UTC-6 (1 hour behind EST)
    ["NA Mountain (MST)"] = 2, -- UTC-7
    ["NA Pacific (PST)"] = 3, -- UTC-8
    ["EU (GMT)"] = 5, -- UTC+0 (5 hours ahead of EST)
    ["JP (JST)"] = 14, -- UTC+9
    ["AU (AEDT)"] = 15 -- UTC+11
}

-- Default timezone - NA East
EventTimer.currentTimezone = "NA East (EST)"

-- Event times in 24-hour format (minutes from midnight) - NA EAST BASE
local EVENTS_NA_EAST = {
    BattleRoyale = {60, 150, 240, 330, 420, 510, 600, 690, 780, 870, 960, 1050, 1140, 1230, 1320},
    InterluminaryParasol = {120, 210, 300, 390, 480, 570, 660, 750, 840, 930, 1020, 1110, 1200, 1290, 1380, 1470},
    CarnivalOfHearts = {90, 180, 270, 360, 450, 540, 630, 720, 810, 900, 990, 1080, 1170, 1260, 1350, 1440}
}

---Convert event times to a specific timezone
---@param baseMinutes number - minutes from midnight in NA East
---@param timezoneOffset number - hours to offset
---@return number - adjusted minutes
local function convertToTimezone(baseMinutes, timezoneOffset)
    -- Convert to minutes offset
    local minuteOffset = timezoneOffset * 60
    local adjustedMinutes = (baseMinutes + minuteOffset) % 1440

    -- Handle negative wraparound
    if adjustedMinutes < 0 then
        adjustedMinutes = adjustedMinutes + 1440
    end

    return adjustedMinutes
end

---Get events for current timezone
---@return table
local function getEventsForTimezone()
    local offset = TIMEZONES[EventTimer.currentTimezone] or 0

    if offset == 0 then
        return EVENTS_NA_EAST
    end

    -- Convert all events
    local converted = {}
    for eventName, times in pairs(EVENTS_NA_EAST) do
        converted[eventName] = {}
        for _, minute in ipairs(times) do
            table.insert(converted[eventName], convertToTimezone(minute, offset))
        end
        table.sort(converted[eventName])
    end

    return converted
end

---Convert event times from minutes to readable format
local function minutesToTime(minutes)
    local hours = math.floor(minutes / 60)
    local mins = minutes % 60
    local period = hours >= 12 and "PM" or "AM"
    if hours > 12 then
        hours = hours - 12
    elseif hours == 0 then
        hours = 12
    end
    return string.format("%d:%02d %s", hours, mins, period)
end

---Get the next event countdown
---@return string eventName, number secondsUntil, string eventTime
function EventTimer.getNextEvent()
    local now = os.time()
    local date = os.date("*t", now)
    local currentMinutes = date.hour * 60 + date.min
    local currentSecs = date.sec

    local nextEventTime = nil
    local nextEventSeconds = math.huge
    local nextEventName = "Unknown"

    -- Get events for current timezone
    local events = getEventsForTimezone()

    print("DEBUG: Current time in minutes: " .. currentMinutes .. ", seconds: " .. currentSecs)

    -- Check all events for the next occurrence
    for eventName, times in pairs(events) do
        for _, eventMinutes in ipairs(times) do
            local secondsUntilEvent

            if eventMinutes > currentMinutes then
                -- Event is later today
                secondsUntilEvent = (eventMinutes - currentMinutes) * 60 - currentSecs
            else
                -- Event is tomorrow
                secondsUntilEvent = ((24 * 60 - currentMinutes) + eventMinutes) * 60 - currentSecs
            end

            if secondsUntilEvent > 0 and secondsUntilEvent < nextEventSeconds then
                nextEventSeconds = secondsUntilEvent
                nextEventName = eventName
                nextEventTime = eventMinutes
                print(
                    "DEBUG: Found event " .. eventName .. " at " .. eventMinutes .. " minutes, " .. secondsUntilEvent ..
                        " seconds away")
            end
        end
    end

    -- if we never found a next event (shouldn't happen) provide sensible defaults
    if nextEventSeconds == math.huge then
        nextEventName = "None"
        nextEventSeconds = 0
        nextEventTime = currentMinutes
        print("DEBUG: No events found, using defaults")
    end

    print("DEBUG: Returning " .. nextEventName .. " with " .. nextEventSeconds .. " seconds until event")
    return nextEventName, nextEventSeconds, minutesToTime(nextEventTime or currentMinutes)
end

---Set the current timezone
---@param timezone string
function EventTimer.setTimezone(timezone)
    if TIMEZONES[timezone] ~= nil then
        EventTimer.currentTimezone = timezone
    end
end

---Get available timezones
---@return table
function EventTimer.getTimezones()
    local zones = {}
    for tz, _ in pairs(TIMEZONES) do
        table.insert(zones, tz)
    end
    table.sort(zones)
    return zones
end

---Format seconds into readable countdown
---@param seconds number
---@return string
function EventTimer.formatCountdown(seconds)
    if seconds < 0 then
        return "Happening Now!"
    end

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

return EventTimer
