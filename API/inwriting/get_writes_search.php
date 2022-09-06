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
$search_term = $_POST['search_term'];

if (substr($search_term, 0, 8) == "tokenID="){

$tID = substr($search_term, 8);
$stmt = $conn->prepare("SELECT * FROM owners WHERE tokenID = ? LIMIT ?");
$stmt->bind_param("ss", $tID, $limit);
}

else{
$search_term = "%".$search_term."%";
$stmt = $conn->prepare("SELECT * FROM owners WHERE tokenString LIKE ? LIMIT ?");
$stmt->bind_param("ss", $search_term, $limit);
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