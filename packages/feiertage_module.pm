package feiertage_module;

use warnings;
use JSON;
use utf8;
use JSON qw(encode_json);
binmode STDOUT, ":utf8";
use Date::Holidays::DE qw(holidays);


my $base_dir = 'C:/Users/Haidary/OneDrive - SINC SharePoint/Mein Files/Sinc Files/Week 12/Webserver';

sub run {
    make_feiertag_list();

    # open my $fh, '<', 'feiertage.json' or die "Could not open file: $!";
    # my $json = do { local $/; <$fh> };
    # close $fh;

    # my @dates;
    # my $data = JSON->new->decode($json);

    # my $date = decode_json($json);

    # foreach my $date (@$data) {
    #     for my $key (keys %$date) {
    #         if ($key eq 'date') {
    #             print "Date: ",$date->{$key}, "\n";
    #         } elsif ($key eq 'name') {
    #             print "Name: ",$date->{$key}->{de}, "\n";
    #         }
    #     }
    # }

}

sub new {
    print("TEST\n");
}
my %holidays = (
    'neuj' => {
        'de' => 'Neujahr',
        'en' => 'New Year\'s day'
    },
    'hl3k' => {
        'de' => 'Hl. 3 Koenige',
        'en' => 'Epiphany'
    },
    'weib' => {
        'de' => 'Weiberfastnacht',
        'en' => 'Fat Thursday'
    },
    'romo' => {
        'de' => 'Rosenmontag',
        'en' => 'Carnival monday'
    },
    'fadi' => {
        'de' => 'Faschingsdienstag',
        'en' => 'Shrove tuesday'
    },
    'asmi' => {
        'de' => 'Aschermittwoch',
        'en' => 'Ash wednesday'
    },
    'frau' => {
        'de' => 'Internationaler Frauentag',
        'en' => 'International Women\'s day'
    },
    'befr' => {
        'de' => 'Tag der Befreiung',
        'en' => 'Liberation day'
    },
    'grdo' => {
        'de' => 'Gruendonnerstag',
        'en' => 'Maundy Thursday'
    },
    'karf' => {
        'de' => 'Karfreitag',
        'en' => 'Good friday'
    },
    'kars' => {
        'de' => 'Karsamstag',
        'en' => 'Holy Saturday'
    },
    'osts' => {
        'de' => 'Ostersonntag',
        'en' => 'Easter sunday'
    },
    'ostm' => {
        'de' => 'Ostermontag',
        'en' => 'Easter monday'
    },
    'pfis' => {
        'de' => 'Pfingstsonntag',
        'en' => 'Whit sunday'
    },
    'pfim' => {
        'de' => 'Pfingstmontag',
        'en' => 'Whit monday'
    },
    'himm' => {
        'de' => 'Himmelfahrtstag',
        'en' => 'Ascension day'
    },
    'fron' => {
        'de' => 'Fronleichnam',
        'en' => 'Corpus christi'
    },
    '1mai' => {
        'de' => 'Maifeiertag',
        'en' => 'Labor day, German style'
    },
    '17ju' => {
        'de' => 'Tag der deutschen Einheit',
        'en' => 'Reunion day'
    },
    'frie' => {
        'de' => 'Augsburger Friedensfest',
        'en' => 'Augsburg peace day'
    },
    'mari' => {
        'de' => 'Mariae Himmelfahrt',
        'en' => 'Assumption day'
    },
    'kind' => {
        'de' => 'Weltkindertag',
        'en' => 'International Childrens Day'
    },
    '3okt' => {
        'de' => 'Tag der deutschen Einheit',
        'en' => 'Reunion day'
    },
    'refo' => {
        'de' => 'Reformationstag',
        'en' => 'Reformation day'
    },
    'alhe' => {
        'de' => 'Allerheiligen',
        'en' => 'All hallows day'
    },
    'buss' => {
        'de' => 'Buss- und Bettag',
        'en' => 'Penance day'
    },
    'votr' => {
        'de' => 'Volkstrauertag',
        'en' => 'Remembrance Day, German Style'
    },
    'toso' => {
        'de' => 'Totensonntag',
        'en' => 'Sunday in commemoration of the dead'
    },
    'adv1' => {
        'de' => '1. Advent',
        'en' => '1st sunday in advent'
    },
    'adv2' => {
        'de' => '2. Advent',
        'en' => '2nd sunday in advent'
    },
    'adv3' => {
        'de' => '3. Advent',
        'en' => '3rd sunday in advent'
    },
    'adv4' => {
        'de' => '4. Advent',
        'en' => '4th sunday in advent'
    },
    'heil' => {
        'de' => 'Heiligabend',
        'en' => 'Christmas eve'
    },
    'wei1' => {
        'de' => '1. Weihnachtstag',
        'en' => 'Christmas'
    },
    'wei2' => {
        'de' => '2. Weihnachtstag',
        'en' => 'Christmas'
    },
    'silv' => {
        'de' => 'Silvester',
        'en' => 'New year\'s eve'
    }
);

sub make_feiertag_list {
    my @feiertag_list;
    my $filename = "$base_dir/feiertage/feiertage.json";
    my @years = ( 2000 .. 2050 );
    if ( -e $filename && -z $filename || !-e $filename ) {

        # file exists but is empty
        print "feiertage.json exists but is empty\n";

        for my $year (@years) {

# my $feiertage_ref = holidays( FORMAT => '%a, %d.%B.%Y', WHERE => ['all'] );
# my $feiertage_ref = holidays(FORMAT => '%a, %d.%B.%Y', ADD => ['heil', 'silv'] );
            my $feiertage_ref = holidays(
                WHERE  => ['all'],
                FORMAT => "%#, %a, %d/%m/%Y",
                YEAR   => $year,
                ADD    => [ 'heil', 'silv', 'romo', 'fadi' ]
            );
            my @feiertage = @$feiertage_ref;

            # print "Feiertage: \n";
            my $index = 0;
            foreach my $date (@feiertage) {
                my ( $abbr, $dayofweek, $date ) = split /,/, $date;

                foreach my $holiday ( keys %holidays ) {
                    if ( $abbr eq $holiday ) {
                        push @feiertag_list,
                          {
                            index     => $index++,
                            date      => $date,
                            dayofweek => $dayofweek,
                            name      => {
                                de => $holidays{$holiday}{'de'},
                                en => $holidays{$holiday}{'en'}
                            }
                          };
                    }

                    open my $fh, '>', 'feiertage.json'
                      or die "Could not open file 'feiertage.json' $!";
                    print $fh encode_json( \@feiertag_list );
                    close $fh;

                }
            }

        }

    }
}

1;
