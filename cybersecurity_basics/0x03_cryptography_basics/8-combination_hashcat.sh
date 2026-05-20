if [ "$#" -ne 2 ]; then
    echo "Usage: $0 wordlist1.txt wordlist2.txt"
    exit 1
fi


while read -r line1; do
    while read -r line2; do
        echo "${line1}${line2}"
    done < "$2"
done < "$1"
