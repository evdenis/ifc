#!/usr/bin/env perl

use warnings;
use strict;
use feature qw/say/;

use utf8;

use Data::Printer;
use Mojo::UserAgent;
use Storable;

use open qw/:std :utf8/;

my $courses;

if (-r '.cache') {
   $courses = retrieve('.cache');
   goto PROCESS;
}

my $ua = Mojo::UserAgent->new;

my $dom = $ua->get('http://mfk.msu.ru/season5.php')
             ->res
             ->dom;

my $links = $dom->find('#rightlower > p > a:nth-child(1)')
                  ->map(sub {[$_->all_text, 'http://mfk.msu.ru/' . $_->attr('href')]})
                  ->to_array;

sub parse_student
{
   my $str = $_[0];
   if ($str =~ m/\A(?<l>[\w-]++(\h\w+)*)\h(?<f>\w\.)(\h(?<p>\w\.))?\h\((?<t>[\w-]++(\hформа,\h\w++)?),\h(?<c>\d)\hкурс\)\z/) {
      return {lastname => $+{l}, firstname => $+{f}, patronymic => $+{p}, type => $+{t}, course => $+{c}}
   } else {
      warn("parsing error: $str\n");
      return undef;
   }
}


foreach(@$links) {
   my $link = $_->[1];
   my $dom  = $ua->get($link)
                ->res
                ->dom;

   my $faculty = '';
   my $students = $dom->find('#rightlower > ol > li[value], #rightlower > h4')
                      ->map(sub{ if ($_->matches('h4')) {$faculty = $_->text; undef} else { my $s = parse_student($_->text); if ($s) { $s->{faculty} = $faculty; $s } else {undef}} })
                      ->compact
                      ->to_array;

   $courses->{$_->[0]}{link} = $link;
   $courses->{$_->[0]}{students} = $students;
}

store $courses, '.cache';

PROCESS:
#output in prolog
sub student_term
{
   my $str = "student(";
   foreach my $key (qw/lastname firstname patronymic faculty type/) {
      $str .= $_[0]->{$key} ? "'$_[0]->{$key}', " : "'notexist', "
   }
   $str .= "$_[0]->{course})";
   $str
}

my @students;
foreach (keys $courses) {
   foreach (@{ $courses->{$_}->{students} }) {
      push @students, student_term($_)
   }
}

@students = sort @students;

#uniq
my $last = '';
@students = grep {if ($last ne $_) {$last = $_; 1} else {0}} @students;

my @courses;
foreach (keys $courses) {
   push @courses, "course('$_')"
}

my @enroll;
foreach (keys $courses) {
   my $course = $_;
   my $students = '[' . join(', ', map {student_term($_)} @{ $courses->{$_}->{students} }) . ']';
   push @enroll, "enroll('$course', $students)";
}

say ':- use_module(library(lists)).';
say '';
say '';
say 'lastname(X)   :- student(X,_,_,_,_,_).';
say 'firstname(X)  :- student(_,X,_,_,_,_).';
say 'patronymic(X) :- student(_,_,X,_,_,_).';
say 'faculty(X)    :- student(_,_,_,X,_,_).';
say 'st_type(X)    :- student(_,_,_,_,X,_).';
say 'st_course(X)  :- student(_,_,_,_,_,X).';
say '';
say '';
say join(".\n", @students) . ".";
say '';
say join(".\n", @courses)  . ".";
say '';
say join(".\n", @enroll)   . ".";

