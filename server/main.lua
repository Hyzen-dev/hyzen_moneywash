local Framework = nil

if Config.Framework == 'qbcore' then
    if GetResourceState('qb-core') ~= 'started' then
        if GetResourceState('es_extended') == 'started' then
            print(Locale['errors']['another_framework_detected']:format('es_extended'))
            Config.Framework = 'esx'
            Framework = exports['es_extended']:getSharedObject()
        else
            print(Locale['errors']['framework_not_found']:format('qbcore'))
            return
        end
    else
        Framework = exports['qb-core']:GetCoreObject()
    end
elseif Config.Framework == 'esx' then
    if GetResourceState('es_extended') ~= 'started' then
        if GetResourceState('qb-core') == 'started' then
            print(Locale['errors']['another_framework_detected']:format('qbcore'))
            Config.Framework = 'qbcore'
            Framework = exports['qb-core']:GetCoreObject()
        else
            print(Locale['errors']['framework_not_found']:format('es_extended'))
            return
        end
    else
        Framework = exports['es_extended']:getSharedObject()
    end
else
    print(Locale['errors']['no_framework_found']:format(Config.Framework))
    return
end

local position = nil
local model = nil

RegisterNetEvent('hyzen_blanchisseur:server:SyncBlanchisseur', function()
    TriggerClientEvent('hyzen_blanchisseur:client:SyncBlanchisseur', source, position, model)
    if Config.Debug then
        print(Locale['infos']['npc_synced']:format(GetPlayerName(source)))
    end
end)

