<?php
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "aurora";

$name = $_GET['name'];
$email = $_GET['email'];
$password1 = $_GET['password'];

$BASE_UPDATED_INTERESTS = '0';
$BASE_UPDATED_LFT = '0'; // These are both like how many interests/lft come with the app (but it's the ID of the downloaded interest/lft) I think base_updated_lft will actually be 0 

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT current_lft_index, current_interest_index FROM helper";
$result = $conn->query($sql);
$UPDATED_INTERESTS = '0';
$UPDATED_LFT = '0';

if ($result->num_rows > 0) {
    
    
    
  // output data of each row
  while($row = $result->fetch_assoc()) {
      $UPDATED_INTERESTS = $row["current_interest_index"];
      $UPDATED_LFT = $row["current_lft_index"];
  }
}



$stmt = $conn->prepare("INSERT INTO users (name, updated_interests, updated_lft, today_alert, tomorrow_alert, darkmode, animations, premium, email, password, phone) VALUES (?, ?, ?, '8', '20', '0', '1', '0', ?, ?, 'EMAILLOGIN')");

$stmt->bind_param("sssss", $name, $UPDATED_INTERESTS, $UPDATED_LFT, $email, $password1);


if ($stmt->execute() === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $stmt->error . "<br>" . $conn->error;
}





$conn->close();

?>