var start;
var play_again;
/// time variables
var startTime = new Date().getTime();
var timerInterval = null;
var elapsedTime = 0;
/// score variables
var score = 0;

// Declare direction globally
let direction = { x: 0, y: 0 }; // Movement direction
console.log("Direction:", direction);

let cols = 20;
let rows = 20;

/// difficulty
var difficulty_level;

// Game Timer
function startTimer() {
  startTime = new Date().getTime();
  timerInterval = setInterval(() => updateTime(), 1000);
}

function stopTimer() {
  if (timerInterval !== null) {
    clearInterval(timerInterval);
    timerInterval = null;
  }
}

function updateTime() {
  if (timerInterval !== null) {
    var currentTime = new Date().getTime();
    var seconds = Math.floor((currentTime - startTime) / 1000);
    var minutes = Math.floor(seconds / 60);
    elapsedTime = seconds;
    var displayTime = pad(minutes) + ":" + pad(seconds % 60);
    document.getElementById("time").innerHTML = displayTime;
    document.getElementById("game-over-time").innerHTML = displayTime;
  }
}
function pad(number) {
  // add a leading zero if the number is less than 10
  return (number < 10 ? "0" : "") + number;
}

function startGame() {
  // Set difficulty level
  difficulty_level = document.getElementById("difficulty").value;
  var difficulty;
  switch (difficulty_level) {
    case "easy":
      difficulty = 200;
      break;
    case "medium":
      difficulty = 130;
      break;
    case "hard":
      difficulty = 90;
      break;
    default:
      difficulty = 100;
  }

  

  let snake = [{ x: 10, y: 10 }];
  let food = spawnFood();

  console.log("snake", snake[0]);
  let x = snake[0].x;
  let y = snake[0].y;

  console.log("x", x, " y", y);
  console.log("food", food);

  function spawnFood() {
    return {
      x: Math.floor(Math.random() * cols),
      y: Math.floor(Math.random() * rows),
    };
  }

  function moveSnake() {
    let head = {
      x: snake[0].x + direction.x,
      y: snake[0].y + direction.y,
    };
    snake.unshift(head);
    if (head.x === food.x && head.y === food.y) {
      score++;
      document.getElementById("score").innerHTML = score;
      document.getElementById("game-over-score").innerHTML = score;
      removeFood(food);
      food = spawnFood();
    } else {
      snake.pop();
    }
  }

  function drawFood() {
    // document.getElementById(food.x + "-" + food.y).classList.add("ball");
    document.getElementById(food.x + "-" + food.y).innerHTML = "🍎";
  }

  function removeFood(food) {
    document.getElementById(food.x + "-" + food.y).innerHTML = "";
  }


  let old_pos = [];

function drawSnake() {
  snake.forEach((segment) => {
    let pos = segment.x + "/" + segment.y;
    if (!old_pos.includes(pos)) {
      old_pos.push(pos);
    }


    let segmentElement = document.getElementById(pos);
    if (segmentElement) {
      segmentElement.classList.add("active");
    }
  });
}

function drawGrid() {
  old_pos.forEach((pos) => {
    if (!snake.some((segment) => `${segment.x}/${segment.y}` === pos)) {
      let segmentElement = document.getElementById(pos);
      if (segmentElement) {
        segmentElement.classList.remove("active");
      }
    }
  });
  old_pos = []; // Clear old positions after updating the grid
}

  // Handle keyboard input and direction
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

  function checkCollision(snake) {
    if (snake[0].x < 0 || snake[0].y < 0 || snake[0].x >= cols || snake[0].y >= rows) {
      stopTimer();
      document.getElementById("game-over").style.display = "flex";
      start.style.display = "block";
      start.innerHTML = "Start again";
      return true;
  }

  for (let i = 1; i < snake.length; i++) {
      if (snake[0].x === snake[i].x && snake[0].y === snake[i].y) {
        stopTimer();
        document.getElementById("game-over").style.display = "flex";
        start.style.display = "block";
        start.innerHTML = "Start again";
        return true;
      }
    }
  }

  function update() {
    if (checkCollision(snake)) {
      failed();
    } else {
      drawGrid();
      
      drawSnake();
      drawFood();
      moveSnake();
    }
  }

  setInterval(update, difficulty);
}

function failed() {
  stopTimer();
  document.getElementById("game-over").style.display = "flex";
  start.style.display = "block";
  start.innerHTML = "Start again";
  return;
}

document.addEventListener("DOMContentLoaded", function () {
  start = document.getElementById("start");
  play_again = document.getElementById("play-again");
  start.onclick = function () {
    start.style.display = "disabeld";
    start.disabled = true;
    startGame();
    startTimer();
  };

  play_again.onclick = function () {
    document.getElementById("game-over").style.display = "none";
    location.reload();
  };
});

// var intervalID = setInterval(function () {

//   drawSnake();
// drawFood();
// moveSnake();

//   var snake_last_id = snake_position[snake_position.length - 1].id;
//   var last_x = parseInt(snake_last_id.split("/")[0]);
//   var last_y = parseInt(snake_last_id.split("/")[1]);

//   if (new_id === ball_last_id) {
//     score += 1;

//     snake.push({ x: x, y: y });

//     console.log("ball eaten");
//     document.getElementById(ball_id).innerHTML = "";
//     document.getElementById(ball_id).classList.remove("ball");

//     ball_x = Math.floor(Math.random() * 20);
//     ball_y = Math.floor(Math.random() * 20);
//     var newBall = ball_x + "-" + ball_y;
//     console.log("newBall", newBall);
//     var newBallCell = document.getElementById(newBall);

//     newBallCell.classList.add("ball");
//     newBallCell.innerHTML = "🍎";
//     ball_last_id = ball_x + "/" + ball_y;
//     ball_id = newBall;

    // document.getElementById("score").innerHTML = score;
    // document.getElementById("game-over-score").innerHTML = score;
//   }

//   document.getElementById(old_id).classList.remove("active");
//   document.getElementById(snake_last_id).classList.remove("active");
//   document.getElementById(new_id).classList.add("active");

//   old_id = new_id;
// }, difficulty);






// Attach the search button's onclick handler after the DOM is loaded
// document.getElementById("search").onclick = function () {
//   var x = document.getElementById("x").value;
//   var y = document.getElementById("y").value;

//   var cell = document.getElementById("cell-" + x + "-" + y);
//   if (cell) {
//     cell.style.backgroundColor = "red";
//   } else {
//     alert("Cell not found!");
//   }
// };
