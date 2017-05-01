package CUZK::Ciselnik;

use Moose;
use CUZK::SOAP;

my $username = 'WSTEST';
my $password = 'WSHESLO';
my $proxy    = 'https://katastr.cuzk.cz/trial/ws/wsdp/2.3/ciselnik';
my $ns       = 'http://katastr.cuzk.cz/ciselnik/types/v2.3';

has 'soap' => (
	is => 'ro',
	lazy => 1,
	builder => '_build_soap',
);

sub _build_soap {
	my $soap = CUZK::SOAP->new( username => $username, password => $password );
	$soap
		->ns($ns, 'typ')
		->proxy($proxy);
	$soap;
}

my @lookup = qw(
  seznamCastiObci
  seznamCiselniku
  seznamCislovaniParcel
  seznamDruhuPozemku
  seznamHistKU
  seznamKU
  seznamKraju
  seznamMestskychCasti
  seznamObci
  seznamOkresu
  seznamOperaciRizeni
  seznamPracovist
  seznamPredmetuRizeni
  seznamStatu
  seznamTypParcely
  seznamTypuJednotek
  seznamTypuOS
  seznamTypuOperaci
  seznamTypuParcel
  seznamTypuPravnichVztahu
  seznamTypuRizeni
  seznamTypuStaveb
  seznamUcelu
  seznamUceluPS
  seznamUlic
  seznamUrceniVymery
  seznamVyuzitiJednotky
  seznamVyuzitiPozemku
  seznamVyuzitiStavby
  seznamZdrojuCislovaniZE
  seznamZprav
  seznamZpusobOchrany
);

my $transform = {
	seznamKraju => sub {
		my ($som) = @_;
		$som->valueof('//kraj');
	},
	seznamObci => sub {
		my ($som) = @_;
		$som->valueof('//obec');
	},
};
		
foreach my $call (@lookup) {
	my $soap_call = "\u${call}Request";
	no strict 'refs';
	*$call = sub {
		my ($self, @rest) = @_;
		my $som = $self->soap->$soap_call(@rest);
		die $som->faultstring if $som->fault;
		return $transform->{$call}->($som) if exists $transform->{$call};
		$som->root;
	};
}

1;
