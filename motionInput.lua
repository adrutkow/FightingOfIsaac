MotionInput = {}

DIRECTIONS = {
    UP = 1,
    DOWN = 2,
    LEFT = 3,
    RIGHT = 4,
}


function MotionInput:new(direction)

    local newObj = {
        direction = direction,
        timer = 0,
        max_time = 30,
    }

    self.__index = self
    return setmetatable(newObj, self)
end



return MotionInput