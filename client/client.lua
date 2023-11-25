local QBCore = exports['qb-core']:GetCoreObject()

--#region Commands

RegisterCommand("shop", function ()
    TriggerServerEvent("yibtag_shop:server:open")
end)

--#endregion

--#region NUI-Callbacks

RegisterNuiCallback("open", function (data, callback)
    SetNuiFocus(true, true)
end)

RegisterNuiCallback("close", function (data, callback)
    SetNuiFocus(false, false)
end)

RegisterNuiCallback("create", function (data, callback)
    -- The rest of data is calculated on the server
    local item = tostring(data.item)
    local amount = tonumber(data.amount)
    local price = tonumber(data.price)

    TriggerServerEvent("yibtag_shop:server:create", item, amount, price)
end)

RegisterNUICallback("fetch", function (data, callback)
    TriggerServerEvent("yibtag_shop:server:fetch")
end)

RegisterNuiCallback("buy", function (data, callback)
    local id = tonumber(data.id)

    TriggerServerEvent("yibtag_shop:server:buy", id)
end)

RegisterNuiCallback("cancel", function (data, callback)
    local id = tonumber(data.id)

    TriggerServerEvent("yibtag_shop:server:cancel", id)
end)

--#endregion

--#region Events

RegisterNetEvent("yibtag_shop:client:open", function (lisence)
    SendNUIMessage({
        type="open",
        lisence=lisence
    })
end)

RegisterNetEvent("yibtag_shop:client:error_message", function (message)
    QBCore.Functions.Notify(
        message,
        "error",
        5000
    )
end)

RegisterNetEvent("yibtag_shop:client:success_message", function (message)
    QBCore.Functions.Notify(
        message,
        "success",
        5000
    )
end)

RegisterNetEvent("yibtag_shop:client:fetch", function (items)
    SendNUIMessage({
        type="fetch",
        items=items
    })
end)

--#endregion