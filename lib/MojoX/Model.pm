package MojoX::Model;
use Mojo::Base -base;

use Carp qw/croak/;

has models  => undef, weak => 1;

sub pg_db     { shift->models->pg_db      };
sub pg_tx     { shift->models->pg_tx      };
sub pg_pubsub { shift->models->pg_pubsub  };
sub pg_notify { shift->models->pg_notify  };

sub stash     { shift->models->stash(@_)  };

sub pg_lock   { shift->pg_db->dbh->{BegunWork} ? 'share' : 'none' }

sub _entity_p {
  my ($self, %params) = @_;

  croak "Required param 'sql' is missing"
    unless defined $params{sql};

  my @values = @{$params{values} //= []};
  my %onward = %{$params{onward} //= {}};

  $params{reverse}  //= 0;
  $params{strict}   //= 'none';
  $params{message}  //= "error.unknown_error_message";
  $params{stash}    //= 'none';
  $params{channel}  //= 'none';
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

    push @{$self->pg_notify}, [$params{channel} => $entity]
      if $params{channel} ne 'none';

    $params{handler}->($entity, %onward);
  });
}

sub _plenty_p {
  my ($self, %params) = @_;

  croak "Required param 'sql' is missing"
    unless defined $params{sql};

  my @values = @{$params{values} //= []};
  my %onward = %{$params{onward} //= {}};

  $params{stash}    //= 'none';
  $params{channel}  //= 'none';
  $params{handler}  //= sub { Mojo::Promise->resolve(@_) };

  $self->pg_db->query_p($params{sql}, @values)->then(sub {
    my ($result) = @_;

    my $hashes = $result->expand->hashes;
    my $plenty = $hashes->to_array;

    $onward{list_size} = $hashes->size;

    $self->stash($params{stash} => [$plenty, %onward])
      if $params{stash} ne 'none';

    $hashes->each(sub {
      push @{$self->pg_notify}, [$params{channel} => $_]
    }) if $params{channel} ne 'none';

    $params{handler}->($plenty, %onward);
  });
}

1;
