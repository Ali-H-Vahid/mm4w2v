# !/bin/bash

tokenize=/home/scortes/projects/mm4w2v/software/mosesdecoder/scripts/tokenizer/tokenizer.perl
remove_stopwords=/home/scortes/projects/mm4w2v/repo/mm4w2v/scripts/remove_stopwords.py
stopwords=/home/scortes/projects/mm4w2v/data/stopwords/

usage()
{
  echo "Usage: $0 src_lang trg_lang src_file trg_file out_dir" > /dev/stderr
  echo "  src_lang    source language code" > /dev/stderr
  echo "  trg_lang    target language code" > /dev/stderr
  echo "  src_file    source language corpus file" > /dev/stderr
  echo "  trg_file    target language corpus file" > /dev/stderr
  echo "  out_dir     directory where the output files will be written" > /dev/stderr
}

if [ $# -ne 5 ]
then
  usage
  exit 2
fi

if [ ! -e $stopwords/$src_lang ]
then
  echo "Error: No stopwords found found for $src_lang (File $stopwords/$src_lang does not exit)"
  exit 3
fi

src_lang=$1
trg_lang=$2
src_file=$3
trg_file=$4
out_dir=$5

mkdir -p $out_dir

cat $src_file |
$tokenize -l $src_lang -no-escape | tee $out_dir/$src_lang.tok |
gawk '{print tolower($0)}' | tee $out_dir/$src_lang.tok.lc |
python $remove_stopwords -l -p $stopwords/$src_lang > $out_dir/$src_lang.tok.lc.no_sw

cat $trg_file |
$tokenize -l $trg_lang -no-escape | tee $out_dir/$trg_lang.tok |
gawk '{print tolower($0)}' | tee $out_dir/$trg_lang.tok.lc |
python $remove_stopwords -l -p $stopwords/$trg_lang > $out_dir/$trg_lang.tok.lc.no_sw

cat $out_dir/$src_lang.tok.lc.no_sw | tr ' ' '\n' | sort | uniq -c | sort -nr | head -5000 | tee $out_dir/$src_lang.tok.lc.no_sw.5k_most_freq |
gawk '{print $2}' | tee $out_dir/$src_lang.tok.lc.no_sw.5k_most_freq.txt |
gawk 'BEGIN{print "<html><head></head><body>"}{if ($0) print "<p>" $0 "</p>"}END{print "</body></html>"}' > $out_dir/$src_lang.tok.lc.no_sw.5k_most_freq.html

paste $out_dir/$src_lang.tok.lc $out_dir/$trg_lang.tok.lc | 
gawk -F "\t" '
{
  nf1 = gsub(" ", " ", $1) + 1
  nf2 = gsub(" ", " ", $2) + 1
  if ($1 && $2 && nf1 <= 50 && nf2 <= 50 && (nf1 / nf2 >= 0.2 && nf1 / nf2 <= 8))
  {
    print $1 "\t" $2
  }
}' > $out_dir/$src_lang-$trg_lang.tok.lc.len_1-50_ratio_02-8

cut -f1 $out_dir/$src_lang-$trg_lang.tok.lc.len_1-50_ratio_02-8 > $out_dir/$src_lang.tok.lc.len_1-50_ratio_02-8
cut -f2 $out_dir/$src_lang-$trg_lang.tok.lc.len_1-50_ratio_02-8 > $out_dir/$trg_lang.tok.lc.len_1-50_ratio_02-8
rm $out_dir/$src_lang-$trg_lang.tok.lc.len_1-50_ratio_02-8

exit 0
