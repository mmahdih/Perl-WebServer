package Notepad;

use strict;
use warnings;
use URI::Escape;
use Cwd;
use JSON;


my $base_dir = "C:/Users/Haidary/OneDrive - SINC SharePoint/Mein Files/Sinc Files/Week 12/Webserver";


sub save_note_on_server {
    my ($client, $req, %notes) = @_;

    my $body = $req->content;

    my ($title)   = $body =~ m/sendTitle=([^&]+)/;
    my ($content) = $body =~ m/sendContent=([^&]+)/;
    my ($index)   = $body =~ m/sendIndex=([^&]+)/;
    $content = uri_unescape($content);
    $title   = uri_unescape($title);
    $title   = substr $title, 0, 10;

print "....................................................\n";
    print "Title: $title\n";
    print "Content: $content\n";
    print "Index: $index\n";
print "....................................................\n";



    my $dir = getcwd() . "/notes";

    if (%notes) {
        foreach my $key ( sort { $a <=> $b } keys %notes ) {

            # print "Note $key: $notes{$key}{title}\n";

            if ( $index ne "" && $index != 0 && $index == $key ) {
                print "Note found\n";
                my $file_path = "$dir/$notes{$key}{title}";
                print "File path: $file_path\n";
                if ( -e $file_path ) {
                    open my $file, '>', $file_path
                    or die "Could not open file: $!";
                    print $file $content;
                    close $file;
                    print "File overwritten\n";
                    last;
                }
            }
            elsif ( $index eq "" || $index == 0 ) {
                print "Note not found\n";
                open my $fh, '>', "$dir/$title.txt"
                or die "Could not open file: $!";
                print $fh $content;
                close $fh;
                print "New file created\n";
                last;
            }
        }
    }
    else {
        print "No notes available\n";
        open my $fh, '>', "$dir/$title.txt"
        or die "Could not open file: $!";
        print $fh $content;
        close $fh;
        print "New file created\n";
    }
}


sub handle_upload_note {
    my ($client, $req, %notes) = @_;

    my $body = $req->content;


    my $title   = "";
    my $content = "";
    my ($index) = $body =~ m/sendIndex=([^&]+)/;

    my @my_body = split( /\n/, $body );
    my @filtered_lines = @my_body[ 4 .. $#my_body - 1 ];

    foreach my $line (@filtered_lines) {
        print $line . "\n";
        $content .= $line . "\n";
    }

    $title = substr $content, 0, 10;

    my $dir = getcwd() . "/notes";
    if (%notes) {
        foreach my $key ( sort { $a <=> $b } keys %notes ) {

            # print "Note $key: $notes{$key}{title}\n";

            if ( $index ne "" && $index != 0 && $index == $key ) {
                print "Note found\n";
                my $file_path = "$dir/$notes{$key}{title}";
                if ( -e $file_path ) {
                    open my $file, '>', $file_path
                    or die "Could not open file: $!";
                    print $file $content;
                    close $file;
                    print "File overwritten\n";
                    last;
                }
            }
            elsif ( $index eq "" || $index == 0 ) {
                print "Note not found\n";
                print "Title: $title\n";
                if ( $title ne "" ) {
                    open my $fh, '>', "$dir/$title.txt"
                    or die "Could not open file: $!";
                    print $fh $content;
                    close $fh;
                    print "New file created\n";
                    last;
                }
                else {
                    print "File is empty\n";
                    last;
                }
            }
        }
    }
    else {
        print "No notes available\n";
        if ( $title ne "" ) {
            open my $fh, '>', "$dir/$title.txt"
            or die "Could not open file: $!";
            print $fh $content;
            close $fh;
        }
        print "New file created\n";
    }

}


sub delete_note_on_server {
    my ($client, $req, %notes) = @_;

    my $body = $req->content;

    my ($index) = $body =~ m/deletenoteIndex=([^&]+)/;
    print "title to delete is: $index\n";

    # my %notes = handel_open_note(%notes);
    my $dir   = getcwd() . "/notes";

    foreach my $key ( sort { $a <=> $b } keys %notes ) {
        if ( $key == $index ) {
            unlink "$dir/$notes{$key}{title}";
            print "deleted";
        }
        else {
            print "note not found\n";
        }
    }
}


sub download_note_on_clientside {
    my ($client, $req, %notes) = @_;

    my $body = $req->content;

    my ($index) = $body =~ m/downloadnoteIndex=([^&]+)/;
    print("Index: $index\n");

    my $data;
    my $filename;
    if ( !$notes{$index} ) {
        print("Note not found\n");
    }
    foreach my $key ( sort { $a <=> $b } keys %notes ) {
        print "the note";

        # print "Note $key: $notes{$key}{title}\n";

        if ( $key == $index ) {
            print "Note found\n";
            $data     = $notes{$key}{content};
            $filename = $notes{$key}{title};
            last;
        }
        else {
            print "note not found\n";
        }
    }

    return $data, $filename;
}

sub notepad_darkmode {
    my ($req) = @_;

    my $head = $req->headers;
    my $cookie = "";

    my ($cookie_value) = $head =~ /^Cookie: .*?=(.*)$/m;

    if ( $cookie_value eq "false" ) {
        $cookie = "darkmode=true";
    }
    elsif ( $cookie_value eq "true" ) {
        $cookie = "darkmode=false";
    }
    return $cookie;
}


1;