use strict;
use warnings;

use Test::More tests => 59;
use Data::Dumper;
use String::Random;

use Bio::KBase::IDServer::Client;
use lib "lib";
use lib "t";
#NEW VERSION WITH AUTO START / STOP SERVICE
use Server;
my ($pid, $url) = Server::start('IDServer');
print "-> attempting to connect to:'".$url."' with PID=$pid\n";

my $obj;
my $return;
my @id_keys;

#
#  Test 1 - Can a new object be created without parameters? 
#
$obj = Bio::KBase::IDServer::Client->new(); # create a new object
ok( defined $obj, "Did an object get defined" );               

#
#  Test 2 - Is the object in the right class?
#
isa_ok( $obj, 'Bio::KBase::IDServer::Client', "Is it in the right class" );   

#
#  Test 3 - Can the object do all of the methods
#

can_ok($obj, qw[    kbase_ids_to_external_ids
    external_ids_to_kbase_ids
    register_ids
    allocate_id_range
    register_allocated_ids
]);

#
#  Test 4 - Can a new object be created with valid parameter? 
#

#my $id_server_url = "http://localhost:7031/";
#my $id_server_url = "http://bio-data-1.mcs.anl.gov/services/idserver";
#my $id_server = Bio::KBase::IDServer::Client->new($id_server_url);
my $id_server = Bio::KBase::IDServer::Client->new($url);
ok( defined $id_server, "Did an object get defined" );               
#
#  Test 5 - Is the object in the right class?
#
isa_ok( $id_server, 'Bio::KBase::IDServer::Client', "Is it in the right class" );   

#
#  METHOD: external_ids_to_kbase_ids
#
note("Test   external_ids_to_kbase_ids");

my $test_kbase_id = '';
my $test_seed_id  = 'fig|1000565.3.peg.4';

#-- Tests 6 and 7 - Too many and too few parameters
eval {$return = $id_server->external_ids_to_kbase_ids('SEED',[$test_seed_id],'EXTRA');  };
isnt($@, undef, 'Call with too many parameters failed properly');

eval {$return = $id_server->external_ids_to_kbase_ids('SEED');  };
isnt($@, undef, 'Call with too few parameters failed properly');

#-- Tests 8 and 9 - Use invalid data.  Expect empty hash to be returned
$return = $id_server->external_ids_to_kbase_ids('SEED', ['BOGUS']);
is(ref($return), 'HASH', "Use InValid data: external_ids_to_kbase_ids returns a hash");

is(keys(%$return), 0, "Give no input: Hash is empty -- No warning");

#-- Tests 10 and 11 - Use Valid data.  Expect hash with data to be returned
$return = $id_server->external_ids_to_kbase_ids('SEED', [$test_seed_id]);
is(ref($return), 'HASH', "Use Valid data: external_ids_to_kbase_ids returns a hash");

@id_keys = keys(%$return);
isnt(scalar @id_keys, 0, "Use Valid data: hash is not empty");
$test_kbase_id = $return->{$id_keys[0]};  ### ID to test kbase_ids_to_external_ids

#-- Tests 12 and 13 - Use Array with both Valid and invalid data.  
#   Expect hash with data to be returned
$return = $id_server->external_ids_to_kbase_ids('SEED', [$test_seed_id, 'fig|83333.1.peg.4.?', 'fig|1000565.3.peg.3']);
is(ref($return), 'HASH', "Use Valid data: external_ids_to_kbase_ids returns a hash");

@id_keys = keys(%$return);
#print Dumper($return);
isnt(scalar @id_keys, 0, "Use Valid data: hash is not empty");

#-- Tests 14 Is the return value scalar.  
foreach (@id_keys)
{
#	print "$_\t$return->{$_}\n";
	is(ref($return->{$_}), '', "Is the return value scalar for $_?");
	last;
}

#
#  METHOD: kbase_ids_to_external_ids
#
note("Test  kbase_ids_to_external_ids");

#-- Tests 15 and 16 - Too many and too few parameters
eval {$return = $id_server->kbase_ids_to_external_ids('SEED',['kb|g.3.peg.2394.?']);  };
isnt($@, undef, 'Call with too many parameters failed properly');

eval {$return = $id_server->kbase_ids_to_external_ids();  };
isnt($@, undef, 'Call with too few parameters failed properly');

