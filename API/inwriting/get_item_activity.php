<?php
header("Access-Control-Allow-Origin: *");
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "inwriting";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$conn->query("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");

$tokenID = $_POST['tokenID'];
/*
SELECT tt.*
FROM texts tt
INNER JOIN
    (SELECT to_address, MAX(time) AS MaxDateTime 
    FROM texts
     WHERE from_address='address_2'
    GROUP BY to_address) groupedtt 
ON tt.to_address = groupedtt.to_address 
AND tt.time = groupedtt.MaxDateTime
*/

$stmt = $conn->prepare("
SELECT function, function_caller, price, toAddress, timeStamp FROM `blockchain` WHERE tokenID= ? ORDER BY timeStamp DESC;
");



$stmt->bind_param("s", $tokenID);
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
        $row->user_id = (string)$row->user_id;
		$tempArray = $row;
        //echo $tempArray->user_id;
        //echo gettype($tempArray->user_id);
        
	    array_push($resultArray, $tempArray);
	}



	// Finally, encode the array to JSON and output the results
	echo json_encode($resultArray, JSON_UNESCAPED_UNICODE);





$conn->close();
?>