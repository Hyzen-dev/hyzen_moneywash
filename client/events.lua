RegisterNetEvent('hyzen_blanchisseur:client:GenerateBlanchisseur', function(position, model)
    if not position or not position.position or not position.showBlip then
        return
    end

    if Config.Debug then
        print(Locale['infos']['npc_generation']:format(position.position.x, position.position.y, position.position.z))
    end

    if DoesEntityExist(ped) then
        DeletePed(ped)
        ped = nil
        if Config.Debug then
            print(Locale['infos']['npc_previous_deleted'])
        end
    end

    ped = GenerateNpc(position.position, model)

    if not ped then
        return
    end

    if position.showBlip then
        blip = GenerateBlip(ped)
    end

    if Config.UseTarget then
        if Config.Framework == 'qbcore' then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {{
                    event = 'hyzen_blanchisseur:client:HandleBlanchisseurTransaction',
                    icon = 'fas fa-money-bill-wave',
                    label = Locale['texts']['wash_money_action']
                }},
                distance = 1.5
            })
        elseif Config.Framework == 'esx' then
            if NetworkGetEntityIsNetworked(ped) then
                local netId = NetworkGetNetworkIdFromEntity(ped)
                exports.ox_target:addEntity(netId, {
                    event = 'hyzen_blanchisseur:client:HandleBlanchisseurTransaction',
                    label = Locale['texts']['wash_money_action'],
                    name = "hyzen_blanchisseur:WashMoney",
                    icon = "fas fa-money-bill-wave",
                    distance = 1.5,
                    canInteract = function()
                        return not isTransactionActive
                    end
                })
            else
                exports.ox_target:addLocalEntity(ped, {
                    event = 'hyzen_blanchisseur:client:HandleBlanchisseurTransaction',
                    label = Locale['texts']['wash_money_action'],
                    name = "hyzen_blanchisseur:WashMoney",
                    icon = "fas fa-money-bill-wave",
                    distance = 1.5,
                    canInteract = function()
                        return not isTransactionActive
                    end
                })
            end
        end
    end
end)

