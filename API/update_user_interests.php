<?php
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "aurora";

/*
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
*/

// should be _POST if they're not already 
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$user_id = $_POST['user_id'];
$interest_id = $_POST['interest_id'];
$user_hash = $_POST['user_hash'];

$stmt = $conn->prepare("SELECT user_id FROM users WHERE hash=?");
$stmt->bind_param("s", $user_hash);
$stmt->execute();
$result = $stmt->get_result();
$user_id_from_hash = "";

while($row = $result->fetch_object())
{
    // Add each row into our results array
    $user_id_from_hash = (string)$row->user_id;
    

}

if ($user_id_from_hash == $user_id){
    

// Create connection


$smash_iid = "0";
$entertainment_iid = "0";
$shopping_iid = "0";

$dota2_iid = "0";
$valorant_iid = "0";
$rocketleague_iid = "0";
$league_iid = "0";
$csgo_iid = "0";
$apex_iid = "0";
$overwatch_iid = "0";
$wildrift_iid = "0";
$fortnite_iid = "0";
$gtav_iid = "0";


$sql = "SELECT interest_id FROM interests WHERE name = 'Grand Theft Auto V'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $gtav_iid = $row["interest_id"];
  }
}

$sql = "SELECT interest_id FROM interests WHERE name = 'Fortnite'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $fortnite_iid = $row["interest_id"];
  }
}

$sql = "SELECT interest_id FROM interests WHERE name = 'League of Legends: Wild Rift'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $wildrift_iid = $row["interest_id"];
  }
}

$sql = "SELECT interest_id FROM interests WHERE name = 'Overwatch'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $overwatch_iid = $row["interest_id"];
  }
}


$sql = "SELECT interest_id FROM interests WHERE name = 'Apex Legends'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $apex_iid = $row["interest_id"];
  }
}

$sql = "SELECT interest_id FROM interests WHERE name = 'Counter-Strike: Global Offensive'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $csgo_iid = $row["interest_id"];
  }
}

$sql = "SELECT interest_id FROM interests WHERE name = 'League of Legends'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $league_iid = $row["interest_id"];
  }
}


$sql = "SELECT interest_id FROM interests WHERE name = 'Rocket League'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $rocketleague_iid = $row["interest_id"];
  }
}

$sql = "SELECT interest_id FROM interests WHERE name = 'VALORANT'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $valorant_iid = $row["interest_id"];
  }
}

$sql = "SELECT interest_id FROM interests WHERE name = 'Dota 2'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $dota2_iid = $row["interest_id"];
  }
}


$sql = "SELECT interest_id FROM interests WHERE name = 'Movies'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $entertainment_iid = $row["interest_id"];
  }
}

$sql = "SELECT interest_id FROM interests WHERE name = 'Smash Ultimate'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $smash_iid = $row["interest_id"];
  }
}

$sql = "SELECT interest_id FROM interests WHERE name = 'shopping'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
      $shopping_iid = $row["interest_id"];
  }
}



// Basically, if user is into x interest (such as MKLeo), add the generalized interest for it as well (such as Smash) - generalized interest could be for just big events of the interest

$sql = "SELECT name, description, category FROM interests WHERE interest_id=?"; // SQL with parameters

if($stmt = $conn->prepare($sql)){
    $stmt->bind_param("s", $interest_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc(); // fetch data   
    $smash = false;
    $entertainment = false;
    
    
    foreach ($user as $row){
        if ((strpos(strtolower($row), "smash")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $smash_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
         //   break;
        }
        
        if ((strpos(strtolower($row), "apex legends")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $apex_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        if ((strpos(strtolower($row), "counter")) !== false or (strpos(strtolower($row), "global offensive")) !== false or (strpos(strtolower($row), "csgo")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $csgo_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        if ((strpos(strtolower($row), "dota")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $dota2_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        if ((strpos(strtolower($row), "fortnite")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $fortnite_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        if ((strpos(strtolower($row), "league of legends")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $league_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        if ((strpos(strtolower($row), "overwatch")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $overwatch_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        if ((strpos(strtolower($row), "rocket league")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $rocketleague_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        if ((strpos(strtolower($row), "valorant")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $valorant_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        if ((strpos(strtolower($row), "wild rift")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $wildrift_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        if ((strpos(strtolower($row), "gta")) !== false or (strpos(strtolower($row), "grand theft auto")) !== false){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $gtav_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
        }
        
        
        
    }
    
    foreach ($user as $row){
        if ($row == "entertainment"){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $entertainment_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
            break;
            
        }
    }
    foreach ($user as $row){
        if ($row == "shopping"){
            
            $stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");
            $stmt->bind_param("ss", $user_id, $shopping_iid);
            if ($stmt->execute() === TRUE) {
              echo "New record created successfully";
            } else {
              echo "Error: " . $stmt->error . "<br>" . $conn->error;
            }
            break;
            
        }
    }
   // echo $user;
}
else{
    echo "failed";
}




$stmt = $conn->prepare("INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)");

$stmt->bind_param("ss", $user_id, $interest_id);


if ($stmt->execute() === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $stmt->error . "<br>" . $conn->error;
}

}



$conn->close();
?>