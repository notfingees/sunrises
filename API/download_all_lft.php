<?php
 // WILL NEED TO DELETE EVERYTHING AFTER IT'S ADDED SINCE THIS DATABASE WILL BE USED AS AN 'UPDATE' MECHANISM 
 // WILL NEED TO DELETE EVERYTHING AFTER IT'S ADDED SINCE THIS DATABASE WILL BE USED AS AN 'UPDATE' MECHANISM 
 // WILL NEED TO DELETE EVERYTHING AFTER IT'S ADDED SINCE THIS DATABASE WILL BE USED AS AN 'UPDATE' MECHANISM 
// Create connection

$user_id = $_GET['user_id'];


$con=mysqli_connect("localhost","FAKE_CREDENTIALS","FAKE_CREDENTIALS","aurora");
$conn=mysqli_connect("localhost","FAKE_CREDENTIALS","FAKE_CREDENTIALS","aurora");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 


$stmt = $con->prepare("SELECT updated_lft FROM users WHERE user_id=?");
$stmt->bind_param("s", $user_id);
$stmt->execute();
$stmt->bind_result($updated_lft);
$stmt->fetch();



$sql = "SELECT * FROM look_forward_to WHERE lft_id > {$updated_lft}";
 
// Check if there are results
if ($result = mysqli_query($conn, $sql))
{
	// If so, then create a results array and a temporary one
	// to hold the data
	$resultArray = array();
	$tempArray = array();
 
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
		// Add each row into our results array
        $row->interest_id = (string)$row->interest_id;
        $row->lft_id = (string)$row->lft_id;
        $row->importance = (string)$row->importance;
		$tempArray = $row;
	    array_push($resultArray, $tempArray);
	}
 
	// Finally, encode the array to JSON and output the results
   // echo $resultArray;
	echo json_encode($resultArray);
}

if (intval($user_id) < 10){
    $ignore = 0;
}
else{
    
    $sql = "SELECT current_lft_index, current_interest_index FROM helper";
    $result = $conn->query($sql);
    $helper_lft = 0;

    if ($result->num_rows > 0) {
      // output data of each row
      while($row = $result->fetch_assoc()) {

        $helper_lft = $row["current_lft_index"];
      }
    }


    $stmt  = $conn->prepare("UPDATE users SET updated_lft=? WHERE user_id=?");

    $stmt->bind_param("ss", $helper_lft, $user_id);

    if ($stmt->execute() === TRUE) {
      $returnint = 0;
    } else {
      $returnint = 1;
    }
}


mysqli_close($conn);

mysqli_close($con);
?>