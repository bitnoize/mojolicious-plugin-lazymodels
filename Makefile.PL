#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'Mojolicious::Plugin::LazyModels',
  VERSION_FROM  => "lib/Mojolicious/Plugin/LazyModels.pm",
  ABSTRACT      => "Easy way to interact with PostgreSQL data models",
  LICENSE       => 'artistic_2',
  AUTHOR        => "Dmitry Krutikov <monstar\@cpan.org>",
  PREREQ_PM     => {
    'Mojolicious' => '8.12',
    'Mojo::Pg'    => '4.19',
  },
  test => { TESTS => 't/*.t' }
);
