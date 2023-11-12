-- TODO : Translate
Lang = {}
Config = {}

Config.Lang = 'en' -- 'fr' or 'en'
Config.Framework = 'qbcore' -- 'qbcore' or 'esx'
Config.UseTarget = false -- GetConvar('UseTarget', 'false') == 'true' -- If you don't have Convar in server.cfg, add it

Config.NpcsModels = { -- https://wiki.rage.mp/index.php?title=Peds
    "a_m_m_bevhills_01",
    "a_m_m_bevhills_02",
    "a_m_m_business_01",
    "a_m_m_eastsa_01",
    "a_m_m_eastsa_02",
    "a_m_m_farmer_01"
}

Config.Money = {
    BlackMoneyType = 'virtual', -- 'virtual' or 'item'
    BlackMoneyName = 'black_money', -- 'cash', 'black_money', 'bank', 'crypto' for qb-core and 'money', 'black_money', 'bank' for esx
    CashType = 'virtual', -- 'virtual' or 'item'
    CashName = 'cash', -- 'cash', 'black_money', 'bank', 'crypto' for qb-core and 'money', 'black_money', 'bank' for esx
    Percentage = {
        Min = 50,
        Max = 100
    }
}

Config.NpcTextType = '3d' -- '3d' or '2d' (useless if Config.UseTarget is true)

Config.DespawnIfPlayerAround = false -- if true, will despawn the npc if a player is around
Config.DespawnDistance = 15 -- in meters

Config.TransactionDuration = 15 -- in seconds

Config.IsNpcRotating = false -- if true, the npc will be rotating between the positions
Config.NpcRotatingTime = 10 -- in seconds

Config.Debug = true -- if true, will print some debug messages

Config.SpawnAtAllPositions = true -- if true, will spawn the npc at all positions (need to set Config.IsNpcRotating to false)

Config.Positions = {
    {
        position = vector4(255.54, -640.58, 40.28, 351.84),
        showBlip = true
    },
    {
        position = vector4(256.43, -636.67, 40.59, 337.3),
        showBlip = true
    },
    {
        position = vector4(252.05, -637.24, 40.32, 134.29),
        showBlip = true
    }
}
