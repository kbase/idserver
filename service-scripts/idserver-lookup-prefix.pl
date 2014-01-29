use strict;
use Data::Dumper;
use MongoDB;

use Getopt::Long::Descriptive;

my($opt, $usage) = describe_options('%c %o prefix [prefix ...]',
				    ['host|h=s', "Mongodb server host", { required => 1 }],
				    ['port|p=i', "Mongodb server port", { default => 27017 }],
				    ['help', "Print usage message and exit"],
    );

print($usage->text), exit if $opt->help;

my $client = MongoDB::MongoClient->new(host => $opt->host, port => $opt->port);
my $database = $client->get_database('idserver_db');
my $data = $database->get_collection('data');
my $next = $database->get_collection('next');

my @prefix = @ARGV;

for my $prefix (@prefix)
{
    $prefix = quotemeta($prefix);
    my $res = $data->find({ kb_id => qr/^$prefix/ });
    while (my $hit = $res->next)
    {
	print "$hit->{kb_id}\t$hit->{ext_name}\t$hit->{ext_id}\n";
    }
    $res = $next->find({prefix  => qr/^$prefix/ });
    while (my $hit = $res->next)
    {
	print "$hit->{prefix}\t$hit->{next_val}\n";
    }
}

