package MooseX::JSONSchema::MetaClassTrait;
# ABSTRACT: Trait for meta classes having a JSON Schema

use Moose::Role;
use JSON::MaybeXS;

has json_schema_id => (
  is => 'rw',
  isa => 'Str',
  lazy_build => 1,
);
sub _build_json_schema_id {
  my ( $self ) = @_;
  my $class = lc($self->name);
  $class =~ s/::/./g;
  return 'https://json-schema.org/perl.'.$class.'.schema.json';
}

has json_schema_schema => (
  is => 'rw',
  isa => 'Str',
  lazy_build => 1,
);
sub _build_json_schema_schema {
  my ( $self ) = @_;
  return 'https://json-schema.org/draft/2020-12/schema';
}

has json_schema_title => (
  is => 'rw',
  isa => 'Str',
  lazy_build => 1,
);
sub _build_json_schema_title {
  my ( $self ) = @_;
  my $class = ref $self;
  $class =~ s/::/ /g;
  return join(' ',map { ucfirst } split(/\s+/, $class));
}

has json_schema_data => (
  is => 'ro',
  isa => 'HashRef',
  lazy_build => 1,
);
sub _build_json_schema_data {
  my ( $self ) = @_;
  return {
    '$id' => $self->json_schema_id,
    '$schema' => $self->json_schema_schema,
    title => $self->json_schema_title,
    type => 'object',
    properties => $self->json_schema_properties,
  };
}

has json_schema_properties => (
  is => 'ro',
  isa => 'HashRef',
  lazy_build => 1,
);
sub _build_json_schema_properties {
  my ( $self ) = @_;
  my @schema_attributes = grep { $_->does('MooseX::JSONSchema::AttributeTrait') } $self->get_all_attributes;
  return { map { $_->name, $_->json_schema_property_data } @schema_attributes };
}

sub json_schema_json {
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