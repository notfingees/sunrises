
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

$limit = $_POST['limit'];
$address = $_POST['address'];
$paginationTimestamp = $_POST['paginationTimestamp'];
$paginationTimestamp = intval($paginationTimestamp);

if (isset($_POST['address']) )
{
$stmt = $conn->prepare("SELECT s1.tokenID, timeStamp, owners.tokenString, owners.price 
FROM blockchain s1 INNER JOIN owners ON s1.tokenID=owners.tokenID 
WHERE timeStamp = (SELECT MAX(timeStamp) FROM blockchain s2 WHERE s1.tokenID = s2.tokenID) AND owners.owner = ?
ORDER BY timeStamp DESC LIMIT ?;");
$stmt->bind_param("ss", $address, $limit);

}
else {

$stmt = $conn->prepare("SELECT s1.tokenID, timeStamp, owners.tokenString, owners.price 
FROM blockchain s1 INNER JOIN owners ON s1.tokenID=owners.tokenID 
WHERE timeStamp = (SELECT MAX(timeStamp) FROM blockchain s2 WHERE s1.tokenID = s2.tokenID) AND timeStamp < ? ORDER BY timeStamp DESC LIMIT ?");
$stmt->bind_param("is", $paginationTimestamp, $limit);
}
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