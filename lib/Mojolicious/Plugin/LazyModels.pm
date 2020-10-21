package Mojolicious::Plugin::LazyModels;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Loader qw/load_class/;
use Mojo::Pg;

our $VERSION = "0.02";
$VERSION = eval $VERSION;

sub register {
  my ($plugin, $app, $conf) = @_;

  die "LazyModels requires 'postgres' config attribute"
    unless defined $conf->{postgres};

  $app->attr(pg => sub { state $pg = Mojo::Pg->new($conf->{postgres}) });

  my $class = join '::', ref $app, 'Models';
  my $e = load_class $class;
  die ref $e ? $e : "LazyModels $class not found" if $e;

  $app->{lazy_models} = $class;
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::LazyModels - Easy way to interact with PostgreSQL data models

=head1 AUTHOR

Dmitry Krutikov E<lt>monstar@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Dmitry Krutikov.

You may distribute under the terms of either the GNU General Public
License or the Artistic License, as specified in the README file.

=cut

