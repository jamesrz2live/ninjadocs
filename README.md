#ninjadocs

Convert markdown documents into a wiki-like website.

## example

Suppose you have some markdown documents in a directory called `docs/`:

    $ tree docs/
    docs/
    ├── README.md
    ├── demo.md
    └── index.md

    0 directories, 3 files

Simply run ninjadocs:

    $ ./ninjadocs --in docs/ --out /tmp/example/
    ☯ NinjaDocs
    (working in /Users/james/git/ninjadocs/docs, output to /tmp/example/)
    •••
    3 sources => 3 html files; 0 errors
    ✌ NinjaDocs

And you get:

    $ tree -a /tmp/example/
    /tmp/example/
    ├── .ninjadocs
    │   ├── README.html
    │   └── demo.html
    └── index.html

    1 directory, 3 files

Enjoy!

## tests

The default rake task is to run the tests, so simply `rake` from within the ninjadocs directory path.
