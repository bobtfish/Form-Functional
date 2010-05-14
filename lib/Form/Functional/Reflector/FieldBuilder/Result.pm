package Form::Functional::Reflector::FieldBuilder::Result;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw/ HashRef /;
use namespace::autoclean;

with 'MooseX::Clone';

has data => (
    isa => HashRef,
    default => sub { {} },
    traits => ['Hash'],
    handles => {
        data => 'elements',
        get => 'get',
    },
);

method clone_and_set ($key, $value) {
    $self->clone(data => { $self->data, $key => $value });
}

method clone_and_delete ($key) {
    my %data = $self->data;
    delete $data{$key};
    $self->clone(data => \%data);
}

__PACKAGE__->meta->make_immutable;
1;
