package html_structure;

use strict;
use warnings;
use JSON;
use CGI::Cookie;
use URI::Escape;

use lib '.';
use lib
'/home/lapdev/Mein/Perl-WebServer/structure';
use calender;
use cloud;
use notepad;
use login;
use signup;
use home;

my $base_dir ='/home/lapdev/Mein/Perl-WebServer';

# importing css

my $home_css = '';
open my $home, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/home.css' or die $!;
while ( my $line = <$home> ) {
    $home_css .= $line;
}
close $home;

my $MFA_page = '';
open my $mfa, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/mfa.css' or die $!;
while ( my $line = <$mfa> ) {
    $MFA_page .= $line;
}
close $mfa;

my $error_css = '';
open my $error, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/error.css' or die $!;
while ( my $line = <$error> ) {
    $error_css .= $line;
}
close $error;


my $notepad_css = '';
open my $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/notepad.css' or die $!;
while ( my $line = <$fh> ) {
    $notepad_css .= $line;
}
close $fh;

my $calender_css = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/calender.css' or die $!;
while ( my $line = <$fh> ) {
    $calender_css .= $line;
}
close $fh;

my $cloud_css = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/cloud.css' or die $!;
while ( my $line = <$fh> ) {
    $cloud_css .= $line;
}
close $fh;

my $login_css = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/login.css' or die $!;
while ( my $line = <$fh> ) {
    $login_css .= $line;
}
close $fh;

my $signup_css = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/signup.css' or die $!;
while ( my $line = <$fh> ) {
    $signup_css .= $line;
}
close $fh;

my $main_css = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/main.css' or die $!;
while ( my $line = <$fh> ) {
    $main_css .= $line;
}
close $fh;

my $main2_css = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/main2.css' or die $!;
while ( my $line = <$fh> ) {
    $main2_css .= $line;
}
close $fh;

my $notfound = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/notfound.css' or die $!;
while ( my $line = <$fh> ) {
    $notfound .= $line;
}
close $fh;

my $alert_page = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/alert.css' or die $!;
while ( my $line = <$fh> ) {
    $alert_page .= $line;
}
close $fh;

my $snake_game = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/css/snake.css' or die $!;
while ( my $line = <$fh> ) {
    $snake_game .= $line;
}
close $fh;

my $snake_game_js = '';
open $fh, '<','/home/lapdev/Mein/Perl-WebServer/structure/game.js' or die $!;
while ( my $line = <$fh> ) {
    $snake_game_js .= $line;
}
close $fh;


sub html_structure {
    my ( $html_body, $html_title ) = @_;

    my $html_content = <<HTML;
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$html_title</title>
    <style>
        
    </style>
</head>

<body>
    $html_body
</body>
</html>
HTML

    return $html_content;
}

sub Comments {
    my ($comment_item) = @_;

    my $html_content = <<HTML;
     <main class="table" id="customers_table">
        <section class="table__header">
            <h1>Customer's Comments</h1>
            <div class="input-group">
                <input type="search" class="search_input" placeholder="Search Data...">
                <button class="button">Search</button>
            <a class="button" href="/newcomment">New</a>
            </div>
            
        </section>
        <section class="table__body">
            <table>
                <thead>
                    <tr>
                        <th style="width: 5%;"> Id </th>
                        <th style="width: 15%;"> Name </th>
                        <th style="width: 20%;"> Email </th>
                        <th style="width: 20%;"> Role </th>
                        <th style="width: 40%;"> Comment </th>
                    </tr>
                </thead>
                <tbody>
                    $comment_item
                </tbody>
            </table>
        </section>
    </main>

HTML

    return $html_content;
}

sub newCommentsItem {
    my ($json_data)  = @_;
    my $comment_item = decode_json($json_data);
    my $html_content = <<HTML;
    <tr>
    <td>$comment_item->{id}</td>
    <td>$comment_item->{name}</td>
    <td>$comment_item->{email}</td>
    <td>$comment_item->{role}</td>
    <td>$comment_item->{comment}</td>
    </tr>
HTML
    return $html_content;
}

