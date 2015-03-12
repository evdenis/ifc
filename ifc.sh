#!/bin/bash

while read link
do
	wget -q -O - "$link" |  dos2unix | xmllint  --recover --html --xpath '(//*[@id="rightlower"]/ol/li/@value)[last()] | //*[@id="rightlower"]/h3[1]/text()[position()=5 or position()=4]' - 2>/dev/null | iconv -f cp1251 -t utf8 | tr '\n' '!'; echo "LINK: !${link}";
done < <(wget -q -O - 'http://mfk.msu.ru/season5.php' | xmllint  --recover --html --xpath '//*[@id="rightlower"]/p/a[1]/@href' - 2>/dev/null | sed -e 's#href="\([^"]\+\)"#edu.msu.ru/mfk/\1\n#g') | perl -ne 'BEGIN { my $counter=0; } m#^(?<pre>.*?)(value="(?<num>[^"]*)")?LINK: (?<link>.*)$#; my $num = 0; $num = $+{num} if defined $+{num}; print $num . $+{pre} . $+{link} . "\n"; $counter+=$num; END { print STDERR "Общее число записавшихся студентов: ${counter}\n"; }' | sort -g -r | sed -e 's#^\([[:digit:]]\+\)#\nЧисло записавшихся студентов: \1#g' -e 's/!\+/\n/g'

