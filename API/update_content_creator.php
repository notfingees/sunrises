<?php

header('Location: https://apps.apple.com/us/app/sunrises/id1583841201');


$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "aurora";


// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
$creator = $_GET['creator'];

$current_hits = 0;

$sql = "SELECT hits FROM referrals WHERE creator=?";
$stmt = $conn->prepare($sql); 
$stmt->bind_param("s", $creator);
$stmt->execute();
$result = $stmt->get_result();
while ($row = $result->fetch_assoc()) {
    $current_hits = $row['hits'];
}

echo $current_hits;



$ch = intval($current_hits);
$ch = $ch + 1;


$sql = "UPDATE referrals SET hits=? WHERE creator=?";
$stmt = $conn->prepare($sql);
$stmt->bind_param('is', $ch, $creator);
$stmt->execute();







$conn->close();
?>