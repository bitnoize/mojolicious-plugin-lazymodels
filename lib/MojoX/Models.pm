package MojoX::Models;
use Mojo::Base -base;

use Mojo::Loader qw/load_class/;

has app       => undef, weak => 1;

has pg_db     => sub { shift->app->pg->db };
has pg_tx     => undef;

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

sub load_model {
  my ($self, $name) = @_;

  my $class = join '::', ref $self->app, 'Model', $name;
  my $e = load_class $class;
  die ref $e ? $e : "LazyModels $class not found" if $e;
  $app->log->debug("LazyModel $class successfully loaded");

  return $class->new(models => $self);
}

1;
