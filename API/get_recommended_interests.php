<?php
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "aurora";

$interest_id = $_POST['interest_id'];
// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}



$stmt = $conn->prepare("SELECT recommended_interest_id FROM recommended_interests WHERE interest_id=?");
$stmt->bind_param("s", $interest_id);
$stmt->execute();
$result = $stmt->get_result();


	// If so, then create a results array and a temporary one
	// to hold the data
	$resultArray = array();
	$tempArray = array();
 
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
		// Add each row into our results array
        $row->recommended_interest_id = (string)$row->recommended_interest_id;
		$tempArray = $row;
	    array_push($resultArray, $tempArray);
	}
	// Finally, encode the array to JSON and output the results
    //header("Content-Type", "application/json");
	echo json_encode($resultArray);





$conn->close();
?>