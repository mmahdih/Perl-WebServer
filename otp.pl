use strict;
use warnings;
use Digest::SHA qw(hmac_sha1_hex);
use Convert::Base32;
use GD::Barcode::QRcode;
use GD::Image;

use MIME::Base32 qw( encode_base32 );

my $base32Secret = generateBase32Secret();
print "secret = $base32Secret\n";


qrcodegenerator("user\@foo.com", $base32Secret);

# while (1) {
    # my $diff = 30 - (time() % 30);
    my $code = generateOTP($base32Secret);
    print "Secret code = $code \n";
#     sleep(1);
# }




sub generateOTP {
    my ($base32Secret) = @_;

    print "Unix time = ", time(), "\n";
    my $time = int(time() / 30);
    print "time = $time\n";
    $time = pack("Q>", $time);
    print "time = $time\n";
    print "base32Secret = $base32Secret\n";
    my $hash = hmac_sha1_hex($time, $base32Secret);
    print "hash = $hash\n";
    my $offset = hex(substr($hash, length($hash) - 1, 1));
    print "offset = $offset\n";
    my $binary = hex(substr($hash, $offset * 2, 8)) & 0x7fffffff;
    print "binary = $binary\n";
    my $token = $binary % 1000000;
    print "token = $token\n";
    return sprintf("%06d", $token);
}



sub generateBase32Secret {
    my $secret = "";
    my @chars = ("A" .. "Z", "2" .. "7");
    for (1 .. 16) {
        $secret .= $chars[rand @chars];
    }

    Convert::Base32::decode_base32($secret);
    return $secret;
}

sub qrcodegenerator {
    my ($keyId, $base32Secret) = @_;
    my $uri = "otpauth://totp/TestApp:$keyId?secret=$base32Secret&issuer=TestApp\n";
    my $qr = GD::Barcode::QRcode->new($uri, { Ecc => 'L', Version => 10, ModuleSize => 3 });

    open my $fh, '>', 'qrcode.png' or die "Cannot open file: $!";
    binmode $fh;
    print $fh $qr->plot->png;
    close $fh;

    print "QR Code saved as qrcode.png\n";
}