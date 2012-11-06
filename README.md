glark(1) - Search text files for complex regular expressions
============================================================

## SYNOPSIS

`glark` [options] expression <file> ... <br>

## DESCRIPTION

Similar to `grep`, `glark` support: Perl-compatible regular expressions, color
highlighting of matches, context around matches, complex expressions ("and" and
"or") and automatic exclusion of non-text files. Its regular expressions should
be familiar to those experienced in Perl, Python or Ruby.

## OPTIONS

Options are in the categories of matching, input, output and information.

For each option of the type `--option=ARG`, the equivalent `--option ARG` can be
used.

### INPUT

  * `-0[nnn]`:
    Use \nnn (octal) as the input record separator. If nnn is omitted, use
    '\n\n' as the record separator, which treats paragraphs as lines.

  * `-d` ACTION, `--directories`=ACTION:
    Directories are processed according to the given `ACTION`, which by default
    is `read`. If `ACTION` is `recurse`, each file in the directory is read and
    each subdirectory is recursed into (equivalent to the `-r` option). If
    `ACTION` is `skip`, directories are not read, and no message is produced.

  * `--binary-files`=TYPE:
    Specify how to handle binary files, thus overriding the default behavior,
    which is to denote the binary files that match the expression, without
    displaying the match. `TYPE` may be one of: `binary`, the default;
    `without-match`, which results in binary files being skipped; and `text`,
    which results in the binary file being treated as text, the display of which
    may have bad side effects with the terminal. Note that the default behavior
    has changed; this previously was to skip binary files. The same effect may
    be achieved by setting `binary-files` to `without-match` in the ~/.glarkrc
    file.

  * `--match-name`=REGEXP:
    Search only files with names that match the given regular expression. As in
    find(1), this works on the basename of the file. This expression can be
    negated and modified with `!` and `i`, such as `!/io\.[hc]$/i`.

  * `--match-path`=REGEXP:
    Search only files with full names that match the given regular expression.
    As in find(1), this works on the path of the file.

  * `--not-name`=REGEXP:
    Do not search files with base names matching the given regular expression.

  * `--not-path`=REGEXP:
    Do not search files with full names matching the given regular expression.

  * `-M`, `--exclude-matching`:
    Do not search files whose names match the primary expression. This can be
    useful for finding external references to a file, or to a class, assuming
    that class names match file names

  * `-r`, `--recurse`:
    Recurse through directories. Equivalent to `--directories=read`.

  * `--split-as-path`:
    If a command line argument includes the path separator (such as ":"), the
    argument will be split by the path separator. This functionality is useful
    for using environment variables as input, such as `$PATH` and `$CLASSPATH`.
    which are automatically split and processed as a list of files and
    directories. This option is enabled by default.

  * `--no-split-as-path`:
    Disables splitting arguments as paths.

  * `--size-limit`=SIZE:
    Limit searches to files no larger than `SIZE` bytes. This is useful when
    running the `--recurse` option on directories that may contain large files.

### MATCHING

  * `-a` NUM expr1 expr2, `--and` NUM expr1 expr2, `--and`=NUM expr1 expr2:
    Match both expressions, within `NUM` lines of each other. See the
    `EXPRESSIONS` section for more information.

  * `( expr1 --and=NUM expr2 )`:
    Same as the above, using infix notation instead of prefix.

  * `--after`=NUM[%]:
    Restrict the search to after the given section, which represents either the
    number of the first line within the valid range, or the percentage of lines
    to be skipped. `--after=25%` means to search the "lower" 25% of each file.
    `--after=10` means to skip the first ten lines of each file.

  * `-b` NUM[%], `--before`=NUM[%]:
    Restrict the search to before the given location, which is either the number
    of the last line within the valid range, or the percentage of lines to be
    searched.

  * `-f` FILE, `--file`=FILE:
    Use the lines in the given file as expressions. Each line consists of a
    regular expression. Complex expressions are supported.

  * `-i`, `--ignore-case`:
    Match regular expressions without regard to case. The default is case
    sensitive.

  * `-m` NUM, `--match-limit`=NUM:
    Output only the first `NUM` matches in each file.

  * `-a` NUM expr1 expr2, `--or` NUM expr1 expr2, `--or`=NUM expr1 expr2:
    Match either expressions. See the `EXPRESSIONS` section for more
    information.

  * `( expr1 --or=NUM expr2 )`:
    Same as the above, using infix notation instead of prefix.

  * `-R`, `--range` NUM[%],NUM[%]:
    Restrict the search to the given range of lines, as either line numbers or a
    percentage of the length of the file.

  * `-v`, `--invert-match`:
    Show lines that do not match the expression.

  * `-w`, `--word`, `--word-regexp`:
    Put word boundaries around each pattern, thus matching only where the full
    word(s) occur in the text. Thus, `glark -w Foo` is the same as `glark
    '/\bFoo\b/'`.

  * `-x`, `--line-regexp`:
    Select only where the entire line matches the pattern(s).

  * `--xor` expr1 expr2:
    Match either of the two expressions, but not both. See the EXPRESSIONS section
    for more information.

  * `( expr1 --xor expr2 )`:
    Same as the above, using infix notation instead of prefix.

