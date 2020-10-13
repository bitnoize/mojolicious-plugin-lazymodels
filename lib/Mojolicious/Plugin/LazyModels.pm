package Mojolicious::Plugin::LazyModels;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Pg;

our $VERSION = "0.01";
$VERSION = eval $VERSION;

sub register {
  my ($plugin, $app, $conf) = @_;

  $app->attr(pg => sub { state $pg = Mojo::Pg->new($conf->{Pg}) });
}

1;
