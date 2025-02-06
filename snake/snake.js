const canvas = document.getElementById("gameCanvas");
const ctx = canvas.getContext("2d");

const tileSize = 10; // Size of each grid tile
const rows = canvas.height / tileSize;
const cols = canvas.width / tileSize;

// Snake initial setup
let snake = [{ x: 10, y: 10 }]; // Initial position
let direction = { x: 0, y: 0 }; // Movement direction
let food = spawnFood();
let score = 0;

// Game loop interval
const gameSpeed = 200;

// Spawn food at random position
function spawnFood() {
    return {
        x: Math.floor(Math.random() * cols),
        y: Math.floor(Math.random() * rows)
    };
}

// Draw snake
function drawSnake() {
    ctx.fillStyle = "green";
    snake.forEach(segment => {
        ctx.fillRect(segment.x * tileSize, segment.y * tileSize, tileSize, tileSize);
    });
}

// Draw food
function drawFood() {
    ctx.fillStyle = "red";
    ctx.fillRect(food.x * tileSize, food.y * tileSize, tileSize, tileSize);
}

// Move snake
function moveSnake() {
    const head = { 
        x: snake[0].x + direction.x, 
        y: snake[0].y + direction.y 
    };

    snake.unshift(head);

    // Check if the snake eats the food
    if (head.x === food.x && head.y === food.y) {
        score++;
        food = spawnFood();
    } else {
        snake.pop(); // Remove the tail if no food is eaten
    }
}

// Check for collisions
function checkCollision() {
    const head = snake[0];

    // Check wall collision
    if (head.x < 0 || head.y < 0 || head.x >= cols || head.y >= rows) {
        return true;
    }

    // Check self-collision
    for (let i = 1; i < snake.length; i++) {
        if (head.x === snake[i].x && head.y === snake[i].y) {
            return true;
        }
    }

    return false;
}

// Update game state
function update() {
    if (checkCollision()) {
        alert(`Game Over! Your score: ${score}`);
        resetGame();
    } else {
        ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas
        moveSnake();
        drawSnake();
        drawFood();
    }
}

// Reset game
function resetGame() {
    snake = [{ x: 10, y: 10 }];
    direction = { x: 0, y: 0 };
    score = 0;
    food = spawnFood();
}

// Handle keyboard input
document.addEventListener("keydown", event => {
    switch (event.key) {
        case "ArrowUp":
            if (direction.y === 0) direction = { x: 0, y: -1 };
            break;
        case "ArrowDown":
            if (direction.y === 0) direction = { x: 0, y: 1 };
            break;
        case "ArrowLeft":
            if (direction.x === 0) direction = { x: -1, y: 0 };
            break;
        case "ArrowRight":
            if (direction.x === 0) direction = { x: 1, y: 0 };
            break;
    }
});

// Start the game loop
setInterval(update, gameSpeed);