sub home_page {
    my ($html_title, $userID) = @_;

    my $navbar = html_navbar();

    if (!defined $userID) {
        $userID = 'Guest';
    }

    my $html_content = <<HTML;
    <!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$html_title</title>
</head>
<style>
    $home_css
    p{}
</style>
<body>
    <div class="main">
        <h1>Welcome $userID</h1>
        <a id="MFA" href="/mfa">Multi Factor Authentication</a>
        <nav>
            <ul>
                <li>
                    <a href="/filemanager">
                        <img width="150" height="150" src="https://img.icons8.com/3d-fluency/300/cloud-folder.png" alt="File Manager Icon" />
                        <label>Cloud Drive</label>
                    </a>
                </li>
                <li>
                    <a href="/notepad">
                        <img width="150" height="150" src="https://img.icons8.com/fluency/300/notepad.png" alt="Notepad Icon" />
                        <label>Notepad</label>
                    </a>
                </li>
                <li>
                    <a href="/calendar">
                        <img width="150" height="150" src="https://img.icons8.com/fluency/300/calendar.png" alt="Calendar Icon" />
                        <label>Calendar</label>
                    </a>
                </li>
            </ul>
        </nav>
        <form action="/user/logout" method="post">
            <input type="submit" value="Logout">
        </form>
    </div>
</body>

</html>

HTML

    return $html_content;
}

sub html_structure_v2 {
    my ( $html_body, $html_title ) = @_;

    my $html_content = <<HTML;
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@{[$html_title || 'HOME']}</title>
    <style>
        $main2_css
        p{}
    </style>
</head>

<body>
    $html_body
</body>
</html>
HTML

    return $html_content;
}

### html_event_structure
sub event_structure {
    my ( $date, $name, $description ) = @_;
    my ($day) = split "/", $date;

    my $html_content = <<HTML;
     <main>
        <div class="container">
        <div class="event-container">
            <div class="teil-1 content">
                <h2>$day</h2>
                
            </div>
            <div class="teil-2 content">
                <h1>Date: $date</h1>
                <h1>Name: $name</h1>
                <h1>Description: @{[$description || 'No description available']}</h1>
            </div>
            <div class="teil-3 content">
                 <img src="https://picsum.photos/150/150" width="120px" height="120px" alt="bird"> 
            </div>
        </div>
        <div class="middle">
            <div class="btn text">Add to Calendar</div>
        </div>
        </div>
     </main>

HTML

    return $html_content;
}

