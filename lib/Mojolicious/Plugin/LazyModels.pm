package Mojolicious::Plugin::LazyModels;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Pg;
use Mojo::Loader qw/load_class/;

our $VERSION = "0.06";
$VERSION = eval $VERSION;

sub register {
  my ($plugin, $app, $conf) = @_;

  $conf->{readwrite}  //= $conf->{connect};
  $conf->{readonly}   //= $conf->{readwrite};
  $conf->{migrations} //= "schema/migrations.sql";

  die "LazyModels requires at last 'connect' config attribute\n"
    unless defined $conf->{readwrite} and defined $conf->{readonly};

  #
  # Accessors
  #

  $app->helper(pg_rw => sub {
    $app->{pg_rw} //= Mojo::Pg->new($conf->{readwrite});
  });

  $app->helper(pg_ro => sub {
    $app->{pg_ro} //= Mojo::Pg->new($conf->{readonly})->options({
      ReadOnly => 1, AutoCommit => 0
    });
  });

  #
  # Models
  #

  $app->helper(models_rw => sub {
    shift->{models_rw} //= $app->{models}->new(
      app       => $app,
      pg_db     => $app->pg_rw->db,
      pg_pubsub => $app->pg_rw->pubsub
    );
  });

  $app->helper(models_ro => sub {
    shift->{models_ro} //= $app->{models}->new(
      app   => $app,
      pg_db => $app->pg_ro->db
    );
  });

  #
  # PubSub
  #

  $app->helper(pubsub_listen => sub {
    my ($c, $channel, $cb) = @_;

    my $pubsub = $app->pg_rw->pubsub;
    $pubsub->json($channel)->listen($channel => $cb);
  });

  $app->helper(pubsub_unlisten => sub {
    my ($c, @unlisten) = @_;

    my $pubsub = $app->pg_rw->pubsub;
    map {
      my ($channel, $handler) = @$_;
      $pubsub->unlisten($channel => $handler);
    } @unlisten;
    return $pubsub;
  });

  $app->helper(pubsub_notify => sub {
    my ($c, @notify) = @_;

    my $pubsub = $app->pg_rw->pubsub;
    map {
      my ($channel, $json) = @$_;
      $pubsub->json($channel)->notify($channel => $json);
    } @notify;
    return $pubsub;
  });

  #
  # Validators
  #

  $app->validator->add_check(boolean => sub {
    shift->in(0, 1)->has_error(shift)
  });

  $app->validator->add_check(unsigned_smallint => sub {
    shift->num($app->{models}->UNSIGNED_SMALLINT)->has_error(shift)
  });

  $app->validator->add_check(unsigned_integer => sub {
    shift->num($app->{models}->UNSIGNED_INTEGER)->has_error(shift)
  });

  $app->validator->add_check(unsigned_bigint => sub {
    shift->num($app->{models}->UNSIGNED_BIGINT)->has_error(shift)
  });

  $app->validator->add_check(signed_smallint => sub {
    shift->num($app->{models}->SIGNED_SMALLINT)->has_error(shift)
  });

  $app->validator->add_check(signed_integer => sub {
    shift->num($app->{models}->SIGNED_INTEGER)->has_error(shift)
  });

  $app->validator->add_check(signed_bigint => sub {
    shift->num($app->{models}->SIGNED_BIGINT)->has_error(shift)
  });

  $app->validator->add_check(like_uuid => sub {
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

Mojolicious::Plugin::LazyModels - Easy way to interact with PostgreSQL Data Models

=head1 AUTHOR

Dmitry Krutikov E<lt>monstar@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Dmitry Krutikov.

You may distribute under the terms of either the GNU General Public
License or the Artistic License, as specified in the README file.

=cut

