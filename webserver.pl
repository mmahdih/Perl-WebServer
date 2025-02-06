use strict;
use warnings;
use Socket;
use IO::Handle;
use IO::Select;
use HTTP::Request;
use HTTP::Response;
use Digest::SHA qw(sha1_base64);
use JSON;
# use HTTP::Cookies;
use Cwd;

# import modules
use lib ".";
use lib '/home/lapdev/Mein/Perl-WebServer/packages';
use lib '/home/lapdev/Mein/Perl-WebServer/packages/utils';
use html_structure;
use HTTP_RESPONSE;
use kalender;
use file_manager;
use notepad;
use handle_get_requests;
use handle_post_requests;
use user_manager;
use cookies;


#variables
my $base_dir = getcwd();
my $server_port = 1212;
my $select;
my @ready;
my @connected;
my %clients;
my %notes;

my $uri = "";
my $method = "";

##################################
# Socket Connection Server Setup #
##################################

# create a socket
socket( my $server, PF_INET, SOCK_STREAM, 0 ) or die "socket: $!";

# connect to the server
bind( $server, sockaddr_in( $server_port, INADDR_ANY ) ) or die "bind: $!";

# listen for incoming connections
listen( $server, 10 ) or die "listen: $!";

print "Server listening on port $server_port\n";
print "Waiting for connections...\n";

$select = IO::Select->new($server);


#################################
# Socket Connection Server Loop #
#################################

