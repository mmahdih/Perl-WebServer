
#!/usr/bin/perl
use strict;
use warnings;
use MIME::Entity;
use Net::SMTP::TLS;

# Gmail SMTP server details
my $smtp_server = 'smtp.gmail.com';
my $smtp_port   = 587;  # Gmail's port for TLS
my $username    = 'your_email@gmail.com';  # Replace with your Gmail address
my $password    = 'your_app_password';     # Replace with your app-specific password

# Create the MIME entity (email message)
my $email = MIME::Entity->build(
    Type    => "multipart/mixed",
    From    => $username,
    To      => 'empfanger@gmail.com',
    Subject => 'Here is your document',
);

# Add a plain text part to the email
$email->attach(
    Type => "text/plain",
    Data => "Dear User,\n\nPlease find the document attached.\n\nBest regards,\nThe Team"
);

# Add a PDF attachment to the email
$email->attach(
    Path        => "C:/Users/Haidary/Documents/NASA_SRTM3/file.pdf", # Corrected file path
    Type        => "application/pdf",
    Encoding    => "base64",
    Disposition => "attachment",
    Filename    => "file.pdf"
);

# Convert the MIME entity to a string (including headers)
my $msg_string = $email->stringify;

# Sending the email using Net::SMTP::TLS for a secure connection
my $smtp = Net::SMTP::TLS->new(
    $smtp_server,
    Port     => $smtp_port,
    User     => $username,
    Password => $password,
    Timeout  => 30,
    Debug    => 1,
);

# Send the email
$smtp->mail($username);
$smtp->to('empfanger@gmail.com');
$smtp->data();
$smtp->datasend($msg_string);
$smtp->dataend();

$smtp->quit;

print "Email sent successfully!\n";
