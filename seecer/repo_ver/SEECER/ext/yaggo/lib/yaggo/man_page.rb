# This file is part of Yaggo.

# Yaggo is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Yaggo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Yaggo.  If not, see <http://www.gnu.org/licenses/>.

require 'pathname'

def display_man_page out
  manual = <<EOS
.TH yaggo 1  "2015-06-24" "version #{$yaggo_version}" "USER COMMANDS"

.SH NAME
yaggo \- command line switch parser generator

.SH SYNOPSIS
.B yaggo
[-o|--output FILE] [-l|--license PATH] [-s|--stub] [--zc PATH] [-e|--extended-syntax] [--man] [-h|--help]

.SH DESCRIPTION
Yaggo stands for Yet Another GenGetOpt. It is inspired by gengetopt
software from the FSF.

Yaggo generates a C++ class to parse command line switches (usually
argc and argv passed to main) using getopt_long. The switches and
arguments to the program are specified in a description file. To each
description file, yaggo generates one C++ header file containing the
parsing code.
.PP
See the EXAMPLES section for a complete and simple example.

.SH OPTIONS
.TP
\-l|\-\-license
Display the file at the top of the generated headers. It usually
contains the license governing the distribution of the headers.
.TP
-m|\-\-man
Display this man page
.TP
\-s|\-\-stub
Generate a stub: a simple yaggo file that can be modified for one's use.
.TP
\-e|--extended-syntax
Use the extended syntax: blocks can be defined on the next line of a command.
.TP
\-h|--help
Display a short help text
.PP

.SH EXAMPLE

Consider the description files 'example_args.yaggo' which defines a
switch "-i" (or "--int") that takes an unsigned integer and defaults
to 42; a switch "-s" (or "--string") that takes a string and can be
given multiple times; a switch "--flag" which does not take any
argument; a switch "--severity" which can take only 3 values: "low",
"middle" and "high".

It takes the following arguments: a string followed by zero or more floating point numbers.

.nf
purpose "Example of yaggo usage"
package "example"
description "This is just an example.
And a multi-line description."

option("int", "i") {
  description "Integer switch"
  uint32; default "42" }
option("string", "s") {
  description "Many strings"
  string; multiple }
option("flag") {
  description "A flag switch"
  flag; off }
option("severity") {
  description "An enum switch"
  enum "low", "middle", "high" }
arg("first") {
  description "First arg"
  c_string }
arg("rest") {
  description "Rest of'em"
  double; multiple }
.fi

The associated simple C++ program 'examples.cpp' which display information about the switches and arguments passed:

.nf
#include <iostream>
#include "example_args.hpp"

int main(int argc, char *argv[]) {
  example_args args(argc, argv);

  std::cout << "Integer switch: " << args.int_arg << "\\\\n";
  if(args.string_given)
    std::cout << "Number of string(s): " << args.string_arg.size() << "\\\\n";
  else
    std::cout << "No string switch\\\\n";
  std::cout << "Flag is " << (args.flag_flag ? "on" : "off") << "\\\\n";
  std::cout << "First arg: " << args.first_arg << "\\\\n";
  std::cout << "Severity arg: " << args.severity_arg << " " << example_args::severity::strs[args.severity_arg] << "\\\\n";
  if(args.severity_arg == example_args::severity::high)
    std::cout << "Warning: severity is high\\\\n";
  std::cout << "Rest:";
  for(example_args::rest_arg_it it = args.rest_arg.begin(); it != args.rest_arg.end(); ++it)
    std::cout << " " << *it;
  std::cout << std::endl;

  return 0;
}
.fi

This can be compiled with the following commands:

.nf
% yaggo example_args.yaggo
% g++ -o example example.cpp
.fi

The yaggo command above will create by default the file
'example_args.hpp' (changed '.yaggo' extension to '.hpp'). The output
file name can be changed with the 'output' keyword explained below.

.SH DESCRIPTION FORMAT

