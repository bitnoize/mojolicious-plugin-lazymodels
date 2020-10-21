package Mojolicious::LazyController;
use Mojo::Base 'Mojolicious::Controller';

has models => sub {
  my ($c) = @_;

  my $app = $c->render_later->app;

  state $models = $app->{models}->new(app => $app);
};

1;
