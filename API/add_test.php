<?php
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
/*
$sql = "DELETE FROM user_interests WHERE interest_id=3";

if ($conn->query($sql) === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}
*/
/*
$sql = "INSERT INTO user_notifications (user_id, today_notification, tomorrow_notification)
VALUES ('1', 'Day 8 of BestNess\' tournament streak, Sunday, and new music from toastydigital', 'Getting a mango smoothie, Illumina1337\'s 1.16 rsg speedrun or reset stream, Day 3 of chess tournament Pogchamps 3')";
*/
$sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name)
VALUES ('1', 'Should get deleted because in the past', 'gaming', '2', '26.07.21', 'TEST')";

if ($conn->query($sql) === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

$sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name)
VALUES ('1', 'Should get downloaded 1', 'gaming', '2', '29.07.21', 'TEST')";

if ($conn->query($sql) === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

$sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name)
VALUES ('1', 'Should get downloaded 2', 'gaming', '2', '30.07.21', 'TEST')";

if ($conn->query($sql) === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

$sql = "INSERT INTO look_forward_to (interest_id, description, category, importance, date, interest_name)
VALUES ('1', 'Should get downloaded 3', 'gaming', '2', '31.07.21', 'TEST')";

if ($conn->query($sql) === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}










$conn->close();
?>