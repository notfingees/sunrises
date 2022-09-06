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


$sql = "SELECT current_lft_index, current_interest_index FROM helper";

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
        $row->current_lft_index = (string)$row->current_lft_index;
        $row->current_interest_index = (string)$row->current_interest_index;
		$tempArray = $row;
	    array_push($resultArray, $tempArray);
	}
	// Finally, encode the array to JSON and output the results
    //header("Content-Type", "application/json");
	echo json_encode($resultArray);
}




$conn->close();
?>