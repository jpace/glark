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
    puts "      --before NUM[%]            Restrict the search to the top % or lines"
    puts "      --after NUM[%]             Restrict the search to after the given location"
    puts "  -d, --directories=ACTION       Process directories as list, skip, or find (recurse)"
    puts "      --binary-files=TYPE        Treat binary files as TYPE"
    puts "      --split-as-path            Treat file arguments as paths, to be split into directories and files"
    puts "      --match-name EXPR          Search only files with names (base names) matching EXPR"
    puts "      --not-name EXPR            Ignore files with names matching EXPR"
    puts "      --match-path EXPR          Search only files with paths (full names) matching EXPR"
    puts "      --not-path EXPR            Ignore files with paths matching EXPR"
    puts "  -M, --exclude-matching         Ignore files with names matching the expression"
    puts "  -R, --range NUM[%],NUM[%]      Restrict the search to the given range of lines per file."
    puts "  -r, --recurse                  Recurse through directories"
    puts "      --size-limit=SIZE          Search only files no larger than SIZE"
    puts ""

    puts "Matching:"
    puts "  -a, --and=NUM EXPR1 EXPR2      Match both expressions, within NUM lines"
    puts "      --extended                 Use the given regular expression as extended"
    puts "  -f, --file=FILE                Use the lines in the given file as expressions"
    puts "  -i, --ignore-case              Ignore case for matching regular expressions"
    puts "  -o, --or EXPR1 EXPR2           Match either of the two expressions"
    puts "  -w, --word                     Match the pattern(s) with word boundaries added"
    puts "  -x, --line-regexp              Select entire line matching pattern"
    puts "      --xor EXPR1 EXPR2          Match either expression, but not both"
    puts ""

    puts "Output:"
    puts "  -A, --after-context=NUM        Print NUM lines of trailing context"
    puts "  -B, --before-context=NUM       Print NUM lines of leading context"
    puts "  -C, -NUM, --context[=NUM]      Output NUM lines of context"
    puts "  -c, --count                    Display only the match count per file"
    puts "      --file-color COLOR         Specify the highlight color for file names"
    puts "      --no-filter                Display the entire file, not only the matching lines"
    puts "  -g, --grep                     Produce output like the grep default"
    puts "  -h, --no-filename              Do not display the names of matching files"
    puts "  -H, --with-filename            Display the names of matching files"
    puts "  -l, --files-with-matches       Print only names of matching file"
    puts "  -L, --files-without-match      Print only names of file not matching"
    puts "      --label=NAME               Use NAME as output file name"
    puts "  -n, --line-number              Display line numbers"
    puts "  -N, --no-line-number           Do not display line numbers"
    puts "      --line-number-color COLOR  Specify the highlight color for line numbers"
    puts "  -m, --match-limit=NUM          Find only the first NUM matches in each file"
    puts "      --text-color COLOR         Specify the highlight color for text"
    puts "  -u, --highlight[=FORMAT]       Enable highlighting. Format is single or multi"
    puts "  -U, --no-highlight             Disable highlighting"
    puts "  -v, --invert-match             Show lines not matching the expression"
    puts "  -y, --extract-matches          Display only the matching region, not the entire line"
    puts "  -Z, --null                     In --files-with-matches mode, write file names followed by NULL"
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
    0.upto(3) do
      break unless dir
      dir = dir.parent
    end

    if dir
      manfile = dir + "doc/glark.1"
      cmd     = "man #{manfile.to_s}"
      IO.popen(cmd) do |io|
        puts io.readlines
      end
    else
      puts "no doc directory"
    end
  end
end
