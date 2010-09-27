Rails Class Notes : Introduction to Ruby and Rails
--------------------------------------------------


A. Getting a Good UNIX Environment
----------------------------------

Windows
-------

Ruby 1.9.2: 
* [Win Installer](http://rubyforge.org/frs/download.php/72170/rubyinstaller-1.9.2-p0.exe)
* Select *"Add Ruby Executables to PATH"* when installing Ruby

SQLite3
* [zip](http://www.sqlite.org/sqlitedll-3_7_2.zip)
* extract and copy sqlite3.dll into C:\Ruby192\bin

Git: 
* [Git For Windows](http://code.google.com/p/msysgit/)
* Click Download, select msysGit-fullinstall.....
* Run installer, installs to C:\msysgit

*or*

* Install Ubuntu 10.04.1 either as a dual boot option or in a virtual
machine like VirtualBox.

Ubuntu
------

Install ruby1.8, ruby1.8-dev, build-essential, libxslt-dev, libxml2-dev,
git-core

OS X
----

* Install Xcode. 
* Install Git.

B. Install RVM (Linux or OS X)
------------------------------

[Ruby Version Manager](http://rvm.beginrescueend.com/)

[Install RVM](http://rvm.beginrescueend.com/rvm/install/)

    $ mkdir rvm
    $ cd rvm
    $ curl http://rvm.beginrescueend.com/releases/rvm-install-head > install
    $ sh install

Follow post install instructions: edit ~/.bashrc according to webpage.

C. Install Ruby 1.9.2 (Linux or OS X)
-------------------------------------

    $ rvm install 1.9.2
    $ rvm use 1.9.2
    $ ruby -v
    ruby 1.9.2p0 .......
    $ rvm --default 1.9.2

D. Install Rails 3 (All Platforms)
----------------------------------

    $ gem install rails

E. Test Rails App
-----------------

Create rails project.

    $ cd
    $ mkdir rails_stuff
    $ cd rails_stuff
    $ rails new test_app

Run bundle install

    $ cd test_app
    $ bundle install

Build default (empty) database:

    $ rake db:create

The rake tool is a handy command for performing many important tasks
with Rails. You can see a list of them like this:

    $ rake -T

Run the server

    $ rails server

Test it out, go to [localhost:3000](http://localhost:3000/)

Kill the server with Control-C

Introduction to Ruby
--------------------

Enter interactive Ruby shell.

    $ irb
    ruby-1.9.2p0 >

Type some simple numbers

    ruby-1.9.2-p0 > 1
    => 1 
    ruby-1.9.2-p0 > 10
    => 10 
    ruby-1.9.2-p0 > 10.00000
    => 10.0

Type some strings

    ruby-1.9.2-p0 > "string"
    => "string" 
    ruby-1.9.2-p0 > 'x'
    => "x" 
    ruby-1.9.2-p0 > "Hi, my name is Bob."
    => "Hi, my name is Bob."

What's going on? The value printed after the arrow is the value of the
expression. These expression don't do anything, they are just numbers or
strings of letters.

Numbers: 1, 20, 100.1, -1.2334, -199999

Strings: "Double quoted", 'single quoted'

Assign some variables

    ruby-1.9.2-p0 > x = 10.0
    => 10.0 
    ruby-1.9.2-p0 > y = 20.0
    => 20.0 
    ruby-1.9.2-p0 > z = x / y
    => 0.5 

Variables hold values. The value of the expression on the right hand
side is assigned to the variable on the left.

Converting between strings and numbers.

    ruby-1.9.2-p0 > x = 10
    => 10 
    ruby-1.9.2-p0 > x.class
    => Fixnum 
    ruby-1.9.2-p0 > y = x.to_s
    => "10" 
    ruby-1.9.2-p0 > y
    => "10" 
    ruby-1.9.2-p0 > y.class
    => String
    ruby-1.9.2-p0 > y.class
    => String
    ruby-1.9.2-p0 > y.to_i
    => 10 
    ruby-1.9.2-p0 > y.to_f
    => 10.0

Create some functions.

    ruby-1.9.2-p0 > def my_func(x)
    ruby-1.9.2-p0 ?>  print x
    ruby-1.9.2-p0 ?>  end
    => nil 
    ruby-1.9.2-p0 > my_func("hello")
    hello => nil 

A function looks like this:

    def function_name(param1, param2, param3)
      expr1
      expr2
      expr3
    end

You call a function this way:

    function_name(x,y,z)

A function might not parameters:

    def func()
      print "hello"
    end

It can be called in two ways:

    func()

_or_

    func

The parentheses when calling a function are optional:

    ruby-1.9.2-p0 > def adder(x,y,z)
    ruby-1.9.2-p0 ?>  print x + y + z
    ruby-1.9.2-p0 ?>  end
    => nil 
    ruby-1.9.2-p0 > adder(1,2,3)
    6 => nil 
    ruby-1.9.2-p0 > adder 1, 2, 3
    6 => nil

There are different kinds of scope, the visibility of variables which
depends on the first letter of the name of the variable:
* Local variables start with a-z or the underscore
* Global variable start with the dollar sign
* Instance variables start with @
* Class variables start with @@
* Constant variables start with a capital letter A-Z, similar to globals

So far we've used local variables, which are only available "locally".
For example:

    def some_function(y)
      x = y
      print x
    end

The variables x and y in that example are local variables, only visible
for a couple lines inside the function.

Global variables are available everywhere in your program.

    $my_global = "Steve"

    def some_function()
      print $my_global
    end

Well talk about instance and class variables a bit later.

Arrays
------

Arrays are a sequence of values in a particular order.

    my_array = [1,2,3,4]

The values can be any kind of value including other arrays.

    ["hello", 3, 4, ["array", "inside", "array"], 100.0]

The values in an array can be pulled out with the bracket syntax:

    ruby-1.9.2-p0 > x = ["A", "B", "C"]
    => ["A", "B", "C"] 
    ruby-1.9.2-p0 > x[0]
    => "A" 
    ruby-1.9.2-p0 > x[1]
    => "B" 
    ruby-1.9.2-p0 > x[2]
    => "C"

The first element is the zeroth element. In programming, you almost
always start counting with 0.

Elements may be added or removed from the end of the array, also known
as pushing and popping.

    ruby-1.9.2-p0 > my_array = []
    => [] 
    ruby-1.9.2-p0 > my_array.push "hello"
    => ["hello"] 
    ruby-1.9.2-p0 > my_array.push "world"
    => ["hello", "world"] 
    ruby-1.9.2-p0 > my_array.pop
    => "world" 
    ruby-1.9.2-p0 > my_array
    => ["hello"]

Classes and Objects
-------------------

Ruby is a so-called Object-Oriented Language. All the values we've seen
so far can be called objects. Objects have a type or "class".

    ruby-1.9.2-p0 > 10.class
    => Fixnum 
    ruby-1.9.2-p0 > "hello".class
    => String 
    ruby-1.9.2-p0 > [1, 3, 4].class
    => Array

You can create your own classes, or modify Ruby's built in classes.
Let's add something silly to the String class.

    ruby-1.9.2-p0 > class String
    ruby-1.9.2-p0 ?>  def say_hello()
    ruby-1.9.2-p0 ?>    print "hello " + self
    ruby-1.9.2-p0 ?>    end
    ruby-1.9.2-p0 ?>  end
    => nil 
    ruby-1.9.2-p0 > "Steve".say_hello
    hello Steve => nil

We can create our own class.

    class Name
      def initialize(first, last)
        @first = first
        @last = last
      end

      def say_hello
        print "Hello, " + @first
      end
    end

You create instances of the class with the new method.

    ruby-1.9.2-p0 > me = Name.new "Steve", "Goss"
    => #<Name:0x00000001146b98 @first="Steve", @last="Goss">
    ruby-1.9.2-p0 > me
    => #<Name:0x00000001146b98 @first="Steve", @last="Goss">
    ruby-1.9.2-p0 > me.say_hello
    Hello, Steve => nil

When you call the new method on the class (Name.new), an instance is
created and the initialize method is called. In the previous example,
two instance variables are created in the initialize method. These
variables exist within the particular instance of the class that was
created. In this case, the created instance we assigned to the variable
"me".

Find more on classes here: [Ruby Classes](http://ruby.runpaint.org/classes)

More about Ruby 1.9 here: [Read Ruby](http://ruby.runpaint.org/)
Another free online Ruby book: [Ruby Essentials](http://www.techotopia.com/index.php/Ruby_Essentials)
[Why's Poignant Guide to Ruby](http://mislav.uniqpath.com/poignant-guide/)

If you are new to Ruby, maybe start with Why's text, move to Ruby
Essentials. Read Ruby is a good reference, but maybe not designed for
Ruby beginners.

Official Ruby Webpage: [ruby-lang.org](http://www.ruby-lang.org/en/)

Rails and MVC
-------------

MVC stands for Model View Controller. It's a way to separate different
parts of the code that do different things. The Controller is the part
of the code that accepts incoming requests and decides what to do. The
Model is the part of the code that takes care of interacting with the
database and may contain some business logic as well. The View is the
part of the code responsible for rendering HTML back to the browser that
sent the request.