A description file is a sequence of statements. A statement is a
keyword followed by some arguments. Strings must be surrounded by
quotes ("" or '') and can span multiple lines. The order of the
statements is irrelevant. Statements are separated by new lines or
semi-colons ';'.

.IP *
Technically speaking, yaggo is implemented as a DSL (Domain Specific
Language) using ruby. The description file is a valid ruby script and
the keywords are ruby functions.
.PP

The following statements are global, not attached to a particular option or argument.

.TP
purpose
A one line description of the program.
.TP
package
The name of the package for the usage string. Defaults to the name of the class.
.TP
usage
The usage string. If none given a standard one is generated by yaggo.
.TP
description
A longer description of the program displayed before the list of switch. Displayed by the help.
.TP
text
Some text to be displayed after the list of switches. Displayed by the help.
.TP
version
The version string of the software.
.TP
license
The license and copyright string of the software.
.TP
name
The name of the class generated. Defaults to the name of the
description file minus the .yaggo extension.
.TP
posix
Posix correct behavior (instead of GNU behavior): switch processing
stops at the first non-option argument
.TP
output
The name of the output file. Defaults to the name of the
description file with the .yaggo extension changed to .hpp.
.PP

The 'option' statement takes one or two arguments, which must be in
parentheses, and a block of statements surrounded by curly braces
({...}). The arguments are the long and short version of the
option. Either one of the long or short version can be omitted. The
block of statements describe the option in more details, as described
below.

A switch is named after the long version, or the short version if no
long version. An 'option' statement for an option named 'switch'
defines one or two public members in the class. For a flag, it
creates 'switch_flag' as a boolean. Otherwise, it
creates 'switch_arg', with a type as specified, and 'switch_given', a
boolean indicating whether or not the switch was given on the command
line.

For example, the statement:

.nf
option("integer", "i") {
  int; default 5
}
.fi

will add the following members to the C++ class:

.nf
int integer_arg;
bool integer_given;
.fi

where "integer_arg" is initialized to 5 and "integer_given" is
initialized to "false". If the switch "--integer 10" or "-i 10" is
passed on the command line "integer_arg" is set to 10 and
integer_given is set to "true".

The statement:

.nf
option("verbose") {
  off
}
.fi

will add the following member to the C++ class:

.nf
bool verbose_flag;
.fi

where "verbose_flag" is initialized to "false". Passing the switch
"--verbose" on the command line sets "verbose_flag" to true".


In addition to the switch created by 'option', the following switches
are defined by default (unless some option statement overrides them):

.TP
\-h, \-\-help
Display the help message.
.TP
\-\-full\-help
Display hidden options as well.
.TP
\-\-version
Display version string.
.PP

The following statement are recognized in an option block:

.TP
description "str"
A short description for this switch.

.TP
int32, int64, uint32, uint64, double, int, long
This switch is parsed as a number with the corresponding type int32_t,
int64_t, uint32_t, uint64_t, double, int and long.

.TP
suffix
Valid for numerical type switches as above. It can be appended
with a SI suffix (e.g. 1M mean 1000000). The suffixes k, M, G, T, P,
and E are supported for all the numerical types. The suffixes m, u, n,
p, f, and a are supported for the double type.

.TP
c_string, string
This switch is taken as a C string (const char *) or a C++ string
(inherits from std::string). The C++ string type has the extra
methods '<type> as_<type>(bool suffix)', where <type> is any numerical
type as above, to convert the string into that type. If the 'suffix'
boolean is true, parsing is done using SI suffixes.

.TP
enum
This statement must be followed by a comma separated list of strings
(as in 'enum "choice0", "choice1", "choice2"'). This switch takes value
a string in the list and is converted to int. C enum type named
"switchname::enum" is defined with the same choices in the given order.

