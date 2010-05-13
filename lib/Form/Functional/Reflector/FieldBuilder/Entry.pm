package Form::Functional::Reflector::FieldBuilder::Entry;
use Moose::Role;
use Form::Functional::Reflector::Types qw/FieldBuilderEntry/;
use namespace::autoclean;

requires qw(match apply);

use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::NeverMatch';

around apply => sub {
    my ($orig, $self, $result, $item) = @_;
    my $new_result = $self->$orig($result, $item);
    $new_result ||= $result; # We still chain in this case, sane?
    if ($self->next_link_matches($item)) {
        my $chained_new_result = $self->apply_to_next_link($new_result, $item);
        $new_result = $chained_new_result if $chained_new_result;
    }
    return $new_result;
};

has next_link => (
    isa => FieldBuilderEntry,
    is => 'ro',
    writer => 'chain',
    default => sub { NeverMatch->new },
    handles => {
        apply_to_next_link => 'apply',
        next_link_matches => 'match',
    }
);

around chain => sub {
    my ($orig, $self, @vals) = @_;
    $self->$orig(@vals);
    return $self;
};

1;
