Hitbox = {}

Testsprite = Sprite()
Testsprite:Load("hitbox/hitbox.anm2", true)

function Hitbox:new(rect, owner, attached, isHurtbox)
    local hitboxSprite = Sprite()
    hitboxSprite:Load("hitbox/hitbox.anm2", true)

    local newObj = {
        rect = rect,
        owner = owner,
        attached = attached,
        sprite = hitboxSprite,
        isHurtbox = isHurtbox,
        customTag = ""
    }
    self.__index = self
    return setmetatable(newObj, self)
end

function Hitbox:draw()

    if SHOW_HITBOXES == false then
        return
    end

    self.sprite:Play("Idle")

    local owner_pos = Isaac.WorldToScreen(self.owner.player.Position)
    local hbox_pos = Vector(self.rect[1], self.rect[2])

    local x = hbox_pos.X + owner_pos.X
    local y = hbox_pos.Y + owner_pos.Y


    local scaleX = self.rect[3] / 9
    local scaleY = self.rect[4] / 9
    self.sprite.Scale = Vector(scaleX,scaleY)

    if self.isHurtbox == true then
        self.sprite.Color = Color(0, 0, 255)
    else
        self.sprite.Color = Color(255, 0, 0)
    end

    self.sprite:Render(Vector(x, y))
    self.sprite:Update()
end

function Hitbox:getWorldRect()
    local owner_pos = Isaac.WorldToScreen(self.owner.player.Position)
    local hbox_pos = Vector(self.rect[1], self.rect[2])
    local x = hbox_pos.X + owner_pos.X
    local y = hbox_pos.Y + owner_pos.Y

    return {x, y, self.rect[3], self.rect[4]}
end

return Hitbox