RegisterNetEvent('hyzen_blanchisseur:client:GenerateBlanchisseurs', function()
    if #peds > 0 then
        for _, ped in pairs(peds) do
            if Config.Debug then
                print(Locale['infos']['npc_previous_deleted'])
            end
            DeletePed(ped)
        end
        peds = {}
    end

    if Config.Debug then
        print(Locale['infos']['npc_generating'])
    end

    if #blips > 0 then
        for _, blip in pairs(blips) do
            if Config.Debug then
                print(Locale['infos']['blip_previous_deleted'])
            end
            RemoveBlip(blip)
        end
        blips = {}
    end

    for _, position in pairs(Config.Positions) do
        local randomModel = Config.NpcsModels[math.random(1, #Config.NpcsModels)]

        ped = GenerateNpc(position.position, randomModel)

        if not ped then
            return
        end

        table.insert(peds, ped)

        if position.showBlip then
            local blip = GenerateBlip(ped)
            table.insert(blips, blip)
        end
    end
end)

RegisterNetEvent('hyzen_blanchisseur:client:SyncBlanchisseur', function(position, model)
    if not position or position == nil or not model or model == nil then
        if Config.Debug then
            print(Locale['infos']['no_npc_found'])
        end
        return TriggerServerEvent('hyzen_blanchisseur:server:ChangeBlanchisseurPosition')
    end

    if DoesEntityExist(ped) then
        DeletePed(ped)
        ped = nil
        if Config.Debug then
            print(Locale['infos']['npc_previous_deleted'])
        end
    end

    TriggerEvent('hyzen_blanchisseur:client:GenerateBlanchisseur', position, model)
end)

RegisterNetEvent('hyzen_blanchisseur:client:HandleBlanchisseurTransaction', function()
    if not Config.Money or not Config.Money.BlackMoneyType or not Config.Money.BlackMoneyName or
        not Config.Money.CashType or not Config.Money.CashName then
        return
    end

    if Config.Debug then
        print(Locale['texts']['transaction_started'])
    end

    if Config.Money.BlackMoneyType == 'item' then
        if Config.Framework == 'qbcore' then
            Framework.Functions.GetPlayerData(function(playerData)
                local hasItem = nil

                for _, item in pairs(playerData.items) do
                    if item.name == Config.Money.BlackMoneyName then
                        hasItem = item
                        break
                    end
                end

                if not hasItem then
                    Framework.Functions.Notify(Locale['texts']['not_enough_black_money'], 'error')

                    if Config.Debug then
                        print(Locale['texts']['transaction_error_not_enough_black_money'])
                    end

                    return
                end

                local amount = hasItem.amount

                if amount <= 0 then
                    Framework.Functions.Notify(Locale['texts']['not_enough_black_money'], 'error')

                    if Config.Debug then
                        print('Blanchisseur transaction failed because you don\'t have any black money')
                    end

                    return
                end

                isTransactionActive = true

                Framework.Functions.Progressbar('blanchisseur_transaction', Locale['texts']['is_washing_money'],
                    Config.TransactionDuration * 1000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                    }, {}, {}, {}, function()
                        TriggerServerEvent('hyzen_blanchisseur:server:HandleBlanchisseurTransaction')
                        isTransactionActive = false
                    end, function()
                        Framework.Functions.Notify(Locale['texts']['transaction_cancelled'], 'error')
                        isTransactionActive = false
                    end)
            end)
        elseif Config.Framework == 'esx' then
            -- TODO
        end
    elseif Config.Money.BlackMoneyType == 'virtual' then
        if Config.Framework == 'qbcore' then
            Framework.Functions.GetPlayerData(function(playerData)
                if not playerData then
                    return Framework.Functions.Notify(Locale['texts']['not_enough_black_money'], 'error')
                end

                if not playerData.money[Config.Money.BlackMoneyName] or playerData.money[Config.Money.BlackMoneyName] <=
                    0 then
                    Framework.Functions.Notify(Locale['texts']['not_enough_black_money'], 'error')

                    if Config.Debug then
                        print(Locale['texts']['transaction_error_not_enough_black_money'])
                    end

                    return
                end

                isTransactionActive = true

                Framework.Functions.Progressbar('blanchisseur_transaction', Locale['texts']['is_washing_money'],
                    Config.TransactionDuration * 1000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                    }, {}, {}, {}, function()
                        TriggerServerEvent('hyzen_blanchisseur:server:HandleBlanchisseurTransaction')
                        isTransactionActive = false
                    end, function()
                        Framework.Functions.Notify(Locale['texts']['transaction_cancelled'], 'error')
                        isTransactionActive = false
                    end)
            end)
        elseif Config.Framework == 'esx' then
            -- TODO
            local playerAccount = nil

            if not Framework or Framework == nil then
                while not Framework do
                    Framework = exports['es_extended']:getSharedObject()
                    Citizen.Wait(1)
                end
            end

            for _, account in pairs(Framework.PlayerData.accounts) do
                if account.name == Config.Money.BlackMoneyName then
                    playerAccount = account
                    break
                end
            end

            if not playerAccount or playerAccount == nil then
                if Config.Debug then
                    print(Locale['errors']['money_account_not_found']:format(Config.Money.BlackMoneyName))
                    return
                end
            end

            Framework.TriggerServerCallback('hyzen_blanchisseur:server:CheckEnoughMoney', function(hasEnoughBlackMoney)
                if not hasEnoughBlackMoney then
                    Framework.ShowNotification(Locale['texts']['not_enough_black_money'], 'error', 3000)

                    if Config.Debug then
                        print(Locale['texts']['transaction_error_not_enough_black_money'])
                    end

                    return
                end

                isTransactionActive = true

                Framework.Progressbar(Locale['texts']['is_washing_money'], Config.TransactionDuration * 1000, {
                    FreezePlayer = true,
                    animation = {},
                    onFinish = function()
                        TriggerServerEvent('hyzen_blanchisseur:server:HandleBlanchisseurTransaction')
                        isTransactionActive = false
                    end,
                    onCancel = function()
                        Framework.ShowNotification(Locale['texts']['transaction_cancelled'], 'error', 3000)
                        isTransactionActive = false
                    end
                })
                return
            end)
        end
    end
end)

if Config.Framework == 'qbcore' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        if Config.SpawnAtAllPositions and not Config.IsNpcRotating then
            LoadFramework()
            TriggerEvent('hyzen_blanchisseur:client:GenerateBlanchisseurs')
        else
            LoadFramework()
            TriggerServerEvent('hyzen_blanchisseur:server:SyncBlanchisseur')
        end
    end)
elseif Config.Framework == 'esx' then
    RegisterNetEvent('esx:playerLoaded', function()
        if Config.SpawnAtAllPositions and not Config.IsNpcRotating then
            TriggerEvent('hyzen_blanchisseur:client:GenerateBlanchisseurs')
        else
            TriggerServerEvent('hyzen_blanchisseur:server:SyncBlanchisseur')
        end
    end)
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.CreateThread(function()
            LoadFramework()
            while not Framework do
                Citizen.Wait(100)
            end

            if Config.SpawnAtAllPositions and not Config.IsNpcRotating then
                TriggerEvent('hyzen_blanchisseur:client:GenerateBlanchisseurs')
            else
                TriggerServerEvent('hyzen_blanchisseur:server:SyncBlanchisseur')
            end

            return
        end)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if #peds > 0 then
            for _, ped in pairs(peds) do
                if Config.Debug then
                    print(Locale['infos']['npc_deleted'])
                end
                DeletePed(ped)
            end
            peds = {}
        end

        if #blips > 0 then
            for _, blip in pairs(blips) do
                if Config.Debug then
                    print(Locale['infos']['blip_deleted'])
                end
                RemoveBlip(blip)
            end
            blips = {}
        end

        if ped and ped ~= 0 then
            if Config.Debug then
                print(Locale['infos']['npc_deleted'])
            end
            DeletePed(ped)
            ped = nil
        end

        if blip and blip ~= 0 then
            if Config.Debug then
                print(Locale['infos']['blip_deleted'])
            end
            RemoveBlip(blip)
            blip = nil
        end
    end
end)
