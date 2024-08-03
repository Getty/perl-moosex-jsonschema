package MooseX::JSONSchema::Role;
# ABSTRACT: Role for classes who have JSON Schema

use Moose::Role;
use JSON::MaybeXS;

sub json_schema_data {
  my ( $self ) = @_;
  return {
    map {
      my $has = 'has_'.$_; $self->$has ? ( $_ => $self->$_ ) : ()
    } keys %{$self->meta->json_schema_properties},
  };
}

sub json_schema_data_json {
  my ( $self, %args ) = @_;
  my $data = $self->json_schema_data;
  my $json = JSON::MaybeXS->new(
    utf8 => 1,
    canonical => 1,
    %args,
  );
  return $json->encode($data);
}

1;