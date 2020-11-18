#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'Mojolicious::Plugin::LazyModels',
  VERSION_FROM  => "lib/Mojolicious/Plugin/LazyModels.pm",
  ABSTRACT      => 'Easy way to interact with PostgreSQL data models',
  LICENSE       => 'artistic_2',
  AUTHOR        => 'Dmitry Krutikov <monstar@cpan.org>',
  META_MERGE    => {
    'meta-spec'   => { version => 2 },
    resources     => {
      bugtracker  => {
        web   => 'https://github.com/bitnoize/mojolicious-plugin-lazymodels/issues'
      },
      license     => [
        'http://www.opensource.org/licenses/artistic-license-2.0'
      ],
      repository  => { 
        type  => 'git',
        url   => 'git://github.com/bitnoize/mojolicious-plugin-lazymodels.git',
        web   => 'https://github.com/bitnoize/mojolicious-plugin-lazymodels',
      },
    },
  },
  PREREQ_PM     => {
    'Mojolicious' => '8.12',
    'Mojo::Pg'    => '4.19'
  },
  test => { TESTS => 't/*.t' }
);
