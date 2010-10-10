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
array in a loop.

    <% some_array = ["Steve", "

