<!DOCTYPE html>
<html>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
    @font-face { font-family: Brown; src: url('Brown-Bold.otf'); } 
    @font-face { font-family: Brown-Light; src: url('Brown-Light.otf'); } 
    body{
        
        background-image: linear-gradient(180deg, #a148ff, #ff4a62, #ff824b);
            background-color: #ff824b;
        background-repeat: no-repeat;
    }
    html, body {margin: 0; height: 100%}
    
        ::placeholder { /* Chrome, Firefox, Opera, Safari 10.1+ */
  color: #ff4a62;
  opacity: 1; /* Firefox */
}

:-ms-input-placeholder { /* Internet Explorer 10-11 */
  color: #ff4a62;
}

::-ms-input-placeholder { /* Microsoft Edge */
  color: #ff4a62;
}
    
    @media only screen and (orientation: landscape){
        
        #hidden_on_desktop{
            display: none;
        }
        
        #interest_suggestion_form{
            position: absolute;
            top: 30vw;
            left: 16vw;
            color: white;
            font-family: Brown;
            font-size: 1.75vw;
            right: 16vw;
            line-height: 2.75vw;

        }
        
        input[type=submit]{
            font-family: Brown;
            color: #ff4a62;
            padding: 0.33vw;
            background-color: white;

            border: none;
        }
        
        input[type=text]{
            border: none;
            padding: 0.33vw;
            font-family: Brown-Light;
        }
        
        
        
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
        top: 11vw;
        left: 16vw;
        right: 16vw;
    }
    #regular_text_size_2{
        color: white;
        font-family: Brown;
        font-size: 1.75vw;
        position: absolute;
        top: 17vw;
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
            top: 26vw;
        }
    
    #screens{
        position: absolute;
        width: 25vw;
        height: auto;
        top: 8vw;
        right: 15vw;
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
        

        position: absolute;
        text-align: left;
        top: 20vw;
        left: 5vw;
        right: 5vw;
        line-height: 4.5vw;
    }
        #regular_text_size_2{
        color: white;
        font-family: Brown;
        font-size: 4vw;
        

        position: absolute;
        text-align: left;
        top: 40vw; 
        left: 5vw;
        right: 5vw;
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
        
        
        #interest_suggestion_form{
            position: absolute;
            top: 85vw;
            left: 5vw;
            right: 5vw;
            color: white;
            font-family: Brown;
            font-size: 4vw;
            right: 16vw;
            line-height: 7vw;

            
        }
        
        input[type=submit]{
            font-family: Brown;
            color: #ff4a62;
            padding: 0.33vw;
            background-color: white;

            border: none;
        }
        
        input[type=text]{
            border: none;
            padding: 0.33vw;
            font-family: Brown-Light;
           
            width: 80%;
        }
        
        
    }    

</style>

<a href="index.php">
<img id="sunrises_text_image" src="sunrises_text.svg" alt="Sunrises Text Logo">
    </a>

<p id="regular_text_size">Advertise on Sunrises<br>The platform where users are looking to look forward to something.</p>
    
<p id="regular_text_size_2">Fill out the form below and our team will reach out within 24 hours. We take this time to analyze each proposed ad campaign to ensure fit for our platform and also to determine the audiences for whom your campaign would best resonate with, thereby guaranteeing advertisers the best leads.</p>
    
<!--<p id="regular_text_size_2">or DM us on instagram @sunrises.app</p>-->

    <a id="about" href="about.html">about</a>
    <a id="business" href="business.php">business</a>
    <a id="contact" href="contact.php">contact</a>
    
<form id="interest_suggestion_form" action="add_business_request.php" method="post">
    
<label for="name">Name:</label><br>
  <input type="text" id="name" name="name" placeholder="John Smith" size="100"><br>
 
    
  <label for="bname">Business name:</label><br>
  <input type="text" id="bname" name="bname" placeholder="Sunrises LLC" size="100"><br>
<label for="blink">Business link:</label><br>
  <input type="text" id="blink" name="blink" placeholder="sunrisesapp.com" size="100"><br>
<label for="bcontact">Contact information:</label><br>
  <input type="text" id="bcontact" name="bcontact" placeholder="Phone/email" size="100"><br>
  <label for="bpromo">Promotion description: (what you're offering customers to look forward to)</label><br>
  <input type="text" id="bpromo" name="bpromo" placeholder="50% off sale, special event, etc." size="100"><br>
<label for="bdate">Promotion date:</label><br>
  <input type="datetime-local" id="bdate" name="bdate"><br>
    <label for="badditional">Additional information</label><br>
  <input type="text" id="badditional" name="badditional" placeholder="Promotion date range, etc." size="100"><br>
    
    <br id="hidden_on_desktop">    
    <input type="submit" style="font:Brown;"><br><br>
</form>
    
    
    
</html>