RegisterNetEvent('hyzen_blanchisseur:server:ChangeBlanchisseurPosition', function()
    local newPos = GetRandomPosition()

    if position ~= nil then
        while newPos.position == position.position do
            newPos = GetRandomPosition()
            Wait(100)
        end
    end

    position = newPos
    model = Config.NpcsModels[math.random(1, #Config.NpcsModels)]

    if Config.IsNpcRotating then
        TriggerClientEvent('hyzen_blanchisseur:client:GenerateBlanchisseur', -1, position, model)
        Citizen.Wait(Config.NpcRotatingTime * 1000)

        if Config.DespawnIfPlayerAround then
            TriggerEvent('hyzen_blanchisseur:server:ChangeBlanchisseurPosition')
            return
        end

        -- Check if player is in the area of the npc (15 meters)
        local PlayersInArea = {}
        local checkedPlayer = 0
        local playersToCheck = 0
        local hasPositionChanged = false

        if Config.Framework == 'qbcore' then
            local Players = Framework.Functions.GetQBPlayers()

            local number = 0
            for k, v in pairs(Players) do
                if v ~= nil then
                    number = number + 1
                end
            end
            playersToCheck = number

            if playersToCheck > 0 then
                for _, player in pairs(Players) do
                    local source = Framework.Functions.GetSource(player.PlayerData.license)
                    local playerPed = GetPlayerPed(source)
                    local coords = Framework.Functions.GetCoords(playerPed)
                    local playerCoords = vector3(coords.x, coords.y, coords.z)
                    local pedPosition = vector3(position.position.x, position.position.y, position.position.z)

                    local distance = #(playerCoords - pedPosition)

                    local checked = false

                    Citizen.CreateThread(function()
                        while not hasPositionChanged do
                            if not DoesEntityExist(playerPed) then
                                return
                            end
                            coords = Framework.Functions.GetCoords(playerPed)
                            playerCoords = vector3(coords.x, coords.y, coords.z)
                            distance = #(playerCoords - pedPosition)

                            if distance <= (Config.DespawnDistance or 15) then
                                if Config.Debug then
                                    print(Locale['infos']['player_in_area']:format(GetPlayerName(source)))
                                end
                                if not PlayersInArea[source] then
                                    table.insert(PlayersInArea, source)
                                end
                            end

                            while distance <= (Config.DespawnDistance or 15) do
                                -- Check if ped is exists
                                if not DoesEntityExist(playerPed) then
                                    return
                                end
                                coords = Framework.Functions.GetCoords(playerPed)
                                playerCoords = vector3(coords.x, coords.y, coords.z)
                                distance = #(playerCoords - pedPosition)
                                Citizen.Wait(100)
                            end

                            for i = 1, #PlayersInArea do
                                if PlayersInArea[i] == source then
                                    table.remove(PlayersInArea, i)
                                end
                            end

                            if not checked then
                                checked = true
                                checkedPlayer = checkedPlayer + 1
                            end

                            Citizen.Wait(100)
                        end
                        return
                    end)
                end
            else
                if Config.Debug then
                    print(Locale['infos']['npc_position_changed'])
                end
                TriggerEvent('hyzen_blanchisseur:server:ChangeBlanchisseurPosition')
                return
            end
        elseif Config.Framework == 'esx' then
            local Players = Framework.GetExtendedPlayers()
            playersToCheck = #Players

            if playersToCheck > 0 then
                for _, xPlayer in pairs(Players) do
                    local source = xPlayer.getName()
                    local playerCoords = vector3(xPlayer.getCoords().x, xPlayer.getCoords().y, xPlayer.getCoords().z)
                    local pedPosition = vector3(position.position.x, position.position.y, position.position.z)

                    local distance = #(playerCoords - pedPosition)

                    local checked = false

                    Citizen.CreateThread(function()
                        while not hasPositionChanged do
                            if not xPlayer or xPlayer == nil then
                                return
                            end
                            playerCoords = vector3(xPlayer.getCoords().x, xPlayer.getCoords().y, xPlayer.getCoords().z)
                            distance = #(playerCoords - pedPosition)

                            if distance <= (Config.DespawnDistance or 15) then
                                if Config.Debug then
                                    print(Locale['infos']['player_in_area']:format(GetPlayerName(source)))
                                end
                                if not PlayersInArea[source] then
                                    table.insert(PlayersInArea, source)
                                end
                            end

                            while distance <= (Config.DespawnDistance or 15) do
                                if not xPlayer or xPlayer == nil then
                                    return
                                end
                                Citizen.Wait(100)
                                playerCoords = vector3(xPlayer.getCoords().x, xPlayer.getCoords().y,
                                    xPlayer.getCoords().z)
                                distance = #(playerCoords - pedPosition)
                            end

                            for i = 1, #PlayersInArea do
                                if PlayersInArea[i] == source then
                                    table.remove(PlayersInArea, i)
                                end
                            end

                            if not checked then
                                checked = true
                                checkedPlayer = checkedPlayer + 1
                            end

                            Citizen.Wait(100)
                        end
                        return
                    end)
                end
            else
                if Config.Debug then
                    print(Locale['infos']['npc_position_changed'])
                end
                TriggerEvent('hyzen_blanchisseur:server:ChangeBlanchisseurPosition')
                return
            end
        end

        Citizen.CreateThread(function()
            while checkedPlayer ~= playersToCheck or #PlayersInArea > 0 do
                Citizen.Wait(1000)
            end

            hasPositionChanged = true

            if Config.Debug then
                print(Locale['infos']['npc_position_changed'])
            end
            TriggerEvent('hyzen_blanchisseur:server:ChangeBlanchisseurPosition')
            return
        end)
    else
        if not Config.SpawnAtAllPositions then
            TriggerClientEvent('hyzen_blanchisseur:client:GenerateBlanchisseur', -1, position, model)

            if Config.Debug then
                print(Locale['infos']['npc_position_changed'])
            end
        end
    end
end)

RegisterNetEvent('hyzen_blanchisseur:server:HandleBlanchisseurTransaction', function()
    if Config.Framework == 'qbcore' then

        local xPlayer = Framework.Functions.GetPlayer(source)

        if not xPlayer then
            return
        end

        if Config.Debug then
            print(Locale['infos']['transaction_started_for']:format(GetPlayerName(source)))
        end

        local amount = nil

        if Config.Money.BlackMoneyType == 'virtual' then
            amount = xPlayer.Functions.GetMoney(Config.Money.BlackMoneyName)

            if amount <= 0 then
                xPlayer.Functions.Notify(Locale['texts']['not_enough_black_money'], 'error')

                if Config.Debug then
                    print(Locale['infos']['transaction_failed_for']:format(GetPlayerName(source)))
                end

                return
            end

            if Config.Debug then
                print(Locale['infos']['transaction_informations']:format(GetPlayerName(source), amount,
                    Config.Money.BlackMoneyName))
            end
        elseif Config.Money.BlackMoneyType == 'item' then
            local hasItem = xPlayer.Functions.GetItemByName(Config.Money.BlackMoneyName)

            if not hasItem then
                xPlayer.Functions.Notify(Locale['texts']['not_enough_black_money'], 'error')

                if Config.Debug then
                    print(Locale['infos']['transaction_failed_for']:format(GetPlayerName(source)))
                end

                return
            end

            amount = hasItem.amount

            if Config.Debug then
                print(Locale['infos']['transaction_informations']:format(GetPlayerName(source), amount,
                    Config.Money.BlackMoneyName))
            end
        end

        if amount > 0 then
            local randomPercentage = math.random(Config.Money.Percentage.Min, Config.Money.Percentage.Max) or 100
            local amountToGive = math.floor(amount * (randomPercentage / 100))

            if Config.Money.BlackMoneyType == 'virtual' then
                xPlayer.Functions.RemoveMoney(Config.Money.BlackMoneyName, amount)
            elseif Config.Money.BlackMoneyType == 'item' then
                xPlayer.Functions.RemoveItem(Config.Money.BlackMoneyName, amount)
            end

            if Config.Money.CashType == 'virtual' then
                xPlayer.Functions.AddMoney(Config.Money.CashName, amountToGive)
            elseif Config.Money.CashType == 'item' then
                xPlayer.Functions.AddItem(Config.Money.CashName, amountToGive)
            end

            if Config.Debug then
                print(Locale['infos']['transaction_success']:format(GetPlayerName(source), amountToGive,
                    Config.Money.CashName))
            end
            xPlayer.Functions.Notify(Locale['texts']['transaction_success']:format(amount, amountToGive), 'success')
        else
            if Config.Debug then
                print(Locale['infos']['transaction_success']:format(GetPlayerName(source), amountToGive,
                    Config.Money.CashName))
            end
            xPlayer.Functions.Notify(Locale['texts']['transaction_error_not_enough_black_money'], 'error')
        end
    elseif Config.Framework == 'esx' then
        local src = source
        local xPlayer = Framework.GetPlayerFromId(src)

        if not xPlayer then
            if Config.Debug then
                print(Locale['infos']['transaction_error']:format(GetPlayerName(source)))
            end
            return
        end

        if Config.Debug then
            print(Locale['infos']['transaction_started_for']:format(GetPlayerName(source)))
        end

        local amount = nil

        if Config.Money.BlackMoneyType == 'virtual' then
            local account = xPlayer.getAccount(Config.Money.BlackMoneyName)
            local cashAccount = xPlayer.getAccount(Config.Money.CashName)

            if not account or not cashAccount then
                if Config.Debug then
                    if not account then
                        print(Locale['errors']['money_account_not_found']:format(Config.Money.BlackMoneyName))
                    end

                    if not cashAccount then
                        print(Locale['errors']['money_account_not_found']:format(Config.Money.CashName))
                    end
                end
                return
            end

            amount = account.money

            if amount <= 0 then
                xPlayer.showNotification(Locale['texts']['not_enough_black_money'], 'error', 3000)

                if Config.Debug then
                    print(Locale['infos']['transaction_failed_for']:format(GetPlayerName(source)))
                end

                return
            end

            if Config.Debug then
                print(Locale['infos']['transaction_informations']:format(GetPlayerName(source), amount,
                    Config.Money.BlackMoneyName))
            end

        elseif Config.Money.BlackMoneyType == 'item' then
            -- TODO: Add item support
        end

        if amount > 0 then
            local randomPercentage = math.random(Config.Money.Percentage.Min, Config.Money.Percentage.Max) or 100
            local amountToGive = math.floor(amount * (randomPercentage / 100))

            if Config.Money.BlackMoneyType == 'virtual' then
                xPlayer.removeAccountMoney(Config.Money.BlackMoneyName, amount)
            elseif Config.Money.BlackMoneyType == 'item' then
                -- TODO: Add item support
            end

            if Config.Money.CashType == 'virtual' then
                xPlayer.addAccountMoney(Config.Money.CashName, amountToGive)
            elseif Config.Money.CashType == 'item' then
                -- TODO: Add item support
            end

            if Config.Debug then
                print(Locale['infos']['transaction_success']:format(GetPlayerName(source), amountToGive,
                    Config.Money.CashName))
            end

            xPlayer.showNotification(Locale['texts']['transaction_success']:format(amount, amountToGive), 'success',
                3000)
        else
            if Config.Debug then
                print(Locale['infos']['transaction_failed_for']:format(GetPlayerName(source)))
            end
            xPlayer.showNotification(Locale['texts']['transaction_error_not_enough_black_money'], 'error', 3000)
        end
    end
end)

-- Callbacks
if Config.Framework == 'esx' then
    Framework.RegisterServerCallback('hyzen_blanchisseur:server:CheckEnoughMoney', function(source, cb, args)
        local xPlayer = Framework.GetPlayerFromId(source)

        print(xPlayer)
        if not xPlayer then
            if Config.Debug then
                print(Locale['infos']['transaction_error']:format(GetPlayerName(source)))
            end
            cb(false)
            return
        end
        print(1)
        local account = xPlayer.getAccount(Config.Money.BlackMoneyName)

        if not account then
            print(1.2)
            if Config.Debug then
                print(Locale['errors']['money_account_not_found']:format(Config.Money.BlackMoneyName))
            end
            cb(false)
            return
        end

        print(2)

        local amount = account.money

        if amount <= 0 then
            print(2.2)
            if Config.Debug then
                print(Locale['infos']['transaction_failed_for']:format(GetPlayerName(source)))
            end
            cb(false)
            return
        end
        print(3)
        cb(true)
    end)
end
