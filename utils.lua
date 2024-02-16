Utils = {}


function Utils:arrayHas(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

function Utils:getIndexInArray(array, value)
    local index = 1
    for i, v in ipairs(array) do
        if v == value then
            return index
        end
        index = index + 1
    end
    return -1

end

function Utils:numberIsBasicallyX(num, X)
    local epsilon = 0.25
    return (X - epsilon) < num and num < (X + epsilon)
end

function Utils:getPlayerID(entityPlayer)
    for i = 0, #Game():GetNumPlayers() do
        if entityPlayer == Game():GetPlayer(i) then
            return i
        end
    end
end

---comment
---@param entityPlayer EntityPlayer
function Utils:getFighterFromPlayer(entityPlayer)
    local playerID = entityPlayer.ControllerIndex
    for i = 1, #Fighters do
        if Fighters[i].playerID == playerID then
            return Fighter[i]
        end
    end
end

function GetTableKeys(tab)
    for k,v in pairs(tab) do
        print(k)
    end
end

function RectCollide(rect1, rect2)
    local x1, y1, w1, h1 = rect1[1], rect1[2], rect1[3], rect1[4]
    local x2, y2, w2, h2 = rect2[1], rect2[2], rect2[3], rect2[4]

    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 - h1 < y2 and
           y1 > y2 - h2
end

return Utils