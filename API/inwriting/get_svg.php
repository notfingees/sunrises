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

$tokenID = $_GET['tokenID'];
$string = "";

$stmt = $conn->prepare("SELECT * FROM owners WHERE tokenID = ?");
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
        $string = (string)$row->tokenString;
		$tempArray = $row;
        //echo $tempArray->user_id;
        //echo gettype($tempArray->user_id);
        
	    array_push($resultArray, $tempArray);
	}
	// Finally, encode the array to JSON and output the results
    //header("Content-Type", "application/json");





/*

$encoded_string = $_GET['encoded_string']; // this is actually the string 

$string = base64_decode($encoded_string);

*/

$no_left = str_replace("<", "&lt;", $string);

$no_left_or_right = str_replace(">", "&gt;", $no_left);

$pieces = explode("\n", $no_left_or_right);

$numLines = count($pieces);

$longest_line_length = 0;
/*
for($i = 0; $i < numLines; $i = $i + 1) {
    echo "in here once";
    
    $line_length = strlen($pieces[i]);
    echo "line length is " . $line_length;
    if ($line_length > $longest_line_length) {
        $longest_line_length = $line_length;
    }
    
    
    
}
*/

foreach ($pieces as $line) {
    $line_length = strlen($line);
    if ($line_length > $longest_line_length) {
        $longest_line_length = $line_length;
    }
}


$line_height="1.208";
$font_link="http://fonts.cdnfonts.com/css/menlo"; 
$dynamic_width_modifier=0.61;
$dynamic_height_modifier=1;
$font_size = 24;

$dynamic_width = intval(($longest_line_length*intval($font_size))*floatval($dynamic_width_modifier));
$dynamic_height = intval(($numLines*floatval($line_height)*1.2*intval($font_size))*floatval($dynamic_height_modifier));


$svgString = "<svg xmlns='http://www.w3.org/2000/svg' width=" 
 . "'" . strval($dynamic_width) . "'" . " height=" . "'" . strval($dynamic_height) ."'" . " font-size='" . strval(intval($font_size)) . "'>" . "<style>@import url('" . $font_link . "');</style>" . "<text font-family='Menlo' x='0' y='0' xml:space='preserve' text-anchor='start'>";
 


foreach ($pieces as $line) {
    $resultLine = "<tspan x='0' dy='" . strval($line_height) . "em'>" . $line . "</tspan>";
    $svgString = $svgString . $resultLine;
}




    # footer/ending of the svgString
$svgString = $svgString . "</text></svg>";

echo $svgString;



?>