#-- Tests 17 and 18 - Use invalid data.  Expect empty hash to be returned
$return = $id_server->kbase_ids_to_external_ids(['kb|g.3.peg.2394.?']);
is(ref($return), 'HASH', "Use InValid data: external_ids_to_kbase_ids returns a hash");

is(keys(%$return), 0, "Give no input: Hash is empty -- No warning");

#-- Tests 19 and 20 - Use Valid data.  Expect hash with data to be returned
$return = $id_server->kbase_ids_to_external_ids([$test_kbase_id]);
is(ref($return), 'HASH', "Use Valid data: external_ids_to_kbase_ids returns a hash");

@id_keys = keys(%$return);
is(scalar @id_keys, 1, "Use Valid data: hash has one element");

#-- Tests 21-23 
#   21 is the return an array
#   22 and 23 are the two items in the array the external_db and external_id  
foreach (@id_keys)
{
	is(ref($return->{$_}), 'ARRAY', "Is the return value scalar for $_?");
	is($return->{$_}->[0], 'SEED', "Is the external_db SEED");
	is($return->{$_}->[1], $test_seed_id, "Is the external_id $test_seed_id");

}

#-- Tests 24 and 25 - Use Array with both Valid and invalid data.  
 #  Expect hash with data to be returned
$return = $id_server->kbase_ids_to_external_ids([$test_kbase_id,$test_kbase_id, '3']);
#print Dumper($return);

is(ref($return), 'HASH', "Use Valid data: external_ids_to_kbase_ids returns a hash");

@id_keys = keys(%$return);
is(scalar @id_keys, 1, "Use Valid data: hash is not empty");

#
#  METHOD: register_ids
#
note("Test  register_ids");

#-- Tests 26 and 27 - Too many and too few parameters
eval {$return = $id_server->register_ids('SEED','SEED','SEED','SEED');  };
isnt($@, undef, 'Call with too many parameters failed properly');

eval {$return = $id_server->register_ids('SEED','SEED');  };
isnt($@, undef, 'Call with too few parameters failed properly');

#-- Tests 28 and 29 -  Test with a valid ID from above
#   Expect a return KBase that was found above (no double registration)
#   Expect one key to the hash and its value is known
$return = $id_server->register_ids('TEST','SEED',[$test_seed_id]);
is(ref($return), 'HASH', "Register_ids returns a hash");

@id_keys = keys(%$return);
is(scalar @id_keys, 1, "Use Valid data: hash has one element");

#-- Tests  30 and 31
#   Are the return values correct?

is($id_keys[0], $test_seed_id, 'Is the key the ID that was registered');
is($return->{$id_keys[0]}, $test_kbase_id, "Is the value the associated KBASE ID");

#-- Tests 32 and 33 -  Test with a valid ID from above but the database is wrong
#   Expect a new KBase ID

$return = $id_server->register_ids('TEST','seed',[$test_seed_id]);
is(ref($return), 'HASH', "Register_ids returns a hash");

@id_keys = keys(%$return);
is(scalar @id_keys, 1, "Use Valid data: hash has one element");

#-- Tests  34-35
#   Test what was returned.  Needs to be new registration ID, not the one above
foreach (@id_keys)
{
#       print "KEY=$_ VALUE=$return->{$_} \n";
	is($_, $test_seed_id, 'Is the key the ID that was registered');
	isnt($return->{$_}, $test_kbase_id, "Is the value IS NOT the associated KBASE ID");
}

#- Tests with bogus test data -
#  Expect new registration ID

$return = $id_server->register_ids('TEST','SEED',['XXXXX']);
@id_keys = keys(%$return);

#-- Tests  36-40 - With new bogus data, get back what we asked for

foreach (@id_keys)
{
#        print "KEY=$_ VALUE=$return->{$_} \n";
	my $return = $id_server->kbase_ids_to_external_ids([$return->{$_}]);
	is(ref($return), 'HASH', "Use Valid data: external_ids_to_kbase_ids returns a hash");
	my @id_keys = keys(%$return);
	is(scalar @id_keys, 1, "Use Valid data: hash has one element");

	foreach (@id_keys)
	{
		is(ref($return->{$_}), 'ARRAY', "Is the return value scalar for $_?");
		is($return->{$_}->[0], 'SEED', "Is the external_db SEED");
		is($return->{$_}->[1], 'XXXXX', "Is the external_id XXXXX");
	}
}


