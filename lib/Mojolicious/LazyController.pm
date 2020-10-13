package Mojolicious::LazyController;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Loader qw/load_class/;

sub models {
  my ($c) = @_;

  my $stash = $c->render_later->stash;
  return $stash->{'mojo.models'} if defined $stash->{'mojo.models'};

  my $class = join '::', ref $c->app, 'Models';
  my $e = load_class $class;
  die "Loading $class failed: $e" if ref $e;

  my $models = $class->new(app => $c->app);
  return $stash->{'mojo.models'} = $models;
}

1;
