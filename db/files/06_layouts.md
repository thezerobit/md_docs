Using Rails Layouts
-------------------

You may remember briefly looking at the file
*app/views/layouts/application.html.erb*. Right now, this file is the
layout for the entire application. Rails only looks for the application
level layout file if there isn't one specified already for the
controller. The *rails generate controller ...* commands does not create
one, but we can. Let's do that by copying the application layout:

    $ cp app/views/layouts/application.html.erb app/views/layouts/public.html.erb

So now we have an exact duplicate of the default application. Let's add
a title header. I'm no designer, so I'll just add a couple html *div's* just
inside the *body* tag:

    <!DOCTYPE html>
    <html>
    <head>
      <title>StoreApp</title>
      <%= stylesheet_link_tag :all %>
      <%= javascript_include_tag :defaults %>
      <%= csrf_meta_tag %>
    </head>
    <body>
      <div id="title_bar">
        <div id="title">My Rails App!</div>
      </div>

    <%= yield %>

    </body>
    </html>

Now to prove that this layout works, go to
[localhost:3000](http://localhost:3000/). It should look like this:

> My Rails App!
>
> Public#index
> ------------
>
> Find me in app/views/public/index.html.erb
>
> Params : {"controller"=>"public", "action"=>"index"}

Not very pretty, but it's a start. You will also see the header at 
[localhost:3000/public/about](http://localhost:3000/public/about) .
It will appear on any page that uses the *public* controller. You will
not see it on any of the generated *categories* scaffolding pages, since
those all use the *categories* controller, and right now would default
to the *app/views/layouts/application.html.erb* layout file.

For this application, we'll just use the *categories* controller for
administrative pages to change, add and delete category definitions from
the database. We'll put all public facing pages in the *public*
controller.

A Touch of CSS
--------------

Let's create a CSS file for our public controller. I think the
appropriate place to add the file would be in the *public/stylesheets*
folder. Create a file called *public/stylesheets/public.css* with the
following contents:

    div#title_bar {
      background:gray;
    }
    div#title {
      font-size:20pt;
    }

Yeah, so I'm not winning any design awards here. Please edit this CSS to
your own liking if you're so hot. In order to get this CSS loaded on
all the pages referenced by the public controller, we need to make sure
the page references it. There is a magical line in the layout already
that looks like this:

    <%= stylesheet_link_tag :all %>

That will look for all CSS files in the *public/stylesheets* folder, so
we don't have to do anything special. Rails will include it. However, we
maybe don't want any other stylesheets than just the one we created, so
let's change that line to:

    <%= stylesheet_link_tag "public" %>

Now it should only reference our *public/stylesheets/public.css* file.
The *app/views/layouts/public.html.erb* file should now look like this:

    <!DOCTYPE html>
    <html>                         
    <head>
      <title>StoreApp</title>      
      <%= stylesheet_link_tag "public" %>
      <%= javascript_include_tag :defaults %>
      <%= csrf_meta_tag %>         
    </head>                        
    <body>
      <div id="title_bar">         
        <div id="title">My Rails App!</div>
      </div>

    <%= yield %>

    </body>
    </html>

