package Bio::KBase::IDServer::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::IDServer::Client

=head1 DESCRIPTION



=cut

sub new
{
    my($class, $url) = @_;

    my $self = {
	client => Bio::KBase::IDServer::Client::RpcClient->new,
	url => $url,
    };
    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 kbase_ids_to_external_ids

  $return = $obj->kbase_ids_to_external_ids($ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$ids is a reference to a list where each element is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is a reference to a list containing 2 items:
	0: an external_db
	1: an external_id
kbase_id is a string
external_db is a string
external_id is a string

</pre>

=end html

=begin text

$ids is a reference to a list where each element is a kbase_id
$return is a reference to a hash where the key is a kbase_id and the value is a reference to a list containing 2 items:
	0: an external_db
	1: an external_id
kbase_id is a string
external_db is a string
external_id is a string


=end text

=item Description

Given a set of KBase identifiers, look up the associated external identifiers.
If no external ID is associated with the KBase id, no entry will be present in the return.

=back

=cut

sub kbase_ids_to_external_ids
{
    my($self, @args) = @_;

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function kbase_ids_to_external_ids (received $n, expecting 1)");
    }
    {
	my($ids) = @args;

	my @_bad_arguments;
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to kbase_ids_to_external_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'kbase_ids_to_external_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.kbase_ids_to_external_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'kbase_ids_to_external_ids',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method kbase_ids_to_external_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'kbase_ids_to_external_ids',
				       );
    }
}



=head2 external_ids_to_kbase_ids

  $return = $obj->external_ids_to_kbase_ids($external_db, $ext_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$external_db is an external_db
$ext_ids is a reference to a list where each element is an external_id
$return is a reference to a hash where the key is an external_id and the value is a kbase_id
external_db is a string
external_id is a string
kbase_id is a string

</pre>

=end html

=begin text

$external_db is an external_db
$ext_ids is a reference to a list where each element is an external_id
$return is a reference to a hash where the key is an external_id and the value is a kbase_id
external_db is a string
external_id is a string
kbase_id is a string


=end text

=item Description

Given a set of external identifiers, look up the associated KBase identifiers.
If no KBase ID is associated with the external id, no entry will be present in the return.

=back

=cut

sub external_ids_to_kbase_ids
{
    my($self, @args) = @_;

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function external_ids_to_kbase_ids (received $n, expecting 2)");
    }
    {
	my($external_db, $ext_ids) = @args;

	my @_bad_arguments;
        (!ref($external_db)) or push(@_bad_arguments, "Invalid type for argument 1 \"external_db\" (value was \"$external_db\")");
        (ref($ext_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"ext_ids\" (value was \"$ext_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to external_ids_to_kbase_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'external_ids_to_kbase_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.external_ids_to_kbase_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'external_ids_to_kbase_ids',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method external_ids_to_kbase_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'external_ids_to_kbase_ids',
				       );
    }
}



=head2 register_ids

  $return = $obj->register_ids($prefix, $db_name, $ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$prefix is a kbase_id_prefix
$db_name is an external_db
$ids is a reference to a list where each element is an external_id
$return is a reference to a hash where the key is an external_id and the value is a kbase_id
kbase_id_prefix is a string
external_db is a string
external_id is a string
kbase_id is a string

</pre>

=end html

=begin text

$prefix is a kbase_id_prefix
$db_name is an external_db
$ids is a reference to a list where each element is an external_id
$return is a reference to a hash where the key is an external_id and the value is a kbase_id
kbase_id_prefix is a string
external_db is a string
external_id is a string
kbase_id is a string


=end text

=item Description

Register a set of identifiers. All will be assigned identifiers with the given
prefix.

If an external ID has already been registered, the existing registration will be returned instead 
of a new ID being allocated.

=back

=cut

sub register_ids
{
    my($self, @args) = @_;

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function register_ids (received $n, expecting 3)");
    }
    {
	my($prefix, $db_name, $ids) = @args;

	my @_bad_arguments;
        (!ref($prefix)) or push(@_bad_arguments, "Invalid type for argument 1 \"prefix\" (value was \"$prefix\")");
        (!ref($db_name)) or push(@_bad_arguments, "Invalid type for argument 2 \"db_name\" (value was \"$db_name\")");
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to register_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'register_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.register_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'register_ids',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method register_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'register_ids',
				       );
    }
}



=head2 allocate_id_range

  $starting_value = $obj->allocate_id_range($kbase_id_prefix, $count)

=over 4

=item Parameter and return types

=begin html

<pre>
$kbase_id_prefix is a kbase_id_prefix
$count is an int
$starting_value is an int
kbase_id_prefix is a string

</pre>

=end html

=begin text

$kbase_id_prefix is a kbase_id_prefix
$count is an int
$starting_value is an int
kbase_id_prefix is a string


=end text

=item Description

Allocate a set of identifiers. This allows efficient registration of a large
number of identifiers (e.g. several thousand features in a genome).

The return is the first identifier allocated.

=back

=cut

sub allocate_id_range
{
    my($self, @args) = @_;

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function allocate_id_range (received $n, expecting 2)");
    }
    {
	my($kbase_id_prefix, $count) = @args;

	my @_bad_arguments;
        (!ref($kbase_id_prefix)) or push(@_bad_arguments, "Invalid type for argument 1 \"kbase_id_prefix\" (value was \"$kbase_id_prefix\")");
        (!ref($count)) or push(@_bad_arguments, "Invalid type for argument 2 \"count\" (value was \"$count\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to allocate_id_range:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'allocate_id_range');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.allocate_id_range",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'allocate_id_range',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method allocate_id_range",
					    status_line => $self->{client}->status_line,
					    method_name => 'allocate_id_range',
				       );
    }
}



=head2 register_allocated_ids

  $obj->register_allocated_ids($prefix, $db_name, $assignments)

=over 4

=item Parameter and return types

=begin html

<pre>
$prefix is a kbase_id_prefix
$db_name is an external_db
$assignments is a reference to a hash where the key is an external_id and the value is an int
kbase_id_prefix is a string
external_db is a string
external_id is a string

</pre>

=end html

=begin text

$prefix is a kbase_id_prefix
$db_name is an external_db
$assignments is a reference to a hash where the key is an external_id and the value is an int
kbase_id_prefix is a string
external_db is a string
external_id is a string


=end text

=item Description

Register the mappings for a set of external identifiers. The
KBase identifiers used here were previously allocated using allocate_id_range.

Does not return a value.

=back

=cut

sub register_allocated_ids
{
    my($self, @args) = @_;

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function register_allocated_ids (received $n, expecting 3)");
    }
    {
	my($prefix, $db_name, $assignments) = @args;

	my @_bad_arguments;
        (!ref($prefix)) or push(@_bad_arguments, "Invalid type for argument 1 \"prefix\" (value was \"$prefix\")");
        (!ref($db_name)) or push(@_bad_arguments, "Invalid type for argument 2 \"db_name\" (value was \"$db_name\")");
        (ref($assignments) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 3 \"assignments\" (value was \"$assignments\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to register_allocated_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'register_allocated_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.register_allocated_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'register_allocated_ids',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method register_allocated_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'register_allocated_ids',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "IDServerAPI.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'register_allocated_ids',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method register_allocated_ids",
            status_line => $self->{client}->status_line,
            method_name => 'register_allocated_ids',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::IDServer::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::IDServer::Client version is $svr_version. API subject to change.\n";
    }
}

package Bio::KBase::IDServer::Client::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}

1;