#
#  METHOD: allocate_id_range
#
note("Test allocate_id_range");

#-- Tests 41 and 42 - Too many and too few parameters
eval {$return = $id_server->allocate_id_range('SEED','SEED','SEED');  };
isnt($@, '', 'Call with too many parameters failed properly');

eval {$return = $id_server->allocate_id_range('SEED');  };
isnt($@, '', 'Call with too few parameters failed properly');

#-- Tests 43-44 invalid and valid numberic parameter
eval {$return = $id_server->allocate_id_range('SEED','XX');  };
isnt($@, '', 'Second parameter needs to be a number');

eval {$return = $id_server->allocate_id_range('SEED',3);  };
is($@, '', 'Second parameter needs to be a number');

#-- Tests 45
$return = $id_server->allocate_id_range('TEST',2);
is(ref($return), '', "Register_ids returns a scalar");

my $return_test = $return;
$return_test    =~ s/\d+//g;

#-- Tests 46 - Must be a number
is($return_test, '', 'The return was a number');
$return_test = $return + 1;
my $test_hash = { 'external_id1'=> $return, 'external_id2'=> $return_test };

#
#  METHOD: register_allocated_ids
#
note("Test register_allocated_ids");

#-- Tests 47 and 48 - Too many and too few parameters
eval {$return = $id_server->register_allocated_ids('SEED','SEED','SEED','SEED');  };
isnt($@, undef, 'Call with too many parameters failed properly');

eval {$return = $id_server->register_allocated_ids('SEED','SEED');  };
isnt($@, undef, 'Call with too few parameters failed properly');

$return = $id_server->register_allocated_ids('TEST','SEED', $test_hash); 

#-- Tests 49-52 - Test the data just added
$return = $id_server->kbase_ids_to_external_ids(["TEST.$return_test"]);

@id_keys = keys(%$return);
is(scalar @id_keys, 1, "Return one key");

foreach (@id_keys)
{
        is(ref($return->{$_}), 'ARRAY', "Is the return value scalar for $_?");
        is($return->{$_}->[0], 'SEED', "Is the external_db SEED");
        is($return->{$_}->[1], 'external_id2', "Is the external_id external_id2");

}

#
#  Now what happens when we try to register more than the two allocated IDs
#    put in numbers that I have made up
#
$test_hash =  { 'external_id6' => 11111, 'external_id7' => 22222,  'external_id8' => 33333, 'external_id9' => 44444 };
$return = $id_server->register_allocated_ids('TEST','SEED', $test_hash); 

#-- Tests 53 - Test data that is invalid
$return = $id_server->kbase_ids_to_external_ids(["TEST.1111"]);
@id_keys = keys(%$return);
is(scalar @id_keys, 0, "Return zero keys if asking for invalid 1111");

#-- Tests 54-55 - Test the data just added
$return = $id_server->kbase_ids_to_external_ids(["TEST.44444"]);
@id_keys = keys(%$return);
is(scalar @id_keys, 1, "Return one key if asking for 44444");
foreach (@id_keys)
{
        is($return->{$_}->[1], 'external_id9', "Is the external_id external_id9 - This was allocated");
}

my $foo = 'NAN';

$test_hash =  { 'external_id' => $foo };
$return = $id_server->register_allocated_ids('TEST','SEED', $test_hash); 

#-- Tests 56-57 - Test the data just added
$return = $id_server->kbase_ids_to_external_ids(["TEST.$foo"]);
@id_keys = keys(%$return);
is(scalar @id_keys, 1, "Return one key when asking for NAN");
foreach (@id_keys)
{
        is($return->{$_}->[1], 'external_id', "Used TEST.$foo and returned external_id (non-numeric test)");
}

#-- Tests 59-59 - Test the data just added
$foo = new String::Random;
my $foo2 = $foo->randregex('\d\d\d\d\d\d\d\d\d'); 

$test_hash =  { 'external_id' => $foo2 };
$return = $id_server->register_allocated_ids('TEST','SEED', $test_hash); 
$return = $id_server->kbase_ids_to_external_ids(["TEST.$foo2"]);
@id_keys = keys(%$return);
is(scalar @id_keys, 1, "Return one key when asking for large random number");
foreach (@id_keys)
{
        is($return->{$_}->[1], 'external_id', "Used TEST.$foo2 and returned external_id (large random number test)");
}
Server::stop($pid);

done_testing();

