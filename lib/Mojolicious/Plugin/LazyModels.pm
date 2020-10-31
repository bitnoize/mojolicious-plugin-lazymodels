package Mojolicious::Plugin::LazyModels;
use Mojo::Base 'Mojolicious::Plugin';

use Scalar::Util qw/looks_like_number/;
use Mojo::Loader qw/load_class/;
use Mojo::Pg;

our $VERSION = "0.05";
$VERSION = eval $VERSION;

sub register {
  my ($plugin, $app, $conf) = @_;

  $conf->{readwrite}  //= $conf->{connect};
  $conf->{readonly}   //= $conf->{readwrite};
  $conf->{migrations} //= "schema/migrations.sql";

  die "LazyModels requires at last 'connect' config attribute\n"
    unless defined $conf->{readwrite} and defined $conf->{readonly};

  $app->helper(pg_rw => sub {
    state $pg = Mojo::Pg->new($conf->{readwrite});
  });

  $app->helper(pg_ro => sub {
    state $pg = Mojo::Pg->new($conf->{readonly})->options({
      ReadOnly => 1, AutoCommit => 0
    });
  });

  $app->helper(models_rw => sub {
    my %attrs = (
      pg_db     => $app->pg_rw->db,
      pg_pubsub => $app->pg_rw->pubsub
    );

    my $models = $app->{models}->new(app => $app, %attrs);
  });

  $app->helper(models_ro => sub {
    my %attrs = (
      pg_db     => $app->pg_ro->db,
      pg_pubsub => $app->pg_ro->pubsub
    );

    my $models = $app->{models}->new(app => $app, %attrs);
  });

  $app->validator->add_check(boolean => sub {
    shift->in(0, 1)->has_error(shift)
  });

  $app->validator->add_check(smallint => sub {
    shift->num($app->{models}->RANGE_SMALLINT)->has_error(shift)
  });

  $app->validator->add_check(integer => sub {
    shift->num($app->{models}->RANGE_INTEGER)->has_error(shift)
  });

  $app->validator->add_check(bigint => sub {
    shift->num($app->{models}->RANGE_BIGINT)->has_error(shift)
  });

  $app->validator->add_check(text => sub {
    shift->like($app->{models}->LIKE_TEXT)->has_error(shift)
  });

  $app->validator->add_check(uuid => sub {
    shift->like($app->{models}->LIKE_UUID)->has_error(shift)
  });

  # Migrate only if migrations file exists
  my $migrations = $app->home->child($conf->{migrations});
  if ($migrations->stat) {
    $app->log->debug("Process migrations from " . $migrations->to_rel);
    $app->pg_rw->migrations->from_file($migrations)->migrate;
  }

  my $class = join '::', ref $app, 'Models';
  my $e = load_class $class;
  die ref $e ? $e : "LazyModels $class not found" if $e;
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

