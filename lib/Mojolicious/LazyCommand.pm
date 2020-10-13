package Mojolicious::LazyCommand;
use Mojo::Base 'Mojolicious::Command';

use Mojo::Loader qw/load_class/;

sub models {
  my ($self) = @_;

  my $class = join '::', ref $self->app, 'Models';
  my $e = load_class $class;
  die "Loading $class failed: $e" if ref $e;

  return $class->new(app => $self->app);
}

1;
