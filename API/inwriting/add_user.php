<?php
header("Access-Control-Allow-Origin: *");
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "inwriting";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}


$address = $_POST['address'];

//$text_message = $_GET['text_message'];


$stmt = $conn->prepare("INSERT INTO accounts (address) VALUES (?)");
$stmt->bind_param("s", $address);

// set parameters and execute
$stmt->execute();


$conn->close();

?>