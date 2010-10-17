Rails Scaffold
--------------

Rails comes with the ability to quickly create working data models. For
production applications, it might not fit exactly what you need, but it
makes for an excellent learning tool.

If we want to add a "Category" model with two fields, a name and a
description, we could do something like this (like all "rails" script
commands, this should be run in the project folder):

    $ rails generate scaffold Category name:string description:string

This is the output:

          invoke  active_record
          create    db/migrate/20101012032533_create_categories.rb
          create    app/models/category.rb
          invoke    test_unit
          create      test/unit/category_test.rb
          create      test/fixtures/categories.yml
          route  resources :categories
          invoke  scaffold_controller
          create    app/controllers/categories_controller.rb
          invoke    erb
          create      app/views/categories
          create      app/views/categories/index.html.erb
          create      app/views/categories/edit.html.erb
          create      app/views/categories/show.html.erb
          create      app/views/categories/new.html.erb
          create      app/views/categories/_form.html.erb
          invoke    test_unit
          create      test/functional/categories_controller_test.rb
          invoke    helper
          create      app/helpers/categories_helper.rb
          invoke      test_unit
          create        test/unit/helpers/categories_helper_test.rb
          invoke  stylesheets
          create    public/stylesheets/scaffold.css

As you can see, rails has done quite a bit of work. First lets look at
the file it made in the *db/migrate* folder. The name of the file starts
with a timestamp, which helps guarantee it's uniqueness. It looks like
this:

    class CreateCategories < ActiveRecord::Migration
      def self.up
        create_table :categories do |t|
          t.string :name
          t.string :description

          t.timestamps
        end
      end

      def self.down
        drop_table :categories
      end
    end

This file represents a database migration, which is another word for a
database change. The timestamp at the beginning of the file name ensures
that the database migrations are always applied in the same order. When
you run the command *rake db:migrate* it will apply the *up* method of
this migration.

    $ rake db:migrate
    (in /home/steve/rails_stuff/store_app)
    ==  CreateCategories: migrating ===============================================
    -- create_table(:categories)
      -> 0.0038s
    ==  CreateCategories: migrated (0.0040s) ======================================

After you run the *rake db:migrate* command, you'll notice that there is
a file *db/schema.rb* that has been created. That file serves as a
description of the database for the application. You shouldn't edit it,
but just add migrations. That file should now look something like this:

    # This file is auto-generated from the current state of the database. Instead
    # of editing this file, please use the migrations feature of Active Record to
    # incrementally modify your database, and then regenerate this schema definition.
    #
    # Note that this schema.rb definition is the authoritative source for your
    # database schema. If you need to create the application database on another
    # system, you should be using db:schema:load, not running all the migrations
    # from scratch. The latter is a flawed and unsustainable approach (the more migrations
    # you'll amass, the slower it'll run and the greater likelihood for issues).
    #
    # It's strongly recommended to check this file into your version control system.

    ActiveRecord::Schema.define(:version => 20101012032533) do

      create_table "categories", :force => true do |t|
        t.string   "name"
        t.string   "description"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

    end

It's got some good advice in there. Let's check in the recent changes to
your git repo.

    $ git add .
    $ git commit -m "Category scaffolding"
    [master 5cdcf4a] Category scaffolding
     16 files changed, 327 insertions(+), 0 deletions(-)
     create mode 100644 app/controllers/categories_controller.rb
     ...

When we ran the command to generate the scaffolding, rails added the
*t.timestamps* declaration in the database migration. That line is
responsible for the addition of the *created_at* and *updated_at*
columns in the *categories* table. The other two columns, *name* and
*description* were the ones we specified.

The script also added a single line to the *config/routes.rb* file:

    resources :categories

This line basically defines a standard set of routes under a specific
controller to manage objects in a particular model, in this case the
resource is *categories*.

You can see an overview of all the routes in the
*app/controllers/categories_controller.rb* file.

Index / Listing
---------------

The first endpoint defined in the controller is the *index* which is the
default action for the controller, so requests to
[localhost:3000/categories](http://localhost:3000/categories) get routed
to this action. It looks like this (in controller file):

      # GET /categories
      # GET /categories.xml
      def index
        @categories = Category.all

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml => @categories }
        end
      end

The interesting part is this line:

    @categories = Category.all

This basically loads all records from the *categories* table in the
database. This works because of a couple other files. As part of the
scaffolding, the Category class was created in the file
*app/models/category.rb*. It doesn't appear to do much, either:

    class Category < ActiveRecord::Base
    end

The ActiveRecord::Base class contains quite a bit of functionality. It
will find the table and its columns automatically and load each row of
the table as a single object. The *all* method effectively loads them
all into a sequence.

