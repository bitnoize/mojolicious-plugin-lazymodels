package MojoX::Model;
use Mojo::Base -base;

use Carp 'croak';

has models  => undef, weak => 1;

sub pg_db     { shift->models->pg_db };
sub pg_tx     { shift->models->pg_tx };

sub stash     { shift->models->stash(@_) };

sub pg_lock   { shift->pg_db->dbh->{BegunWork} ? 'share' : 'none' }

sub _entity_p {
  my ($self, %params) = @_;

  croak "Required param 'sql' missing"
    unless defined $params{sql};

  my @values = @{$params{values} //= []};
  my %onward = %{$params{onward} //= {}};

  $params{stash}    //= 'none';
  $params{reverse}  //= 0;
  $params{handler}  //= sub { Mojo::Promise->resolve(@_) };

  $self->pg_db->query_p($params{sql}, @values)->then(sub {
    my ($result) = @_;

    my $entity = $result->expand->hash;

    $self->stash($params{stash} => [$entity, %onward])
      if $params{stash} ne 'none';

    unless ($params{reverse}) {
      return Mojo::Promise->reject(@params{qw/message strict/}, %onward)
        if $params{strict} ne 'none' and not defined $entity;
    }

    else {
      return Mojo::Promise->reject(@params{qw/message strict/}, %onward)
        if $params{strict} ne 'none' and defined $entity;
    }

    $params{handler}->($entity, %onward);
  });
}

sub _plenty_p {
  my ($self, %params) = @_;

  croak "Required param 'sql' missing"
    unless defined $params{sql};

  my @values = @{$params{values} //= []};
  my %onward = %{$params{onward} //= {}};

  $params{stash}    //= 'none';
  $params{handler}  //= sub { Mojo::Promise->resolve(@_) };

  $self->pg_db->query_p($params{sql}, @values)->then(sub {
    my ($result) = @_;

    my $hashes = $result->expand->hashes;
    my $plenty = $hashes->to_array;

    $onward{size} = $hashes->size;

    $self->stash($params{stash} => [$plenty, %onward])
      if $params{stash} ne 'none';

    $params{handler}->($plenty, %onward);
  });
}

1;
