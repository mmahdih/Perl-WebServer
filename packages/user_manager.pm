package user_manager;

use strict;
use warnings;
use Digest::SHA qw(sha256);
use JSON;
use Data::Dumper;
use URI::Escape;

use Digest::SHA qw(hmac_sha1_hex);
use Convert::Base32;
use GD::Barcode::QRcode;
use GD::Image;
use MIME::Base32 qw( encode_base32 );

use lib '.';
use lib "/home/lapdev/Mein/Perl-WebServer/packages";


my $base_dir = '/home/lapdev/Mein/Perl-WebServer';



sub handle_login_user {
    my ( $client, $req ) = @_;

    my ($username) = $req->content =~ m/username=([^&]+)/;
    my ($password) = $req->content =~ m/password=([^&]+)/;

    print "Username: $username\n";
    print "Password: $password\n";
    my $userId;
    my $password_hash = Digest::SHA->new(256)->add($password)->hexdigest;

    print "Password Hash: $password_hash\n";

    my $sessionId = int(rand(1000000000000000000000000) + 1000000000000000000000000);

    my $users;
    if ( -s "$base_dir/User/user_data.json" ) {
        open my $fh, '<', "$base_dir/User/user_data.json" or die $!;
        local $/ = undef;
        my $json_data = <$fh>;
        $users = decode_json($json_data);
        close $fh;
    } else {
        $users = [];
    }

    my $found = 0;
    foreach my $user (@$users) {
        if ( $user->{username} eq $username && $user->{password} eq $password_hash ) {
            print "Login successful\n";
            $user->{session_id} = $sessionId;
            print "Session ID: $sessionId\n";
            open my $fh, '>', "$base_dir/User/user_data.json" or die $!;
            print $fh encode_json($users);
            close $fh;
            $found = 1;
            return "success", "session_id=$sessionId", $sessionId;
        }
    }

    if ($found == 0) {
        print "Login failed\n";
        return "failed";
    }
    
}
sub handle_logout_user {
    my ( $client, $req ) = @_;
    my $cookies = "";
    ($cookies) = $req->headers->header('Cookie') =~ /session_id=([^;]+)/;
     print "Session ID: $cookies\n";
    my $delete_cookies = "session_id=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/";

    my $users = [];
    open my $fh, '<', "$base_dir/User/user_data.json" or die $!;
    local $/ = undef;
    my $json_data = <$fh>;
    if ($json_data) {
        $users = decode_json($json_data);
    }
    close $fh;

    print "Logout successful\n";
    print Dumper($users);

    foreach my $user (@$users) {
        print "Session ID: $user->{session_id}\n";
        if (defined $user->{session_id} && $user->{session_id} eq $cookies) {
            $user->{session_id} = undef;
            print 'user session id deleted\n';
            open my $fh, '>', "$base_dir/User/user_data.json" or die $!;
            print $fh encode_json($users);
            close $fh;
        }
    }

    return $delete_cookies;
}

sub handle_register_user {
    my ( $client, $req ) = @_;

    my $body = $req->content;
    print "Body: $body\n";

    my ($username) = $req->content =~ m/username=([^&]+)/;
    $username = uri_unescape($username);
    my ($password) = $req->content =~ m/password=([^&]+)/;
    $password = uri_unescape($password);
    my ($email) = $req->content =~ m/email=([^&]+)/;
    $email = uri_unescape($email);
    my ($display_name) = $req->content =~ m/display-name=([^&]+)/;
    $display_name = join ' ', map { ucfirst } split / /, uri_unescape($display_name);




    my ($dob_day) = $req->content =~ m/dob-day=([^&]+)/;
    my ($dob_month) = $req->content =~ m/dob-month=([^&]+)/;
    my ($dob_year) = $req->content =~ m/dob-year=([^&]+)/;

    my ($dob) = "$dob_day/$dob_month/$dob_year";




    # print "Username: $username\n";
    # print "Password: $password\n";
    # print "Email: $email\n";
    # print "Display Name: $display_name\n";
    # print "Dob: $dob\n";

    my $userId = int(rand(1000000000) + 1000000000);
    my $password_hash = Digest::SHA->new(256)->add($password)->hexdigest;

    # Initialize $users as an empty array
    my $users = [];

    # Try to open and read the user_data.json file
    if (open my $user_handler, '<', "$base_dir/User/user_data.json") {
        local $/ = undef;
        my $json_data = <$user_handler>;
        close $user_handler;

        # Check if the file is not empty
        if ($json_data) {
            $users = decode_json($json_data);
        }
    } else {
        print "Could not open file: $!\n";
    }

    # Check if username already exists
    foreach my $user (@$users) {
        if ($user->{username} eq $username) {
            print "User already exists!\n";
            return "exists";
        }
    }

    # If $users is empty, set the id to 1, otherwise increment the last user's id
    my $id = @$users ? $users->[-1]->{index} + 1 : 1;

    push @$users, {
        index       => $id,
        user_id          => $userId,
        session_id => undef,
        username    => $username,
        password    => $password_hash,
        role => 'user',
        email => $email,
        display_name => $display_name,
        dob => $dob,
        # created_at => time, # ! This might make trouble
        multi_factor_auth => 0,
        multi_factor_auth_code => undef
    };

    # mkdir "$base_dir/User/$username" unless -d "$base_dir/User/$username";

    # Try to open and write to the user_data.json file
    if (open my $fh, '>', "$base_dir/User/user_data.json") {
        print $fh encode_json($users);
        close $fh;
        print "User registered successfully!\n";
        return "registered";
    } else {
        print "Could not open file for writing: $!\n";
        return "error";
    }
}


