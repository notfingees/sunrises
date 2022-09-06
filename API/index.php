<!DOCTYPE html>
<html>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
    @font-face { font-family: Brown; src: url('Brown-Bold.otf'); } 
    @font-face { font-family: Brown-Light; src: url('Brown-Light.otf'); }
    body{
        background-color: #ff4a62;
        background-image: linear-gradient(180deg, #a148ff, #ff4a62, #ff824b)
    }
    html, body {margin: 0; height: 100%; overflow: hidden}
    
    
    @media only screen and (orientation: landscape){
        #sunrises_text_image{
        position: absolute;
        left: 3vw;
        top: 3vw;
        width: 12vw;
        height: auto;
        
    }
    
    #regular_text_size{
        color: white;
        font-family: Brown;
        font-size: 1.75vw;
        position: absolute;
        top: 15vw;
        left: 16vw;
    }
    
    #sunrises_text_image_large{
        position: absolute;
        width: 28vw;
        height: auto;
        top: 20vw; 
        left: 16vw;
    }
    
    #contact{
        position: absolute;
        right: 3vw;
        top: 3vw;
        color: white;
        font-family: Brown;
        font-size: 1.75vw;
        text-decoration: none;
        
    }
    
    #about{
        position: absolute;
        right: 22vw;
        top: 3vw;
        color: white;
        font-family: Brown;
        font-size: 1.75vw;
        text-decoration: none;
        
    }
    
        #business{
        position: absolute;
        right: 12vw;
        top: 3vw;
        color: white;
        font-family: Brown;
        font-size: 1.75vw;
        text-decoration: none;
        
    }
    
 
        
        #download-now-button{
            background-color: white;
            border: none;
  color: #ff4a62;
  padding: 1vw 1.75vw;
  text-align: center;
  text-decoration: none;

  font-size: 1.75vw;
        font-family: Brown;
            margin: auto;

        
  cursor: pointer;
            position: absolute;
        left: 16vw;
            top: 26vw;
        }
    
    #screens{
        
        width: 25vw;
        height: auto;
        /*
        position: absolute;
        top: 8vw;
        right: 15vw;
        */
    }
        
        .container{
            position: absolute;
            top: 8vw;
            right: 15vw;
        }
        
        #date_month{
            color: white;
        font-family: Brown;
        font-size: 0.8vw;
            position: absolute;
            top: 5vw;
            left: 3vw;
            
        }
        
        #date_day{
            color: white;
            font-family: Brown;
            font-size: 4vw;
            position: absolute;
            top: 3vw;
            left: 3vw;
        }
        
        #lft{
            color: white;
            font-family: Brown-Light;
            font-size: 1vw;
            position: absolute;
            top: 11vw;
            left: 3vw;
            right: 10vw;
            line-height: 1.2vw;
        }
        
        
    }   

    @media only screen and (orientation: portrait){
        /* mobile */
        
        
        #sunrises_text_image{
        position: absolute;
        left: 3vw;
        top: 3vw;
        width: 18vw;
        height: auto;
        
    }
    
    #regular_text_size{
        color: white;
        font-family: Brown;
        font-size: 4vw;
        

        position: relative;
        text-align: center;
        top: 27vw;
    }
    
    #sunrises_text_image_large{

        width: 56vw;
        height: auto;
        display: block;
        margin-left: auto;
        margin-right: auto;
        position: relative;
        top: 27vw;

    }
    
    #contact{
        position: absolute;
        right: 3vw;
        top: 3vw;
        color: white;
        font-family: Brown;
        font-size: 2.25vw;
        text-decoration: none;  
    }
    
    #about{
        position: absolute;
        right: 29vw;
        top: 3vw;
        color: white;
        font-family: Brown;
        font-size: 2.25vw;
        text-decoration: none;        
    }
        
        #business{
        position: absolute;
        right: 15vw;
        top: 3vw;
        color: white;
        font-family: Brown;
        font-size: 2.25vw;
        text-decoration: none;        
    }
 
        #download-now-button{
            background-color: white;
            border: none;
  color: #ff4a62;
  padding: 2vw 3vw;
  text-align: center;
  text-decoration: none;
            margin: auto;
  font-size: 4vw;
        font-family: Brown;
            

        
  cursor: pointer;
            display: block;
        margin-left: auto;
        margin-right: auto;
        position: relative;
            top: 32vw;
        }
    
        
    #screens{
        
        width: 70vw;
        height: auto;
        
        top: 44vw;
        display: block;
        margin-left: auto;
        margin-right: auto;
        position: relative;
        
    }
        
        .container{
          /*
            display: block;
            margin-left: auto;
            margin-right: auto;
            position: relative;
            */
            position: relative;
         
        }
        
        #date_month{
            color: white;
        font-family: Brown;
        font-size: 2.25vw;
            position: absolute;
            top: 58vw;
            left: 23vw;
            
        }
        
        #date_day{
            color: white;
            font-family: Brown;
            font-size: 9vw;
            position: absolute;
            top: 55vw;
            left: 23vw;
        }
        
        #lft{
            color: white;
            font-family: Brown-Light;
            font-size: 3vw;
            position: absolute;
            top: 73vw;
            left: 23vw;
            right: 40vw;
            line-height: 3.5vw;
        }
    }    

</style>
    
<img id="sunrises_text_image" src="sunrises_text.svg" alt="Sunrises Text Logo">

<p id="regular_text_size">something to look forward to every day</p>
<img id="sunrises_text_image_large" src="sunrises_text.svg" alt="Sunrises Text Logo Large">
    <a id="about" href="about.html">about</a>
    <a id="business" href="business.php">business</a>
    <a id="contact" href="contact.php">contact</a>
    
    <button onclick="location.href='https://apps.apple.com/us/app/sunrises/id1583841201'" id="download-now-button">download now</button>
<div class="container">
<img id="screens" src="screens_no_text.svg" alt="Screenshots of the Sunrises app">
    <p id="date_month"><?php 
        #date_default_timezone_set("America/New_York");
        echo date("F")
        
        
        ?></p>
    <p id="date_day"><?php
        #date_default_timezone_set("America/New_York");
            echo date("j")
    
    ?>
    </p>
    
    <p id="lft"><?php
            
            
$servername = "localhost";
$username = "FAKE_USER";
$password = "FAKE_PASSWORD";
$dbname = "aurora";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

        $date = date("d") . "." . date("m") . "." . date("y");
        $lfts = array();
      #  echo $date;
$sql = "SELECT description FROM look_forward_to WHERE importance='2' AND date='" . $date . "'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
  // output data of each row
  while($row = $result->fetch_assoc()) {
    #  echo $row['description'];
      array_push($lfts, $row["description"]);
   // echo "id: " . $row["id"]. " - Name: " . $row["firstname"]. " " . $row["lastname"]. "<br>";
  }
} else {
 // echo "0 results";
}
        
shuffle($lfts);
echo "Today, look forward to " . $lfts[0];

$conn->close();

#echo "Today, look forward to AdinRoss' Twitch Stream";
            
            
            ?></p>
    
</div>
    
</html>