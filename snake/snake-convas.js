const canvas = document.getElementById("gameCanvas");
const context = canvas.getContext("2d");

const tileSize = 20; // Size of each grid tile
const rows = canvas.height / tileSize;
const cols = canvas.width / tileSize;

let snake = [{ x: 10, y: 10 }]; // Initial position
let direction = { x: 0, y: 0 }; // Movement direction
let food = spawnFood();
let score = 0;

// Game loop interval
const gameSpeed = 200;

console.log(direction);

function spawnFood() {
  return {
    x: Math.floor(Math.random() * cols),
    y: Math.floor(Math.random() * rows),
  };
}
function drawFood() {
  context.fillStyle = "red";
  context.fillRect(food.x * tileSize, food.y * tileSize, tileSize, tileSize);
}

function drawSnake() {
  context.fillStyle = "green";
  snake.forEach((segment) => {
    context.fillRect(
      segment.x * tileSize,
      segment.y * tileSize,
      tileSize,
      tileSize
    );
  });
}


function moveSnake() {
  const head = { x: snake[0].x + direction.x, y: snake[0].y + direction.y };
  snake.unshift(head);
  if (head.x === food.x && head.y === food.y) {
    score++;
    food = spawnFood();
  } else {
    snake.pop();
  }
}



function checkCollision () {
    if (snake[0].x < 0 || snake[0].y < 0 || snake[0].x >= cols || snake[0].y >= rows) {
        return true;
    }

    for (let i = 1; i < snake.length; i++) {
        if (snake[0].x === snake[i].x && snake[0].y === snake[i].y) {
            return true;
        }
    }
}


function update() {
    if (checkCollision()) {
        alert(`Game Over! Your score: ${score}`);
        resetGame();
    } else {
        context.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas
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

document.addEventListener("keydown", (event) => {
  switch (event.key) {
    case "ArrowUp":
      if (direction.y === 0) direction = { x: 0, y: -1 };
      console.log(direction);
      break;
    case "ArrowDown":
      if (direction.y === 0) direction = { x: 0, y: 1 };
      console.log(direction);
      break;
    case "ArrowLeft":
      if (direction.x === 0) direction = { x: -1, y: 0 };
      console.log(direction);
      break;
    case "ArrowRight":
      if (direction.x === 0) direction = { x: 1, y: 0 };
      console.log(direction);
      break;
  }
});

setInterval(update, gameSpeed);

// # draw a rectangle
// ctx.fillStyle = "rgb(200 0 0)";
// ctx.fillRect(10, 10, 100, 100);

// ctx.clearStyle = "rgb(0 0 200 / 50%)";
// ctx.clearRect(25, 25, 70, 70);

// ctx.strokeStyle = "rgb(200 0 0)";
// ctx.strokeRect(30, 30, 60, 60);

// # draw a triangle
// ctx.beginPath();
// ctx.moveTo(75, 50);
// ctx.lineTo(100, 75);
// ctx.lineTo(100, 25);
// ctx.fill();

// # draw a smiley face
// ctx.beginPath();
// ctx.arc(75, 75, 60, 0 , Math.PI * 2, true);
// ctx.moveTo(110, 75);
// ctx.arc(75, 75, 35, 0, Math.PI, false);
// ctx.moveTo(65, 65);
// ctx.arc(60, 65, 5, 0, Math.PI * 2, true);
// ctx.moveTo(95, 65);
// ctx.arc(90, 65, 5, 0, Math.PI * 2, true);
// ctx.stroke();

// ctx.beginPath();
// ctx.arc(100, 100, 50, Math.PI / 9, Math.PI * 2, false);
// ctx.stroke();

// for (let i = 0; i < 4; i++) {
//     for (let j = 0; j < 3; j++) {
//       ctx.beginPath();
//       const x = 70 + j * 130; // x coordinate
//       const y = 70 + i * 130; // y coordinate
//       const radius = 50; // Arc radius
//       const startAngle = 0; // Starting point on circle
//       const endAngle = Math.PI + (Math.PI * j) / 2; // End point on circle
//       const counterclockwise = i % 2 !== 0; // clockwise or counterclockwise

//       ctx.arc(x, y, radius, startAngle, endAngle, counterclockwise);

//       if (i > 1) {
//         ctx.fill();
//       } else {
//         ctx.stroke();
//       }
//     }
//   }

// Quadratic curves example
// The quadraticCurveTo() method creates a quadratic Bezier curve from the current canvas position to the specified point.
// The first set of coordinates (x1, y1) is the first control point, and the second set of coordinates (x2, y2) is the second control point.
// The third set of coordinates (x, y) is the ending point of the curve.
// The curve starts at the current position and ends at (x, y), with (x1, y1) and (x2, y2) as control points.
// ctx.beginPath();
// ctx.moveTo(75, 25);
// ctx.quadraticCurveTo(25, 25, 25, 62.5); // curve from (75, 25) to (25, 62.5) with control point (25, 25)
// ctx.quadraticCurveTo(25, 100, 50, 100); // curve from (25, 62.5) to (50, 100) with control point (25, 100)
// ctx.quadraticCurveTo(50, 120, 30, 125); // curve from (50, 100) to (30, 125) with control point (50, 120)
// ctx.quadraticCurveTo(60, 120, 65, 100); // curve from (30, 125) to (65, 100) with control point (60, 120)
// ctx.quadraticCurveTo(125, 100, 125, 62.5); // curve from (65, 100) to (125, 62.5) with control point (125, 100)
// ctx.quadraticCurveTo(125, 25, 75, 25); // curve from (125, 62.5) to (75, 25) with control point (125, 25)
// ctx.fill();

// roundedRect(ctx, 12, 12, 500, 350, 15, 'stroke');
// roundedRect(ctx, 27, 27, 470, 320, 15, 'stroke');
// roundedRect(ctx, 120, 120, 140, 80, 15, 'stroke');
// roundedRect(ctx, 350, 200, 60, 140, 25, 'stroke');

// ctx.beginPath();
// ctx.arc(75, 75, 30, Math.PI / 7, -Math.PI / 7, false);
// ctx.lineTo(75, 75);
// ctx.fill();

// for (let i = 0; i < 8; i++) {
//     ctx.fillRect(120 + i * 40, 70, 10, 10);
// }

// for (let i = 0; i < 6; i++) {
//     ctx.fillRect(300 , 110 + i * 40, 10, 10);
// }

// ctx.strokeStyle='black';
// ctx.strokeRect(20, 20 , 500, 350);

// ctx.strokeStyle='black';
// ctx.strokeRect(35, 35 , 470, 320);

// function roundedRect(ctx, x, y, width, height, radius, style) {
//     ctx.beginPath();
//     ctx.moveTo(x + radius, y);
//     ctx.lineTo(x + width - radius, y);
//     ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
//     ctx.lineTo(x + width, y + height - radius);
//     ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
//     ctx.lineTo(x + radius, y + height);
//     ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
//     ctx.lineTo(x, y + radius);
//     ctx.quadraticCurveTo(x, y, x + radius, y);

//     if (style === 'fill') {
//         ctx.fill();
//     } else if (style === 'stroke') {
//         ctx.stroke();
//     }
// }
