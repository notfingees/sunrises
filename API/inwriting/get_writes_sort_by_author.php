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

/*
$conn->query("SET CHARACTER SET utf8mb4_bin");
$conn->query("SET NAMES utf8mb4_bin");
*/

$conn->query("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");

$address = $_POST['address'];

/*
SELECT owners.tokenID, owners.tokenString, owners.owner, owners.listed, owners.price, owners.locked, s1.tokenID FROM blockchain s1
INNER JOIN owners ON s1.tokenID=owners.tokenID WHERE s1.function_caller='0x6d8d7c6092f802eb6a3409ae0c2e453dec120783' AND s1.function LIKE '%mint%' LIMIT 10;
*/

$stmt = $conn->prepare("
SELECT owners.tokenID, owners.tokenString, owners.owner, owners.listed, owners.price, owners.locked, s1.tokenID FROM blockchain s1
INNER JOIN owners ON s1.tokenID=owners.tokenID WHERE s1.function_caller=? AND s1.function LIKE '%mint%';
");

$tokenID = 0;
$stmt->bind_param("s", $address);
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
   // $row->user_id = (string)$row->user_id;
    
    $tokenID = $row->tokenID;

    $tempArray = $row;
    array_push($resultArray, $tempArray);
}


	// Finally, encode the array to JSON and output the results
	echo json_encode($resultArray, JSON_UNESCAPED_UNICODE);





$conn->close();
?>