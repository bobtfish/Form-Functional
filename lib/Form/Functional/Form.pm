package Form::Functional::Form;
# ABSTRACT: Reasonable Forms taking advantage of immutability and functional data structures

use Moose 0.90;
use namespace::autoclean;

extends 'Form::Functional::Field';
with 'Form::Functional::Field::Compound' => {
    fields => {
        required => 1,
    },
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

=cut
