package endPoints;

use strict;
use warnings;
use JSON;
use Time::Piece;
use Date::Holidays::DE qw(holidays);

my $base_dir = "C:/Users/Haidary/OneDrive - SINC SharePoint/Mein Files/Sinc Files/Week 12/Webserver";


# my $feiertage_ref = holidays();
# my @feiertage     = @$feiertage_ref;

# sub get_year {

#     my $today = localtime->dmy('/');
#     print "Today is $today\n";

#     my $feiertage_ref = holidays(WHERE    => ['all']);
#     foreach my $feiertag (@$feiertage_ref) {
#         print "$feiertag\n";
#     }
# }

sub get_feiertags_of_today {
    my ($year) = @_;

    my $today = localtime->dmy('/');

    open my $fh, '<', '$base_dir/feiertags.json' or die "Could not open file: $!";
    my $json = do { local $/; <$fh> };
    close $fh;

    my $data = JSON->new->decode($json);
    foreach my $holiday (@$data) {
        if ( $holiday->{date} eq $today ) {
            print $holiday->{name};
            return $holiday->{name};
        }
        else {
            print
"No holiday found for today. Get your freeking ass back to work !\n";
            return
"No holiday found for today. Get your freeking ass back to work !\n";
        }
    }

    print "No holiday found for today. Get your freeking ass back to work !\n";

}

sub get_feiertags_of_year {
    my ($year) = @_;

    my $path = $base_dir . "/feiertage/feiertage.json";
    open my $fh, '<', $path or die "Could not open file: $!";
    my $json = do { local $/; <$fh> };
    close $fh;

    my @dates;
    my $data = JSON->new->decode($json);

    # foreach my $date (@$data) {
    #     print($date);
    # }
    # print ("HASON $json");
    # foreach my $date (@$data) {
    #     print($date);
    # }

    # my %data = JSON::decode_json($json);
    my $date = decode_json($json);

    foreach my $holiday (@$date) {
        if ( $holiday->{date} =~ /\b$year\b/ ) {

            # $holiday->{date} =~ /\b$month\/$year\b/;
            # print "Holiday found: $holiday->{name}\n";
            # print($holiday->{name} . "\n");
            # print($holiday->{date} . "\n");

            # return $holiday->{name};
            # return $holiday->{date};
            push @dates, [ $holiday->{date}, $holiday->{name}->{de} ];
        }
        else {
            # print "No holiday found in this month\n";
            # return undef;
            next;
        }
    }

    return @dates;

}

sub get_feiertags_of_month {
    my ( $year, $month ) = @_;
    my $path = $base_dir . "/feiertage/feiertage.json";
    open my $fh, '<', $path or die "Could not open file: $!";
    my $json = do { local $/; <$fh> };
    close $fh;

    my @dates;
    my $data = JSON->new->decode($json);

    my $date = decode_json($json);

    foreach my $holiday (@$data) {

        # print("$month, $year");
        # print "/$month\/$year([^\s]+)/ \n";
        # print "$year \n";
        #    print "Date: $holiday->{date} \n";
        # print "Holiday found: $holiday->{name}\n";
        # print "Holiday found: $holiday->{date}\n";
        if ( $holiday->{date} =~ /$month\/$year/ ) {

            # print "Holiday found: $holiday->{name}\n";

            my $holiday_date  = $holiday->{date};
            my @date          = split( '/', $holiday_date );
            my $holiday_month = $date[1];

            # print "Holiday month: $holiday_month\n";

            # print("HOLIDAY DATE: $holiday_date \n");
            # print("MONTH: $month \n");
            if ( $holiday_month != $month ) {
                next;
            }

            # }
            # if ( $holiday->{date} =~ /\b$month\/$year\b/ ) {

            # $holiday->{date} =~ /\b$month\/$year\b/;
            # print "Holiday found: $holiday->{name}\n";
            # print($holiday->{name} . "\n");
            # print($holiday->{date} . "\n");

            # return $holiday->{name};
            # return $holiday->{date};
            push @dates, [ $holiday->{date}, $holiday->{name}->{de} ];

            # print ($holiday->{name}->{de} . "\n");
        }
        else {
            # print "No holiday found in this month\n";
            # return undef;
            next;
        }
    }

    return @dates;

}

use JSON;

sub get_feiertag {
    my ( $day, $month, $year ) = @_;

    my $path = $base_dir . "/feiertage/feiertage.json";
    open my $fh, '<', $path or die "Could not open file: $!";
    my $json = do { local $/; <$fh> };
    close $fh;

    my $data = JSON->new->decode($json);
    foreach my $holiday (@$data) {

        # print $holiday->{name}->{de};
        # print $holiday->{date}, "\n";
        my $holiday_date  = $holiday->{date};
        my @holidaydate   = split( '/', $holiday_date );
        my $holiday_day   = $holidaydate[0];
        my $holiday_month = $holidaydate[1];
        my $holiday_year  = $holidaydate[2];

        # print "$holiday_day, $date\n";

        if (   $holiday_day == $day
            && $holiday_month == $month
            && $holiday_year == $year )
        {
            # print "Holiday found: $holiday->{name}->{de}\n";

            # print $holiday->{name}->{de};
            return $holiday->{name}->{de};
        }
        else {
            # print "No holiday found in this date\n";
        }
    }

    # print "No holiday found for date $date";
}

sub get_all_feiertags {

}

1;
