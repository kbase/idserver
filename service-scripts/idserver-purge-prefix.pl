use strict;
use Data::Dumper;
use MongoDB;

use Getopt::Long::Descriptive;

my($opt, $usage) = describe_options('%c %o prefix [prefix ...]',
				    ['purge', "Do the purge"],
				    ['host|h=s', "Mongodb server host", { required => 1 }],
				    ['port|p=i', "Mongodb server port", { default => 27017 }],
				    ['help', "Print usage message and exit"],
    );

print($usage->text), exit if $opt->help;

$MongoDB::Cursor::timeout = 600000;

my $client = MongoDB::MongoClient->new(host => $opt->host, port => $opt->port);
my $database = $client->get_database('idserver_db');
my $data = $database->get_collection('data');
my $next = $database->get_collection('next');

my @prefix = @ARGV;

for my $prefix (@prefix)
{
    if ($prefix eq '')
    {
	die "Will not purge empty prefix\n";
    }
    my $qprefix = quotemeta($prefix);
    my $res = $database->run_command({count => 'data', query => {kb_id => qr/^$qprefix/}});
    die "failed query " . Dumper($res) unless $res->{ok};
    print "ext count for $prefix is $res->{n}\n";

    $res = $next->find({prefix  => qr/^$qprefix/ });
    while (my $hit = $res->next)
    {
	print "$hit->{prefix}\t$hit->{next_val}\n";
    }

    if ($opt->purge)
    {
	$res = $data->remove({kb_id => qr/^$qprefix/}, { safe => 1 });
	print Dumper($res);
	$res = $next->remove({prefix => qr/^$qprefix/}, { safe => 1 });
	print Dumper($res);
    }
}

