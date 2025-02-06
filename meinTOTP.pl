
use strict;
use warnings;
use Digest::SHA qw(hmac_sha1_hex);
use Convert::Base32;
use GD::Barcode::QRcode;
use GD::Image;

use MIME::Base32 qw( encode_base32 );

## Time-based One-time Password Algorithm
#
#
# TOTP(K, T) = HOTP(K, ⌊T/30⌋)
#
#
## Parameters
# T = current unix time
# C = time step (30 seconds) (T / 30)
# K = base32 secret key
# H = HMAC-SHA1(K, C)





sub generate_secret_key {
    my $length = shift || 16;  # 16 bytes is a common length for secret keys
    my $random_bytes = '';
    for (1..$length) {
        $random_bytes .= chr(int(rand(256)));
    }
    return encode_base32($random_bytes);
}

my $secret_key = generate_secret_key(16);
print "------------------------------------\n";
print "Secret Key: $secret_key\n";
print "Length: ", length($secret_key), "\n";
print "------------------------------------\n";











# Generate a base32 secret key by randomly selecting characters from the set (A-Z, 2-7).
sub generate_base32_secret {
    my @chars = ("A".."Z", "2".."7");
    my $length = scalar(@chars);
    my $base32_secret = "";
    for (my $i = 0; $i < 16; $i++) {
            $base32_secret .= $chars[rand($length)];
    }
    return $base32_secret;
}


my $current_UNIX_time = time();

my $time_step = int($current_UNIX_time / 30);       # 30 seconds
my $base32_secret = generate_base32_secret();
# my $hmac_sha1_hex = hmac_sha1_hex($time_step, $base32_secret);


sub generate_current_number {
    my ($base32_secret) = @_;

    my $decode = Convert::Base32::decode_base32($base32_secret);
    print "Decode = $decode\n";
    print "Current Unix time = $current_UNIX_time\n";
    print "Time step = $time_step\n";
    $time_step = pack("Q>", $time_step);
    print "Time step in big endian = $time_step\n";
    my $hmac_sha1_hex = hmac_sha1_hex($time_step, $decode);
    print "HMAC-SHA1 = $hmac_sha1_hex\n";
    
    my $offset = hex(substr($hmac_sha1_hex, length($hmac_sha1_hex) - 1, 1));
    print "Offset = $offset\n";
    print "HEX offset = ", substr($hmac_sha1_hex, length($hmac_sha1_hex) - 1, 1) ,  "\n";
    my $truncated_hash = substr($hmac_sha1_hex, $offset * 2, 8);
    print "Truncated hash = $truncated_hash\n";
    my $encrypted = hex($truncated_hash) & 0x7fffffff;
    print "Encrypted = $encrypted\n";
    my $token = $encrypted % 1000000;
    return sprintf("%06d", $token);
}



# print
print "Secret = $base32_secret\n";
print "Time step = $time_step\n";
# print "HMAC-SHA1 = $hmac_sha1_hex\n";  # EX: 9ad5fca015ea8ec7c6be1ec0109b653f0cdea9e2

print "////////\n";


my $uri = "otpauth://totp/TestApp:testUser?secret=$base32_secret&issuer=TestApp\n";
my $qr = GD::Barcode::QRcode->new($uri, { Ecc => 'L', Version => 10, ModuleSize => 3 });

open my $fh, '>', 'qrcode.png' or die "Cannot open file: $!";
binmode $fh;
print $fh $qr->plot->png;
close $fh;

print "QR Code saved as qrcode.png\n";

# for (my $i = 0; $i < 10; $i++) {
#     sleep(1);
# }



# while (1) {
    # my $diff = 30 - (time() % 30);
        print "Current number = ", generate_current_number($base32_secret),"\n";
    # sleep(1);
# }



