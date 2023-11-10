Framework = nil
ped = nil
peds = {}

blip = nil
blips = {}

isTransactionActive = false
isTextShowed = false

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
