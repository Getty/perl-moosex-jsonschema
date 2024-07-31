package MooseX::JSONSchema::AttributeTrait;

use Moose::Role;

has json_schema_description => (
  is => 'ro',
  isa => 'Str',
  predicate => 'has_json_schema_description',
);

has json_schema_type => (
  is => 'ro',
  isa => 'Str',
  predicate => 'has_json_schema_type',
);

has json_schema_args => (
  is => 'ro',
  isa => 'HashRef',
  lazy_build => 1,
);
sub _build_json_schema_args {{}}

has json_schema_property_data => (
  is => 'ro',
  isa => 'HashRef',
  lazy_build => 1,
);
sub _build_json_schema_property_data {
  my ( $self ) = @_;
  return {
    type => $self->json_schema_type,
    description => $self->json_schema_description,
    %{$self->json_schema_args},
  };
}

1;