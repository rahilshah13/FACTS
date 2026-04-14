# 1. [[ $(grep -c '' ./src/component/Prolog/words.pl) -eq $(grep -o '\.' ./src/component/Prolog/words.pl | wc -l) ]] && echo "Equal" || echo "Not Equal"
# 2. LC_ALL=C sort -o ./src/component/Prolog/words.pl ./src/component/Prolog/words.pl
# 3. grep -vE '^entry\(.*\)\.$' ./src/component/Prolog/words.pl && echo "Invalid entries found" || (LC_ALL=C sort -c ./src/component/Prolog/words.pl && echo "Sorted")
###
#for f in ./DICTIONARY/*.pl; do L=$(grep -c '' "$f"); P=$(grep -o '\.' "$f" | wc -l); echo -n "$f: Lines=$L, Periods=$P - "; [[ $L -eq $P ]] && echo "Equal" || echo "Not Equal"; done
#for f in ./DICTIONARY/*.pl; do LC_ALL=C sort -o "$f" "$f"; done
#for f in ./DICTIONARY/*.pl; do echo -n "$f: "; grep -vE '^entry\(.*\)\.$' "$f" && echo "Invalid entries found" || (LC_ALL=C sort -c "$f" && echo "Sorted"); done