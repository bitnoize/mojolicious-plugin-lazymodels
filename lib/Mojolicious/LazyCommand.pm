package Mojolicious::LazyCommand;
use Mojo::Base 'Mojolicious::Command';

has models => sub {
  my ($self) = @_;

  my $app = $self->app;

  die "Seems LazyModels interface not loaded\n"
    unless defined $app->{lazy_models};

  state $models = $app->{lazy_models}->new(app => $app);
};

1;
