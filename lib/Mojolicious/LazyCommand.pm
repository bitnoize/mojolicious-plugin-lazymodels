package Mojolicious::LazyCommand;
use Mojo::Base 'Mojolicious::Command';

has models => sub {
  my ($self) = @_;

  my $app = $self->app;

  state $models = $app->{models}->new(app => $app);
};

1;
