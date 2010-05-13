package Form::Functional::Reflector::FieldBuilder::Result;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw/ HashRef /;
use namespace::autoclean;

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
    blessed($self)->new(data => { $self->data, $key => $value });
}

method clone_and_delete ($key) {
    my %data = $self->data;
    delete $data{$key};
    blessed($self)->new(data => \%data);
}

__PACKAGE__->meta->make_immutable;
1;
