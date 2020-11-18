package MojoX::Models;
use Mojo::Base -base;

use Carp qw/croak/;
use Mojo::Collection;
use Mojo::Loader qw/load_class/;
use Mojo::Util;

has app => undef, weak => 1;

has [qw/pg_db pg_tx pg_pubsub/];

has pg_notify => sub { Mojo::Collection->new };

sub PUBSUB_CHANNELS     { }

sub UNSIGNED_SMALLINT   { 0, 32767 }
sub UNSIGNED_INTEGER    { 0, 2147483647 }
sub UNSIGNED_BIGINT     { 0, 1152921504606846976 }

sub SIGNED_SMALLINT     { -32768,               32767 }
sub SIGNED_INTEGER      { -2147483648,          2147483647 }
sub SIGNED_BIGINT       { -9223372036854775808, 9223372036854775807 }

sub LIKE_UUID           { qr/^[0-9a-f]{8}-
                              [0-9a-f]{4}-
                              [0-9a-f]{4}-
                              [0-9a-f]{4}-
                              [0-9a-f]{12}$/ix }

sub pg_atomic {
  my ($self) = @_;

  $self->pg_tx($self->pg_db->begin);
  $self->pg_pubsub->json($_) for $self->PUBSUB_CHANNELS;

  return $self;
}

sub pg_commit {
  my ($self) = @_;

  $self->pg_tx->commit;

  while ($self->pg_notify->size) {
    my ($channel, $json) = @{shift @{$self->pg_notify}};

    croak "Malformed Postgres PubSub notify"
      unless defined $channel
        and  not ref $channel
        and  ref $json eq 'HASH';

    croak "Unknown Postgres PubSub channel '$channel'"
      unless grep { $_ eq $channel } $self->PUBSUB_CHANNELS;

    $self->pg_pubsub->notify($channel => $json);
  }

  return $self;
}

sub stash { Mojo::Util::_stash(stash => @_) }

sub _load_model {
  my ($self, $name) = @_;

  my $class = join '::', ref $self->app, 'Model', $name;
  my $e = load_class $class;
  die ref $e ? $e : "LazyModels $class not found" if $e;
  $self->app->log->debug("Model '$class' successfully loaded");

  my $model = $class->new(models => $self);
}

1;
