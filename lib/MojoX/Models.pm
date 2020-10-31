package MojoX::Models;
use Mojo::Base -base;

use Mojo::Util;
use Mojo::Loader qw/load_class/;

has app => undef, weak => 1;

has [qw/pg_db pg_pubsub pg_tx/];

sub RANGE_SMALLINT  { 0, 32767 }
sub RANGE_INTEGER   { 0, 2147483647 }
sub RANGE_BIGINT    { 0, 1152921504606846976 }

sub LIKE_TEXT       { qr/^[ -~]+$/ }
sub LIKE_UUID       { qr/^[0-9a-f]{8}-
                          [0-9a-f]{4}-
                          [0-9a-f]{4}-
                          [0-9a-f]{4}-
                          [0-9a-f]{12}$/ix }

sub stash { Mojo::Util::_stash(stash => @_) }

sub pg_atomic {
  my ($self) = @_;

  $self->pg_tx($self->pg_db->begin);

  return $self;
}

sub pg_commit {
  my ($self) = @_;

  $self->pg_tx->commit;

  return $self;
}

sub _load_model {
  my ($self, $name) = @_;

  my $class = join '::', ref $self->app, 'Model', $name;
  my $e = load_class $class;
  die ref $e ? $e : "LazyModels $class not found" if $e;
  $self->app->log->debug("Model '$class' successfully loaded");

  my $model = $class->new(models => $self);
}

1;
