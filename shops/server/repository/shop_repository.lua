local ShopRepository = {}


function ShopRepository:getAllShops()
    local result = MySQL.query.await('SELECT * FROM shops')
    return result or {}
end


function ShopRepository:getShopItems(shopId)
    local result = MySQL.query.await('SELECT * FROM shop_items WHERE shop_id = ?', { shopId })
    return result or {}
end


function ShopRepository:getStatistics(shopId)
    local result = MySQL.query.await('SELECT * FROM shop_statistics WHERE shop_id = ?', { shopId })
    return result[1] or {}
end


function ShopRepository:updateItemStock(shopId, itemName, stock)
    return MySQL.update.await(
        'UPDATE shop_items SET stock = ? WHERE shop_id = ? AND name = ?',
        { stock, shopId, itemName }
    )
end


function ShopRepository:addTransaction(data)
    return MySQL.insert.await(
        'INSERT INTO shop_transactions (shop_id, player_identifier, player_name, item_name, quantity, total_price, final_price) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            data.shopId,
            data.playerIdentifier,
            data.playerName,
            data.itemName,
            data.quantity,
            data.totalPrice,
            data.finalPrice
        }
    )
end


function ShopRepository:clearAllCache()

end

return ShopRepository
