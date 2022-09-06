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
$lecture = $_GET['lecture'];
$course_material = $_GET['course_material'];
$read_assignment = $_GET['read_assignment'];
$part_one = $_GET['part_one'];
$part_two = $_GET['part_two'];
$part_three = $_GET['part_three'];
$debug = $_GET['debug'];
$submit = $_GET['submit'];

//$text_message = $_GET['text_message'];

$stmt = $conn->prepare("INSERT INTO daily (username, lecture, course_material, read_assignment, part_one, part_two, part_three, debug, submit) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
if (!$stmt->bind_param("sssssssss", $username, $lecture, $course_material, $read_assignment, $part_one, $part_two, $part_three, $debug, $submit)){
    echo $conn->error;
}
else{
    echo "successful1";
}

// set parameters and execute
$stmt->execute();




echo 'success 7';

$conn->close();

?>