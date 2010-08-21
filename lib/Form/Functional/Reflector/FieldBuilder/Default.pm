package Form::Functional::Reflector::FieldBuilder::Default;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

with 'Form::Functional::Reflector::FieldBuilder::Entry::Role::Multiplex' => {
    entries_from => 'builder',
};

use aliased ();
BEGIN {
aliased->import($_) for map { 'Form::Functional::Reflector::FieldBuilder::Entry::' . $_ } qw/
    MatchAttribute
    RequiredFromAttribute
    NameFromAttribute
    TypeConstraintFromAttribute

    MatchTypeConstraint
    RequiredFromConstraint
    NameFromConstraint
    TypeConstraintFromConstraint
/;
}

method _build_entries { [
    MatchAttribute->chain( {},
        NameFromAttribute->chain( {},
            RequiredFromAttribute->chain( {},
                TypeConstraintFromAttribute->new
    ))),
    MatchTypeConstraint->chain( {},
        NameFromConstraint->chain( {},
            RequiredFromConstraint->chain( {},
                TypeConstraintFromConstraint->new
    ))),
] }

__PACKAGE__->meta->make_immutable;
1;