The *index* action of the *categories* controller looks for a template
file with the name *app/views/categories/index.html.erb* which the
scaffold generator was nice enough to create:

    <h1>Listing categories</h1>

    <table>
      <tr>
        <th>Name</th>
        <th>Description</th>
        <th></th>
        <th></th>
        <th></th>
      </tr>

    <% @categories.each do |category| %>
      <tr>
        <td><%= category.name %></td>
        <td><%= category.description %></td>
        <td><%= link_to 'Show', category %></td>
        <td><%= link_to 'Edit', edit_category_path(category) %></td>
        <td><%= link_to 'Destroy', category, :confirm => 'Are you sure?', :method => :delete %></td>
      </tr>
    <% end %>
    </table>

    <br />

    <%= link_to 'New Category', new_category_path %>

Until you've created some categories, this page will contain an empty
list. Fortunately, the scaffolding creates all you need to create,
modify, and delete individual records. The last line of the
*index.html.erb* template creates a link to the *new* action of the
*categories* controller. The *new* action does not actually create new
records in the database, it merely renders a form that allows the user
to enter details about the object they would like to create. Here is the
*new* action in the controller:

    # GET /categories/new
    # GET /categories/new.xml
    def new
      @category = Category.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @category }
      end
    end

Hm, it sure looks like it is creating a new Category object. It is, but
it isn't saving it to the database, just creating one in memory to be
used by the view. The view template
(*app/views/categories/new.html.erb*) is this:

    <h1>New category</h1>

    <%= render 'form' %>

    <%= link_to 'Back', categories_path %>

That strange line in the middle is actually referring to a partial
template called *form* which is in a different file,
*app/views/categories/_form.html.erb*. The reason that the form is
broken out into a separate file is because it is shared by the *edit*
template which is used to edit existing objects. Here is the
partial template:

    <%= form_for(@category) do |f| %>
      <% if @category.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(@category.errors.count, "error") %> prohibited this category from being saved:</h2>

          <ul>
          <% @category.errors.full_messages.each do |msg| %>
            <li><%= msg %></li>
          <% end %>
          </ul>
        </div>
      <% end %>

      <div class="field">
        <%= f.label :name %><br />
        <%= f.text_field :name %>
      </div>
      <div class="field">
        <%= f.label :description %><br />
        <%= f.text_field :description %>
      </div>
      <div class="actions">
        <%= f.submit %>
      </div>
    <% end %>

This form is packed with a lot of important bits and warrants further
study. What is important to note is that the *form_for* helper generates
a form that posts to the */categories* just like the index action, but
if you look at the generated form code, the form tag contains an
attribute *method="post"*. This means that when the form is submitted
to the server, it is a POST request. When you merely navigate to a web
address in your browser, you send a GET request. Rails allows different
request types to be handled differently. That form post to
*/categories* is handled by the *create* method. Here is the *create*
controller action:

    # POST /categories
    # POST /categories.xml
    def create
      @category = Category.new(params[:category])

      respond_to do |format|
        if @category.save
          format.html { redirect_to(@category, :notice => 'Category was successfully created.') }
          format.xml  { render :xml => @category, :status => :created, :location => @category }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
        end
      end
    end

As you see, the comments at the beginning show the HTTP method (POST in
this case) and an example route to get to this action. This is the
action that handles the form submission from the *new* page. Again, it
creates a Category object in memory, but populates it with the form data
that was posted (the contents of *params[:category]*). The
*@category.save* bit attempts to create a record in the database, if it
is successful, it redirects to the the page representing that object. If
it fails for some reason, it redisplays the form. That's a bit of a
high-level explanation, but if you look at the code you might be able to
get an idea of how that works.

Right now, just try the controller out. With the development server
running (*rails server*), navigate to [localhost:3000/categories](http://localhost:3000/categories)
and click on the "New Category" link at the bottom of the page. That
gives you a form to create a category. Fill in a name and description
and then click the "Create Category" button. If all goes well, that will
create a category and take you to the page [localhost:3000/categories/1](http://localhost:3000/categories/1)
which shows the details for that particular category. From there you can
click the "Back" link which will take you back to the listing of all
categories. Follow all the links, add and delete more categories, and
edit existing categories. All of those pages, forms and database actions
are mediated by the scaffolding and pass through the *categories*
controller.

The ability for Rails to generate this type of scaffolding exists mainly
as a way to teach good habits in Rails programming. It is quite handy
for beginners or even veteran Rails programmers to create usable models
quickly, but usually it needs quite a bit of tweaking to fit the exact
needs of a given web application.


