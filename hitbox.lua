Hitbox = {}

local hitboxSprite = Sprite()
hitboxSprite:Load("hitbox/hitbox.anm2", true)

function Hitbox:new(x, y, w, h, owner, attached)
    owner = owner or nil
    attached = attached or false
    local newObj = {
        x = x,
        y = y,
        w = w,
        h = h,
        owner = owner,
        attached = attached,
        sprite = Sprite()
    }
    return setmetatable(newObj, self)
end

function Hitbox:draw()
    hitboxSprite:Render(Vector(self.x, self.y))
    hitboxSprite:Update()
end

return Hitbox