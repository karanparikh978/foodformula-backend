namespace :update_restaurant_data do

    desc "Update bhai bhai data"
    task update_bhai_bhai_data: :environment do
        ids = [1411, 1412, 1413, 1414, 1415, 1416, 1417, 1418, 1419, 1420, 1589, 1591, 1592, 1593, 1594, 1595, 1596, 1597, 1598, 1599, 1600, 1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613, 1614, 1615, 1616, 1617, 1618, 1619, 1620, 1621, 1622, 1623, 1624, 1625, 1626, 1627, 1628, 1629, 1630, 1631, 1632, 1633, 1634, 1635, 1636, 1637, 1638, 1639, 1640, 1649, 1650, 1651, 1652, 1653, 1654, 1655, 1656, 1657, 1658, 1659, 1662, 1663, 1664, 1665, 1666, 1667, 1668, 1669, 1670, 1671, 1673, 1674, 1675, 1676, 1677, 1678, 1680, 1681, 1682, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 1691, 1692, 1693, 1694, 1695, 1696, 1697, 1698, 1699, 1700, 1701, 1702]
        recipes = MastersFoodItem.includes(:aliases).where(id: ids)
        recipes.each do |recipe|
            if recipe.id != 1411 && recipe.id != 1412
                p recipe.id
                recipe_name = recipe.name
                new_recipe_name = recipe_name + ' - Oil'
                recipe.name = new_recipe_name
                recipe.save
                recipe_aliases = recipe.aliases
                if recipe_aliases.present?
                    recipe_aliases.each do |ali|
                        if ali.language_id == 1
                            ali_alias = ali.alias + ' - Oil'
                            ali.alias = ali_alias
                            ali.save
                        elsif ali.language_id == 2
                            ali_alias = ali.alias + ' - ઓઇલ'
                            ali.alias = ali_alias
                            ali.save
                        end
                    end
                end
            end
        end
    end

    desc "Update bhai bhai data 2"
    task update_bhai_bhai_data_2: :environment do
        ids = [1413, 1414, 1415, 1416, 1417, 1418, 1419, 1420, 1589, 1591, 1592, 1593, 1594, 1595, 1596, 1597, 1598, 1599, 1600, 1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613, 1614, 1615, 1616, 1617, 1618, 1619, 1620, 1621, 1622, 1623, 1624, 1625, 1626, 1627, 1628, 1629, 1630, 1631, 1632, 1633, 1634, 1635, 1636, 1637, 1638, 1639, 1640, 1649, 1650, 1651, 1652, 1653, 1654, 1655, 1656, 1657, 1658, 1659, 1662, 1663, 1664, 1665, 1666, 1667, 1668, 1669, 1670, 1671, 1673, 1674, 1675, 1676, 1677, 1678, 1680, 1681, 1682, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 1691, 1692, 1693, 1694, 1695, 1696, 1697, 1698, 1699, 1700, 1701, 1702]
        recipes = MastersFoodItem.includes(:aliases,:images,:prices).where(id: ids)
        recipes.each do |recipe|
            p recipe.id
            new_recipe = MastersFoodItem.new
            new_recipe = recipe.dup
            new_recipe.save

            new_recipe_name = new_recipe.name.delete_suffix('Oil')
            new_recipe_name = new_recipe_name + 'Butter'
            new_recipe.name = new_recipe_name
            new_recipe.save

            images = recipe.images
            if images.present?
                images.each do |image|
                    img = EntityImage.new
                    img.entity_type = image.entity_type
                    img.entity_type_id = new_recipe.id
                    img.url = image.url
                    img.status_id = image.status_id
                    img.save
                end
            end

            aliases = recipe.aliases
            if aliases.present?
                aliases.each do |ali|
                    new_ali = FoodItemAlias.new
                    new_ali.language_id = ali.language_id
                    new_ali.food_item_id = new_recipe.id
                    if ali.language_id == 1
                        new_alias = ali.alias.delete_suffix('Oil')
                        new_alias = new_alias + 'Butter'
                    elsif ali.language_id == 2
                        new_alias = ali.alias.delete_suffix('ઓઇલ')
                        new_alias = new_alias + 'બટર'
                    end
                    new_ali.alias = new_alias
                    new_ali.save
                end
            end
            butter_price = FoodItemPrice.where(food_item_id: recipe.id,entity_id: 5).first
            if butter_price.present?
                food_item_price = FoodItemPrice.new
                food_item_price.food_item_id = new_recipe.id
                food_item_price.entity_id = 3
                food_item_price.price = butter_price.price
                food_item_price.save
            end
        end
    end

end
