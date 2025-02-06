package Kalender;

use strict;
use warnings;
use JSON;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Request::Common;
use URI::Escape;

use lib ".";
use lib '/home/lapdev/Mein/Perl-WebServer/packages';
use html_structure;
use HTTP_RESPONSE;
use endPoints;
use feiertage_module;
use file_manager;


sub get_kalender {
    my ($req) = @_;

    my $body = $req->content;
    my ($date) = $body =~ m/feiertag=([^&]+)/;
    $date =~ s/-/\//g;
    
    my ( $year, $month, $day ) = split( '/', $date );
    print "date is: $day/$month/$year\n";

    my $holiday = endPoints::get_feiertag( $day, $month, $year );
    my $bodydata = html_structure::event_structure( "$day/$month/$year", $holiday );

    return $bodydata;

}

sub get_day {
    my ( $day, $month, $year ) = @_;

    my $date = "$day/$month/$year";

    my $title = endPoints::get_feiertag( $day, $month, $year );

    # Start of HTML body content
    my $body = html_structure::event_structure( $date, $title, "TEST" );
    return $body;
}

sub get_months {
    my ($month, $year ) = @_;

    my $date = "$month/$year";
    my $body;

    my @holidays = endPoints::get_feiertags_of_month( $year, $month );
    foreach my $holiday (@holidays) {
        print "Holiday: $holiday->[0], $holiday->[1]\n";
        $body .= html_structure::event_structure( $holiday->[0],
            $holiday->[1] );
    }

    return $body;
}

sub get_year {
    my ($year ) = @_;

    # Start of HTML body content
    my $body = "";
    my @holidays = endPoints::get_feiertags_of_year($year);
    foreach my $holiday (@holidays) {

        $body .= html_structure::event_structure( $holiday->[0],
            $holiday->[1] );

    }

return $body;

}
1;