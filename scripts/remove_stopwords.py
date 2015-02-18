"""
Given a text file and a list of stop-words, this script writes the content of the text file after
 removing stop-words. The scripts assumes that the tokens in the text file are separated by spaces.
"""

import sys
import argparse


def remove_stopwords(input_file, stopwords, lowercase=False, remove_punctuation=False):
    for line in input_file:
        line_without_stopwords = []
        for word in line.split():
            word_comparing = word.lower() if lowercase else word
            if not word_comparing in stopwords:
                if remove_punctuation:
                    if word.decode("utf-8").isalnum():
                        line_without_stopwords.append(word)
                else:
                    line_without_stopwords.append(word)
        yield ' '.join(line_without_stopwords)


def read_stopwords(input_file, lowercase=False):
    stopwords = set()
    for line in input_file:
        word = line.split()[0]
        if lowercase:
            stopwords.add(word.lower())
        else:
            stopwords.add(word)
    return stopwords


def main():
    parser = argparse.ArgumentParser(description="Given a text file and a list of stop-words, this script writes the "
                                                 "content of the text file after removing stop-words.")
    parser.add_argument("stopword_list", help="path of the file containing the list of stop-words, one per line")
    parser.add_argument("input", nargs='?', help="path of the input file, default is standard input", default=None)
    parser.add_argument("output", nargs='?', help="path of the output file, default is standard output", default=None)
    parser.add_argument("-l", "--lowercase", help="lowercase both words and stopwords when comparing them",
                        action='store_true', default=False)
    parser.add_argument("-p", "--remove_punctuation", help="also remove non alphanumeric words",
                        action='store_true', default=False)
    args = parser.parse_args()

    stopword_file = open(args.stopword_list, 'r')
    input_file = sys.stdin if args.input is None else open(args.input, 'r')
    output_file = sys.stdout if args.output is None else open(args.output, 'w')

    stopwords = read_stopwords(stopword_file, args.lowercase)
    for line in remove_stopwords(input_file, stopwords, args.lowercase, args.remove_punctuation):
        output_file.write(line)
        output_file.write('\n')

    return 0

if __name__ == '__main__':
    sys.exit(main())
