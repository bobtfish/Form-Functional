package Form::Functional::Field::Compound;
# ABSTRACT: A compound field (containing other fields) within a form

use MooseX::Role::Parameterized;
use Form::Functional::Types qw(Field Fields);
use MooseX::Types::Moose qw(HashRef);
use MooseX::Types::Structured qw(Dict);
use MooseX::Types::LoadableClass 0.002 qw(LoadableClass);
use namespace::autoclean;

parameter fields_options => (
    is       => 'ro',
    init_arg => 'fields',
    default  => sub { +{} },
);

role {
    my ($p) = @_;

    has fields => (
        traits   => [qw(Array)],
        isa      => Fields,
        handles  => {
            fields => 'elements',
        },
        %{ $p->fields_options },
    );

    has fields_by_name => (
        traits   => [qw(Hash)],
        isa      => HashRef,
        init_arg => undef,
        lazy     => 1,
        builder  => '_build_fields_by_name',
        handles  => {
            find_field_by_name  => 'get',
            find_fields_by_name => 'get',
        },
    );

    has processed_class => (
        is      => 'ro',
        isa     => LoadableClass,
        coerce  => 1,
        default => 'Form::Functional::Processed',
        handles => {
            _new_processed => 'new',
        },
    );

    method validate => sub {
        my ($self, $args) = @_;
        return [map {
            $self->_new_processed({
                field        => $self,
                input_values => $_,
            });
        } @{ ref $args->{values} eq 'ARRAY' # FIXME - coercion
                 ?  $args->{values}
                 : [$args->{values}]
        }];
    };

    # convenience wrapper, i guess
    method process => sub {
        my ($self, $values) = @_;
        defined $_ && confess $_ for (Dict[
            values      => HashRef,
        ])->validate($values);
        $self->validate($values)->[0];
    };

    method _build_fields_by_name => sub {
        my ($self) = @_;
        return { $self->fields };
    };
};

1;
