package Mojolicious::LazyController;
use Mojo::Base 'Mojolicious::Controller';

has models => sub {
  my ($c) = @_;

  my $app = $c->render_later->app;

  die "Seems LazyModels interface not loaded\n"
    unless defined $app->{lazy_models};

  state $models = $app->{lazy_models}->new(app => $app);
};

1;