If you now load [localhost:3000/](http://localhost:3000/) you will see
that the "My Rails App!" section at the top has a gray background and
larger font. There are whole books on CSS, of which I have read none. So
if you want your page to look nice, you might have to do some research,
or find someone to work with who knows how to make web pages look nice.

Git to it
---------

Don't forget to commit your changes to Git:

    $ git add .
    $ git commit -m "added public layout and stylesheet"
    [master 36e7db0] added public layout and stylesheet
     2 files changed, 23 insertions(+), 0 deletions(-)
     create mode 100644 app/views/layouts/public.html.erb
     create mode 100644 public/stylesheets/public.css

Create Some Top Level Navigation Links
--------------------------------------

So right now, there's no way to get from the *public#index* page to the
*public#about* page or vice-versa. One way to solve this is to create
some navigation links in the header.

We can do this in pure HTML to keep things simple. Edit the public
layout to look like this:

    <!DOCTYPE html>
    <html>                         
    <head>
      <title>StoreApp</title>      
      <%= stylesheet_link_tag "public" %>
      <%= javascript_include_tag :defaults %>
      <%= csrf_meta_tag %>         
    </head>                        
    <body>
      <div id="title_bar">         
        <div id="title">My Rails App!</div>
        <div id="title_nav">
          <a href="/">Index</a> ..
          <a href="/public/about">About</a>
        </div>
      </div>

    <%= yield %>

    </body>
    </html>

Navigate to [localhost:3000/](http://localhost:3000/) . It should look
like this (roughly):

<blockquote><div style="background:gray;">
<div style="font-size:20pt">My Rails App!</div>
<div><a href="#">Index</a> . 
<a href="#">About</a></div>
</div>

<h2>Public#index</h2> 

<p>Find me in app/views/public/index.html.erb</p> 

<p>Params : {"controller"=>"public", "action"=>"index"}</p></blockquote>

Commit!

    $ git add .
    $ git commit -m "Added public nav links"
    [master 3976d8f] Added public nav links
     1 files changed, 4 insertions(+), 0 deletions(-)

Adding a New Action
-------------------

Since the *categories* controller is not public-facing, or at least we
don't intend it to be public facing, let's add an action to the *public*
controller that will give us a page for each category.

I like to add the machinery to the Rails application in roughly the
order that it is processed. The first thing we need to worry about is
routing. Edit the *config/routes.rb* file and add the following route:

    match "/cat/:id" => "public#cat"

Of course, now requests to something like [localhost:3000/cat/1](http://localhost:3000/cat/1)
will expect to find a *cat* action in the public controller. We should
add one. Edit *app/controllers/public_controller.rb* to look like this:

    class PublicController < ApplicationController
      def index                    
        @params = params.to_s
      end                          

      def about
      end

      def cat
        @category = Category.find(params[:id])
      end

    end

Does that line with a call to *Category.find* look familiar, it should.
It's a direct copy from the *show* action from the *category*
controller. It tries to load the Category from the database that
corresponds to the id number from the URL. That's the ":id" part of the
route.

The *public* controller is going to be looking for a template to render
for this page. It's going to look for a file called
*app/views/public/cat.html.erb* so let's make one:

    <div class="category_name">
      <%= @category.name %>
    </div>
    <div class="category_description">
      <%= @category.description %>
    </div>

Now there is enough to view a public details page for a category. If
there is a category with an ID of 1, (the first one you created, which
you might have deleted) you will be able to get that page here: 
[localhost:3000/cat/1](http://localhost:3000/cat/1) .

More Nav Links
--------------

In order for the visitor to the site to be able to get to the category
details pages, we'll need links. For simplicity sake, let's add that to
the top of the page in the *public* layout
(*app/views/layout/public.html.erb*).

    <!DOCTYPE html>
    <html>                  
    <head>
      <title>StoreApp</title>      
      <%= stylesheet_link_tag "public" %> 
      <%= javascript_include_tag :defaults %>
      <%= csrf_meta_tag %>         
    </head>                        
    <body>
      <div id="title_bar">
        <div id="title">My Rails App!</div>
        <div id="title_nav">
          <a href="/">Index</a> .. 
          <a href="/public/about">About</a>
        </div>
        <div id="category_nav">
          <% @categories.each do |cat| %>
            <a href="/cat/<%= cat.id %>">
              <%= cat.name %>
            </a> .
          <% end %>
        </div>
      </div>

    <%= yield %>

    </body>
    </html>

This layout is used by all the actions in the *public* controller, so
we'll need to make sure that we load the categories for each action in
*app/controllers/public_controller.rb*. This is the naive way to do it:

    class PublicController < ApplicationController
      def index
        @categories = Category.all
        @params = params.to_s
      end

      def about
        @categories = Category.all
      end

      def cat
        @categories = Category.all
        @category = Category.find(params[:id])
      end

    end

Adding the same exact line to each action is against the software
development principle of DRY (don't repeat yourself). Rails provides a
way to have an method run on the Controller class at the beginning of
each request. So we can change the above to this:

    class PublicController < ApplicationController
      before_filter :load_categories

      def index
        @params = params.to_s
      end

      def about
      end

      def cat
        @category = Category.find(params[:id])
      end

      private

      def load_categories
        @categories = Category.all
      end

    end

The *before_filter* specifies a method that is run before any other
action method is run. In this case, it will load the categories before
doing anything else for any actions in the *public* controller.

You should now have two levels of navigation links, one for the Index
and About pages, and one for the various public category pages.

Now that the page has been made functional. It should probably be made
to look half-decent. That just involves editing the various templates
and public.css file.

Don't forget to commit your changes to git.

On Errors
---------

There is always the possibility for errors to occur. If you have any
trouble getting these examples to run. You may have missed a step or
entered some thing slightly wrong, or mispelled a variable name, etc.
There are too many possible errors to list them all here. Your best bet,
when there is an error, is to look at the error message for file names
and line numbers. Those will usually point you in the right direction.
There are two types of bugs: syntax errors, where a typo makes your code
invalid, and logic errors where the code you've written is valid code,
but it just happens to do something different than what you were hoping
it would do. Keep in mind that Rails will do what ever you tell it to,
even if it isn't what you want it to do, so you might not get an error
message every time something is wrong. You might just get unexpected
output.



