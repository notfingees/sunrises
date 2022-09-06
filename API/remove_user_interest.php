<?php
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "aurora";

$user_id = $_POST['user_id'];
$interest_id = $_POST['interest_id'];
$user_hash = $_POST['user_hash'];

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$stmt = $conn->prepare("SELECT user_id FROM users WHERE hash=?");
$stmt->bind_param("s", $user_hash);
$stmt->execute();
$result = $stmt->get_result();
$user_id_from_hash = "";

while($row = $result->fetch_object())
{
    // Add each row into our results array
    $user_id_from_hash = (string)$row->user_id;

}

if ($user_id_from_hash == $user_id){
    
$stmt = $conn->prepare("DELETE FROM user_interests WHERE interest_id=? AND user_id=?");
$stmt->bind_param("ss", $interest_id, $user_id);
$stmt->execute();
}
/*
$sql = "INSERT INTO user_interests (user_id, interest_id)
VALUES ('1', '1')";

if ($conn->query($sql) === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

*/






$conn->close();
?>