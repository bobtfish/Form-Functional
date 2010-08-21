package Form::Functional::Reflector::FieldBuilder::Entry::TypeConstraintFromConstraint;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw/ Any /;
use namespace::autoclean;

method match { 1 }

# FIXME - Fold this logic and the other TypeConstraintFrom into a role.
method apply ($result, $item) {
    my $tc = $item->[1];
    my $new_result = $result->clone_and_merge_r(with => {type_constraints => [$tc]});

    if ($tc->has_coercion) {
        $new_result = $new_result->clone_and_merge_r(with => {coerce => 1});
    }

    return $new_result;
}

with 'Form::Functional::Reflector::FieldBuilder::Entry';

__PACKAGE__->meta->make_immutable;
1;
