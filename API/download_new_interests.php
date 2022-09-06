<?php
 // WILL NEED TO DELETE EVERYTHING AFTER IT'S ADDED SINCE THIS DATABASE WILL BE USED AS AN 'UPDATE' MECHANISM 
 // WILL NEED TO DELETE EVERYTHING AFTER IT'S ADDED SINCE THIS DATABASE WILL BE USED AS AN 'UPDATE' MECHANISM 
 // WILL NEED TO DELETE EVERYTHING AFTER IT'S ADDED SINCE THIS DATABASE WILL BE USED AS AN 'UPDATE' MECHANISM 
// Create connection
$user_id = $_GET['user_id'];

$con=mysqli_connect("localhost","FAKE_CREDENTIALS","FAKE_CREDENTIALS","aurora");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

 
$stmt = $con->prepare("SELECT updated_interests FROM users WHERE user_id=?");
$stmt->bind_param("s", $user_id);
$stmt->execute();
$stmt->bind_result($updated_interests);
$stmt->fetch();
//echo $updated_interests, "is updated_interests";
    /*
$result = $con->query($sql);
$updated_interests = 0;
if ($result->num_rows > 0) {
  // output data of each row
  while($row = $result->fetch_assoc()) {
      $updated_interests = $row["updated_interests"];
  }
}
*/

/*
// This SQL statement selects ALL from the table 'Locations'
$sql = "SELECT previous_interest_index FROM helper";

$previous_interest_index = 0;

// Check if there are results

if ($result = $con->query($sql))
{
	// Loop through each row in the result set
	while($row = $result->fetch_assoc())
	{
        $previous_interest_index = $row["previous_interest_index"];
        
    //    echo $previous_interest_index;
	}
}   


//echo $previous_interest_index;

*/

$conn=mysqli_connect("localhost","FAKE_CREDENTIALS","FAKE_CREDENTIALS","aurora");

$sql2 = "SELECT * FROM interests WHERE interest_id > '$updated_interests'";
//$sql2 = "SELECT * FROM interests";
 
// Check if there are results
if ($result = mysqli_query($conn, $sql2))
{
	// If so, then create a results array and a temporary one
	// to hold the data
	$resultArray = array();
	$tempArray = array();
 
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
		// Add each row into our results array
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
    $helper_interest = 0;

    if ($result->num_rows > 0) {
      // output data of each row
      while($row = $result->fetch_assoc()) {

        $helper_interest = $row["current_interest_index"];
      }
    }


    $stmt  = $conn->prepare("UPDATE users SET updated_interests=? WHERE user_id=?");

    $stmt->bind_param("ss", $helper_interest, $user_id);

    if ($stmt->execute() === TRUE) {
      $returnint = 0;
    } else {
      $returnint = 1;
    }

}





mysqli_close($con);
mysqli_close($conn);
?>