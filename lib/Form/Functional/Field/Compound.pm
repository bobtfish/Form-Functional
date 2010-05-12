package Form::Functional::Field::Compound;

use MooseX::Role::Parameterized;
use Form::Functional::Types qw(Field Fields);
use MooseX::Types::LoadableClass qw(ClassName);
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

    has processed_class => (
        is      => 'ro',
        isa     => ClassName,
        coerce  => 1,
        default => 'Form::Functional::Processed',
        handles => {
            _new_processed => 'new',
        },
    );

    method process => sub {
        my ($self, $values) = @_;
        return $self->_new_processed({
            field        => $self,
            input_values => $values,
        });
    };

    method validate => sub {
        my ($self, @values) = @_;
        my @ret = grep {
            scalar keys %{ $_ }
        } map {
            +{ $self->process($_)->_errors }
        } @values;
        return @ret ? \@ret : undef;
    };
};

1;
