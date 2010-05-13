package Form::Functional::Reflector::FieldBuilder::Entry::MatchTypeConstraint;
use Moose;
use Method::Signatures::Simple;
use Form::Functional::Types qw/ TypeConstraint /;
use namespace::autoclean;

method match ($item) {
    is_TypeConstraint($item);
}

with 'Form::Functional::Reflector::FieldBuilder::Entry::Role::MatchOnly';

__PACKAGE__->meta->make_immutable;
1;
