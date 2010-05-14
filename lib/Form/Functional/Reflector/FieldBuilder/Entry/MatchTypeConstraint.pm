package Form::Functional::Reflector::FieldBuilder::Entry::MatchTypeConstraint;
use Moose;
use Method::Signatures::Simple;
use Form::Functional::Reflector::Types qw/ NameAndConstraintPair /;
use namespace::autoclean;

method match ($item) {
    is_NameAndConstraintPair($item);
}

with 'Form::Functional::Reflector::FieldBuilder::Entry::Role::MatchOnly';

__PACKAGE__->meta->make_immutable;
1;
