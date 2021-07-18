local _A = {}
local playerSpawned = false

_A.IsInSpectatorMode = function()
    return Citizen.InvokeNative(0x048746E388762E11, Citizen.ReturnResultAnyway())
end

AddEventHandler("playerSpawned", function()
    _A.commands = #GetRegisteredCommands()
    _A.resources = GetNumResources()
    playerSpawned = true
    SetEntityVisible(GetPlayerPed(-1), true)
end)

function SetWeaponDrops()
	local handle, ped = FindFirstPed()
	local finished = false

	repeat
		if not IsEntityDead(ped) then
			SetPedDropsWeaponsWhenDead(ped, false)
		end
		finished, ped = FindNextPed(handle)
	until not finished

	EndFindPed(handle)
end

Citizen.CreateThread(function()
    local ped = GetPlayerPed(-1)
    local pid = PlayerId()
    local vehicle = GetVehiclePedIsIn(ped)
    local oldCoords = GetEntityCoords(ped)
    SetEntityVisible(ped, true)

    while true do
        Citizen.Wait(500)
        ped = GetPlayerPed(-1)
        pid = PlayerId()
        vehicle = GetVehiclePedIsIn(ped)

		SetWeaponDrops()

        if _A.IsInSpectatorMode() then
            TriggerServerEvent("AntiSpectate")
        end

        if playerSpawned then
            local alpha = GetEntityAlpha(ped)
            if not IsEntityVisible(ped) or not IsEntityVisibleToScript(ped) or alpha <= 150 then
                TriggerServerEvent("AntiInvisible")
            end

            if not IsPedInAnyVehicle(ped, true) and GetEntitySpeed(ped) > 10 and not IsPedFalling(ped) and not IsPedInParachuteFreeFall(ped) and not IsPedJumpingOutOfVehicle(ped) and not IsPedRagdoll(ped) and GetVehiclePedIsEntering(ped) ~= 0 then
                TriggerServerEvent("AntiSpeedHacks")
            end

            if not _A.IsInSpectatorMode() then
                local ped = PlayerPedId()
                local x, y, z = table.unpack(GetEntityCoords(ped) - GetFinalRenderedCamCoord())
    
                if (x > 50) or (y > 50) or (z > 50) or (x < -50) or (y < -50) or (z < -50) then
                    TriggerServerEvent("AntiFreeCam")
                end
            end
        end

        Citizen.Wait(500)
        ped = GetPlayerPed(-1)
        pid = PlayerId()
        vehicle = GetVehiclePedIsIn(ped)

        if playerSpawned then
            local ret, bulletproof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, drownProof = GetEntityProofs(ped)
            if bulletproof == 1 or fireProof == 1 or explosionProof == 1 or collisionProof == 1 or meleeProof == 1 or steamProof == 1 or drownProof == 1 then
                TriggerServerEvent("AntiEntityProofs", { bulletproof = bulletproof, fireProof = fireProof, explosionProof = explosionProof, collisionProof = collisionProof, meleeProof = meleeProof, steamProof = steamProof, drownProof = drownProof })
            end

            if GetPlayerInvincible(ped) then
                TriggerServerEvent("GodMode", "3")
            end
        end
        
        Citizen.Wait(500)
        ped = GetPlayerPed(-1)
        pid = PlayerId()
        vehicle = GetVehiclePedIsIn(ped)

        if IsPedInAnyVehicle(ped) and playerSpawned then
            SetVehicleTyresCanBurst(vehicle, true)

            if GetPlayerVehicleDamageModifier(pid) > 1.0 then
                TriggerServerEvent("vehicleDamagerModifier")
            end

            if GetVehicleCheatPowerIncrease(vehicle) > 1.0 then
                TriggerServerEvent("vehicleCheatPower")
            end

            if not GetVehicleTyresCanBurst(vehicle) then
                TriggerServerEvent("invincibleTyres")
            end

            if GetVehicleTopSpeedModifier(vehicle) > 1.0 then
                TriggerServerEvent("vehicleTopSeedModifier")
            end

            if GetPlayerVehicleDefenseModifier(vehicle) > 1.0 then
                TriggerServerEvent("vehicleDefenseModifier")
            end

            local topSpeedModifier = round(GetVehicleTopSpeedModifier(vehicle))
            if topSpeedModifier > 5.0 then
                TriggerServerEvent("AntiVehicleModifier", { topSpeedModifier = topSpeedModifier, vehicle = vehicle } )
            end
        end

        Citizen.Wait(500)
        ped = GetPlayerPed(-1)
        pid = PlayerId()
        vehicle = GetVehiclePedIsIn(ped)

        if IsPedArmed(ped, 6) and playerSpawned then
            local currentWeapon = GetSelectedPedWeapon(ped)
            if GetWeaponDamageModifier(currentWeapon) > 1.0 then
                TriggerServerEvent("AntiWeaponDamageModifier")
            end

            if GetPlayerWeaponDamageModifier(pid) > 1.0 then
                TriggerServerEvent("AntiWeaponDamageModifier")
            end

            if GetPlayerMeleeWeaponDamageModifier(pid) > 1.0 then
                TriggerServerEvent("AntiMeleeDamagerModifier")
            end

            if GetPlayerMeleeWeaponDefenseModifier(pid) > 1.0 then
                TriggerServerEvent("AntiMeleeDefenseModifier")
            end

            if GetPlayerWeaponDefenseModifier(pid) > 1.0 then
                TriggerServerEvent("AntiWeaponDefenseModifier")
            end

            if GetPlayerWeaponDefenseModifier_2(pid) > 1.0 then
                TriggerServerEvent("AntiWeaponDefenseModifier")
            end
        end

        Citizen.Wait(500)
        if numResources ~= GetNumResources() or GetResourceByFindIndex(GetNumResources()) ~= nil then
            local resourceList = {}
            for i = 0, GetNumResources() - 1 do
                resourceList[i + 1] = GetResourceByFindIndex(i)
                Citizen.Wait(100)
            end

            if GetResourceByFindIndex(GetNumResources()) ~= nil then
                resourceList[GetNumResources() + 1] = GetResourceByFindIndex(GetNumResources())
            end
    
            TriggerServerEvent("CheckResources", resourceList)
            numResources = GetNumResources()
        end
    end
end)