while (1) {
    if ( $select->can_read(0) ) {
        @ready = $select->can_read(0);
        foreach my $client (@ready) {
            if ( $client eq $server ) {

                # accept a new connection
                my $client_addr = accept( my $client_socket, $server );

                # my $client_socket = acc$server->accept or die "accept: $!";
                $select->add($client_socket);
                $clients{$client}{status} = 'Connected';

                # get the client's address
                my ( $client_port, $client_ip ) = sockaddr_in($client_addr);
                $client_ip = inet_ntoa($client_ip);
                print "Client connected from $client_ip:$client_port\n\n";
            }
            else {

                my $request = "";
                if (!$clients{$client}{request}) {
                    $clients{$client}{request_length} = 0;
                    $clients{$client}{content_length} = 0;

                    my $buffer;
                    recv( $client, $buffer, 1024, 0 );
                    if (!$buffer) {
                        print "No data received from client\n";
                        $select->remove($client);
                        close $client;
                        next;
                    }
                    $request = $buffer;
                    # print "Request from client: \n$request\n";
                    
                    $clients{$client}{request} = $request;
                    my $content_length;
                    if ( $request =~ /Content-Length: (\d+)\r/ ) {
                        $content_length = $1;
                        $clients{$client}{content_length} = $content_length;
                        my ( $header, $body ) = split( /\r\n\r\n/, $request );

                        my $request_length = length($body);
                        $clients{$client}{request_length} = $request_length;

                    }
                }

                

                my $buffer;

                if ($clients{$client}{content_length} && $clients{$client}{request_length} < $clients{$client}{content_length}) {
                    recv( $client, $buffer, 1024, 0 );
                    $request .= $buffer;
                    $clients{$client}{request} .= $buffer;
                    $clients{$client}{request_length} += length($buffer);
                } 

                # print "Request from client: \n$clients{$client}{request}\n";


                if ($clients{$client}{request_length} >= $clients{$client}{content_length}  || length($buffer) < 1024) {
                    my $client_request = $clients{$client}{request};
                    my $req = HTTP::Request->parse($clients{$client}{request});
                    my $method = $req->method;
                    my $uri = $req->uri;

                    if (!$method || !$uri) {
                        next;
                    }
                    ############################
                    # Handle All POST requests #
                    ############################
                    if ( $method eq 'POST' ) {
                        print("POSTI\n");       
                        print("URI: $uri\n");                 
                        #####################################
                        # Handle All POST requests of Login #
                        #####################################
                        if( $uri =~ "/user/login" ) {
                            my ($result, $cookie ) = user_manager::handle_login_user( $client, $req );


                            if ($result eq "success") {
                                print "REQUEST: \n", $req->as_string, "\n";
                                my $body = html_structure::Alert_page("success", "Logged in successful", "Home");
                                my $res = HTTP_RESPONSE::GET_OK_200_with_cookie( $body, $cookie );
                                print $client $res;
                                $select->remove($client);
                                close $client;
                                print "Connection closed.\n";
                                print "\n";
                                print "\n";
                            } elsif ($result eq "failed") {
                                my $body = html_structure::Alert_page("error", "Login failed\n Please check your username and password and try again.");
                                my $res = HTTP_RESPONSE::BAD_REQUEST_400($body);
                                print $client $res;
                                $select->remove($client);
                                close $client;
                                print "Connection closed.\n";
                                print "\n";
                                print "\n";
                            }
                        }

                        elsif ( $uri =~ "/user/register" ) {
                            my ($result ) = user_manager::handle_register_user( $client, $req );

                            if ($result eq "registered") {
                                my $body = html_structure::Alert_page("success", "Registered successful", "Login");
                                my $res = HTTP_RESPONSE::GET_OK_200( $body);
                                print $client $res;   
                            } elsif ($result eq "exists") {
                                my $body =  html_structure::Alert_page("error", "Username already exists");
                                my $res = HTTP_RESPONSE::BAD_REQUEST_400($body);
                                print $client $res;
                            }
                            $select->remove($client);
                            close $client;
                            print "Connection closed.\n";
                            print "\n";
                            print "\n";
                        }

                        elsif ( $uri =~ "/user/logout" ) {
                            my ($result) = user_manager::handle_logout_user( $client, $req );
                            print "\nresult   : $result\n";
                            # print $result;
                            my $res = HTTP_RESPONSE::REDIRECT_303_with_cookie( "Logged out successful", "/login", $result );
                            print $client $res;
                            $select->remove($client);
                            close $client;
                            print "Connection closed.\n";
                            print "\n";
                            print "\n";
                        }

                        ###########################################
                        # Handle All POST requests of Cloud Drive #
                        ###########################################
                        elsif ( $uri =~ "/file/upload" ) {
                            my ($result, $username, $user_role) = user_manager::user_login_check($client, $req);

                            if ($result eq "success") {
                                file_manager::handle_save_file( $client, $req, $username, $user_role );
                                my $res = HTTP_RESPONSE::REDIRECT_303( "Upload successful", "/filemanager" );
                                print $client $res;
                            } elsif ($result eq "fail") {
                                my $body = html_structure::html_error_page("You are not logged in", "/login", "Back to login");
                                my $res = HTTP_RESPONSE::BAD_REQUEST_400($body);
                                print $client $res;
                            }
                            $select->remove($client);
                            close $client;
                            print "Connection closed.\n";
                            print "\n";
                            print "\n";
                        }

                        elsif ( $uri =~ "/file/delete" ) {
                            my ($result, $username, $user_role) = user_manager::user_login_check($client, $req);

                            if ($result eq "success") {
                            file_manager::handle_delete_file($client, $req, $username, $user_role);
                            print $client HTTP_RESPONSE::REDIRECT_303( "File deleted",
                                "/filemanager" );

                            } elsif ($result eq "fail") {
                                my $body = html_structure::html_error_page("You are not logged in", "/login", "Back to login");
                                my $res = HTTP_RESPONSE::BAD_REQUEST_400($body);
                                print $client $res;
                            }
                            $select->remove($client);
                            close $client;
                            print "Connection closed.\n";
                            print "\n";
                            print "\n";
                        }

                        elsif ( $uri =~ "/file/download" ) {
                            my ($result, $username, $user_role) = user_manager::user_login_check($client, $req);

                            if ($result eq "success") {
                                my ($data, $filename) = file_manager::handle_download_file($client, $req, $username, $user_role);

                            if ( defined $data ) {
                                my $res = HTTP_RESPONSE::POST_SENDFILE_200( $data, $filename,
                                    "/filemanager" );
                                print $client $res;
                            }
                            else {
                                print $client HTTP_RESPONSE::NOT_FOUND_404(
                                    html_structure::PAGE_NOT_FOUND() );
                            }
                            } elsif ($result eq "fail") {
                                my $body = html_structure::html_error_page("You are not logged in", "/login", "Back to login");
                                my $res = HTTP_RESPONSE::BAD_REQUEST_400($body);
                                print $client $res;
                            }
                            
                            $select->remove($client);
                            close $client;
                            print "Connection closed.\n";
                            print "\n";
                            print "\n";
                        }
                    

                    #######################################
                    # Handle All POST requests of notepad #
                    #######################################

                    ###  Save note  ###
                    elsif ( $uri eq '/notepad/savenote' ) {
                        print "BLALALALALALALALALAA\n";
                        Notepad::save_note_on_server($client, $req, %notes);

                        my $res = HTTP_RESPONSE::REDIRECT_303( undef, "/notepad" );
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    ###  Delete note  ###
                    elsif ( $uri eq '/notepad/deletenote' ) {
                        Notepad::delete_note_on_server($client, $req, %notes);

                        my $res = HTTP_RESPONSE::REDIRECT_303( undef, "/notepad" );
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";

                    }

                    ###  Download note  ###
                    elsif ( $uri eq '/save-note' ) {

                        my ($data, $filename) = Notepad::download_note_on_clientside($client, $req, %notes);

                        if ( defined $data ) {
                            my $res = HTTP_RESPONSE::POST_SENDFILE_200( $data, $filename, "/notepad" );
                            print $client $res;
                        }
                        else {
                            print $client HTTP_RESPONSE::NOT_FOUND_404(html_structure::PAGE_NOT_FOUND());
                        }
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    ### dark mode ###
                    elsif ( $uri eq '/darkmode' ) {
                        my ($cookie) = Notepad::notepad_darkmode($req);
                        print "cookie: $cookie\n";
                        print "REQUEST: $req\n";

                        print $client HTTP_RESPONSE::REDIRECT_303_with_cookie( undef, "/notepad", $cookie );
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    elsif ( $uri eq '/notepad/upload' ) {
                        Notepad::handle_upload_note($client, $req, %notes);
                        
                        print $client HTTP_RESPONSE::REDIRECT_303( "Upload successful", "/notepad" );
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }


                    ########################################
                    # Handle All POST requests of Calender #
                    ########################################

                    ###  Get a feiertag  ###
                    elsif ( $uri eq '/feiertags/search' ) {
                        print "req:\n";
                        # Generate final HTML response
                        my $body = html_structure::html_structure_v2(Kalender::get_kalender($req));
                        my $res  = HTTP_RESPONSE::POST_OK_200($body);

                        # Send response to client
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";

                    }

                    elsif ( $uri eq '/feiertags/year/previous' ) {
                        
                        print $client HTTP_RESPONSE::REDIRECT_303( "previous", "/previous" );
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    elsif ( $uri eq '/feiertags/year/next' ) {

                        print $client HTTP_RESPONSE::REDIRECT_303( "next", "/next" );
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    ### Get by Date ###
                    elsif ($uri =~ m/^\/feiertags\/year\/(\d+)\/month\/(\d+)\/day\/(\d+)$/ )
                    {
                        my ( $year, $month, $day ) = ( $1, $2, $3 );
                        
                        # Generate final HTML response
                        my $body = html_structure::html_structure_v2(Kalender::get_day($day, $month, $year));
                        my $res = HTTP_RESPONSE::GET_OK_200($body);
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";

                    }

                    elsif ( $uri =~ m/^\/feiertags\/year\/(\d+)\/month\/(\d+)/ ) {
                        my ( $year, $month ) = ( $1, $2 );

                        # Generate final HTML response
                        my $body = html_structure::html_structure_v2(Kalender::get_months($month, $year));
                        my $res  = HTTP_RESPONSE::GET_OK_200($body);

                        # Send response to client
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";

                    }

                    elsif ( $uri =~ m/^\/feiertags\/year\/(\d+)/ ) {

                        my $year = $1;

                        # Generate final HTML response
                        my $body = html_structure::html_structure_v2(Kalender::get_year($year));
                        my $res = HTTP_RESPONSE::GET_OK_200($body);

                        # Send response to client
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    elsif ( $uri eq '/feiertags/today' ) {

                        my $response = "HTTP/1.1 200 OK\r\n";
                        $response .= "Content-Type: text/html\r\n";
                        $response .= "\r\n";

                        # Start of HTML body content
                        my $bodydata = "";
                        my $holiday = endPoints::get_feiertags_of_today();
                        my $today   = localtime->dmy('/');
                        $bodydata .= html_structure::event_structure( $today, $holiday );

                        # Generate final HTML response
                        my $body = html_structure::html_structure_v2($bodydata);

                        # Send response to client
                        print $client $response . $body;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }
}

                }

                my $req = HTTP::Request->parse($clients{$client}{request});
                # print "REQUEST: in GET\n";
                # print $req->as_string();
                my $head = $req->headers;
                $method = $req->method;
                $uri = $req->uri;


                if (defined $head->header('Sec-WebSocket-Key')) {
                    print "Websocket connection detected.\n";
                    my $key = sha1_base64($head->header('Sec-WebSocket-Key') . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11') . "=";
                    print $client "HTTP/1.1 101 Switching Protocols\r\n";
                    print $client "Upgrade: websocket\r\n";
                    print $client "Connection: Upgrade\r\n";
                    print $client "Sec-WebSocket-Accept: $key\r\n\r\n";
                    print "Websocket connection established.\n";

                } else {
                    # print "No websocket connection detected.\n";

                }

                ###########################
                # Handle All GET requests #
                ###########################
                if ( $method eq 'GET' ) {
                    
                    if ( $uri eq '/' ) {

                        
                        # print "Welcome to the Perl HTTP Server!\n";
                        # # print $req->as_string();
                        # print "\n";
                        # print "End_of_request\n";
                        # # Generate final HTML response

                        # print "Request from client: \n$clients{$client}{request}\n";


                        my $cookie_header = $head->header('Cookie');
                        my ($cookies) = $cookie_header && $cookie_header =~ /session_id=([^;]+)/;
                        if (defined $cookies) {
                            print $cookies . "\n";
                            print "Cookie found\n";
                            print "User is logged in.\n";
                            print "Redirecting to home page.\n";

                            # Generate final HTML response
                            my $res  = HTTP_RESPONSE::REDIRECT_303( $cookies, "/home" );
                            print $client $res;
                        } else {
                            print "No cookie found\n";
                            print "User is not logged in.\n";
                            print "Redirecting to login page.\n";

                            # Generate final HTML response
                            my $res  = HTTP_RESPONSE::REDIRECT_303( "", "/login" );
                            print $client $res;
                        }

                        # Send response to client
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }
                    
                    # home #
                    elsif ( $uri eq '/home' ) {
                        my $page_title = "Home";
                        # my ($cookie) = $head =~ /^Cookie: (.*)$/m;
                        # my %cookies = split(/;/, $cookie);
                        # my $session_id = $cookies{session_id};
                        # my $header = $req->as_string;
                        # print "User ID: $session_id\n";

                        my ($result, $username, $user_role, $display_name) = user_manager::user_login_check($client, $req);
                        print "Display Name: $display_name\n";
                        if ($result eq "success") {
                            # Generate final HTML response
                            my $body = html_structure::home_page($page_title, $display_name);
                            my $res  = HTTP_RESPONSE::GET_OK_200($body);
                            print $client $res;
                        } elsif ($result eq "failed") {
                            # Generate final HTTP response
                            my $body = html_structure::html_error_page("Unauthorized", "/localhost:1212/login", "Back to login");
                            my $res = HTTP_RESPONSE::UNAUTHORIZED_401($body);
                            print $client $res;
                        }
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    ### GET icon  ###
                    elsif ( $uri eq '/favicon.ico' ) {
                        open my $icon, '<', 'bilder/favicon.ico' or die $!;
                        binmode $icon;

                        my $icon_data = do { local $/; <$icon> };
                        my $date_now = localtime();
                        my $last_modified_date = $date_now;
                        my $res = HTTP_RESPONSE::GET_OK_200_with_cashe($icon_data, $last_modified_date, $date_now);

                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    elsif ( $uri eq "/login" ) {

                        my ($result, $username, $user_role) = user_manager::user_login_check($client, $req);

                        if ($result eq "success") {
                            # Generate final HTML response
                            my $res  = HTTP_RESPONSE::REDIRECT_303( $username, "/home" );
                            print $client $res;
                        } elsif ($result eq "failed") {
                            # Generate final HTML response
                            my $body = html_structure::html_login_page();
                            my $res  = HTTP_RESPONSE::GET_OK_200($body);
                            print $client $res;
                        }
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    elsif ( $uri eq "/register" ) {
                        # Generate final HTML response
                        my $body = html_structure::html_register_page();
                        my $res  = HTTP_RESPONSE::GET_OK_200($body);
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }
                    elsif ( $uri =~ "/filemanager" ) {
                        my ($result, $username, $user_role) = user_manager::user_login_check($client, $req);

                        if ($result eq "success") {
                            my $res_body = html_structure::filemanager_html_structure(file_manager::list_files($username, $user_role));
                        my $res = HTTP_RESPONSE::GET_OK_200($res_body);
                        print $client $res;
                        } elsif ($result eq "failed") {
                            # Generate final HTML response
                            my $body = html_structure::html_error_page("Unauthorized", "/localhost:1212/login", "Back to login");
                            my $res = HTTP_RESPONSE::UNAUTHORIZED_401($body);
                            print $client $res;
                            }
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    elsif ( $uri eq '/notepad' ) {

                    my ($result, $username, $user_role) = user_manager::user_login_check($client, $req);


                    if ($result eq "success") {
                        my $index    = 1;
                        my $dir      = $base_dir . "/notes";
                        opendir( my $dh, $dir ) or do {
                            warn "Could not open directory '$dir': $!";
                            next;
                        };
                        my @entries = readdir($dh);
                        closedir($dh);

                        foreach my $entry (@entries) {
                            next if ( $entry eq '.' || $entry eq '..' );
                            if ( -d "$dir/$entry" ) {
                                next;
                            }
                            else {

                                ## open and read the file
                                my $content = html_structure::open_note("$dir/$entry");
                                my $title   = $entry;

                                # Add notes to the hash for indexing
                                $notes{ $index++ } = {
                                    title   => $title,
                                    content => $content,
                                    number  => $entry
                                };
                            }
                        }

                        # Generate final HTML response
                        my $body =
                        html_structure::notepad_html_structure( "title", "", %notes );
                        my $res = HTTP_RESPONSE::GET_OK_200($body);

                        # Send response to client
                        print $client $res;
                    } elsif ($result eq "failed") {
                        # Generate final HTML response
                        my $body = html_structure::html_error_page("Unauthorized", "/localhost:1212/login", "Back to login");
                        my $res = HTTP_RESPONSE::UNAUTHORIZED_401($body);
                        print $client $res;
                    }
                    $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";

                    } 

                    ### calender ##  
                    elsif ( $uri eq '/calendar' ) {
                        # Generate final HTML response
                        my $body = html_structure::calender_html("Calender");
                        my $res  = HTTP_RESPONSE::GET_OK_200($body);
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    } elsif ( $uri eq '/snake' ) {
                        
                        # Generate final HTML response
                        my $body = html_structure::snake_game();
                        my $res  = HTTP_RESPONSE::GET_OK_200($body);
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    elsif ( $uri eq '/snake/v2' ) {
                        # Generate final HTML response
                        my $body = html_structure::snake_game_v2();
                        my $res  = HTTP_RESPONSE::GET_OK_200($body);
                        print $client $res;
                        $select->remove($client);
                        close $client;
                        print "Connection closed.\n";
                        print "\n";
                        print "\n";
                    }

                    # ### 404 NOT FOUND ###
                    # else {
                    #     my $title = "404 NOT FOUND";

                    #     # Generate final HTML response
                    #     my $body = html_structure::PAGE_NOT_FOUND();
                    #     my $res  = HTTP_RESPONSE::NOT_FOUND_404($body);

                    #     print $client $res;
                    #     $select->remove($client);
                    #     close $client;
                    #     print "Connection closed.\n";
                    #     print "\n";
                    #     print "\n";
                    # }
                }
            }
        }
    }
}