sub notepad_html_structure {

    my ( $title, $content, %notes ) = @_;

    my @content_copy = split( /\n/, $content );

    my $labelText   = ( substr( $content,         0, 20 ) // '' );
    my $contentText = ( substr( $content_copy[1], 0, 30 ) // '' )
      if defined $content_copy[1];

    my $note = '';

    foreach my $key ( sort { $a <=> $b } keys %notes ) {
        $note .=
          create_new_note( $notes{$key}{title}, $notes{$key}{content}, $key );
    }

    my $html_content = <<HTML;
    
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"> -->
        <title>$title</title>
        <style>
            $notepad_css
            p{}
        </style>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                document.querySelectorAll('.save-btn').forEach(item => {
                    item.addEventListener('click', function() {
                        const noteContent = document.getElementById('content').value;

                        console.log("test");
                        console.log(noteContent);
                        console.log("test");
                    });
                })

                document.querySelectorAll('.note_item').forEach(item => {
                    item.addEventListener('click', function() {
                        const noteContent = this.querySelector('span').innerText;
                        document.getElementById('content').value = noteContent;
                        const noteIndex = this.querySelector('span#noteIndex').innerText;
                        document.getElementById('deletenoteIndex').value = noteIndex;
                        document.getElementById('downloadnoteIndex').value = noteIndex;
                        document.getElementById('sendIndex').value = noteIndex;
                        
                        document.getElementById('sendContent').value = noteContent;
                    document.getElementById('sendTitle').value = noteContent;
                    

                        
                        });
                });
            });

            document.addEventListener('DOMContentLoaded', function() {
                const contentInput = document.getElementById('content');
                contentInput.addEventListener('input', function() {
                    const noteContent = this.value;
                    document.getElementById('sendContent').value = noteContent;
                    document.getElementById('sendTitle').value = noteContent;
                                    
                });
            });


         //   document.addEventListener('DOMContentLoaded', function() {
        // let cookie = document.cookie.match(/darkmode=([^;]+)/);
        // if (cookie[1] === "true") {
        //     console.log(cookie);
        //     document.body.classList.toggle('dark-mode', true);
        //     let button = document.getElementById('toggleDarkMode');
// 
        // } else {
        //     console.log(cookie);
        //     document.body.classList.toggle('dark-mode', false);
       // }
      //  });
        </script>
    </head>
    <body>
        <div class="container">
            <div class="notes_container">
                <div class="search_container">
                    <input type="text" id="search" name="search" placeholder="Search for notes...">
                </div>
                <div class="notes">
                    $note
                </div>
                <a class="home" href="/">Back to Home</a>

                    
            </div>
            <div class="note_container">
                <div class="note">
                    <textarea class="textarea" id="content" name="content" placeholder="Enter your content here...">$content</textarea>
                </div>
                <div class="toolbar">
                    <div style="display: flex; align-items: center;">
                        <form id="darkModeForm" action="/darkmode" method="post"> 
                            <button class="btn" id="toggleDarkMode" type="submit"><img width="24" height="24" src="https://img.icons8.com/material-rounded/24/do-not-disturb-2.png" alt="do-not-disturb-2"/></button>
                        </form>


                        <form method="post" action="/notepad/deletenote">
                        <input type="number" id="deletenoteIndex" name="deletenoteIndex" value="" hidden>
                        <button class="btn" type="submit"><img width="24" height="24" src="https://img.icons8.com/material-rounded/24/filled-trash.png" alt="filled-trash"/></button>
                        </form>


                        <form action="/save-note" method="post">
                        <input type="number" id="downloadnoteIndex" name="downloadnoteIndex" value="" hidden>
                        <button class="btn" type="submit"><img width="24" height="24" src="https://img.icons8.com/material-rounded/24/downloading-updates.png" alt="downloading-updates"/></button>
                        </form>
                        <form action="/notepad/upload" method="post" enctype="multipart/form-data">
                            <label for="file" class="btn"><img width="24" height="24" src="https://img.icons8.com/material-rounded/24/upload--v1.png" alt="upload--v1"/></label>
                            <input type="file" id="file" name="file" style="display:none" onchange="this.form.submit()">
                        </form>
                    </div>
                    <div class="justify_tools">
                        <input type="radio" id="right" name="justify" value="right" onclick="document.querySelector('textarea').style.textAlign = 'left'">
                        <label for="right"><img width="24" height="24" src="https://img.icons8.com/material-outlined/24/align-left.png" alt="align-left"/></label>
                        <input type="radio" id="center" name="justify" value="center" checked onclick="document.querySelector('textarea').style.textAlign = 'center'">
                        <label for="center"><img width="24" height="24" src="https://img.icons8.com/ios-filled/50/align-center.png" alt="align-center"/></label>
                        <input type="radio" id="left" name="justify" value="left" onclick="document.querySelector('textarea').style.textAlign = 'right'">
                        <label for="left"><img width="24" height="24" src="https://img.icons8.com/ios-filled/50/align-right.png" alt="align-right"/></label>
                    </div>
                    <div style="display: flex; flex-direction: row;">
                        <input type="checkbox" id="lightmode" checked hidden>
                        <label class="btn" for="lightmode"><img width="24" height="24" src="https://img.icons8.com/material-rounded/24/filled-like.png" alt="filled-like"/></label>
                        <form method="post" action="/notepad/savenote">
                            <input type="text" id="sendTitle" name="sendTitle" value="" hidden>
                            <textarea id="sendContent" name="sendContent" value="" hidden></textarea>
                            <input type="number" id="sendIndex" name="sendIndex" value="" hidden>
                            <button class="btn save-btn" id="save"  type="submit"><img width="24" height="24" src="https://img.icons8.com/material-rounded/24/save-close.png" alt="save-close"/></button>
                        </form>

                        <button class="btn" onclick="document.querySelector('textarea').value = ''"><img width="24" height="24" src="https://img.icons8.com/material-rounded/24/plus-2-math--v1.png" alt="plus-2-math--v1"/></button> 
                    </div>
                    
                    
                </div>
            </div>
        </div>
    </body>
    </html>

HTML

    return $html_content;
}

