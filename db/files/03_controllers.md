Rails Controllers
-----------------

In Rails, a request is routed to an action which is merely a method in a
controller class. The 'rails' script has a way to generate bare-bones
controllers. It works like this: 'rails generate controller
controllername action1 action2 action3'. Let's make a 'public'
controller with an 'index' action and an 'about' action. Run the
following command in the project folder:

    $ rails generate controller public index about

You should see the following (or similar) output:

          create  app/controllers/public_controller.rb
           route  get "public/about"
           route  get "public/index"
          invoke  erb
          create    app/views/public
          create    app/views/public/index.html.erb
          create    app/views/public/about.html.erb
          invoke  test_unit
          create    test/functional/public_controller_test.rb
          invoke  helper
          create    app/helpers/public_helper.rb
          invoke    test_unit
          create      test/unit/helpers/public_helper_test.rb

Using the 'rails' script to generate this boilerplate code is a great
way to see how Rails works. The first file, public&#95;controller.rb,
contains the controller class. It looks like this:

    class PublicController < ApplicationController
      def index
      end

      def about
      end

    end

So a controller is just a class that inherits from the
ApplicationController class and the actions are methods in that class.
These methods, which are empty for now, provide a place for you to put
some dynamic behavior, some code that runs when someone invokes those
actions by loading a page / sending a request to you Rails app. By
default, rails actions are available by the path '/controller/action'.
So, fire up your application by running 'rails server' and navigate your
browser to
[localhost:3000/public/index](http://localhost:3000/public/index). You
should see something like this:

> Public#index
> ------------
>
> Find me in app/views/public/index.html.erb

Indeed, the 'rails' script created a folder for public controller
views: *app/views/public* and two Erb (embedded Ruby) files,
*index.html.erb* and *about.html.erb*. The empty *index* action in the
PublicController will render the index.html.erb view by default. First
let's set up a default route to the public/index action.

Routes in Rails are defined in the *config/routes.rb* file. It looks
like this (ignoring the comment lines):

    StoreApp::Application.routes.draw do
      get "public/index"

      get "public/about"
    end

Without getting into details about routing, lets add one line to map the
root path '/' to the public/index action:

    StoreApp::Application.routes.draw do
      get "public/index"

      get "public/about"

      match "" => "public#index"

    end

Now start up the server and navigate to
[localhost:3000](http://localhost:3000/). You should see the same
index.html.erb rendered.

Controller Params
-----------------

In a standard web request, there may be a query string which is
generally a series of mappings that follow a question mark (?). The
following URL contains a query string:

    http://localhost:3000/?page=10

The query string in the previous example is:

    page=10

It is a mapping the key being *page* which maps to the value *10* .
Query strings may contain multiple mappings like the following:

    http://localhost:3000/?page=10&this=that&a=b

Adding a query string to a request does not change the controller action
that is called, but the query parameters are available to the controller
action in a variable called *params* which is a hash.

A Note on Ruby Hashes
---------------------

A Ruby hash is a data structure that represents any number of mappings.
A hash looks like this:

    { 'page' => 10, 'this' => 'that', 'a' => 'b' }

They can be assigned to variables and values extracted or assigned
through the square bracket syntax. Let's fire up *irb* and take them for
a spin:

    $ irb
    ruby-1.9.2-p0 > my_hash = { "page" => '10' }
    => {"page"=>"10"} 
    ruby-1.9.2-p0 > my_hash.class
    => Hash 
    ruby-1.9.2-p0 > my_hash["page"]
    => "10" 
    ruby-1.9.2-p0 > my_hash["missing"]
    => nil 
    ruby-1.9.2-p0 > my_hash["missing"] = "here!"
    => "here!" 
    ruby-1.9.2-p0 > my_hash["missing"]
    => "here!" 
    ruby-1.9.2-p0 > my_hash
    => {"page"=>"10", "missing"=>"here!"} 

Since query parameters are mappings, the hash provides an excellent
container for those values. It also contains the controller and action
values.

Passing data to the view
------------------------

The controller can pass information to view through instance variables
(the ones that start with @). Almost all data types in Ruby have a
method, *to_s* which creates a string representation of the object.
We'll use that in the index controller to create string representation
of the *params* hash that will be displayed in the view.

First, let's edit *app/controllers/public&#95;controller.rb* to look like this:

    class PublicController < ApplicationController
      def index
        @params = params.to_s
      end

      def about
      end

    end

And edit *app/views/index.html.erb* to look like this:

    <h1>Public#index</h1>
    <p>Find me in app/views/public/index.html.erb</p>

    <p>Params : <%= @params %></p>

Now the page will echo back the contents of the *params* hash.
[localhost:3000/?page=10](http://localhost:3000/?page=10) will look
something like this:


> Public#index
> ------------
>
> Find me in app/views/public/index.html.erb
>
> Params : {"page"=>"10", "controller"=>"public", "action"=>"index"}

The "page" parameter is clearly set, as well as the controller and
action names.

Git Git Git
-----------

So, you've made some changes. Happy with them? Then commit! Ironically,
"committing" your changes does not mean that you are committed to them,
since you can always back up to a previous version, it just means you
have committed them to repository in the same way you might commit your
crazed aunt into a mental institution after she had a nervous breakdown
at a family get-together.

    $ git status
    # On branch master
    # Changed but not updated:
    #   (use "git add <file>..." to update what will be committed)
    #   (use "git checkout -- <file>..." to discard changes in working directory)
    #
    # modified:   config/routes.rb
    #
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    # app/controllers/public_controller.rb
    # app/helpers/public_helper.rb
    # app/views/public/
    # test/functional/
    # test/unit/
    no changes added to commit (use "git add" and/or "git commit -a")

That *git status* command is pretty handy. It shows what's been changed
and even gives some suggestions at the end. Let's add the changes (it
means you are preparing them for being committed, much like getting your
aunt into the car to take her to the institution). You get your changes
into the "car" by adding them:

    $ git add .

Git is silent on this one. It figures you know what you're doing. That
trusty *git status* command is a good one to throw out now, so you can
see all your changes are buckled in the car (staged) and ready to be
committed.

    $ git status
    # On branch master
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    # new file:   app/controllers/public_controller.rb
    # new file:   app/helpers/public_helper.rb
    # new file:   app/views/public/about.html.erb
    # new file:   app/views/public/index.html.erb
    # modified:   config/routes.rb
    # new file:   test/functional/public_controller_test.rb
    # new file:   test/unit/helpers/public_helper_test.rb
    #

Do the deed.

    $ git commit -m "added public controller"
    [master f2cc49b] added public controller
     7 files changed, 41 insertions(+), 0 deletions(-)
     create mode 100644 app/controllers/public_controller.rb
     create mode 100644 app/helpers/public_helper.rb
     create mode 100644 app/views/public/about.html.erb
     create mode 100644 app/views/public/index.html.erb
     create mode 100644 test/functional/public_controller_test.rb
     create mode 100644 test/unit/helpers/public_helper_test.rb

One final *git status* for good luck.

    $ git status
    # On branch master
    nothing to commit (working directory clean)

OK, now you're ready to move on to the next section.

