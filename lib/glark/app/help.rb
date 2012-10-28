#!/usr/bin/ruby -w
# -*- ruby -*-

class GlarkHelp
  def show_usage
    puts "Usage: glark [options] expression file..."
    puts "Search for expression in each file or standard input."
    puts "Example: glark --and=3 'try' 'catch' *.java"
    puts ""

    puts "Input:"
    puts "  -0[nnn]                        Use \\nnn as the input record separator"
    puts "  -d, --directories=ACTION       Process directories as read, skip, or recurse"
    puts "      --binary-files=TYPE        Treat binary files as TYPE"
    puts "      --[with-]basename, "
    puts "      --[with-]name EXPR         Search only files with base names matching EXPR"
    puts "      --without-basename, "
    puts "      --without-name EXPR        Ignore files with base names matching EXPR"
    puts "      --[with-]fullname, "
    puts "      --[with-]path EXPR         Search only files with full names matching EXPR"
    puts "      --without-fullname, "
    puts "      --without-path EXPR        Ignore files with full names matching EXPR"
    puts "  -M, --exclude-matching         Ignore files with names matching the expression"
    puts "  -r, --recurse                  Recurse through directories"
    puts "      --size-limit=SIZE          Search only files no larger than SIZE"
    puts ""

    puts "Matching:"
    puts "  -a, --and=NUM EXPR1 EXPR2      Match both expressions, within NUM lines"
    puts "      --before NUM[%]            Restrict the search to the top % or lines"
    puts "      --after NUM[%]             Restrict the search to after the given location"
    puts "  -f, --file=FILE                Use the lines in the given file as expressions"
    puts "  -i, --ignore-case              Ignore case for matching regular expressions"
    puts "  -m, --match-limit=NUM          Find only the first NUM matches in each file"
    puts "  -o, --or EXPR1 EXPR2           Match either of the two expressions"
    puts "  -R, --range NUM[%],NUM[%]      Restrict the search to the given range of lines"
    puts "  -v, --invert-match             Show lines not matching the expression"
    puts "  -w, --word, --word-regexp      Put word boundaries around each pattern"
    puts "  -x, --line-regexp              Select entire line matching pattern"
    puts "      --xor EXPR1 EXPR2          Match either expression, but not both"
    puts ""

    puts "Output:"
    puts "  -A, --after-context=NUM        Print NUM lines of trailing context"
    puts "  -B, --before-context=NUM       Print NUM lines of leading context"
    puts "  -C, -NUM, --context[=NUM]      Output NUM lines of context"
    puts "  -c, --count                    Display only the match count per file"
    puts "      --file-color COLOR         Specify the highlight color for file names"
    puts "      --no-filter                Display the entire file"
    puts "  -g, --grep                     Produce output like the grep default"
    puts "  -h, --no-filename              Do not display the names of matching files"
    puts "  -H, --with-filename            Display the names of matching files"
    puts "  -l, --files-with-matches       Print only names of matching file"
    puts "  -L, --files-without-match      Print only names of file not matching"
    puts "      --label=NAME               Use NAME as output file name"
    puts "  -n, --line-number              Display line numbers"
    puts "  -N, --no-line-number           Do not display line numbers"
    puts "      --line-number-color COLOR  Specify the highlight color for line numbers"
    # puts "      --output=FORMAT            Produce output in the format (ansi, grep)"
    puts "      --text-color COLOR         Specify the highlight color for text"
    puts "  -u, --highlight[=FORMAT]       Enable highlighting. Format is single or multi"
    puts "  -U, --no-highlight             Disable highlighting"
    puts "  -y, --extract-matches          Display only the matching region, not the entire line"
    puts "  -Z, --null                     In -l mode, write file names followed by NULL"
    puts ""

    puts "Debugging/Errors:"
    puts "      --conf                     Write the current options in RC file format"
    puts "      --dump                     Write all options and expressions"
    puts "      --explain                  Write the expression in a more legible format"
    puts "  -q, --quiet                    Suppress warnings"
    puts "  -Q, --no-quiet                 Enable warnings"
    puts "  -s, --no-messages              Suppress warnings"
    puts "  -V, --version                  Display version information"
    puts "      --verbose                  Display normally suppressed output"

    puts ""
    puts "On Unix systems, run glark --man for more information."
  end
  
  def show_man
    pn = Pathname.new __FILE__

    dir = pn
    0.upto(2) do
      break unless dir
      dir = dir.parent
    end

    if dir
      manfile = dir + "doc/glark.man"
      cmd     = "man #{manfile.to_s}"
      IO.popen(cmd) do |io|
        puts io.readlines
      end
    else
      puts "no doc directory"
    end
  end
end
