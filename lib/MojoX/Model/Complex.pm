package MojoX::Model::Complex;
use Mojo::Base 'MojoX::Model';

use Carp qw/croak/;

sub TABLE_ALIAS   { die "Constant 'TABLE_ALIAS' not implemented" }
sub TABLE_SERIAL  { die "Constant 'TABLE_SERIAL' not implemented" }

sub check_params {
  my ($self, $params, @fields) = @_;

  croak "Wrong 'check_params' helper usage"
    unless ref $params eq 'HASH' and @fields;

  my @miss = grep { not defined $params->{$_} } @fields;
  croak "Missing required params: @miss" if @miss;

  return $self;
}

sub make_ignore {
  my ($self, $params) = @_;

  croak "Wrong 'make_ignore' helper usage"
    unless ref $params eq 'HASH'
      and defined $params->{sql}
      and not ref $params->{sql};

  $params->{ignore} //= 0;

  if ($params->{ignore}) {
    $params->{sql} .= sprintf "AND %s.%s != ?\n",
      $self->TABLE_ALIAS, $self->TABLE_SERIAL;

    push @{$params->{values}}, $params->{ignore};
  }

  return $self;
}

sub make_lock {
  my ($self, $params) = @_;

  croak "Wrong 'make_lock' helper usage"
    unless ref $params eq 'HASH'
      and defined $params->{sql}
      and not ref $params->{sql};

  $params->{lock} //= $self->pg_lock;

  if ($params->{lock} ne 'none') {
    my @lock = (uc $params->{lock}, $self->TABLE_ALIAS);
    $params->{sql} .= sprintf "FOR %s OF %s\n", @lock;
  }

  return $self;
}

sub query_p {
  my ($self, $params) = @_;

  croak "Wrong 'query_p' helper usage"
    unless ref $params eq 'HASH'
      and defined $params->{sql}
      and not ref $params->{sql}
      and ref $params->{values} eq 'HASH';

  $self->pg_db->query_p($params->{sql}, @{$params->{values}});
}

sub pass_single {
  my ($self, $params, $entity, %onward) = @_;

  croak "Wrong 'pass_entity' helper usage"
    unless ref $params eq 'HASH'
      and defined $params->{stash}
      and not ref $params->{stash}
      and defined $params->{strict}
      and not ref $params->{strict}
      and defined $params->{message}
      and not ref $params->{message};

  $params->{reverse} //= 0;
  $params->{handler} //= sub { Mojo::Promise->resolve(@_) };

  $self->stash($params->{stash} => [$entity, %onward])
    if $params->{stash} ne 'none';

  unless ($params->{reverse}) {
    return Mojo::Promise->reject(@$params{qw/message strict/}, %onward)
      if $params->{strict} ne 'none' and not defined $entity;
  }

  else {
    return Mojo::Promise->reject(@$params{qw/message strict/}, %onward)
      if $params->{strict} ne 'none' and defined $entity;
  }

  $params->{handler}->($entity, %onward);
}

sub pass_plural {
  my ($self, $params, $plenty, %onward) = @_;

  croak "Wrong 'pass_plural' helper usage"
    unless ref $params eq 'HASH'
      and defined $params->{stash}
      and not ref $params->{stash};

  $params->{handler} //= sub { Mojo::Promise->resolve(@_) };

  $self->stash($params->{stash} => [$plenty, %onward])
    if $params->{stash} ne 'none';

  $params->{handler}->($plenty, %onward);
}

1;
