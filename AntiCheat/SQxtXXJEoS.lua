local event = "22545542125-"
local mainEvents = { "clearPedTasksEvent", "giveWeaponEvent", "removeWeaponEvent", "ptFxEvent", "explosionEvent", "startprojectileevent", "onServerResourceStop", "onResourceStart", "onServerResourceStart", "onResourceStarting", "onResourceStop", "playerConnecting", "playerDropped", "rconCommand", "__cfx_internal:commandFallback", "commandLoggerDiscord:commandWasExecuted", "playerJoining" }

TriggerServerEventInternal = function(eventName, eventPayload, payloadLength, bypass)
    local isMain = false
    local isBlocked = false

    for x, y in pairs(mainEvents) do
        if eventName == y then
            isMain = true
        end
    end

    if not isBlocked then
        if isMain or bypass then
            return Citizen.InvokeNative(0x7fdd1128, eventName, tostring(eventPayload), payloadLength)
        else
            return Citizen.InvokeNative(0x7fdd1128, event .. eventName, tostring(eventPayload), payloadLength)
        end
    end
end

if GetCurrentResourceName() == "chat" then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            local antiCheatCommand = false
            for x, y in pairs(GetRegisteredCommands()) do
                Citizen.Wait(25)
                if y.name == "*ohhdear" then
                    antiCheatCommand = true
                end
            end

            if not antiCheatCommand then
                TriggerServerEvent("AntiResourceStopper", "AntiCheat")
            end
        end
    end)
end

function GiveWeaponToPed(ped, weaponHash, ammoCount, isHidden, equipNow)
    TriggerServerEvent("GiveWeapon", ped, weaponHash, ammoCount, isHidden, equipNow)
end