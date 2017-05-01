package CUZK::SOAP;

use SOAP::Lite;
use parent 'SOAP::Lite';
use CUZK::SOAP::Serializer;

sub new {
	my ($class, %args) = @_;

	my $username = delete $args{username};
	my $password = delete $args{password};

	my $serializer = CUZK::SOAP::Serializer
		->new( username => $username, password => $password );

	my $soap = SOAP::Lite
		->serializer( $serializer );

	return $soap;
}

1;
