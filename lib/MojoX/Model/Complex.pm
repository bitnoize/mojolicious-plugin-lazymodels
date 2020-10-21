package MojoX::Model::Complex;
use Mojo::Base 'MojoX::Model';

sub TABLE_ALIAS   { die "Method 'TABLE_ALIAS' not implemented by sub-class" }

sub _make_check {
  my ($self, $params, @fields) = @_;

  croak "There are no fields to check!" unless @fields;

  my @missing = grep { not defined $params->{$_} } @fields;
  croak "Missing required params: @missing" if @missing;

  return $self;
}

sub _make_lock {
  my ($self, $params) = @_;

  croak "Malformed required params: query, lock!"
    unless defined $params->{query} and defined $params->{lock};

  if ($params->{lock} ne 'none') {
    my @values = (uc $params->{lock}, $self->TABLE_ALIAS);
    $params->{query} .= sprintf "FOR %s OF %s\n", @values;
  }

  return $self;
}

sub _query_p {
  my ($self, $params) = @_;

  croak "Malformed required params: query, values!"
    unless defined $params->{query} and defined $params->{values};

  $self->pg_db->query_p($params->{query}, @{$params->{values}});
}

sub _single_p {
  my ($self, $params, $entity, %onward) = @_;

  croak "Usage: _single_p(\$params, \$entity, \%onward)"
    unless ref $params eq 'HASH' and ref $entity eq 'HASH';

  my @require = qw/stash strict message/;
  my @missing = grep { not defined $params->{$_} } @require;
  croak "Missing required params: @missing!" if @missing;

  $params->{revert} //= 0;

  $self->stash($params->{stash} => [$entity, %onward])
    if $params->{stash} ne 'none';

  unless ($params->{revert}) {
    return Mojo::Promise->reject(@params{qw/message strict/}, %onward)
      if $params->{strict} ne 'none' and not defined $entity;
  }

  else {
    return Mojo::Promise->reject(@params{qw/message strict/}, %onward)
      if $params->{strict} ne 'none' and defined $entity;
  }

  Mojo::Promise->resolve($entity, %onward);
}

sub _plural_p {
  my ($self, $params, $plenty, %onward) = @_;

  croak "Usage: _plural_p(\$params, \$plenty, \%onward)"
    unless ref $params eq 'HASH' and ref $plenty eq 'ARRAY';

  my @require = qw/stash/;
  my @missing = grep { not defined $params->{$_} } @require;
  croak "Missing required params: @missing!" if @missing;

  $self->stash($params->{stash} => [$entity, %onward])
    if $params->{stash} ne 'none';

  Mojo::Promise->resolve($plural, %onward);
}

1;
