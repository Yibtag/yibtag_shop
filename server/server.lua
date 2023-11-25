local QBCore = exports['qb-core']:GetCoreObject()

--#region Stratup

Citizen.CreateThread(function ()
    MySQL.query.await(
        "CREATE TABLE IF NOT EXISTS `yibtag_shop` (`id` INT NOT NULL, `date` INT, `owner` VARCHAR(255), `item` VARCHAR(255), `amount` INT, `price` FLOAT, PRIMARY KEY (`id`));"
    )
end)

--#endregion

--#region Events

RegisterNetEvent("yibtag_shop:server:open", function ()
    local source = source
    local lisence = QBCore.Functions.GetIdentifier(source, 'license')

    TriggerClientEvent("yibtag_shop:client:open", source, lisence)
end)

RegisterNetEvent("yibtag_shop:server:create", function (item, amount, price)
    local source = source

    -- Create and verify lisence
    local owner = QBCore.Functions.GetIdentifier(source, 'license')

    -- Create date object
    local date = os.time()

    -- Verifying item and amount
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "Cannot get player information!")
        return
    end

    -- Removing the items
    if not Player.Functions.RemoveItem(item, amount) then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "You dont have the items youre trying to sell!")
        return
    end

    MySQL.insert.await('INSERT INTO `yibtag_shop` (date, owner, item, amount, price) VALUES (?, ?, ?, ?, ?)', {
        date, owner, item, amount, price
    })

    TriggerClientEvent("yibtag_shop:client:success_message", source, "Successfuly listed the item!")
end)

RegisterNetEvent("yibtag_shop:server:fetch", function ()
    local source = source

    local response = MySQL.query.await("SELECT * FROM `yibtag_shop`")

    if not response then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "Unable to query the database!")
        return
    end

    TriggerClientEvent("yibtag_shop:client:fetch", source, response)
end)

RegisterNetEvent("yibtag_shop:server:buy", function (id)
    local source = source

    local listings = MySQL.query.await(
        "SELECT * FROM `yibtag_shop` WHERE `id` = ?", {
        id
    })

    if not listings then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "The listing you are trying to purchase doesent exist!")
        return
    end

    local listing = listings[1]

    if not listing then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "The listing you are trying to purchase doesent exist!")
        return
    end

    local item, amount, price in listing

    if not (item or amount or price) then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "Invalid listing information!")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "Unable to get player information!")
        return
    end

    if not Player.Functions.RemoveMoney("bank", price) then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "Could not charge you!")
        return
    end

    if not Player.Functions.AddItem(item, amount) then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "Failed to give you item!")
        return
    end

    MySQL.update.await("DELETE FROM `yibtag_shop` WHERE `id` = ?", {
        id
    })

    TriggerClientEvent("yibtag_shop:client:success_message", source, "Successfuly bought the item!")
end)

RegisterNetEvent("yibtag_shop:server:cancel", function (id)
    local source = source

    local listings = MySQL.query.await(
        "SELECT * FROM `yibtag_shop` WHERE `id` = ?", {
        id
    })

    if not listings then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "The listing you are trying to purchase doesent exist!")
        return
    end

    local listing = listings[1]

    if not listing then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "The listing you are trying to purchase doesent exist!")
        return
    end

    local item, amount, owner in listing

    if not (item or amount or owner) then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "Invalid listing information!")
        return
    end

    local lisence = QBCore.Functions.GetIdentifier(source, 'license')

    if not owner == lisence then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "You dont own this listing!")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "Unable to get player information!")
        return
    end

    if not Player.Functions.AddItem(item, amount) then
        TriggerClientEvent("yibtag_shop:client:error_message", source, "Failed to give you item!")
        return
    end

    MySQL.update.await("DELETE FROM `yibtag_shop` WHERE `id` = ?", {
        id
    })

    TriggerClientEvent("yibtag_shop:client:success_message", source, "Successfuly canceled the listing!")
end)

--#endregion