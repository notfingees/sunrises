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

$address = $_POST['address'];
$bio = $_POST['bio'];
$twitter = $_POST['twitter'];
$instagram = $_POST['instagram'];
$discord = $_POST['discord'];
$website = $_POST['website'];

if (isset($_POST['bio']) and strlen($bio) >= 1 )
{
$stmt  = $conn->prepare("UPDATE accounts SET bio=? WHERE address=?");
$stmt->bind_param("ss", $bio, $address);
$stmt->execute();
}
if (isset($_POST['twitter']) and strlen($twitter) >= 1)
{
$stmt  = $conn->prepare("UPDATE accounts SET twitter=? WHERE address=?");
$stmt->bind_param("ss", $twitter, $address);
$stmt->execute();
}
if (isset($_POST['instagram']) and strlen($instagram) >= 1)
{
$stmt  = $conn->prepare("UPDATE accounts SET instagram=? WHERE address=?");
$stmt->bind_param("ss", $instagram, $address);
$stmt->execute();
}
if (isset($_POST['discord']) and strlen($discord) >= 1)
{
$stmt  = $conn->prepare("UPDATE accounts SET discord=? WHERE address=?");
$stmt->bind_param("ss", $discord, $address);
$stmt->execute();
}
if (isset($_POST['website']) and strlen($website) >= 1)
{
$stmt  = $conn->prepare("UPDATE accounts SET website=? WHERE address=?");
$stmt->bind_param("ss", $website, $address);
$stmt->execute();
}



$conn->close();

?>
