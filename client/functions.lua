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