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

$string = $_POST['string'];
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

$tokenID = "";
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

//	echo json_encode($resultArray, JSON_UNESCAPED_UNICODE);



$stmt = $conn->prepare("
SELECT * FROM `blockchain` WHERE tokenID= ? AND function='buy' AND price > 0 ORDER BY timeStamp ASC;
");

$timestampArray = array();
$priceArray = array();

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
       // $row->user_id = (string)$row->user_id;
        
        $ts = $row->timeStamp;
        $p = $row->price;
        
        
        array_push($timestampArray, $ts);
        array_push($priceArray, $p);

        
        
        
	  //  array_push($resultArray, $tempArray);
	}


$returnArray = array();
array_push($returnArray, $priceArray);
array_push($returnArray, $timestampArray);


echo json_encode($returnArray, JSON_UNESCAPED_UNICODE);






$conn->close();
?>