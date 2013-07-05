#!/bin/sh

# WordFinder -- find matching dictionary words for Scrabble given a set of letters.

datafile="words.txt"
possibilities="possibilities.txt"

maxlength=15
minlength=2

#maxlength=25
#minlength=6

# adjust lengths because wc -c adds 1 char
maxlength=$(( $maxlength + 1 ))
minlength=$(( $minlength + 1 ))

if [ -z "$1" ] ; then 
    echo "Usage: $(basename $0) letters"; exit 1
fi

if [ ! -z "$2" ] ; then # if targetlength has been entered (length not zero)
    targetlength=$2
else
    targetlength=0
fi

occurrences() {
    # how many times does 'letter' occur in 'word'?
    local count=$( echo $2 | grep -o $1 | wc -l )
    freq=$count
}

echo "" > $possibilities

# Grep word list for words containing our letters - note that this list may 
# have more occurrences of each letter

for possibility in $(grep -vE "[^$1]" $datafile)

# Check if length of word lies between our minlength and maxlength range
# If in range then write word to possibilities.txt file.

do
    length=$(echo $possibility | wc -c)
    if [ !$length -gt $maxlength ] && [ !$length -lt $minlength ] ; then
        echo $possibility >> $possibilities
    fi
done

# grab the letters that we have
search_str=$1

if [ $targetlength -eq 0 ] ; then
    # get the length of the letters plus length of phrase below
    msg="Possible words from [$search_str]"
    line_length=$(( ${#search_str} + 22 ))
else
    msg="Possible $targetlength letter words from [$search_str]"
    line_length=$(( ${#targetlength} + ${#search_str} + 30 ))
fi

# save string for delimiting output
string=$(for ((i=1; i<=$line_length; i++));do printf "%s" "-";done;printf "\n")

# This writes the header of the output
echo $string
echo $msg
echo $string

# Check each word in possibilities.txt
for  word in $(cat $possibilities)

do
    length=$(echo $word | wc -c); length="$(( $length - 1 ))" 
    # Length of word is one less than reported by wc (ignore newline)

    idx=1
    
    while [ $idx -le $length ] ; do
        letter=$(echo $word | cut -c$idx)
        occurrences $letter $word
        wordfreq=$freq # number of times letter occurs #1
        occurrences $letter $1 # and letter occurrences #2
        
        uword=$(echo $word | tr '[[:lower:]]' '[[:upper:]]') # convert to UPPERCASE
        
        if [ $wordfreq -gt $freq ] ; then
            #echo "-- word $word was skipped (too many $letter)"
            break
        else
            if [ $idx -eq $length ] ; then
                if [ $targetlength -ne 0 ]; then
                    if [ $length -eq $targetlength ]; then
                        echo "$uword"
                    fi
                else
                    echo "$uword"
                fi
            fi
        fi
        
        idx=$(( $idx + 1 ))
    done
done

echo $string
