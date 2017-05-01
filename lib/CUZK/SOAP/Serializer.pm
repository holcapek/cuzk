package CUZK::SOAP::Serializer;

use strict;
use warnings;
use vars '@ISA';
require SOAP::Lite;
@ISA = 'SOAP::Serializer';

sub new {
	my ($class, %args) = @_;
	my $username = delete $args{username};
	my $password = delete $args{password};
	my $self = $class->SUPER::new(%args);

	no warnings 'redefine';
	# SOAP::Serializer calls $self->new() sometimes,
	# which throws _cuzk_* away
	#$self->{_cuzk_username} = $username;
	#$self->{_cuzk_password} = $password;
	*CUZK::SOAP::Serializer::username = sub { $username };
	*CUZK::SOAP::Serializer::password = sub { $password };

	$self->readable( 1 );
	return $self;
}

sub wsse_header {
	my ($self) = @_;
	SOAP::Header
		->attr({
			'xmlns:wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
			'xmlns:wsu'  => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd',
		})
		->mustUnderstand(1)
		->name('wsse:Security')
		->value(
			\SOAP::Header
				->name('wsse:UsernameToken')
				->value(
					\SOAP::Header->value(
						SOAP::Header
							->name('wsse:Username')
							->value($self->username)
							->type(''),
						SOAP::Header
							->name('wsse:Password')
							->value($self->password)
							->attr({'Type' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'})
							->type(''),
						)
				)
		);
}

sub envelope {
	my ($self, $call_type, $call_name, @rest) = @_;
	# this is here to work around xsi:nul="true" being
	# set to method element, and which make the call fail
	if ($call_type eq 'method' and !@rest) {
		$self->SUPER::envelope(
			'freeform',
			SOAP::Data
				->name($call_name)
				->prefix('typ'),
			$self->wsse_header,
			@rest
		);
	} else {
		$self->SUPER::envelope($call_type, $call_name, @rest);
	}
}

1;
