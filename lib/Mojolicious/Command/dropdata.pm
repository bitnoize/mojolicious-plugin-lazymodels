package Mojolicious::Command::dropdata;
use Mojo::Base 'Mojolicious::Command';

use Mojo::Util qw/getopt dumper/;

has description => "Cleanup database";
has usage       => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;

  my $app = $self->app;

  if ($app->mode eq 'production') {
    die "REALY_CLEANUP_DATABASE environment variable does not set\n"
      unless $ENV{REALY_CLEANUP_DATABASE};
  }

  $app->log->info("Drop PostgreSQL database..");
  $app->pg_rw->migrations->from_file('schema/migrations.sql')->migrate(0);
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Command::dropdata - Roll-back database migrations

=head1 SYNOPSIS

  Usage: APPLICATION dropdata [OPTIONS]

    mojo dropdata

  Options:
    -h, --help    Show this summary of available options

