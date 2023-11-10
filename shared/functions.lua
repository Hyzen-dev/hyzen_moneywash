function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = (string.len(text)) / 370

    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
end

function GenerateBlip(entity)
    local blip = AddBlipForEntity(ped)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Locale['texts']['blipName'])
    EndTextCommandSetBlipName(blip)

    return blip
end

function GetRandomPosition()
    local position = Config.Positions[math.random(1, #Config.Positions)]
    return position
end