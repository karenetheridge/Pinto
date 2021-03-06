package Pinto::Action::List;

# ABSTRACT: An action for listing contents of a repository

use Moose;

use Carp qw(croak);

use MooseX::Types::Moose qw(Str HashRef);
use Pinto::Types qw(IO);

use namespace::autoclean;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------
# ISA

extends 'Pinto::Action';

#------------------------------------------------------------------------------

has out => (
    is      => 'ro',
    isa     => IO,
    coerce  => 1,
    default => sub { [fileno(STDOUT), '>'] },
);


has format => (
    is      => 'ro',
    isa     => Str,
    default => '',
);


has where => (
    is      => 'ro',
    isa     => HashRef,
    default => sub { {} },
);

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    my $where = $self->where();

    my $attrs = { order_by => [ qw(name version path) ],
                  prefetch => 'distribution' };

    my $rs = $self->repos->db->select_packages($where, $attrs);

    my $format = $self->format();
    while( my $package = $rs->next() ) {
        print { $self->out() } $package->to_formatted_string($format);
    }

    return 0;
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;

__END__
