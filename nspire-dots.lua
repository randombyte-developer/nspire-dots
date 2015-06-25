--NspireDots by RandomByte(apps.randombyteqgmail.com; https://github.com/randombyte-developer)

local debug = true

local width, height = 0, 0
local xCenter, yCenter = 0, 0
local window = platform.window

local colors = {
    black = {0, 0, 0}    
}

local boom = {
    startPosX = 60,
    fired = false,
    x = 0,
    y = 0,
    d = 30,
    r = 15,
    speed = 15,
    activeSkin = 0,
    skins = {
        [0] = {
            color = {0, 153, 0},
            nc = {255, 51, 204}
        }
    }
}

local dot = {
    x = 0,
    y = 0,
    d = 30,
    r = 15,
    speed = 0,
    speedMin = 2,
    speedMax = 4.2,
    direction = 0, -- -1 left +1 right 
    hitAnimate = -1,
    spawnBox = {
        left = 40,
        right = 160,
        top = 250,
        bottom = 125
    },
    activeSkin = 0,
    skins = {
        [0] = {
            color = {0, 51, 204}
        }
    }
}

function boom.reset()
    boom.x = boom.startPosX
    boom.y = yCenter
    boom.fired = false
end

function boom.fire()
    boom.fired = true
end

function boom.tick()
    if (boom.fired == true) then
        boom.x = boom.x + boom.speed
        
        --border
        if (boom.x > width) then
            boom.reset()
            dot.spawn()
            c = false
        end
        
        --collision check(rect)
        if (boom.x + boom.r > dot.x and dot.y - dot.r <= boom.y + boom.r and dot.y + dot.r >= boom.y - boom.r) then
            --collision check(circle, Pythagorean theorem)
            if (math.sqrt(
                    ((boom.x - dot.x) * (boom.x - dot.x)) +
                    ((boom.y - dot.y) * (boom.y - dot.y))
                ) <= boom.r + dot.r) then
            
                boom.reset()
                dot.spawn()
                c = true
            end
        end
    end
end

function boom.draw(gc)
    boom.skins[boom.activeSkin].draw(gc)
end

boom.skins[0].draw = function(gc)
    gc:clp(c and boom.skins[0].color or boom.skins[0].nc)
    gc:fillArc(boom.x-boom.r, boom.y-boom.r, boom.d, boom.d, 0, 360)
end

function dot.spawn()
    dot.x = math.random(dot.spawnBox.bottom, dot.spawnBox.top)
    dot.y = math.random(dot.spawnBox.left, dot.spawnBox.right)
    dot.direction = math.random(0, 1) == 0 and -1 or 1
    dot.speed = math.random(dot.speedMin*10, dot.speedMax*10)/10 --to get float values
    hitAnimate = -1
end

dot.skins[0].draw = function(gc)
    gc:clp(dot.skins[0].color)
    gc:fillArc(dot.x-dot.r, dot.y-dot.r, dot.d, dot.d, 0, 360)
end

function dot.tick()
    if (dot.direction == -1) then
        if (dot.y > dot.spawnBox.left) then
            dot.y = dot.y - dot.speed
        else
            dot.direction = 1
            dot.y = dot.y + dot.speed
        end
    elseif (dot.direction == 1) then
        if (dot.y < dot.spawnBox.right) then
            dot.y = dot.y + dot.speed
        else
            dot.direction = -1
            dot.y = dot.y + dot.speed
        end
    end
end

function dot.draw(gc)
    dot.skins[dot.activeSkin].draw(gc)
end

function on.construction()
    intoGC("cl", function(gc, r, g, b) gc:setColorRGB(r, g, b) end) --color
    intoGC("clp", function(gc, color) gc:setColorRGB(unpack(color)) end) --color packed
    timer.start(0.01)
end

function on.resize(w, h)
    width = w
    height = h
    
    xCenter = width/2
    yCenter = height/2
    
    gameStart() --restart whole game to ensure that the positions are correct
end

function on.timer()
    gameTick()
    window:invalidate()
end

function gameStart()
    boom.reset()
end

function on.enterKey()
    boom.fire()
end

function on.charIn(input)
    if (input == "1") then
        dot.spawn()
        boom.reset()
    end
end

function gameTick()
    dot.tick()
    boom.tick()
end

function on.paint(gc)
    if (debug) then
        drawDebug(gc)
    end
    
    boom.draw(gc)
    dot.draw(gc)
end

function drawDebug(gc)
    for i = 0, width, 25 do
            if (i%50 == 0) then
                gc:cl(255, 0, 0)
            else
                gc:cl(0, 0, 100)
            end
            gc:drawLine(i, 0, i, height)
        end
        
        for i = 0, height, 25 do
            if (i%50 == 0) then
                    gc:cl(255, 0, 0)
            else
                    gc:cl(0, 0, 100)
            end
            gc:drawLine(0, i, width, i)
        end
        
        gc:clp(colors.black)
        gc:drawString("d=".. dot.direction ..";speed=".. dot.speed ..";fired=".. (boom.fired and "true" or "false") ..";b.x=".. boom.x, 10, 5)
        
        gc:cl(255, 0, 255)
        gc:drawLine(boom.x, boom.y, dot.x, dot.y)
        gc:cl(0, 255, 0)
        gc:drawLine(boom.x, boom.y, dot.x, boom.y)
        gc:drawLine(dot.x, boom.y, dot.x, dot.y)
end

function intoGC(k, v)
    platform.withGC(getmetatable)[k] = v
end