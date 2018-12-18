require("linalg")

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
perl.xscale,perl.yscale = 1200,600
perl.boxsizex,perl.boxsizey = 0,0
perl.meteor_n = 1000
perl.flow_speed = 5
perl.internal_counter = 0

function perl:getDims(w,h)
        perl.xdim, perl.ydim = w, h
        perl.boxsizex = perl.xdim/perl.xscale
        perl.boxsizey = perl.ydim/perl.yscale
end

function perl:init()
        perl.grid = getmat( math.floor(perl.xdim/perl.xscale) + 1, math.floor(perl.ydim/perl.yscale) + 1 )
        perl:reset()

        perl.meteors = getmat(perl.meteor_n,1)
        for i = 1,#perl.meteors do
                perl.meteors[i] = {}
                perl.meteors[i].x,perl.meteors[i].y = math.random()*perl.xdim,math.random()*perl.ydim
                perl.meteors[i].xp,perl.meteors[i].yp = perl.meteors[i].x,perl.meteors[i].y
        end
        
end

function perl:distributeGradients()
        for i = 1,#perl.grid do
                for j = 1,#perl.grid[i] do
                        -- METHOD ONE: by canonical directions
                        -- local pick = math.random(1,8)
                        -- perl.grid[i][j] = canonicals[pick]

                        -- METHOD TWO: ABSOLUTE CHAOS
                        perl.grid[i][j] = perl:getRandomUnit()
                end
        end
end

-- PRECONDITION: x,y has to be within the screen!
function perl:getNoise(x,y)
        
        local heads_x, heads_y = math.floor(x/perl.xscale), math.floor(y/perl.yscale)
        local tails_x, tails_y = x - heads_x*perl.xscale, y - heads_y*perl.yscale

        local A = normalize({-tails_x,-tails_y})
        local B = normalize({perl.boxsizex-tails_x,-tails_y})
        local C = normalize({-tails_x,perl.boxsizey-tails_y})
        local D = normalize({perl.boxsizex-tails_x,perl.boxsizey-tails_y})

        local del_A = dot(A, perl.grid[heads_x+1][heads_y+1])
        local del_B = dot(B, perl.grid[heads_x+2][heads_y+1])
        local del_C = dot(C, perl.grid[heads_x+1][heads_y+2])
        local del_D = dot(D, perl.grid[heads_x+2][heads_y+2])

        local interpolated = (del_A+del_B+del_C+del_D)/4

        return interpolated
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
end

function perl:draw()

        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(scene)

end

function perl:update(dt,frames)

        if (perl.internal_counter % 30 == 0) then
                perl.meteor_n = perl.meteor_n + 1
                perl.meteors[perl.meteor_n] = {}
                perl.meteors[perl.meteor_n].x,perl.meteors[perl.meteor_n].y = math.random()*perl.xdim,math.random()*perl.ydim
                perl.meteors[perl.meteor_n].xp,perl.meteors[perl.meteor_n].yp = perl.meteors[perl.meteor_n].x,perl.meteors[perl.meteor_n].y
        end

        for i,_ in pairs(perl.meteors) do
                local turn = perl:getNoise(perl.meteors[i].x,perl.meteors[i].y)*2*math.pi -- radians
                perl.meteors[i].xp = perl.meteors[i].x
                perl.meteors[i].yp = perl.meteors[i].y

                perl.meteors[i].x = perl.meteors[i].xp + perl.flow_speed*(math.cos(turn))
                perl.meteors[i].y = perl.meteors[i].yp + perl.flow_speed*(math.sin(turn))
                if (    (perl.meteors[i].x < 0) or (perl.meteors[i].x > perl.xdim) or 
                        (perl.meteors[i].y < 0) or (perl.meteors[i].y > perl.ydim)
                ) then
                        perl.meteors[i] = {}
                        perl.meteors[i].x,perl.meteors[i].y = math.random()*perl.xdim,math.random()*perl.ydim
                        perl.meteors[i].xp,perl.meteors[i].yp = perl.meteors[i].x,perl.meteors[i].y
                end
        end

        love.graphics.setCanvas(scene)
                love.graphics.setColor(perl.internal_counter/512,perl.internal_counter/32,perl.internal_counter,0.1)
                for _,star in pairs(perl.meteors) do
                        love.graphics.line(star.x,star.y,star.xp,star.yp)
                end
        love.graphics.setCanvas()

        perl.internal_counter = perl.internal_counter + 1
end

function perl:getRandomUnit()
        local vec = {math.random()*(math.random()-0.5),math.random()*(math.random()-0.5)}
        
        for i in ipairs(vec) do
                vec[i] = vec[i]/norm(vec)
        end

        return vec
end

return perl