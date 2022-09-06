<?php
header("Access-Control-Allow-Origin: *");
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "inwriting";

$string = $_POST['string'];

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


$tokenID = 0;
$stmt = $conn->prepare("
SELECT * FROM `owners` WHERE tokenString= ?;
");
$stmt->bind_param("s", $string);
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




$stmt = $conn->prepare("
SELECT function_caller FROM `blockchain` WHERE tokenID= ? AND function LIKE '%mint%';
");

$stmt->bind_param("s", $tokenID);
$stmt->execute();
$result = $stmt->get_result();

// Loop through each row in the result set
while($row = $result->fetch_object())
{
    // Add each row into our results array
   // $row->user_id = (string)$row->user_id;
    
    $function_caller = (string)$row->function_caller;
    $resultArray[0]->function_caller = $function_caller;

  //  $tempArray = $row;
//    array_push($resultArray, $tempArray);
}



	// Finally, encode the array to JSON and output the results
echo json_encode($resultArray, JSON_UNESCAPED_UNICODE);





$conn->close();
?>