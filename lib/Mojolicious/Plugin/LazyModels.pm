package Mojolicious::Plugin::LazyModels;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Loader qw/load_class/;
use Mojo::Pg;

our $VERSION = "0.02";
$VERSION = eval $VERSION;

sub register {
  my ($plugin, $app, $conf) = @_;

  die "LazyModels requires 'readwrite' and 'readonly' attributes\n"
    unless $conf->{readwrite} and $conf->{readonly};

  $app->helper(pg_rw => sub {
    state $pg = Mojo::Pg->new($conf->{readwrite});
  });

  $app->helper(pg_ro => sub {
    state $pg = Mojo::Pg->new($conf->{readonly})->options(ReadOnly => 1);
  });

  $app->helper(models_rw => sub {
    my $models = $app->{models}->new(app => $app, pg_db => $app->pg_rw->db);
  });

  $app->helper(models_ro => sub {
    my $models = $app->{models}->new(app => $app, pg_db => $app->pg_ro->db);
  });

  my $class = join '::', ref $app, 'Models';
  my $e = load_class $class;
  die ref $e ? $e : "LazyModels $class not found!" if $e;
  $app->log->debug("Models '$class' successfully loaded");

  $app->{models} = $class;
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::LazyModels - Easy way to interact with PostgreSQL data models

=head1 AUTHOR

Dmitry Krutikov E<lt>monstar@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Dmitry Krutikov.

You may distribute under the terms of either the GNU General Public
License or the Artistic License, as specified in the README file.

=cut