sub user_login_check {
    my ( $client, $req , $page_title) = @_; 

    my $username = "";
    my $user_role = "";
    my $display_name = "";


    my $cookie_header = $req->headers->header('Cookie');
    my ($cookies) = $cookie_header && $cookie_header =~ /session_id=([^;]+)/;
    
    if (defined $cookies) {
        my $users = [];
        if (open my $user_handler, '<', "$base_dir/User/user_data.json"){
        local $/ = undef;
        my $json_data = <$user_handler>;
        if ($json_data) {
            $users = decode_json($json_data);
        }


        foreach my $user (@$users) {
            if ($user->{session_id} eq $cookies) {
                $username = $user->{username};
                $user_role = $user->{role};
                $display_name = $user->{display_name};
                print "User is logged in.\n";
                print "Session IDD: $cookies\n";
                last;
            } else {
                next;
            } 
        }
        close $user_handler;
        } else {
            print "Error reading user data.\n";
            print "Exiting...\n";
            exit;
        }


        return "success", $username, $user_role, $display_name;
    } else {
        print "No cookie found\n";
        print "User is not logged in.\n";
        print "Redirecting to login page.\n";
        return "failed"
    }


}

sub handle_mfa_verify {
    my ( $client, $req ) = @_;
    

    print "MFA Verification\n";
    my $req_body = $req->content;
    my ($mfa_code_user_input) = $req_body =~ m/code=([^&]+)/;
    print "MFA Code: $mfa_code_user_input\n";

    my $secret_code = "";
    my $username = "";

    my $cookie_header = $req->headers->header('Cookie');
    my ($cookies) = $cookie_header && $cookie_header =~ /session_id=([^;]+)/;


    
    my $users;
    if ( -s "$base_dir/User/user_data.json" ) {
        open my $fh, '<', "$base_dir/User/user_data.json" or die $!;
        local $/ = undef;
        my $json_data = <$fh>;
        $users = decode_json($json_data);
        close $fh;
    } else {
        $users = [];
    }

    my $found = 0;
    foreach my $user (@$users) {
        if ( $user->{session_id} eq $cookies ) {
            print "Login successful\n";
            $username = $user->{username};
            $secret_code = $user->{multi_factor_auth_code};
            $found = 1;

        }
    }
    
    print "Secret Code: $secret_code\n";
    my $current_number = generate_current_number($secret_code);
    print "Current Number: $current_number\n";
    if ($current_number eq $mfa_code_user_input) {
        print "MFA Verification successful\n";
        foreach my $user (@$users) {
            if ( $user->{session_id} eq $cookies ) {
                $user->{multi_factor_auth} = 1;
                open my $fh, '>', "$base_dir/User/user_data.json" or die $!;
                print $fh encode_json($users);
                close $fh;
                return "success";
            }
        }
    } else {
        print "MFA Verification failed\n";
        return "failed";
    }



}




sub generate_current_number {
    my ($base32_secret) = @_;

    my $decode = Convert::Base32::decode_base32($base32_secret);

    my $current_UNIX_time = time();
    my $time_step = int($current_UNIX_time / 30);       # 30 seconds
    $time_step = pack("Q>", $time_step);

    my $hmac_sha1_hex = hmac_sha1_hex($time_step, $decode);

    my $offset = hex(substr($hmac_sha1_hex, length($hmac_sha1_hex) - 1, 1));
    my $truncated_hash = substr($hmac_sha1_hex, $offset * 2, 8);
    my $encrypted = hex($truncated_hash) & 0x7fffffff;
    my $token = $encrypted % 1000000;

    return sprintf("%06d", $token);
}


1;
