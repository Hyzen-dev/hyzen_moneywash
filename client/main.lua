if Config.UseTarget then
    if Config.Framework == 'qbcore' then
        if GetResourceState('qb-target') ~= 'started' then
            print(Locale['errors']['target_not_found']:format('qb-target'))
            Config.UseTarget = false
        end
    elseif Config.Framework == 'esx' then
        if GetResourceState('ox_target') ~= 'started' then
            print(Locale['errors']['target_not_found']:format('ox_target'))
            Config.UseTarget = false
        end
    end
end

-- Loops
if not Config.UseTarget then
    Citizen.CreateThread(function()
        if not Config.SpawnAtAllPositions and Config.IsNpcRotating then
            while true do
                local sleep = 1000
                if not ped or ped == nil then
                    Citizen.Wait(sleep)
                end

                local pedCoords = GetEntityCoords(ped)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = GetDistanceBetweenCoords(pedCoords, playerCoords, true)

                if distance <= 1.5 then
                    if Config.NpcTextType == '3d' then
                        sleep = 0
                        if not isTransactionActive then
                            Draw3DText(pedCoords.x, pedCoords.y, pedCoords.z + 0.5,
                                Locale['texts']['wash_money_action_3d'])
                        else
                            Draw3DText(pedCoords.x, pedCoords.y, pedCoords.z + 0.5, Locale['texts']['is_washing_money'])
                        end
                    else
                        if Config.Framework == 'qbcore' then
                            sleep = 0
                            if not isTransactionActive then
                                exports['qb-core']:DrawText(Locale['texts']['wash_money_action_2d'])
                                isTextShowed = true
                            else
                                exports['qb-core']:HideText()
                            end
                        elseif Config.Framework == 'esx' then
                            sleep = 1
                            if not isTransactionActive then
                                Framework.TextUI(Locale['texts']['wash_money_action_2d'])
                                isTextShowed = true
                            else
                                Framework.HideUI()
                            end
                        end
                    end
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent('hyzen_blanchisseur:client:HandleBlanchisseurTransaction')
                    end
                else
                    if Config.Framework == 'qbcore' then
                        if isTextShowed then
                            exports['qb-core']:HideText()
                            isTextShowed = false
                        end
                    elseif Config.Framework == 'esx' then
                        if isTextShowed then
                            Framework.HideUI()
                            isTextShowed = false
                        end
                    end
                end
                Citizen.Wait(sleep)
            end
        end
    end)
end
