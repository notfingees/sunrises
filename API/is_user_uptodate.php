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


$stmt = $conn->prepare("SELECT updated_interests, updated_lft FROM users WHERE user_id=?");
$stmt->bind_param("s", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$resultArray = array();
	$tempArray = array();
 
	// Loop through each row in the result set
	while($row = $result->fetch_object())
	{
		// Add each row into our results array
        $row->updated_interests = (string)$row->updated_interests;
        $row->updated_lft = (string)$row->updated_lft;
		$tempArray = $row;
	    array_push($resultArray, $tempArray);
	}
	// Finally, encode the array to JSON and output the results
    //header("Content-Type", "application/json");
	echo json_encode($resultArray);
    


$conn->close();
?>