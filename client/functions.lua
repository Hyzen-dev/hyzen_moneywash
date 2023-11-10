function LoadFramework()
    Citizen.CreateThread(function()
        if Config.Framework == 'qbcore' then
            if GetResourceState('qb-core') ~= 'started' then
                if GetResourceState('es_extended') == 'started' then
                    print(Locale['errors']['another_framework_detected']:format('es_extended'))
                    Config.Framework = 'esx'
                    Framework = exports['es_extended']:getSharedObject()
                    while not Framework do
                        Framework = exports['es_extended']:getSharedObject()
                        Citizen.Wait(1)
                    end
                else
                    print(Locale['errors']['framework_not_found']:format('qbcore'))
                    return
                end
            else
                while not Framework do
                    Framework = exports['qb-core']:GetCoreObject()
                    Citizen.Wait(1)
                end
                Framework = exports['qb-core']:GetCoreObject()
            end
        elseif Config.Framework == 'esx' then
            if GetResourceState('es_extended') ~= 'started' then
                if GetResourceState('qb-core') == 'started' then
                    print(Locale['errors']['another_framework_detected']:format('qbcore'))
                    Config.Framework = 'qbcore'
                    Framework = exports['qb-core']:GetCoreObject()
                    while not Framework do
                        Framework = exports['qb-core']:GetCoreObject()
                        Citizen.Wait(1)
                    end
                else
                    print(Locale['errors']['framework_not_found']:format('es_extended'))
                    return
                end
            else
                while not Framework do
                    Framework = exports['es_extended']:getSharedObject()
                    Citizen.Wait(1)
                end
                Framework = exports['es_extended']:getSharedObject()
            end
        else
            print(Locale['errors']['no_framework_found']:format(Config.Framework))
            return
        end
        return
    end)
end

function GenerateNpc(position, randomModel)
    if not position then
        return
    end

    local model = GetHashKey(randomModel)

    -- Si le model n'existe pas dans le CDImage alors on retourne une erreur
    if not IsModelInCdimage(model) then
        if Config.Debug then
            print(Locale['errors']['npc_model_not_found']:format(randomModel))
        end
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    local ped = CreatePed(4, model, position.x, position.y, position.z - 0.98, position.w, false, true)

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    SetEntityInvincible(ped, true)

    SetModelAsNoLongerNeeded(model)

    return ped
end
