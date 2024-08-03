package MooseX::JSONSchema;
# ABSTRACT: Adding JSON Schema capabilities to your Moose class

use Moose::Exporter;
use Carp qw( croak );

Moose::Exporter->setup_import_methods(
  with_meta => [
    qw( array string object number integer boolean ),
    qw( json_schema_id json_schema_title json_schema_schema ),
  ],
  base_class_roles => ['MooseX::JSONSchema::Role'],
  class_metaroles => {
    class => ['MooseX::JSONSchema::MetaClassTrait'],
  },
  role_metaroles  => {
    role => ['MooseX::JSONSchema::MetaClassTrait'],
  },
);

sub json_schema_id { shift->json_schema_id(shift) }
sub json_schema_title { shift->json_schema_title(shift) }
sub json_schema_schema { shift->json_schema_schema(shift) }

sub array { add_json_schema_attribute( array => @_ ) }
sub string { add_json_schema_attribute( string => @_ ) }
sub object { add_json_schema_attribute( object => @_ ) }
sub number { add_json_schema_attribute( number => @_ ) }
sub integer { add_json_schema_attribute( integer => @_ ) }
sub boolean { add_json_schema_attribute( boolean => @_ ) }

sub add_json_schema_attribute {
  my ( $type, $meta, $name, $description, @args ) = @_;
  my $subtype;
  if ($type eq 'array' or $type eq 'object') {
    $subtype = shift @args;
  }
  my %opts = (
    json_schema_description => $description,
    json_schema_type => $type,
    predicate => 'has_'.$name,
    is => 'ro',
    isa => (
      $type eq 'string' ? 'Str'
      : $type eq 'number' ? 'Num'
      : $type eq 'integer' ? 'Int'
      : $type eq 'array' ? 'ArrayRef'
      : $type eq 'object' ? 'HashRef' : croak(__PACKAGE__.' can\'t handle type '.$type)),
    @args,
  );
  if ($opts{traits}) {
    push @{$opts{traits}}, 'MooseX::JSONSchema::AttributeTrait';
  } else {
    $opts{traits} = ['MooseX::JSONSchema::AttributeTrait'];
  }
  my %context = Moose::Util::_caller_info;
  $context{context} = 'moosex jsonschema attribute declaration';
  $context{type} = 'class';
  my @options = ( definition_context => \%context, %opts );
  my $attrs = ( ref($name) eq 'ARRAY' ) ? $name : [ ($name) ];
  $meta->add_attribute( $_, @options ) for @$attrs;
}

1;

=head1 SYNOPSIS

  package PersonClass;

  use Moose;
  use MooseX::JSONSchema;

  json_schema_title "A person";

  string first_name => "The first name of the person";
  string last_name => "The last name of the person";
  integer age => "Current age in years", json_schema_args => { minimum => 0, maximum => 200 };

  1;

  package CharacterClass;

  use Moose;
  use MooseX::JSONSchema;

  extends 'PersonClass';

  json_schema_title "Extended person";

  string job => "The job of the person";

  1;

  my $json_schema_json = PersonClass->meta->json_schema_json;

  my $person = PersonClass->new(
    first_name => "Peter",
    last_name => "Parker",
    age => 21,
  );

  my $json_schema_data_json = $person->json_schema_data_json;

=head1 DESCRIPTION

B<THIS API IS WORK IN PROGRESS>

=head1 SUPPORT

Repository

  https://github.com/Getty/perl-moosex-jsonschema
  Pull request and additional contributors are welcome
 
Issue Tracker

  https://github.com/Getty/perl-moosex-jsonschema/issues

=cut