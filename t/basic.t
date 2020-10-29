use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use_ok('MojoX::Model');
use_ok('MojoX::Models');
use_ok('Mojolicious::Command::dropdata');
use_ok('Mojolicious::Plugin::LazyModels');

done_testing;
