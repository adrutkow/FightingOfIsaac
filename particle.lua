Particle = {}

function Particle:new(id, x, y)
    local particleSprite = Sprite()
    particleSprite:Load("misc/hiteffect1.anm2", true)

    local newObj = {
        x = x,
        y = y,
        sprite = particleSprite,
    }
    self.__index = self
    return setmetatable(newObj, self)
end


function Particle:tick()
    self:draw()
    if self.sprite:IsFinished("Idle") then
        print("finished")
        self:kill()
    end
end

function Particle:draw()

    self.sprite:Play("Idle")
    local pos = Isaac.WorldToScreen(Fighters[1].player.Position) + Vector(self.x, self.y)
    self.sprite:Render(pos)
    self.sprite:Update()
end

function Particle:kill()
    table.remove(Particles, 1)
end


return Particle