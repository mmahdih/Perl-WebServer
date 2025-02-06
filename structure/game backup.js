var start;
var play_again;
/// time variables
var startTime = new Date().getTime();
var timerInterval = null;
var elapsedTime = 0;
/// score variables
var score = 0;

// Declare direction globally
let directions = ["left", "up", "right", "down"];
let direction;
console.log(direction);

/// difficulty
var difficulty_level;

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
  difficulty_level = document.getElementById("difficulty").value;
  var difficulty;



  document.onkeydown = function (event) {
    switch (event.keyCode) {
      case 37:
        direction = "left";
        break;
      case 38:
        direction = "up";
        break;
      case 39:
        direction = "right";
        break;
      case 40:
        direction = "down";
        break;
    }
  };

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
  direction = directions[Math.floor(Math.random() * directions.length)];

  // Attach the search button's onclick handler after the DOM is loaded
  document.getElementById("search").onclick = function () {
    var x = document.getElementById("x").value;
    var y = document.getElementById("y").value;

    var cell = document.getElementById("cell-" + x + "-" + y);
    if (cell) {
      cell.style.backgroundColor = "red";
    } else {
      alert("Cell not found!");
    }
  };



  var ball_cell = document.querySelectorAll(".ball")[0];
  var ball = document.querySelectorAll(".ball")[1];

  console.log(document.querySelectorAll(".ball"));

  // getting ball id and position
  var ball_id = ball_cell.id;
  var ball_x = parseInt(ball_id.split("-")[0]);
  var ball_y = parseInt(ball_id.split("-")[1]);

  var ball_last_id = ball_x + "/" + ball_y;

  var snake_position = document.querySelectorAll(".active");
  var snake_id = snake_position[0].id;
  var x = parseInt(snake_id.split("/")[0]);
  var y = parseInt(snake_id.split("/")[1]);

  let snake = [
    { x: x, y: y }
  ]

  var intervalID = setInterval(function () {
    if (direction === "left") {
  
      x -= 1;
      console.log("going to left");
    } else if (direction === "right") {
  
      x += 1;
      console.log("going to right");
    } else if (direction === "up") {
 
      y -= 1;
      console.log("going to up");
    } else if (direction === "down") {
      y += 1;
      console.log("going to down");
    }

    if (x < 0 || x >= 20 || y < 0 || y >= 20) {
      clearInterval(intervalID);
  stopTimer();
  document.getElementById("game-over").style.display = "flex";
  start.style.display = "block";
  start.innerHTML = "Start again";
  return;
    }
    
    var new_id = x + "/" + y;
    if (new_id === snake_last_id) {
      clearInterval(intervalID);
  stopTimer();
  document.getElementById("game-over").style.display = "flex";
  start.style.display = "block";
  start.innerHTML = "Start again";
  return;
    }

    var snake_last_id = snake_position[snake_position.length - 1].id;
    var last_x = parseInt(snake_last_id.split("/")[0]);
    var last_y = parseInt(snake_last_id.split("/")[1]);

    if (new_id === ball_last_id) {
      score += 1;

      snake.push({ x: x, y: y });

      console.log("ball eaten");
      document.getElementById(ball_id).innerHTML = "";
      document.getElementById(ball_id).classList.remove("ball");

      ball_x = Math.floor(Math.random() * 20);
      ball_y = Math.floor(Math.random() * 20);
      var newBall = ball_x + "-" + ball_y;
      console.log("newBall", newBall);
      var newBallCell = document.getElementById(newBall);

      newBallCell.classList.add("ball");
      newBallCell.innerHTML = "🍎";
      ball_last_id = ball_x + "/" + ball_y;
      ball_id = newBall;

      document.getElementById("score").innerHTML = score;
      document.getElementById("game-over-score").innerHTML = score;
    }

    document.getElementById(old_id).classList.remove("active");
    document.getElementById(snake_last_id).classList.remove("active");
    document.getElementById(new_id).classList.add("active");

    old_id = new_id;
  }, difficulty);

  var old_id = x + "/" + y;

  document.getElementById("direction").innerHTML = direction;


}

function failed() {
  clearInterval(intervalID);
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
