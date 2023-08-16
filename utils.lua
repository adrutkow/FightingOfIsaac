Utils = {}


function Utils:arrayHas(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

function Utils:numberIsBasicallyX(num, X)
    local epsilon = 0.1
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

return Utils