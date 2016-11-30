package CurrencyGraphic; 
use v5.22.2;
use strict;
use Switch;
use Date::Simple (':all');
use WWW::Mechanize;
use HTML::TableExtract;
use GD::Graph::lines;

my %config = ( 
    cb => { 
        currency => {
            USD => 'R01235',
            EUR => 'R01239',
            CNY => 'R01375',
            JPY => 'R01820',
        },
        attr => {
            attribs => {
                class => 'data',
            },
        },
    },
    fin => {
        currency => {
            USD => '52148',
            EUR => '52170',
            CNY => '52207',
            JPY => '52246',
        },
        attr => {
            attribs => {
                class => 'karramba',
            },
        },
    },
    val => {
        currency => {
            USD => '840',
            EUR => '978',
            CNY => '156',
            JPY => '392',
        },
        attr => {
            attribs => {
                border => 0,
                width => 433,
                cellpadding => 6,
                cellspacing => 1,
            },
        },
    },
);

my ($firstDate, $lastDate);
my $siteID;
    
sub setParameters {
    my ($id, $first, $last) = @_;
    $firstDate = Date::Simple->new($first);
    $lastDate = Date::Simple->new($last);
    die('Invalid <start_date> or <end_date>') if !defined $firstDate || !defined $lastDate; 
    die('Incorrect date interval') if $lastDate < $firstDate;
    $siteID = $id if exists $config{$id} or die('Unknown site id');
}

my $getURL = sub {
    my ($currency) = @_;
    my ($first, $last) = ($firstDate->format("%d.%m.%Y"), $lastDate->format("%d.%m.%Y"));
    my ($y1, $m1, $d1) = $firstDate->as_ymd;
    my ($y2, $m2, $d2) = $lastDate->as_ymd;

    switch ($siteID) {
        case 'cb' {
            return "http://www.cbr.ru/currency_base/dynamics.aspx?VAL_NM_RQ=$currency&date_req1=$first&date_req2=$last&rt=1&mode=1"; 
        }
        case 'fin' {
            return "http://www.finmarket.ru/currency/rates/?id=10148&pv=1&cur=$currency&bd=$d1&bm=$m1&by=$y1&ed=$d2&em=$m2&ey=$y2&x=36&y=16#archive";
        }
        case 'val' {
            return "http://val.ru/valhistory.asp?tool=$currency&bd=$d1&bm=$m1&by=$y1&ed=$d2&em=$m2&ey=$y2&showchartp=False";
        }
    }
};

my $getTable = sub {
    my ($link) = @_;

    my $mech = WWW::Mechanize->new();
    $mech->get($link);
    my $table = HTML::TableExtract->new(%{$config{$siteID}{attr}});

    return $table->parse($mech->content());
};

my $getData = sub {
    my %data;

    foreach my $cur (keys %{$config{$siteID}{currency}}) {
        my $table = $getTable->($getURL->($config{$siteID}{currency}{$cur}));

        foreach my $ts ($table->tables) {
            my (undef, @rows) = $ts->rows;

            foreach my $cell (@rows) {
                if ($#{$data{date}} < $#rows) {
                    push (@{$data{date}}, $cell->[0]);
                }

                push (@{$data{$cur}}, ($cell->[2] / $cell->[1])); 
            }
        }
    }
    
    return %data;
};

sub getGraphic {
    my %data = $getData->();
    my @graphicData = $data{date};
    my @titles;
    foreach my $key (keys %data) {
        push (@graphicData, $data{$key}) if $key ne 'date';
        push (@titles, $key) if $key ne 'date';
    }

    my ($width, $height) = (1000, 700);
    my $skip = int((($lastDate - $firstDate) * 8) / ($width - $height / 10) + 1);
    my @colors = ['green', 'blue', 'red', 'black'];
    
    my %graphicConf = (
            title           => 'Time interval of currency change',
            x_label         => 'Date',
            y_label         => 'Currency',
            line_width      => 2,
                     
            dclrs         => @colors,  
            bgclr         => 'white',   # background colour
            fgclr         => 'black',   # Axes and grid
            labelclr      => 'black',   # labels on axes
            axislabelclr  => 'black',   # values on axes
            legendclr     => 'black',   # Text for the legend
            textclr       => 'black',   # All text, apart from the following 2
                                                    
            x_label_skip    =>  $skip,
            x_tick_offset     => ($lastDate - $firstDate) % $skip,
            x_labels_vertical => 1,
            transparent => 0,
                                                                 
            y_tick_number   =>  8,
    );

    my $graphic = GD::Graph::lines->new($width, $height);
    $graphic->set(%graphicConf) or warn $graphic->error;
    $graphic->set_legend_font('GD::gdMediumNormalFont');
    $graphic->set_legend(@titles);

    my $image = $graphic->plot(\@graphicData) or die $graphic->error;

    open (my $file, "> currencyGraphic[$siteID].png") or die $!;
    binmode($file);
    print $file $image->png;
    close $file;
}
