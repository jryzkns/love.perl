require("linalg")

-- idea: each star gets its own internal counter, so new stars will be dark instead of very white

local canonicals =    {
                        {0,-1},
                        {math.sqrt(2)/2,-math.sqrt(2)/2},
                        {1,0},
                        {math.sqrt(2)/2,math.sqrt(2)/2},
                        {0,1},
                        {-math.sqrt(2)/2,math.sqrt(2)/2},
                        {-1,0},
                        {-math.sqrt(2)/2,-math.sqrt(2)/2}
                }

local perl = {}

perl.xdim,perl.ydim = 0,0
perl.xscale,perl.yscale = 600,600 -- needs to be divisors of 1200 and 600 lol
perl.meteor_n = 1000
perl.flow_speed = 5
perl.internal_counter = 0

function perl:getDims(w,h) perl.xdim, perl.ydim = w, h end

function perl:init()
        perl.grid = getmat( math.floor(perl.xdim/perl.xscale) + 1, math.floor(perl.ydim/perl.yscale) + 1 )
        perl:reset()
        perl.meteors = getmat(perl.meteor_n,1)
        for i = 1,#perl.meteors do perl.meteors[i] = perl:newStar() end
end

function perl:newStar()
        local new_star = {}
        new_star.x, new_star.y = math.random()*perl.xdim,math.random()*perl.ydim
        new_star.xp, new_star.yp = new_star.x, new_star.y
        return new_star
end

function perl:distributeGradients()
        for i = 1,#perl.grid do
                for j = 1,#perl.grid[i] do
                        -- -- METHOD ONE: by canonical directions
                        -- local pick = math.random(1,8)
                        -- perl.grid[i][j] = canonicals[pick]

                        -- METHOD TWO: ABSOLUTE CHAOS
                        perl.grid[i][j] = perl:getRandomUnit()
                end
        end
end

-- what if x,y are right on the boundaries?m
function perl:getNoise(x,y)
        
        -- grab indices of the nearest floored noise vector cell
        local heads_x, heads_y = math.floor(x/perl.xscale), math.floor(y/perl.yscale)
        
        -- x,y proportions away from the nearest floored noise vector cell
        local tails_x = perl:ease((x - heads_x*perl.xscale)/perl.xscale)
        local tails_y = perl:ease((y - heads_y*perl.yscale)/perl.yscale)

        local A = normalize({tails_x,tails_y})
        local B = normalize({tails_x - 1, tails_y})
        local C = normalize({tails_x,tails_y - 1})
        local D = normalize({tails_x - 1, tails_y - 1})
        
        local del_A = dot(A, perl.grid[heads_x+1][heads_y+1])
        local del_B = dot(B, perl.grid[heads_x+2][heads_y+1])
        local del_C = dot(C, perl.grid[heads_x+1][heads_y+2])
        local del_D = dot(D, perl.grid[heads_x+2][heads_y+2])
        
        -- bilinear interpolation
        x1 =                    perl:lerp(del_A,del_B,tails_x/perl.xscale)
        x2 =                    perl:lerp(del_C,del_D,tails_x/perl.xscale)
        local interpolated =    perl:lerp(x1,x2,tails_y/perl.yscale)
        
        -- naive marginalization
        -- local interpolated = (del_A+del_B+del_C+del_D)/4

        return interpolated
end

function perl:lerp(a,b,t) return a * (1-t) + b * t end

function perl:ease(t)
        return (t * t * t * (t * (t * 6 - 15) + 10))
end

function perl:keypressed(key,scancode,isrepeat)
        if key == "a" then
                perl:reset()
        elseif key == "up" then
                perl.flow_speed = perl.flow_speed + 1
        elseif key == "down" then
                perl.flow_speed = perl.flow_speed - 1
        end
end

function perl:reset()
        perl:distributeGradients()
        scene = love.graphics.newCanvas(perl.xdim,perl.ydim)
        perl.internal_counter = 0
        perl.meteors = getmat(perl.meteor_n,1)
        for i = 1,#perl.meteors do perl.meteors[i] = perl:newStar() end
end

function perl:draw()
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(scene)

        -- debugging color circle
        -- local current = perl:getColor(perl.internal_counter)
        -- love.graphics.setColor(current[1],current[2],current[3],1)
        -- love.graphics.circle("fill",0,0,50)
end

function perl:update(dt,frames)

        for i,_ in pairs(perl.meteors) do
                local step_direction = perl:getNoise(perl.meteors[i].x,perl.meteors[i].y)*2*math.pi
                -- if (step_direction > 2*math.pi) then print("wtf") end
                perl.meteors[i].xp, perl.meteors[i].yp = perl.meteors[i].x, perl.meteors[i].y
                perl.meteors[i].x = perl.meteors[i].xp + perl.flow_speed * math.cos(step_direction)
                perl.meteors[i].y = perl.meteors[i].yp + perl.flow_speed * math.sin(step_direction)
                if (    (perl.meteors[i].x < 0) or (perl.meteors[i].x > perl.xdim) or 
                        (perl.meteors[i].y < 0) or (perl.meteors[i].y > perl.ydim)
                ) then perl.meteors[i] = perl:newStar() end
        end

        love.graphics.setCanvas(scene)
                local color = perl:getColor(perl.internal_counter)
                love.graphics.setColor(color[1],color[2],color[3],0.1)
                for _,star in pairs(perl.meteors) do love.graphics.line(star.x,star.y,star.xp,star.yp) end
        love.graphics.setCanvas()

        perl.internal_counter = perl.internal_counter + 1
end

-- we need a spicy coloring function
function perl:getColor(frame)

        local t = frame/10

        -- -- original
        local r = frame/1000
        local g = frame/100
        local b = frame/10

        -- -- this thing gives me the pumping sensation
        -- local r = (math.sin(t)+1)/2
        -- local g = (math.cos(t)+1)/2
        -- local b = 0.1

        return {r,g,b}
end

function perl:getRandomUnit()
        local direction = math.random()*2*math.pi
        return {math.cos(direction), math.sin(direction)}
end

return perl
