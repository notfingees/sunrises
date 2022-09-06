<?php
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "aurora";


$user_id = $_POST['user_id'];
$largest_interest_id = $_POST['largest_interest_id'];
$largest_lft_id = $_POST['largest_lft_id'];
$user_hash = $_POST['user_hash'];

//echo $user_id, $largest_interest_id, $largest_lft_id;

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
    
    echo "true";
    
$sql = "SELECT current_lft_index, current_interest_index FROM helper";
$result = $conn->query($sql);
$updated_interests = 0;
$updated_lft = 0;

if ($result->num_rows > 0) {
  // output data of each row
  while($row = $result->fetch_assoc()) {
      
    $updated_interest = $row["current_interest_index"];
    $updated_lft = $row["current_lft_index"];
  }
}




if ($largest_interest_id == "0"){
    echo "Didn't download any new interests, keep the user at the same for now";
}
else{
    $stmt  = $conn->prepare("UPDATE users SET updated_interests=? WHERE user_id=?");

    $stmt->bind_param("ss", $updated_interest, $user_id);

    if ($stmt->execute() === TRUE) {
      echo "New record created successfully";
    } else {
      echo "Error: " . $stmt->error . "<br>" . $conn->error;
    }
}
if ($largest_lft_id == "0"){
    echo "Didn't download any new LFTs, keep the user at the same for now";
}
else{
    $stmt  = $conn->prepare("UPDATE users SET updated_lft=? WHERE user_id=?");

    $stmt->bind_param("ss", $updated_lft, $user_id);

    if ($stmt->execute() === TRUE) {
      echo "New record created successfully";
    } else {
      echo "Error: " . $stmt->error . "<br>" . $conn->error;
    }
}
}





$conn->close();
?>