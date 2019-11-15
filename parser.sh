#!/bin/bash
rm tempfile;
echo 'Проводим разбор исходных html файлов каталога с помощью Xpath';
htmls=($(find ./html -name '*.html'))
for html in ${htmls[@]};do 
names=`echo "$html" | sed 's/^\.\/html\/\(.*[^\.html]\).*$/\1/'`;
echo 'Разбираем файл:' $names;
pandoc -p -s  --html-q-tags  --normalize --from html --to html $html -o   tmpfile  2> error.log; 
xsltproc -o temp --novalid --html 'htmltemplate.xsl' tmpfile;
rm tmpfile;
sed -n '/^.*\<site\>/p' temp | sed -n 's/<site>/;/p' | sed -n 's/<\/site>/;/p' | sed -n 's/^/'$names';/p' >> tempfile; #получили базу тип компании-название-адрес сайта - название сайта в csv
done
echo 'Парсим адреса почты быстрым парсером с помощью текстового браузера'
counter=1;
while read rec; do 
uri=$(echo $rec | csvtool -t ";" -u ";" col 3 -); 
echo 'Парсим сайт номер '$counter':' $uri;
links -force-html -dump $uri -http.fake-firefox 1 > temp; #Быстрый парсер
grep -E -o -I "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" temp >mailstemp;
mails=$(sort < mailstemp | uniq | tr '\n' ';');
echo 'Получили адреса:' $mails;
echo $rec';'$mails >> contacts.tmp;
rm temp;
let counter+=1;
done < tempfile;
rm mailstemp;
rm temp;
echo 'Проводим промежуточную валидацию базы почтовых адресов';
sed 's/Rating\@Mail\.ru\|ajax-loader\@2x\.gif\|rxngrevan\@jro-qrpvfvba\.eh/;/g' contacts.tmp  > base.tmp; #промежуточная валидация базы
echo 'Парсим недостающие адреса глубинным парсером';
while read rec; do 
mails=$(echo $rec | csvtool -t ";" -u ";" col 5 -); 
uri=$(echo $rec | csvtool -t ";" -u ";" col 3 -);
echo 'Обрабатываем сейчас запись:' $mails $uri; 
if (( ${#mails} < 2 )); then #медленный парсер
wget --reject=png,jpg,css,jpeg,gif,js,ico,pdf,doc,docx,xsl,xsls,mp4,mp3,woff,woff2,eot,ttf,svg,txt -t 20 -r -l 2 -o parsing.log -nd -P "files" -O temp -U "Mozilla 2.0" $uri;
grep -E -o -I "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" temp >mailstemp;
emails=$(sort < mailstemp | uniq | tr '\n' ';');
echo 'Дополнительные адреса:' $emails;
echo $rec';'$emails >> base.csv;
else
echo $rec >> base.csv;
fi
done < base.tmp;
rm contacts.tmp;
