package Form::Functional::Reflector::FieldBuilder::Result;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw/ HashRef /;
use Carp qw/croak/;
use Hash::Merge 0.12;
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

around data => sub {
    my ($orig, $self) = @_;
    my %data = $self->$orig;
    #use Data::Dumper;
    #warn Dumper \%data;
    foreach my $k (keys %data) {
        if (blessed($data{$k})||'' eq __PACKAGE__) {
            $data{$k} = { $data{$k}->data };
        }
    }
    return %data;
};

around get => sub {
    my ($orig, $self, $key) = @_;
    my $value = $self->$orig($key);
    if (blessed($value)||'' eq __PACKAGE__) {
        return { $value->data };
    }
    return $value;
};

method clone_and_set ($key, $value) {
    if (ref($value) eq 'HASH') {
        $value = __PACKAGE__->new(data => $value);
        croak "Cannot merge data in $key with pre-existing data without a merge direction - try clone_and_merge_r or clone_and_merge_l"
            if (ref($self->get($key)) eq 'HASH');
    }
    if ($self->get($key) && ref($self->get($key)) ne ref($value)) {
        croak sprintf("Cannot set key '%s' to type %s - it already holds a %s",
            $key, ref($value)||'SCALAR', ref($self->get($key))||'SCALAR');
    }
    $self->clone(data => { $self->data, $key => $value });
}

method clone_and_delete ($key) {
    my %data = $self->data;
    delete $data{$key};
    $self->clone(data => \%data);
}

method _clone_and_merge ($merger, $key, $val) {
    my $current = $self->get($key);
    $current ||= {}; # FIXME - Undef is a valid value, should test exists!
    my $type = ref($current) || 'SCALAR';
    croak "Cannot merge hash with non hash ($type) for key $key"
        unless $type eq 'HASH';
    #use Devel::Dwarn;
    #Dwarn [$current, $val];
    $self->clone_and_delete($key)->clone_and_set($key, $merger->merge($current, $val));
}

my $lm = Hash::Merge->new( 'LEFT_PRECEDENT' );
method clone_and_merge_l ($key, $val) {
    $self->_clone_and_merge($lm, $key, $val);
}

my $rm = Hash::Merge->new( 'RIGHT_PRECEDENT' );
method clone_and_merge_r ($key, $val) {
    $self->_clone_and_merge($rm, $key, $val);
}

#clone_merge_{l,r}(@path, $val)
#clone_with(@kv_pairs) and clone_without(@k_list)

__PACKAGE__->meta->make_immutable;
1;
