Rails Views
-----------

Rails views are the files that format the output of the response. There
are two files that Rails looks for: the layout and the template. Rails
looks for a layout in the *app/views/layouts* folder with the name of
the controller class, otherwise it looks for *application.html.erb* in
that folder. By default Rails projects have the
*app/views/layouts/application.html.erb* for the layout. Let's look at
it:

    <!DOCTYPE html>
    <html>
    <head>
      <title>StoreApp</title>      
      <%= stylesheet_link_tag :all %>
      <%= javascript_include_tag :defaults %>
      <%= csrf_meta_tag %>
    </head>
    <body>

    <%= yield %>

    </body>
    </html>

This files provides a shell of sorts, the main body will be rendered
where the *yield* statement is. There are a some helpers that load some
default Rails CSS and JavaScript files.

For the main template, Rails looks, by default, in the
*app/views* folder for a folder with the controller name and a template
file with the action name. The *rails generate controller* command we
did earlier created two such files for our two controller actions:
*app/views/public/index.html.erb* and *app/views/public/about.html.erb*.

There are different types of views, but the default Rails views are
*.erb* or Embedded Ruby format. Embedded Ruby does pretty much just what
it says, it allows you to embed bits of Ruby code directly in the view.

There are two types of tags there is the tag that lets you run arbitrary
bits of Ruby code without displaying anything:

    <% name = "Steve" %>

And there is the tag that echoes the value of the Ruby statement back to
the user as part of the displayed text:

    <%= name %>

Arrays and Looping
------------------

Let's divert for a minute to take a look at how to loop through an array 
in Ruby. Arrays have a method called *each* which can be followed by a
do clause to perform some actions with each element of the array. Here's
  an example:

    ruby-1.9.2-p0 > my_array = ["a", "b", "c"]
     => ["a", "b", "c"] 
    ruby-1.9.2-p0 > my_array.each do |thing|
    ruby-1.9.2-p0 >     puts thing
    ruby-1.9.2-p0 ?>  end
    a
    b
    c
     => ["a", "b", "c"] 

This is a bit tricky, the part between the vertical bars after the *do*
statement is the name we give each element of the array. The code
between that and the *end* statement is run once for each element of the
array. In this case, we have a single command that just prints the
element, the *puts* function.

Embedded Ruby allows you to use this syntax to render elements from an
array in an ordered list.

    <ol>
      <% some_array = ["Billy", "Bobby", "Jimmy"] %>
      <% some_array.each do |name| %>
        <li> <%= name %> </li>
      <% end %>
    </ol>

If you replace the contents of *app/views/public/index.html.erb* with
that markup and navigate to [localhost:3000](http://localhost:3000/) you
should see the following:

> 1. Billy
> 2. Bobby
> 3. Jimmy

The markup for the body of the response looks like this:

    <ol> 
        <li> Billy </li> 
        <li> Bobby </li> 
        <li> Jimmy </li> 
    </ol> 

Text rendered to your response from Ruby variables is escaped by
default, so user-entered data, for example, will not change the
rendering of the page which is a security issue. Let's try a different
array of string:

    <ol>
      <% some_array = ["Billy", "Bobby", "<script>alert('danger!')</script>"] %>
      <% some_array.each do |name| %>
        <li> <%= name %> </li>
      <% end %>
    </ol>

Just renders:

> 1. Billy
> 2. Bobby
> 3. &lt;script&gt;alert('danger!');&lt;/script&gt;

If you look at the HTML response, you can see the escaping:

    <ol> 
        <li> Billy </li> 
        <li> Bobby </li> 
        <li> &lt;script&gt;alert('danger!');&lt;/script&gt; </li> 
    </ol> 

Rails replaced the *&lt;* and *&gt;* symbols with the HTML entities
'*&amp;lt;*' and '*&amp;gt;*'.

If you want, you can disable the escaping by telling Rails that the
string is safe to be rendered directly as HTML:

    <ol>
      <% some_array = ["Billy", "Bobby", "<script>alert('danger!')</script>"] %>
      <% some_array.each do |name| %>
        <li> <%= name.html_safe %> </li>
      <% end %>
    </ol>

Loading, the page, you will see a popup that says, "Danger!". As you can
see, it is generally best to leave the normal escaping on, since you
wouldn't want user entered data to be able to execute arbitrary JavaScript 
code in the browser.

Using Git to Undo Temporary Changes
-----------------------------------

If you've been following along these sections, then your Rails app will
be a Git repository. If so, you've made some changes in this section,
mainly just to the *app/views/public/index.html.erb* file. In any event,
lets ask Git what has changed.

    $ git status
    # On branch master
    # Changed but not updated:
    #   (use "git add <file>..." to update what will be committed)
    #   (use "git checkout -- <file>..." to discard changes in working directory)
    #
    # modified:   app/views/public/index.html.erb
    #
    no changes added to commit (use "git add" and/or "git commit -a")

Ah, so git know what files have changed. We can even get more detail:

    git diff
    diff --git a/app/views/public/index.html.erb b/app/views/public/index.html.erb
    index 44317c5..fd3af64 100644
    --- a/app/views/public/index.html.erb
    +++ b/app/views/public/index.html.erb
    @@ -1,4 +1,6 @@
    -<h1>Public#index</h1>
    -<p>Find me in app/views/public/index.html.erb</p>
    -
    -<p>Params : <%= @params %></p>
    +<ol>
    +  <% some_array = ["Billy", "Bobby", "Jimmy"] %>
    +  <% some_array.each do |name| %>
    +    <li> <%= name %> </li>
    +  <% end %>
    +</ol>

Well, I'm not crazy about the Billy and Bobby stuff, so let's take the
opportunity to back out these changes. They haven't been staged or
committed yet, so it should be easy. In fact, *git status* told us what
to do, it said 

    #   (use "git checkout -- <file>..." to discard changes in working directory)

Let's follow its instructions:

    $ git checkout -- app/views/public/index.html.erb

Git is silent, again.

    $ git status
    # On branch master
    nothing to commit (working directory clean)

Aha! The change has been reverted. Let's see what the file looks like:

    $ cat app/views/public/index.html.erb 
    <h1>Public#index</h1>
    <p>Find me in app/views/public/index.html.erb</p>

    <p>Params : <%= @params %></p>

*cat* is a handy Unix tool that just prints the contents of a file to
the screen. Here we can use it to see what's in a file without having to
open it up in an editor. Here we see the file is back to its old self
without any of the Billy and Bobby nonsense.

See you in the next section!



