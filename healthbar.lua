HealthBar = {}

function HealthBar:new(fighterIndex)
    local healthsprite = Sprite()
    healthsprite:Load("hitbox/hitbox.anm2", true)

    local newObj = {
        fighterIndex = fighterIndex,
        sprite = healthsprite,
        position = Vector(10, 15),
        size = Vector(100, 10),
        maxValue = 200,
        value = 200,
    }

    self.__index = self
    return setmetatable(newObj, self)
end

function HealthBar:draw()
    self.sprite:Play("Idle")


    local index = self.fighterIndex
    local value = 200

    if Fighters[index] then
        value = Fighters[index].health
    end

    local x = self.position.X
    local y = self.position.Y


    local scaleX = self.size.X / 9
    local scaleY = self.size.Y / 9
    self.sprite.Scale = Vector(scaleX * (value / self.maxValue), scaleY)
    

    if self.fighterIndex == 2 then
        self.sprite.Scale = Vector(-(scaleX * (value / self.maxValue)), scaleY)
        x = x + 460
    end

    if index == 1 then
        Isaac.RenderText(value, x, y, 1, 1, 1, 255)
    else
        Isaac.RenderText(value, x - 18, y, 1, 1, 1, 255)
    end


    self.sprite:Render(Vector(x, y))
    self.sprite:Update()
end