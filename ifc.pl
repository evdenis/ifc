#!/usr/bin/env perl

use warnings;
use strict;

use Data::Printer;
use Mojo::UserAgent;


my $ua = Mojo::UserAgent->new;

my $dom = $ua->get('http://mfk.msu.ru/season5.php')
             ->res
             ->dom;

my $links = $dom
            ->find('#rightlower > p > a:nth-child(1)')
            ->map(sub {[$_->all_text, 'http://mfk.msu.ru/' . $_->attr('href')]})
            ->to_array;

p $links;

