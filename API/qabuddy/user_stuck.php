<?php
header("Access-Control-Allow-Origin: *");
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "qabuddy";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$username = $_GET['username'];
$stuck_on = $_GET['stuck_on'];
$tried = $_GET['tried'];
$potential_solution = $_GET['potential_solution'];
$question = $_GET['question'];


//$text_message = $_GET['text_message'];

$stmt = $conn->prepare("INSERT INTO stuck (username, stuck_on, tried, potential_solution, question) VALUES (?, ?, ?, ?, ?)");
if (!$stmt->bind_param("sssss", $username, $stuck_on, $tried, $potential_solution, $question)){
    echo $conn->error;
}
else{
    echo "successful1";
}

// set parameters and execute

if (!$stmt->execute()){
    echo $conn->error;
}
else{
    echo "successful1";
}




echo 'success 8';

$conn->close();

?>