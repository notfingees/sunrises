
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
$now = $_POST['now'];
$before = $_POST['before'];
$address = $_POST['address'];

// HAVE TO REMOVE ONLY FULL GROUP BY
if (isset($_POST['address']) )
{
    
    $stmt = $conn->prepare("SELECT owners.tokenString, blockchain.tokenID, COUNT(blockchain.tokenID) AS most_frequently_appearing, owners.price FROM blockchain INNER JOIN owners ON blockchain.timeStamp > ? AND blockchain.tokenID=owners.tokenID AND owners.owner=? GROUP BY tokenID ORDER BY most_frequently_appearing DESC LIMIT ?;");

$stmt->bind_param("sss", $before, $address, $limit);
    
}
else{
    $stmt = $conn->prepare("SELECT owners.tokenString, blockchain.tokenID, COUNT(blockchain.tokenID) AS most_frequently_appearing, owners.price FROM blockchain INNER JOIN owners ON blockchain.timeStamp > ? AND blockchain.tokenID=owners.tokenID GROUP BY tokenID ORDER BY most_frequently_appearing DESC LIMIT ?;");

$stmt->bind_param("ss", $before, $limit);
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