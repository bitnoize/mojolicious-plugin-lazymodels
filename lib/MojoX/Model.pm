package MojoX::Model;
use Mojo::Base -base;

has models    => undef, weak => 1;

sub pg_db     { shift->models->pg_db };
sub pg_tx     { shift->models->pg_tx };

sub stash     { shift->models->stash };

sub pg_lock   { shift->pg_db->dbh->{BegunWork} ? 'share' : 'none' }

1;