### OUTPUT

  * `-A` NUM, `--after-context`=NUM:
    Print `NUM` lines after a matched expression.

  * `-B NUM, `--before-context`=NUM:
    Print `NUM` lines before a matched expression.

  * `-C` [NUM], `-NUM`, `--context[=NUM]`:
    Output `NUM` lines of context around a matched expression. The default is no
    context. If no `NUM` is given for this option, the number of lines of
    context is 2.

  * `-c, `--count`:
    Instead of normal output, display only the number of matches in each file.

  * `-F`, `--file-color`=COLOR:
    Specify the highlight color for file names. See the HIGHLIGHTING section for
    the values that can be used.

  * `--no-filter`:
    Display the entire file(s). Useful to see highlighted matches as well as
    non-matching lines.

  * `-g`, `--grep`:
    Produce output like the (legacy) grep default: file names, no line numbers,
    and a single line of the match, which will be the first line for matches
    that span multiple lines. If the EMACS environment variable is set, this
    value is set to true.

  * `-h`, `--no-filename`:
    Do not display the names of the files that matched.

  * `-H`, `--with-filename`:
    Display the names of the files that matched. This is the default behavior.

  * `-l`, `--files-with-matches`:
    Print only the names of the file that matched the expression.

  * `-L`, `--files-without-match`:
    Print only the names of the file that did `not` match the expression.

  * `--label`=NAME:
    Use `NAME` as the output file name. This is useful when reading from
    standard input, such as glark being piped from an archive listing (tar tvf
    or jar tvf).

  * `-n`, `--line-number`:
    Display the line numbers. This is the default behavior.

  * `-N`, `--no-line-number:
    Do not display the line numbers.

  * `--line-number-color`=COLOR:
    Specify the highlight color for line numbers. This defaults to none (no
    highlighting). See the HIGHLIGHTING section for more information.

  * `-T`, `--text-color`=COLOR:
    Specify the highlight color for text. See the HIGHLIGHTING section for more
    information.

  * `-u`, `--highlight`=FORMAT:
    Enable highlighting. This is the default behavior. Format is "single" (one
    color) or "multi" (different color per regular expression). See the HIGHLIGHTING
    section for more information.

  * `-U`, `--no-highlight`:
    Disable highlighting.

  * `-y`, `--extract-matches`:
    Display only the region that matched, not the entire line. If the expression
    contains "backreferences" (i.e., expressions bounded by "( ... )"), then
    only the portion captured will be displayed, not the entire line. This
    option is useful with `-g`, which eliminates the default highlighting and
    display of file names.

  * `-Z`, `--null`:
    When in `-l` mode, write file names followed by the ASCII NUL character ('\0')
    instead of '\n'. This is line `find ... -print0`, for piping into another
    command.

### INFORMATION

  * `-?`, `--help`:
    Display the help message.

  * `--config`:
    Display the settings glark is using, and exit. Since this is run after
    configuration files are read, this may be useful for determining values of
    configuration parameters.

  * `--explain`:
    Write the expression in a more legible format, useful for debugging complex
    expressions.

  * `-q`, `-s`, `--quiet`, `--no-messages`:
    Suppress warnings.

  * `-Q`, `--no-quiet`:
    Enable warnings. This is the default.

  * `-V`, `--version`:
    Display version information.

  * `--verbose`:
    Display normally suppressed output, for debugging purposes.

## EXPRESSIONS

    Regular expressions are expected to be in the Perl/Ruby format. `perldoc
    perlre` has more general information. The expression may be of either form:

        something
        /something/

    There is no difference between the two forms, except that with the latter, one
    can provide the "ignore case" modifier, thus matching "someThing" and
    "SoMeThInG":

        % glark /something/i

    This is redundant with the `-i` (`--ignore-case`) option.

    All regular expression characters and options are available, such as "\w"
    and ".*?". For example:

        % glark '\b[a-z][^\d]\d{1,3}.*\s*>>\s*\d+\s*.*& +\d{3}'

    If the `and` and `or` options are not used, the last non-option is
    considered to be the expression to be matched. In the following, "printf" is
    used as the expression.

        % glark -w printf *.c

    POSIX character classes (e.g., [[:alpha:]]) are also supported.

### COMPLEX EXPRESSIONS

    Complex expressions combine regular expressions (and complex expressions
    themselves) with logical AND, OR, and XOR operators. Both prefix and infix
    notations are supported.

  * `-a` NUM expr1 expr2, `--and=NUM` expr1 expr2, `--end-of-and`, `( expr1 --and NUM expr2 )`:
    Match both of the two expressions, within <number> lines of each other. The
    forms `-aNUM` and `--and=NUM` are also supported. In the latter syntax,
    `--end-of-and` is optional.

    If the number provided is -1 (negative one), the distance is considered to
    be "infinite", and thus, the condition is satisfied if both expressions
    match within the same file.

    If the number provided is 0 (zero), the condition is satisfied if both
    expressions match on the same line.

    If the --and option is used, and the follow argument is not numeric, then
    the value defaults to zero.

    A warning will result if the value given in the number position does not
    appear to be numeric.

  * `-o` expr1 expr2, `--or` expr1 expr2 `--end-of-or`, `( expr1 --or expr2 )`:
    Match either of the two expressions. As with the -`-and` option, the two
    forms are equivalent, and `--end-of-or` is optional.

  * `--xor` expr1 expr2 `--end-of-xor`, `( expr1 B<--xor> expr2 )`:
    Match either of the two expressions, but not both. `--end-of-xor` is
    optional.

### NEGATED EXPRESSIONS

    Regular expressions can be negated, by being prefixed with '!', and using
    the '/' quote characters around the expression, such as:

        !/this/

    This has the effect of "match anything other than `this`". For a single
    expression, this is no different than the `-v` (`--invert-match`) option,
    but it can be useful in complex expressions, such as:

        --and 0 this '!/that/'

    which means "match and line that has "this", but not "that".

## HIGHLIGHTING

    Matching patterns and file names can be highlighted using ANSI escape
    sequences. Both the foreground and the background colors may be specified,
    from the following:

        black
        blue
        cyan
        green
        magenta
        red
        white
        yellow
    
    The foreground may have any number of the following modifiers applied:
    
        blink
        bold
        concealed
        reverse
        underline
        underscore
    
    The format is "MODIFIERS FOREGROUND on BACKGROUND". For example:
    
        red
        black on yellow                    (the default for patterns)
        reverse bold                       (the default for file names)
        green on white
        bold underline red on cyan
    
    By default text is highlighted as black on yellow. File names are written in
    reversed bold text.

## EXAMPLES

### BASIC USAGE
    
  * `% glark format *.h`:
    Searches for "format" in the local .h files.

  * `% glark --ignore-case format *.h`:
    Searches for "format" without regard to case. Short form:

    % glark -i format *.h
    
  * `% glark --context=6 format *.h`:
    Produces 6 lines of context around any match for "format". Short forms:

    % glark -C 6 format *.h
    % glark -6 format *.h
    
  * `% glark --exclude-matching Object *.java`:
    Find references to "Object", excluding the files whose names match "Object".
    Thus, SessionBean.java would be searched; EJBObject.java would not. Short
    form:

    % glark -M Object *.java
    
  * `% glark --grep --extract-matches '(\w+)\.printStackTrace\(.*\)' *.java`:
    Show only the variable name of exceptions that are dumped. Short form:

    % glark -gy '(\w+)\.printStackTrace\(.*\)' *.java
    
  * `% who| glark -gy '^(\S+)\s+\S+\s*May 15'`:
    Display only the names of users who logged in today.
    
  * `% glark -l '\b\w{25,}\b' *.txt`:
    Display (only) the names of the text files that contain "words" at least 25
    characters long.
    
  * `% glark --files-without-match '"\w+"'`:
    Display (only) the names of the files that do not contain strings consisting of
    a single word. Short form:

    % glark -L '"\w+"'
    
  * `% for i in *.jar; do jar tvf $i | glark --LABEL=$i Exception; done`:
    Search the files for 'Exception', displaying the jar file name instead of the
    standard input marker ('-').

  * `% glark --text-color "red on white" '\b[[:digit:]]{5}\b' *.c`:
    Display (in red text on a white background) occurrences of exactly 5 digits.
    Short form:

    % glark -T "red on white" '\b\d{5}\b' *.c

    See the HIGHLIGHTING section for valid colors and modifiers.

### COMPLEX EXPRESSIONS
    
  * `% glark --or format print *.h"`:
    Searches for either "printf" or "format". Short form:

    % glark -o format print *.h
    
  * `% glark --and 4 printf format *.c *.h`:
    Searches for both "printf" or "format" within 4 lines of each other. Short
    form:

    % glark -a 4 printf format *.c *.h
    
  * `% glark --context=3 --and 0 printf format *.c"`:
    Searches for both "printf" or "format" on the same line ("within 0 lines of each
    other"). Three lines of context are displayed around any matches. Short
    form:

    % glark -3 -a 0 printf format *.c
    
  * `% glark -8 -i -a 15 -a 2 pthx '\.\.\.' -o 'va_\w+t' die *.c`:
    (In order of the options:) Produces 8 lines of context around case insensitive
    matches of ("phtx" within 2 lines of '...' (literal)) within 15 lines of (either
    "va_\w+t" or "die").
    
  * `% glark --and -1 '#define\s+YIELD' '#define\s+dTHR' *.h`:
     Looks for "#define\s+YIELD" within the same file (-1 == "infinite distance") of
    "#define\s+dTHR". Short form:

    % glark -a -1 '#define\s+YIELD' '#define\s+dTHR' *.h

### RANGE LIMITING

  * `% glark --before 50% cout *.cpp`:
    Find references to "cout", within the first half of the file. Short form:

    % glark -b 50% cout *.cpp

  * `% glark --after 20 cout *.cpp`:
    Find references to "cout", starting at the 20th line in the file. Short
    form:

    % glark -b 50% cout *.cpp

  * `% glark --range 20,50% cout *.cpp`:
    Find references to "cout", in the first half of the file, after the 20th line.
    Short form:

    % glark -R 20,50% cout *.cpp

### FILE PROCESSING

  * `% glark -r print .`:
    Search for "print" in all files at and below the current directory.

  * `% glark --fullname='/\.java$/' -r println org`:
    Search for "println" in all Java files at and below the "org" directory.

  * `% glark --basename='!/CVS/' -r '\b\d\d:\d\d:\d\d\b' .`:
    Search for a time pattern in all files without "CVS" in their basenames.

  * `% glark --size-limit=1024 -r main -r .`:
    Search for "main" in files no larger than 1024 bytes.

## ENVIRONMENT

  * `GLARKOPTS`:
    A string of whitespace-delimited options. Because of parsing constraints,
    should probably not contain complex regular expressions.

  * `$HOME/.glarkrc`:
    A resource file, containing name/value pairs, separated by either ':' or '='.
    The valid fields of a .glarkrc file are as follows, with example values:
        after-context:     1
        before-context:    6
        context:           5
        file-color:        blue on yellow
        highlight:         off
        ignore-case:       false
        quiet:             yes
        text-color:        bold reverse
        line-number-color: bold
        verbose:           false
        grep:              true
        
    "yes" and "on" are synonymnous with "true". "no" and "off" signify "false".
    
    My ~/.glarkrc file contains:
        context: 3
        quiet: true
    
  * `/path/.../.glarkrc`:
    See the `local-config-files` field below.

### FIELDS
    
  * `after-context`:
    See the `--after-context` option. For example, for 3 lines of context after the
    match:
    
        after-context: 3
    
  * `basename`:
    See the `--basename` option. For example, to omit Subversion directories:
    
        basename: !/\.svn/
    
  * `before-context`:
    See the `--before-context` option. For example, for 7 lines of context before
    the match:
    
        before-context: 7
    
  * `binary-files`:
    See the `--binary-files` option. For example, to skip binary files:
    
        binary-files: without-match
    
  * `context`:
    See the `--context` option. For example, for 2 lines before and after matches:
    
        context: 2
    
  * `expression`:
    See the `EXPRESSION` section. Example:
        expression: --or '^\s*public\s+class\s+\w+' '^\s*\w+\(
    
  * `file-color`:
    See the `--file-color` option. For example, for white on black:
        file-color: white on black
    
  * `filter`:
    See the `--filter` option. For example, to show the entire file:
    
        filter: false
    
  * `fullname`:
    See the `--fullname` and `--basename` options. For example, to omit CVS files:
    
        fullname: !/\bCVS\b/

  * `grep`:
    See the `--grep` option. For example, to always run in grep mode:
    
        grep: true
    
  * `highlight`:
    See the `--highlight` option. To turn off highlighting:
    
        highlight: false
    
  * `ignore-case`:
    See the `--ignore-case` option. To make matching case-insensitive:
    
        ignore-case: true
    
  * `known-nontext-files`:
    The extensions of files that should be considered to always be nontext (binary).
    If a file extension is not known, the file contents are examined for nontext
    characters. Thus, setting this field can result in faster searches. Example:
    
        known-nontext-files: class exe dll com
    
    See the `Exclusion of Non-Text Files` section in `NOTES` for the default
    settings.
    
  * `known-text-files`:
    The extensions of files that should be considered to always be text. See above
    for more. Example:
    
        known-text-files: ini bat xsl xml
    
    See the `Exclusion of Non-Text Files` section in `NOTES` for the default
    settings.
    
  * `local-config-files`:
    By default, glark uses only the configuration file ~/.glarkrc. Enabling this
    makes glark search upward from the current directory for the first .glarkrc
    file.
    
    This can be used, for example, in a Java project, where .class files are binary,
    versus a PHP project, where .class files are text:
    
        /home/me/.glarkrc
    
            local-config-files: true
    
        /home/me/projects/java/.glarkrc
    
            known-nontext-files: class
    
        /home/me/projects/php/.glarkrc
    
            known-text-files: class
    
    With this configuration, .class files will automatically be treated as binary
    file in Java projects, and .class files will be treated as text. This can speed
    up searches.
    
    Note that the configuration file ~/.glarkrc is read first, so the local
    configuration file can override those settings.
    
  * `quiet`:
    See the `--quiet` option.
    
  * `show-break`:
    Whether to display breaks between sections, when displaying context. Example:
    
        show-break: true
    
    By default, this is false.
    
  * `text-color`:
    See the `--text-color` option. Example:
    
        text-color: bold blue on white
    
  * `verbose`:
    See the `--verbose` option. Example:
    
        verbose: true

### Exclusion of Non-Text Files

Non-text files are automatically skipped, by taking a sample of the file and
checking for an excessive number of non-ASCII characters. For speed purposes,
this test is skipped for files whose suffixes are associated with text files:
    
        c
        cpp
        css
        h
        f
        for
        fpp
        hpp
        html
        java
        mk
        php
        pl
        pm
        rb
        rbw
        txt
    
Similarly, this test is also skipped for files whose suffixes are associated
with non-text (binary) files:
    
        Z
        a
        bz2
        elc
        gif
        gz
        jar
        jpeg
        jpg
        o
        obj
        pdf
        png
        ps
        tar
        zip
    
See the `known-text-files` and `known-nontext-files` fields for denoting file
name suffixes to associate as text or nontext.
    
### Exit Status
    
The exit status is 0 if matches were found; 1 if no matches were found, and 2 if
there was an error. An inverted match (the -v/--invert-match option) will result
in 1 for matches found, 0 for none found.

## SEE ALSO

For regular expressions, the `perlre` man page.

Mastering Regular Expressions, by Jeffrey Friedl, published by O'Reilly.

## CAVEATS

"Unbalanced" leading and trailing slashes will result in those slashes being
included as characters in the regular expression. Thus, the following pairs are
equivalent:

    /foo        "/foo"
    /foo\/      "/foo/"
    /foo\/i     "/foo/i"
    foo/        "foo/"
    foo/        "foo/"

The code to detect nontext files assumes ASCII, not Unicode.

## AUTHOR

Jeff Pace (jeugenepace at gmail dot com)

www.incava.org/projects/glark

https://github.com/jeugenepace/glark

## COPYRIGHT

Copyright (c) 2006-2012, Jeff Pace.

All Rights Reserved. This module is free software. It may be used, redistributed
and/or modified under the terms of the Lesser GNU Public License. See
http://www.gnu.org/licenses/lgpl.html for more information.
