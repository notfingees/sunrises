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


$stmt  = $conn->prepare("UPDATE planning SET 
lecture = ?,
course_material = ?,
read_assignment = ?,
part_one = ?,
part_two = ?,
part_three = ?,
debug = ?,
submit = ?
WHERE username=?");

if (!$stmt->bind_param("sssssssss", $lecture, $course_material, $read_assignment, $part_one, $part_two, $part_three, $debug, $submit, $username)){
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




$conn->close();

?>
