package feiertage;

use warnings;
use JSON;
use utf8;
use JSON qw(encode_json);
binmode STDOUT, ":utf8";
use Date::Holidays::DE qw(holidays);



sub run {

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
        'en' => 'Reunion day (>= 1954, <= 1990)'
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
        'en' => 'Reunion day (>= 1990)'
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

    # my $feiertage_ref = holidays( FORMAT => '%a, %d.%B.%Y', WHERE => ['all'] );
    # my $feiertage_ref = holidays(FORMAT => '%a, %d.%B.%Y', ADD => ['heil', 'silv'] );
    my $feiertage_ref = holidays( WHERE    => ['all'],
                                  FORMAT   => "%#, %a, %d/%m/%Y",
                                  YEAR     => 2024,
                                  ADD      => ['heil', 'silv' , 'romo', 'fadi']);
    my @feiertage     = @$feiertage_ref;

    print "Feiertage: \n";
    foreach my $feiertag (@feiertage) {
        my ($date) = split /,/, $feiertag;
        print "$date | $feiertag\n";
    }

}



sub easter_sunday {
    my $year = shift;


    my $a = $year % 19;
    my $b = int($year / 100);
    my $c = $year % 100;
    my $d = int($b / 4);
    my $e = $b % 4;
    my $f = int(($b + 8) / 25);
    my $g = int(($b - $f + 1) / 13);
    my $h = (19 * $a + $b - $d - $g + 15) % 30;
    my $i = int($c / 4);
    my $k = $c % 4;
    my $l = (32 + 2 * $e + 2 * $i - $h - $k) % 7;
    my $m = int(($a + 11 * $h + 22 * $l) / 451);
    my $n = int(($h + $l - 7 * $m + 114) / 31);
    my $p = ($h + $l - 7 * $m + 114) % 31;
    my $day = $p + 1;
    # my $month = ($n == 3) ? "March" : "April";
    my $month = $n;

    print "Ostersonntag: $day.$month.$year\n";
return ($year, $month, $day);

}


# my ($year, $month, $day) = easter_sunday(2024);

# my $easter_day = Date.new($year, $month, $day);

# my $romo = $easter_day - 48;
# my $fadi = $easter_day - 47;
# my $grun = $easter_day - 3;
# my $karf = $easter_day - 2;
# my $osts = $easter_day;
# my $ostm = $easter_day + 1;
# my $himm = $easter_day + 39;
# my $pfis = $easter_day + 49;
# my $pfim = $easter_day + 50;
# my $fron = $easter_day + 60;

# # print the dates
# print "Romo: $romo";
# print "Fadi: $fadi";
# print "Grun: $grun";
# print "Karf: $karf";
# print "Osts: $osts";
# print "Ostm: $ostm";
# print "Himm: $himm";
# print "Pfis: $pfis";
# print "Pfim: $pfim";
# print "Fron: $fron";


1;