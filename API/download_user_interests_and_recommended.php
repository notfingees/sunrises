<?php
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "aurora";

$user_id = $_POST['user_id'];

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}


$stmt = $conn->prepare("SELECT interest_id FROM user_interests WHERE user_id=?");
$stmt->bind_param("s", $user_id);
$stmt->execute();
$result = $stmt->get_result();

//$sql = "SELECT interest_id FROM user_interests WHERE user_id='$user_id'";

//if ($result = mysqli_query($conn, $sql))
//{
	// If so, then create a results array and a temporary one
	// to hold the data
	$resultArray = array();
	$tempArray = array();
 
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
		// Add each row into our results array
        $row->interest_id = (string)$row->interest_id;
		$tempArray = $row;
	    array_push($resultArray, $tempArray);
	}
	// Finally, encode the array to JSON and output the results
    //header("Content-Type", "application/json");
  //  $resultArray = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];
	echo json_encode($resultArray);

//}




$conn->close();
?>