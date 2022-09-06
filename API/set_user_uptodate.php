<?php
 // WILL NEED TO DELETE EVERYTHING AFTER IT'S ADDED SINCE THIS DATABASE WILL BE USED AS AN 'UPDATE' MECHANISM 
 // WILL NEED TO DELETE EVERYTHING AFTER IT'S ADDED SINCE THIS DATABASE WILL BE USED AS AN 'UPDATE' MECHANISM 
 // WILL NEED TO DELETE EVERYTHING AFTER IT'S ADDED SINCE THIS DATABASE WILL BE USED AS AN 'UPDATE' MECHANISM 
// Create connection

$user_id = $_GET['user_id'];
$user_hash = $_POST['user_hash'];


$con=mysqli_connect("localhost","FAKE_CREDENTIALS","FAKE_CREDENTIALS","aurora");
$conn=mysqli_connect("localhost","FAKE_CREDENTIALS","FAKE_CREDENTIALS","aurora");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
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
 

if (intval($user_id) < 10){
    $ignore = 0;
}
else{
    
    $sql = "SELECT current_lft_index, current_interest_index FROM helper";
    $result = $conn->query($sql);
    $helper_lft = 0;
    $helper_interests = 0;

    if ($result->num_rows > 0) {
      // output data of each row
      while($row = $result->fetch_assoc()) {

        $helper_lft = $row["current_lft_index"];
        $helper_interests = $row["current_interest_index"];
      }
    }


    $stmt  = $conn->prepare("UPDATE users SET updated_lft=? WHERE user_id=?");

    $stmt->bind_param("ss", $helper_lft, $user_id);

    if ($stmt->execute() === TRUE) {
      $returnint = 0;
    } else {
      $returnint = 1;
    }
    $stmt  = $conn->prepare("UPDATE users SET updated_interests=? WHERE user_id=?");

    $stmt->bind_param("ss", $helper_interests, $user_id);

    if ($stmt->execute() === TRUE) {
      $returnint = 0;
    } else {
      $returnint = 1;
    }
    
}
}

mysqli_close($conn);

mysqli_close($con);
?>