<!DOCTYPE html>

<html>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
    @font-face { font-family: Brown; src: url('Brown-Bold.otf'); } 
    body{
        background-color: #ff4a62;
        background-image: linear-gradient(180deg, #a148ff, #ff4a62, #ff824b);
        background-repeat: no-repeat;
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
        right: 16vw;
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
            top: 23vw;
        }
    
    #screens{
        position: absolute;
        width: 25vw;
        height: auto;
        top: 8vw;
        right: 15vw;
    }
        
        .content {
  padding: 0 18px;
  display: none;
  overflow: hidden;
        position: absolute;
        top: 29vw;
        font-family: Brown;
        color: white;
        background-color: #ff4a62;

}
    }   

    @media only screen and (orientation: portrait){
        /* mobile */
        
        
        .content {
  padding: 0 18px;
  display: none;
  overflow: hidden;
        position: absolute;
        top: 60vw;
        font-family: Brown;
        color: white;
        background-color: #ff4a62;
            left: 3vw;
            right: 3vw;

}
        
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
        left: 3vw; 
        right: 3vw;
        
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
    }    
    
    

</style>

    <a href="index.php">
<img id="sunrises_text_image" src="sunrises_text.svg" alt="Sunrises Text Logo">
    </a>
    <a id="about" href="about.html">about</a>
    <a id="business" href="business.php">business</a>
    <a id="contact" href="contact.php">contact</a>
    

<p id="regular_text_size"><?php
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

$name = $_POST["iname"];
$desc = $_POST["idesc"];
$link = $_POST["ilink"];
$date = date("d") . "." . date("m") . "." . date("y");

$stmt = $conn->prepare("INSERT INTO suggestions (interest_name, description, link, date_submitted) VALUES (?, ?, ?, ?)");

$stmt->bind_param("ssss", $name, $desc, $link, $date);


if ($stmt->execute() === TRUE) {
  echo "Thanks for submitting a suggestion! We hope you continue to enjoy Sunrises!";
} else {
  echo "There was an error submitting your suggestion - please try again";
}






$conn->close();
?>
</p>
   


</html>