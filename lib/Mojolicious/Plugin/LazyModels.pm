package Mojolicious::Plugin::LazyModels;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Loader qw/load_class/;
use Mojo::Pg;

our $VERSION = "0.02";
$VERSION = eval $VERSION;

sub register {
  my ($plugin, $app, $conf) = @_;

  $conf->{postgres} or die "LazyModels requires 'postgres' config attribute";

  $app->attr(pg => sub { state $pg = Mojo::Pg->new($conf->{postgres}) });

  my $class = join '::', ref $app, 'Models';
  my $e = load_class $class;
  die ref $e ? $e : "LazyModels $class not found" if $e;
  $app->log->debug("LazyModels $class successfully loaded");

  $app->{models} = $class;
}

1;