.TP
required
This switch is required. An error is generated if not given on the
command line.
.TP
conflict
Specify a comma separated list of switches that conflicts with this
one.
.TP
imply
Specify a comma separated list of switches (of type flag) which are
implied by this one.
.TP
hidden
This switch is not shown with --help. Use --full-help to see the
hidden switches, if any.
.TP
secret
This switch is not shown in any help message. Neither --help nor
--full-help.
.TP
multiple
This switch can be passed multiple times. The values are stored in a
std::vector. A type for the iterator is also defined in the class with
the name 'switch_arg_it', where 'switch' is the name of the option.
.TP
flag
This switch is a flag and does not take an argument.
.TP
on, off
The default state for a flag switch. Implies flag. Unless the 'no'
option is used (see below), with 'off', the default value of the flag
is "false" and passing --flag sets it to true. With 'on', the default
value of the flag is "true" and passing --flag sets it to false.
.TP
no
A flag with two switches. If the switch is named "flag", two switches
are generated: --flag and --noflag, respectively setting it to "true"
and "false". The 'on' and 'off' options define the default value.
.TP
default "val"
The default value for this switch. It can be a string or a valid
number. SI suffixes are supported as well (for example "1M" means 1
m`illion).
.TP
typestr "str"
In the help message, by default, the type of the option is
displayed. It can be replaced by the string given to 'typestr'.
.TP
at_least n
The given switch must be given at least n times. Implies multiple.
.TP
access "type"
Make sure that the string passed is a path to which we have
access. "type" is a comma separated list of "read", "write" or
"exec". It is checked with access(2). The same warning applies:

"Warning: Using access() to check if a user is authorized to, for
example, open a file before actually doing so using open(2) creates a
security hole, because the user might exploit the short time interval
between checking and opening the file to manipulate it.  For this
reason, the use of this system call should be avoided.  (In the
example just described, a safer alternative would be to temporarily
switch the process's effective user ID to the real ID and then call
open(2).)"

.PP

A 'arg' statement defines an arg passed to the command line. The
statement takes a single argument, the name of the arg, and a block of
statements. The block of statements are similar to the option block,
except that "hidden", "flag", "on", "off" and "no" are not allowed. At
most one arg can have the 'multiple' statement, and it must be the
last one.

.SH EXAMPLE USAGE

The argument object parses the switches on construction or later on
using the parse method. For example, the two pieces code show these
two different usage.

Using parse method:
.nf
  example_args args; // Global variable with switches

  int main(int argc, char* argv[]) {
    args.parse(argc, argv);
  }
.fi

Parse on construction:
.nf
  int main(int argc, char* argv[]) {
    example_args args(argc, argv);
  }
.fi

The subclass error can be used to output error messsage (and terminate
program). It output an error message, the usage string, etc. The error
class behave like an output stream, it can be used to create
complicated error message. For example:

.nf
  if(false_condition)
    example_args::error() << "Failed to open file '" << args.file_arg << "'";
.fi

An error object prints an error message and terminate the program with
exit upon destruction. An exit code can be passed to error. By default
the exit code (passed to exit) is the constant EXIT_FAILURE (normally
1). For example:

.nf
  example_args::error(77) << "Failed with return code 77";
.fi

.SH LICENSE

There are 2 parts to the software: the yaggo ruby script itself, and
the header files generated by yaggo from the description files. The
licenses are as follow:

.TP
yaggo the ruby script
This software is licensed under the GNU General
Public License version 3 or any later version. Copyright (c) 2011
Guillaume Marcais.

.TP The generated header files.  These files have the license and
copyright that you, the user of yaggo, assign with the 'license'
keyword.  .PP In short: only yaggo the software is GPL. The generated
header files are considered derivative of your work (e.g. the
description), and you define the copyright and license of those as you
see fit.

.SH BUGS
.IP *
The error message returned by ruby can be a little confusing.

.SH AUTHOR
Guillaume Marcais (gmarcais@umd.edu)
.SH SEE ALSO
getopt_long(3), gengetopt(1), exit(2)
EOS

  if !out && STDOUT.isatty
    require 'tempfile'
    Tempfile.open("yaggo_man") do |fd|
      begin
        fd.write(manual)
        fd.flush
        system("man", fd.path)
      ensure
        fd.unlink
      end
    end
  elsif !out
    STDOUT.puts(manual)
  else
    path = Pathname.new(out)
    path.write manual
  end
end