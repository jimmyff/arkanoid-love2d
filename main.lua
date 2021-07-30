

width, height = 800, 600
ballRadius = 5
ballX, ballY = width/2, height/2
previousBallX, previousBallY = ballX, ballY
ballVelocityX, ballVelocityY = 4, 4

lavaHeight = 25
paddleSpeed = 10
paddleWidth, paddleHeight = 100, 10
paddleX, paddleY = width/2, height - paddleHeight - lavaHeight

ballStuckOnPaddle = true

lives = 3
score = 0

blockMargin, blockHeight = 60, 20
blockColCount, blockRowCount = 10, 5
blocks = {}
blockWidth = 100 -- This gets calculated later


-- This function happens when game starts
function love.load () 

    success = love.window.setMode(width, height, {})

    -- Little inside joke :)
    love.window.setTitle('SNAKE')

    setupNewGame()
    
end


-- Lets create the blocks for our level
function setupNewGame() 

    -- lets reset the game
    lives = 3
    score = 0
    blocks = {}
    paddleX = width / 2
    ballStuckOnPaddle = true

    -- lets create the blocks
    local blocksWidth = width - (blockMargin * 2)
    blockWidth = (blocksWidth / blockColCount) - 1

    -- itterate over each block column and row and make a block
    for x = 0, blockColCount - 1 do        
        for y = 0, blockRowCount - 1 do
            local blockX = blockMargin + (x * (blockWidth + 1))
            local blockY = blockMargin + (y * (blockHeight + 1))
            table.insert(blocks, {blockX, blockY})
        end
    end
end

-- Check block collisions - oh no! This is the scary bit!
function checkBlockCollisions() 

    -- itterate over each block and check for collision§
    for k, block in pairs(blocks) do
        
        if  ballX + ballRadius >= block[1] and
            ballX - ballRadius <= block[1] + blockWidth and
            ballY + ballRadius >= block[2] and
            ballY - ballRadius <= block[2] + blockHeight then

                score = score + 100

                -- the ball has colided with the block!
                -- which direction to bounce?

                -- are we bouncing off one of the left or right sides?
                if previousBallX - ballRadius <= block[1] or 
                    previousBallX + ballRadius >= block[1] + blockWidth then
                   ballVelocityX = -ballVelocityX     
                end

                -- are we bouncing off one of the top or bottom sides?
                if previousBallY - ballRadius <= block[2] or 
                previousBallY + ballRadius >= block[2] + blockHeight then
                   ballVelocityY = -ballVelocityY     
                end

            -- this removes the block from our game
            table.remove(blocks, k)

        end

    end
    
end



-- This function happens at the start of the game loop
function love.update (dt)

    previousBallX, previousBallY = ballX, ballY

    -- Keyboard control here
    if love.keyboard.isDown('left') then
        paddleX = paddleX - paddleSpeed
    end
    if love.keyboard.isDown('right') then
        paddleX = paddleX + paddleSpeed
    end
    if love.keyboard.isDown('space') and ballStuckOnPaddle == true then
        ballStuckOnPaddle = false
        if ballVelocityY > 0 then
            ballVelocityY = -ballVelocityY
        end
    end

    if paddleX - (paddleWidth/2) < 0 then
        paddleX = paddleWidth/2
    end

    if paddleX + (paddleWidth/2) > width then
        paddleX = width - (paddleWidth/2)
    end

    -- Ball code
    if ballStuckOnPaddle then
        ballX = paddleX
        ballY = paddleY - (paddleHeight / 2)
    else
        -- Ball physics here
        ballX = ballX + ballVelocityX
        ballY = ballY + ballVelocityY

        if (ballY + ballRadius) >= height or (ballY - ballRadius) <= 0 then
            ballVelocityY = -ballVelocityY
        end
        if (ballX + ballRadius) >= width or (ballX - ballRadius) <= 0 then
            ballVelocityX = -ballVelocityX
        end

        -- Has the ball collided with the paddle
        if  ballX + ballRadius >= paddleX - (paddleWidth/2) and
            ballX - ballRadius <= paddleX + (paddleWidth/2) and
            ballY + ballRadius >= paddleY - (paddleHeight/2) and
            ballY - ballRadius <= paddleY + (paddleHeight/2) and 
            ballVelocityY > 0 then

            -- put the ball on the paddle and reverse Y velocity
            ballY = paddleY - paddleHeight / 2
            ballVelocityY = -ballVelocityY
            score = score + 10
         
            -- Has the ball landed in the lava
            else if ballY + ballRadius > height - lavaHeight then
                lives = lives - 1
                ballStuckOnPaddle = true
            end

        end

        -- Has the ball collided with the blocks?
        checkBlockCollisions()

    end


    -- is it game over?
    if lives <= 0 then
        setupNewGame()
    end

    -- has the player won the game?
    if #blocks == 0 then
        setupNewGame()
    end


end


-- This function happens after the update function
function love.draw () 

    -- draw ui
    love.graphics.setColor(1, 1, 1)
    love.graphics.print('Lives: ' .. lives, 10, 10)
    love.graphics.print('Score: ' .. score, 10, 30)

    -- lets draw our lava!!
    love.graphics.setColor(1, 0.3, 0, 1)
    love.graphics.rectangle('fill', 0, height - lavaHeight, width, height)    

    -- lets draw the ball
    love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.print(ballX ..' x ' .. ballY, 10, 10)
    love.graphics.circle('fill', ballX, ballY, ballRadius)

    -- lets draw the paddle
    love.graphics.setColor(0, 0.8, 1, 1)
    love.graphics.rectangle('fill', paddleX - (paddleWidth/2), paddleY, paddleWidth, paddleHeight)


    -- lets draw the blocks! yay!!
    love.graphics.setColor(0.2, 0.9, 0.08)
    for k, block in pairs(blocks) do
        love.graphics.rectangle('fill', block[1], block[2], blockWidth, blockHeight)
    end

end