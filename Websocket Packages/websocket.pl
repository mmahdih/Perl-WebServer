use strict;
use warnings;
use IO::Socket::INET;

# Create a simple TCP server
my $server = IO::Socket::INET->new(
    LocalPort => 8080,
    Listen    => 5,
    Proto     => 'tcp',
    Reuse     => 1,
) or die "Could not create socket: $!\n";

print "WebSocket server started on port 8080...\n";

while (my $client = $server->accept()) {
    my $request = '';
    $client->recv($request, 1024);

    print "Received request:\n$request\n";

    # Parse HTTP headers
    my %headers;
    if ($request =~ /\r\n\r\n/) {
        my ($header_block) = split /\r\n\r\n/, $request, 2;
        for my $line (split /\r\n/, $header_block) {
            if ($line =~ /^(\S+):\s*(.+)$/) {
                $headers{$1} = $2;
            }
        }
    }

    # Check for Sec-WebSocket-Key
    if (exists $headers{'Sec-WebSocket-Key'}) {
        print "Sec-WebSocket-Key: $headers{'Sec-WebSocket-Key'}\n";

        # Send WebSocket handshake response
        use Digest::SHA qw(sha1_base64);
        my $accept_key = sha1_base64($headers{'Sec-WebSocket-Key'} . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11') . "=";

        print $client "HTTP/1.1 101 Switching Protocols\r\n";
        print $client "Upgrade: websocket\r\n";
        print $client "Connection: Upgrade\r\n";
        print $client "Sec-WebSocket-Accept: $accept_key\r\n\r\n";
        print "WebSocket handshake completed\n";
        print $accept_key;
        

    } else {
        print "Sec-WebSocket-Key not found!\n";
        print $client "HTTP/1.1 400 Bad Request\r\n\r\n";
    }

    close $client;
}
