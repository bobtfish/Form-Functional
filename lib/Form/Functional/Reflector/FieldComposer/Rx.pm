package Form::Functional::Reflector::FieldComposer::Rx;

use Moose;
use namespace::autoclean;
use Hash::Merge;

sub output_from_fields {
    my ($self, @fields) = @_;
    my $merge = Hash::Merge->new( 'LEFT_PRECEDENT' );
    my $out = {
        type     => '//rec',
    };
    $out = $merge->merge($out, $_) for @fields;
    return $out;
}

with 'Form::Functional::Reflector::FieldComposer';

__PACKAGE__->meta->make_immutable;
1;