sub create_new_note {
    my ( $title, $content, $key ) = @_;

    my @content_copy = split( /\n/, $content );

    my $labelText = ( substr( $content, 0, 20 ) // '' );
    my $contentText = substr( $content_copy[1] // '', 0, 30 );

    my $html_content = <<HTML;

                <div class="note_item">
                    <input type="checkbox" id="note1" class="checkbox">

                    <input type="radio" id="$labelText" name="$labelText" hidden>
                    <label for="$labelText" class="note_label">
                        <div class="note_title">$labelText</div>
                        <p class="note_content">$contentText ... </p>
                        <span hidden>$content</span>
                        <span hidden id="noteIndex">$key</span>
                    </label>
                </div>

HTML

    return $html_content;
}

sub filemanager_html_structure {
    my ($file_list) = @_;

    my $html_content = <<HTML;
    <html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>File Manager</title>
<style>
  $cloud_css
    p{}
</style>

</head>
<body>
<div class="container">
    <a  href="/">Back to Home</a>
    <h1>File Manager</h1>
    
    <form action="/file/upload" method="post" enctype="multipart/form-data">
        <label for="name">File name:<span> *</span></label>
        <input type="text" name="name" id="name" required placeholder="Enter a name for the file">

        <label for="file" required>Select a file to upload:<span> *</span></label>
        <input type="file" name="file" id="file">

        <input type="submit" value="Upload">
    </form>
    
</div>
<div class="container">
        <h1>Uploaded Files</h1>
        $file_list
    </div>
</body>
</html>

HTML
    return $html_content;
}

sub get_file_list {
    my ( $filename, $filesize, $filetype ) = @_;
    my $html_content = <<HTML;
    <div class="file-item">
        <div class="file-info">
            <h2><span>File Name: </span>$filename</h2>
            <div>
                <p><span>File Size: </span>$filesize</p>
                <p><span>File Type: </span>$filetype</p>
            </div>
        </div>
        <div class="button-container">
            <form action="/file/download/" method="post">
                <input type="hidden" name="filename" value="$filename">
                <input type="submit" value="Download">
            </form>

            <form action="/file/delete" method="post">
                <input type="hidden" name="filename" value="$filename">
                <input type="submit" value="Delete">
            </form>
        </div>
    </div>
HTML
    return $html_content;
}

sub html_login_page {

    my $html_content = <<HTML;
   <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <style>
        $login_css
        p{}
    </style>
</head>
<body>
    <main class="login-container">
        <section class="photo">
            <img src="https://cdn.pixabay.com/photo/2022/10/03/13/16/houses-7495861_1280.jpg" alt="Photo">
        </section>

        <section class="login-details">
            <div class="top">
                <h1>Welcome Back!</h1>
                <p class="form__description">Please, enter your information</p>
            </div>
            <form action="/user/login" method="post">
                <div class="input-container">
                    <label for="username" class="input-label">Username:</label>
                    <input
                        id="username"
                        type="text"
                        placeholder="Write here..."
                        name="username"
                        class="input-field"
                        required
                    />
                </div>
                <div class="input-container">
                    <label for="password" class="input-label">Password:</label>
                    <input
                        id="password"
                        type="password"
                        placeholder="Write here..."
                        name="password"
                        class="input-field"
                        required
                    />
                </div>

                <input type="submit" value="Login">
            </form>

            <p>Don't have an account? <a href="/register">Register now</a></p>
        </section>
    </main>
</body>
</html>

HTML

    return $html_content;
}

sub html_register_page {


    my $html_content = <<HTML;
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Register</title>
        <style>
        $signup_css
        p{}
        </style>
    </head>
        <body>
            <main class="signup-container">
                <section class="photo">
                    <img src="https://cdn.pixabay.com/photo/2022/07/30/03/13/eibsee-7352987_1280.jpg" alt="Photo">
                </section>

                <section class="signup-details">
                    <div class="top">
                        <h1>Welcome</h1>
                        <p class="form__description">Please, enter your information</p>
                    </div>
                    <form action="/user/register" method="post">
                        <div class="input-container">
                            <label for="username" class="input-label">Username:</label>
                            <input
                                id="username"
                                type="text"
                                placeholder="Write here..."
                                name="username"
                                class="input-field"
                                required
                            />
                        </div>
                        <div class="input-container">
                            <label for="password" class="input-label">Password:</label>
                            <input
                                id="password"
                                type="password"
                                placeholder="Write here..."
                                name="password"
                                class="input-field"
                                required
                            />
                        </div>
                        <div class="input-container">
                            <label for="email" class="input-label">Email:</label>
                            <input
                                id="email"
                                type="email"
                                placeholder="Write here..."
                                name="email"
                                class="input-field"
                                required
                            />
                        </div>
                        <div class="input-container">
                            <label for="display-name" class="input-label">Display Name:</label>
                            <input
                                id="display-name"
                                type="text"
                                placeholder="Write here..."
                                name="display-name"
                                class="input-field"
                                required
                            />
                        </div>
                        <div class="input-container">
                            <label for="dob" class="input-label">Date of Birth:</label>
                            <div class="date-input">
                                <input
                                    id="dob-day"
                                    type="number"
                                    placeholder="DD"
                                    name="dob-day"
                                    class="input-field"
                                    min="1"
                                    max="31"
                                    required
                                />
                                <div class="date-separator">/</div>
                                <input
                                    id="dob-month"
                                    type="number"
                                    placeholder="MM"
                                    name="dob-month"
                                    class="input-field"
                                    min="1"
                                    max="12"
                                    required
                                />
                                <div class="date-separator">/</div>
                                <input
                                    id="dob-year"
                                    type="number"
                                    placeholder="YYYY"
                                    name="dob-year"
                                    class="input-field"
                                    min="1900"
                                    max="2100"
                                    required
                                />

                            </div>
                        </div>
                        <input type="submit" value="Register">
                    </form>
                    <p>Already have an account? <a href="/login">Login now</a></p>
                </section>
            </main>
    </body>
    </html>

HTML


    return $html_content;
}


sub html_error_page {
    my ($error_message, $path, $error_link) = @_;
    my $html_content = <<HTML;
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Error</title>
        <style>
        $error_css
        p{}
        </style>
    </head>
        <body>
            <main>
                <h1>Error</h1>
                <p>$error_message</p>
                <a href="/$path">$error_link</a>
            </main>
    </body>
    </html>

HTML
    return $html_content;
}



sub html_navbar {

    my $html_content = <<HTML;
    <nav class="navbar">
    <ul class="navbar__list">
            <li class="navbar__item"><a href="/home">Home</a></li>
            <li class="navbar__item"><a href="/about">About</a></li>
            <li class="navbar__item"><a href="/contact">Contact</a></li>
    </ul>
    </nav>

HTML
return $html_content;
}





sub calender_html {
    my ($html_title) = @_;

    my $html_content = <<HTML;
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$html_title</title>
    <style>
      $calender_css   
      p {
      }
    </style>
</head>
<body>
    <div class="main">
        <a class="home" href="/">Back to Home</a>

    <br/>
    <div class="year">
      <a href="/feiertags/year/previous" style="text-decoration: none;">
        <img width="48" height="48" src="https://img.icons8.com/fluency/48/back.png" alt="back"/>
      </a>
      <a href="/feiertags/year/2024" class="btn" style="text-decoration: none; font-size: 20px;">
          2024
      </a>
      <a href="/feiertags/year/next" style="text-decoration: none;">
          <img width="48" height="48" src="https://img.icons8.com/fluency/48/back.png" alt="next" style="rotate:180deg;"/>
      </a>
    </div>
    <br/>
    <br/>

    <div class="months">
        <a href="/feiertags/year/2024/month/1" class="btn">Januar</a>
        <a href="/feiertags/year/2024/month/2" class="btn">Februar</a>
        <a href="/feiertags/year/2024/month/3" class="btn">März</a>
        <a href="/feiertags/year/2024/month/4" class="btn">April</a>
        <a href="/feiertags/year/2024/month/5" class="btn">Mai</a>
        <a href="/feiertags/year/2024/month/6" class="btn">Juni</a>
        <a href="/feiertags/year/2024/month/7" class="btn">Juli</a>
        <a href="/feiertags/year/2024/month/8" class="btn">August</a>
        <a href="/feiertags/year/2024/month/9" class="btn">September</a>
        <a href="/feiertags/year/2024/month/10" class="btn">Oktober</a>
        <a href="/feiertags/year/2024/month/11" class="btn">November</a>
        <a href="/feiertags/year/2024/month/12" class="btn">Dezember</a>
    </div>

    <form method="post" action="/feiertags/search">
        <input type="date" id="feiertag" name="feiertag" format="dd-MM-yyyy" placeholder="Search a Feiertag" />
        <button type="submit" value="Submit" class="btn">Search</button>
    </form>
</div>

</body>
</html>

HTML

    return $html_content;
}

## End ###

sub open_note {
    my ($note_add) = @_;

    # print "Note added: $note_add\n";

    open( my $fh, "<", $note_add ) or die $!;
    my $content = do { local $/; <$fh> };
    close $fh;

    return $content;
}

sub save_note {
    my ( $note_add, $content ) = @_;

    # print "Note added: $note_add\n";

    open( my $fh, ">", $note_add ) or die $!;
    print $fh $content;
    close $fh;

    # print "Note saved successfully\n";
    return $content;
}

sub PAGE_NOT_FOUND {
    my $html_content = <<HTML;
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found</title>
    <style>
      $notfound
       p{}
    </style>
</head>
<body>
    <div class="container">
        <img src="https://via.placeholder.com/400x200?text=404+Error" alt="404" class="illustration">
        <h1>Oops! Page Not Found</h1>
        <p>We're sorry, but the page you're looking for doesn't exist. It might have been removed, renamed, or is temporarily unavailable.</p>
        <a href="/">Go B to Home</a>
    </div>
</body>
</html>

HTML
    return $html_content;
}




sub Alert_page {
    my ($page, $message, $redirect) = @_;

    print "Page: $page\n";

    my $html_content;

    if ($page eq "error") {
        $html_content = <<HTML;
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>404 - Page Not Found</title>
        <style>
        $alert_page
        p{}
        </style>
    </head>
    <body>
        <div class="container">
            <img src="https://via.placeholder.com/400x200?text=Something+Went+Wrong" alt="Error" class="illustration">
            <h1>Error!</h1>
            <p>$message</p>
            <a href="/">Try Again</a>
        </div>
    </body>
    </html>

HTML
    } elsif ($page eq "success") {
        $html_content = <<HTML;
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>404 - Page Not Found</title>
        <style>
        $alert_page
        p{}
        </style>
    </head>
    <body>
        <div class="container">
            <img src="https://via.placeholder.com/400x200?text=Success" alt="Success" class="illustration">
            <h1>Success!</h1>
            <p>$message</p>
            <a href="/">$redirect</a>
        </div>
    </body>
    </html>

HTML
    } elsif ($page eq "warning") {
        $html_content = <<HTML;
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>WARNING</title>
            <style>
                
              $alert_page
               p{}
            </style>
        </head>
        <body>
            <div class="container">
                <img src="https://via.placeholder.com/400x200?text=Warning" alt="Warning" class="illustration">
                <h1>Warning!</h1>
                <p>$message</p>
                <a href="/">Go Back Home</a>
            </div>
        </body>
        </html>

HTML
    }

    return $html_content;
}




#* Multi Factor Authentication Page

sub MFA_page {

    my $html_content = <<HTML;
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MFA</title>
    <style>
      $MFA_page
      p{}
    </style>
</head>
<body>
    <div class="container">
        <a href="/">Go Back Home</a>
        <h1>MFA</h1>
        <p>Multi Factor Authentication</p>
        
        <img src="qrcodes/qrcode.png" alt="MFA Illustration" width="500" height="500" class="illustration">
        
        <form action="/mfa/verify" method="post">
            <label for="code">Enter Code:</label>
            <input type="text" id="code" name="code" required>
            <input type="submit" value="Verify">
        </form>
    </div>
</body>
</html>
HTML

    return $html_content;
}


sub html_mfa_verify_page {
    
    my $html_content = <<HTML;
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MFA</title>
    <style>
      $MFA_page
      p{}
    </style>
</head>
<body>
    <div class="container">
        <h1>MFA</h1>
        <p>Multi Factor Authentication</p>
        
        
        <form action="/mfa/verify" method="post">
            <label for="code">Enter Code:</label>
            <input type="text" id="code" name="code" required>
            <input type="submit" value="Verify">
        </form>
    </div>
</body>
</html>
HTML

    return $html_content;
}










sub snake_game {

    my $game = shift;
    my $player = shift;

    my $board = game_board(20, 20);


    my $html_content = <<HTML;
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Snake Game</title>
        <style>
            $snake_game
            p{}
        </style>
        <script>
            $snake_game_js
        </script>
    </head>
    <body>
        <div id="direction"     hidden></div>
        <div id="search-cell" hidden>
            <input type="number" placeholder="x" id="x">
            <input type="number" placeholder="y" id="y">

            <button id="search">Search</button>
        </div>
        <h1>Snake Game</h1>
        <div id="score-container"> 
            <div>
            <h2>Score: </h2>
            <h2 id="score"> 0</h2>
            </div>
            <div id="time" >00:00</div>
        </div>
        <div class="button-container">
            <div> 
                <label id="difficulty-label" for="difficulty">Difficulty:</label>
                <select id="difficulty">
                    <option value="easy" selected>Easy</option>
                    <option value="medium">Medium</option>
                    <option value="hard">Hard</option>
                </select>
            </div>
            <button class="button" id="start">Start Game</button>

        </div>
        <div class="container">
            $board
        </div>

        <div id="game-over">
            <h1>Game Over</h1>
            <p>Score: <span id="game-over-score" >0</span></p>
            <p>Time: <span id="game-over-time"  >00:00</span></p>
            <button class="button" id="play-again">Play Again</button>
        </div>
    </body>
    </html>

HTML
    return $html_content;
}

sub make_ball {

    my ($x, $y) = @_;

    # my $img = ($ball eq "ball-$x-$y") ? '🍎' : '';
    # my $ball_postition = ($ball eq "ball-$x-$y") ? 'ball' : '';

    my $html_content = <<HTML;
    <div class="board-cell " id=$x-$y>
    </div>

HTML
    return $html_content;
}

sub make_snake {
    my ($x, $y) = @_;

    # my $snake_postition = ($snake eq "snake-$x-$y") ? 'active' : '';

    my $html_content = <<HTML;
    <div class="snake-cell" id=$x/$y>
    </div>

HTML
    return $html_content;
}

sub game_board {
    my ($x, $y) = @_;

    # my $ball = "ball-" . int(rand($x)) . "-" . int(rand($y));
    # my $snake = "snake-" . int(rand($x)) . "-" . int(rand($y));


    # if ($ball eq $snake) {
    #     $snake = "snake-" . int(rand($x)) . "-" . int(rand($y));
    # }
    my $board = '';
    my $snake_element = '';

    for (my $i = 0; $i < $y; $i++) {
        for (my $j = 0; $j < $x; $j++) {
            $board .= make_ball($j, $i);
            $snake_element .= make_snake($j, $i);
        }
    }

    my $html_content = <<HTML;
    <div class="board">
         $board
    </div>
    <div class="snake"> 
        $snake_element
    </div>
    
HTML

    return $html_content;
}




sub snake_game_v2 {

    my $html_content = <<HTML;
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
    </head>
    <body>
    <svg width="300px" height="175px" version="1.1">
        <path fill="transparent" stroke="#000000" stroke-width="4" d="M10 80 Q 77.5 10, 145 80 T 280 80" class="path"></path>
    </svg>


    </body>
    </html>
HTML

    return $html_content;

}


1;