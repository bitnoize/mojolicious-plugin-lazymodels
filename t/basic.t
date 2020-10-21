use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use_ok('MojoX::Model');
use_ok('MojoX::Model::Complex');
use_ok('MojoX::Models');
use_ok('Mojolicious::LazyController');
use_ok('Mojolicious::LazyCommand');
use_ok('Mojolicious::Plugin::LazyModels');

done_testing;
