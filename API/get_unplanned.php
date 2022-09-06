<?php
header("Access-Control-Allow-Origin: *");

$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "qabuddy";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$username = $_GET['username'];



$stmt = $conn->prepare("
SELECT * FROM planning WHERE username=?;
");



$stmt->bind_param("s", $username);

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
		$tempArray = $row;

        
	    array_push($resultArray, $tempArray);
	}



	// Finally, encode the array to JSON and output the results

//    header("Content-Type", "application/json");
echo json_encode($resultArray, JSON_UNESCAPED_UNICODE);



echo "result gotten";

$conn->close();
?>