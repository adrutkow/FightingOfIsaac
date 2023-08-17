Hitbox = {}



function Hitbox:new(rect, owner, attached)
    local hitboxSprite = Sprite()
    hitboxSprite:Load("hitbox/hitbox.anm2", true)

    local newObj = {
        rect = rect,
        owner = owner,
        attached = attached,
        sprite = hitboxSprite
    }
    self.__index = self
    return setmetatable(newObj, self)
end

function Hitbox:draw()
    self.sprite:Play("Idle")

    
    local owner_pos = Isaac.WorldToScreen(self.owner.Position)

    local x = self.rect[1] + owner_pos.X
    local y = self.rect[2] + owner_pos.Y

    local scaleX = self.rect[3] / 10
    local scaleY = self.rect[4] / 10
    self.sprite.Scale = Vector(scaleX,scaleY)


    self.sprite:Render(Vector(x, y))

    print(self.sprite.Position)

    -- PIVOT BOTTOM RIGHT

    

    self.sprite:Update()
end

return Hitbox