local detections = 0
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if playerSpawned then
            local ped = GetPlayerPed(-1)
            local health = GetEntityHealth(ped)
            SetEntityHealth(ped,  health - 2)
            Citizen.Wait(1)
            if not IsPlayerDead(pid) then
                if GetEntityHealth(ped) == health and GetEntityHealth(ped) ~= 0 then
                    detections = detections + 1
                    if detections == 5 then
                        TriggerServerEvent("GodMode", "1")
                    end
                elseif GetEntityHealth(ped) == health - 2 then
                    if detections ~= 0 then
                        detections = detections - 1
                    end
                    SetEntityHealth(ped, GetEntityHealth(ped) + 2)
                end
            end
        end
    end
end)

-- No Clip / Invisible
local invisDetections = 0
local noClipDetections = 0
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        local ped = GetPlayerPed(-1)
        local pedCoords = GetEntityCoords(ped)
        local ret, groundCoords = GetGroundZFor_3dCoord(pedCoords.x, pedCoords.y, pedCoords.z)
        local dist = GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.x, pedCoords.y, groundCoords, true)

        if dist > 15.0 and not IsPedInAnyVehicle(ped) and not IsPedInParachuteFreeFall(ped) and not IsPedFalling(ped) then
            noClipDetections = noClipDetections + 1
            if noClipDetections > 5 and playerSpawned then
                noClipDetections = 0
                TriggerServerEvent("AntiNoClip")
            end
        end

        if not IsEntityVisible(ped) then
            invisDetections = invisDetections + 1
            if invisDetections > 5 and playerSpawned then
                TriggerServerEvent("AntiInvisible")
                invisDetections = 0
            end
        else
            invisDetections = 0
        end
    end
end)

local isDead = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local ped = GetPlayerPed(-1)
        if IsEntityDead(ped) then
            isDead = true
            Citizen.Wait(500)
        elseif isDead then
            isDead = false
            if playerSpawned then
                TriggerServerEvent("SelfRevive")
            end
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent("AntiCheat:ResPed")
AddEventHandler("AntiCheat:ResPed", function(ped, coords, heading)
    isDead = false
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading or 0.0, true, false)
	SetPlayerInvincible(ped or GetPlayerPed(-1), false)
	ClearPedBloodDamage(ped or GetPlayerPed(-1))
end)

function round(num)
    return tonumber(string.format("%.2f", num))
end