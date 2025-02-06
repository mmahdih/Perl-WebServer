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

sub generate_base32_secret {
    my @chars = ("A".."Z", "2".."7");
    my $length = scalar(@chars);
    my $base32_secret = "";
    for (my $i = 0; $i < 16; $i++) {
            $base32_secret .= $chars[rand($length)];
    }
    return $base32_secret;
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

my $base32_secret = generate_base32_secret();
print "Secret = $base32_secret\n";

my $uri = "otpauth://totp/TestApp:testUser?secret=$base32_secret&issuer=TestApp\n";
my $qr = GD::Barcode::QRcode->new($uri, { Ecc => 'L', Version => 10, ModuleSize => 3 });

open my $fh, '>', 'qrcode.png' or die "Cannot open file: $!";
binmode $fh;
print $fh $qr->plot->png;
close $fh;

print "QR Code saved as qrcode.png\n";

while (1) {
    my $diff = 30 - (time() % 30);
    print "Current number = ", generate_current_number($base32_secret),"\n";
    sleep(1);
}

