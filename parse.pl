#!/usr/bin/env perl

use warnings;
use strict;
use utf8;

use Data::Printer;

use open qw/:std :utf8/;

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

foreach (<DATA>)
{
   chomp;
   my $s = parse_student($_);
   p $s;
}


__DATA__
Дасуев М. Л. (очно-заочная форма, бакалавриат, 3 курс)
Божинов А. Б. (очно-заочная форма, бакалавриат, 3 курс)
Касьянова М. С. (очно-заочная форма, бакалавриат, 2 курс)
Абдель Маджид А. А. (магистратура, 1 курс)
Лусена Де Маседу Гедеш Т. (магистратура, 1 курс)
