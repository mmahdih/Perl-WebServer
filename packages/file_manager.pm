package file_manager;


use strict;
use warnings;
use JSON;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Request::Common;
use URI::Escape;
use Digest::SHA qw(sha256_hex);
use Cwd;

# import modules
use lib ".";
use lib
'C:/Users/Haidary/OneDrive - SINC SharePoint/Mein Files/Sinc Files/Week 12/Webserver/packages';
use html_structure;
use HTTP_RESPONSE;


my $base_dir = "C:/Users/Haidary/OneDrive - SINC SharePoint/Mein Files/Sinc Files/Week 12/Webserver";


sub list_files {
    my ($username, $user_role) = @_;

    my $file_list = "";
    print "Listing files...\n";
    my $dir = $base_dir . '/User' . '/' . $username;
    mkdir $dir if !-d $dir;
    mkdir $dir . '/notes' if !-d $dir . '/notes';
    mkdir $dir . '/files' if !-d $dir . '/files';
    opendir(my $dh, $dir . '/files') || die "Can't open directory: $!";
    while (my $file = readdir($dh)) {
        my $filename = $file;
        my $filesize = "";
        my $filetype = "";

        if ($file eq '.' || $file eq '..') {
            next;
        }
        elsif (-z "$dir/$file") {
            # print "Empty file: $file\n";
            next;
        }
        else {
            # print "File: $file\n";
            $filesize = -s "$dir/files/$file";
            $filesize = handel_file_size($filesize);
            $filetype = substr($file, rindex($file, ".") + 1, length($file) - rindex($file, ".") - 1); #$filename;
            $file_list .= html_structure::get_file_list($filename, $filesize, $filetype);
        }
    }
    closedir($dh);
    return $file_list;

}


sub handle_save_file {
    my ($client, $req, $username, $user_role) = @_;

    my $body = $req->content;
    
    my $content_type = $req->header('Content-Type');
    ($content_type, my $boundary) = split("; boundary=", $content_type);
    $boundary = "--$boundary";
    print "Boundary: $boundary\n";


    my (undef, $filename, $file) = split($boundary, $body, 3);
    print("FILENAME: $filename\n");
    my ($name) = $filename =~ /\r\n\r\n(.*)\r\n/;

    my $data = "";
    # my ($content_Type) = $file =~ /Content-Type="([^"]+)"/;

    my @my_body = split( /\r\n/, $file );
    my @filtered_lines = @my_body[ 4 .. $#my_body - 1 ];
    my $dir = $base_dir . "/User/$username/files";
    foreach my $line (@filtered_lines) {
        $data .= $line . "\r\n";
    }


    my ($file_type) = $file =~ /filename="(.*)"/;
    $file_type = substr($file_type, rindex($file_type, ".") + 1, length($file_type) - rindex($file_type, ".") - 1);
    print "Data name: $file_type\n";

    $data = substr $data, 0, -1;
    

    my $file_hash = Digest::SHA->new(256)->add($data)->hexdigest;
    print "File hash after upload: $file_hash\n";

    ### check if file already exists in database ###
    my $hash_file = "$base_dir/hashes/data_hashes.txt";
    open(my $hashes_fh, '+<', $hash_file) or die "Could not open file: $!";
    my @hashes = <$hashes_fh>;
    my $file_exists = 0;
    for my $hash (@hashes) {
        chomp $hash;
        # check if hash already exists in database
        if ($hash eq $file_hash) {
            print "File already exists in database\n";
            $file_exists = 1;
            close $hashes_fh;
            last;
        }
    }
    if ( !$file_exists ) {
        print $hashes_fh "$file_hash\n";
        close $hashes_fh;
        print "File does not exist in database\n";

        ### write file to directory ###
        print "Writing file to directory...\n";
        print "Directory: $dir/\n";
        open(my $fh, '>:raw', "$dir/" . "$name" . ".$file_type")
        or do {
            warn "Could not open file: $!";
            return;
        };
        print $fh $data;
        close $fh;
        print "Filename: $filename\n";
        print "File created\n";
    }

    return "File saved";

}

sub handle_delete_file {
    my ($client, $req, $username, $user_role) = @_;

    my ($filename) = $req->content =~ /filename=(.*)/;
            $filename = uri_unescape($filename);
            $filename =~ tr/+/ /;
            print "Filename: $filename\n";
            my $file_path = $base_dir . "/User/$username/files/$filename";
            my $hash_path = $base_dir . "/hashes/data_hashes.txt";
            print "File path: $file_path\n";

            my $data = "";

            open my $fh, '<', $file_path or die "Could not open file: $!";
            binmode $fh;
            $data = do { local $/; <$fh> };
            close $fh;

        
            my $file_hash = Digest::SHA->new(256)->add($data)->hexdigest;
            $file_hash = $file_hash . "\n";
            print "File hash after delete: $file_hash\n";



            open my $hashes_fh, "<" , $hash_path or die "Could not open file: $!";
            my @hashes = <$hashes_fh>;
            foreach my $line (@hashes) {
                if ($line eq $file_hash) {
                    @hashes = grep { $_ ne $line } @hashes;
                    last;
            }
            }
            # @hashes = grep { chomp; $_ ne $file_hash } @hashes;
            open $hashes_fh, ">", $hash_path or die "Could not open file for writing: $!";
            print $hashes_fh @hashes;
            close $hashes_fh;



            unlink $file_path;
            return "File deleted";
}


sub handle_download_file {
    my ($client, $req, $username, $user_role) = @_;
    
    my ($filename) = $req->content =~ /filename=(.*)/;
    $filename = uri_unescape($filename);
    $filename =~ tr/+/ /;

    my $file_path = $base_dir . "/User/$username/files/$filename";
    open my $fh, '<', $file_path or die "Could not open file: $!";
    binmode $fh;
    my $data = do { local $/; <$fh> };
    close $fh;

    return $data, $filename;
}



sub handel_file_size {
    my ($size_in_bytes) = @_;

    my $size_in_Megabytes = $size_in_bytes / 1024 / 1024;
    my $size_in_Gigabytes = $size_in_bytes / 1024 / 1024 / 1024;

    if ( $size_in_Gigabytes >= 1 ) {
        $size_in_Gigabytes = sprintf( "%.2f", $size_in_Gigabytes );
        return "$size_in_Gigabytes GB";
    }
    elsif ( $size_in_Megabytes >= 1 ) {
        $size_in_Megabytes = sprintf( "%.2f", $size_in_Megabytes );
        return "$size_in_Megabytes MB";
    }
    else {
        my $size_in_Kilobytes = $size_in_bytes / 1024;
        $size_in_Kilobytes = sprintf( "%.2f", $size_in_Kilobytes );
        return "$size_in_Kilobytes KB";
    }
}



1;