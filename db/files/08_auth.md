Rails Authentication
--------------------

There is no built in authentication framework in Rails, although several
modules do exist which provide a lot of the pieces necessary for robust
user and login management. What our application needs right now is
something simple to keep random visitors out of the non-public
controllers. Rails makes it simple enough to roll our own authentication
system for administrators.

Create Admin Table and Scaffolding
----------------------------------

First we need to create a database table to hold admin info:

    $ rails generate scaffold Admin name:string email:string password:string
          invoke  active_record
          create    db/migrate/20101115005951_create_admins.rb
          create    app/models/admin.rb
          invoke    test_unit
          create      test/unit/admin_test.rb
          create      test/fixtures/admins.yml
           route  resources :admins
          invoke  scaffold_controller
          create    app/controllers/admins_controller.rb
          invoke    erb
          create      app/views/admins
          create      app/views/admins/index.html.erb
          create      app/views/admins/edit.html.erb
          create      app/views/admins/show.html.erb
          create      app/views/admins/new.html.erb
          create      app/views/admins/_form.html.erb
          invoke    test_unit
          create      test/functional/admins_controller_test.rb
          invoke    helper
          create      app/helpers/admins_helper.rb
          invoke      test_unit
          create        test/unit/helpers/admins_helper_test.rb
          invoke  stylesheets
       identical    public/stylesheets/scaffold.css

Migrate the database to add the table:

    $ rake db:migrate
    (in /home/steve/rails_stuff/store_app)
    ==  CreateAdmins: migrating
    ===================================================
    -- create_table(:admins)
       -> 0.0020s
       ==  CreateAdmins: migrated (0.0021s)
       ==========================================

Store the Hash of a Password
----------------------------

Now before we go in and add an administrative user, we don't want to
store passwords directly as plain text. You may have noticed I added the
password field as an integer. Instead of plain text, we'll store the
hash of the password string. Ruby strings have a *hash* method that
generates an integer from a string. Hash values bear no resemblance to
the string they come from, but are consistent. When a person tries to
log in as an administrator, we only need to compare the SHA256 hash of
the password they enter to the hash value stored in the database. 

To use the SHA256 hashing algorithm, you need to add the following line
to *config/application.rb*:

    require 'digest/sha2'

We need to edit the *app/controllers/admins_controller* to change the
password to a hash before storing it in the database. You'll need to
edit the *create* and *update* actions like this:

    # POST /admins
    # POST /admins.xml
    def create
      # @admin = Admin.new(params[:admin])
      to_create = params[:admin].clone
      to_create['password'] = (Digest::SHA2.new << to_create['password']).to_s
      @admin = Admin.new(to_create)

      respond_to do |format|
        if @admin.save
          format.html { redirect_to(@admin, :notice => 'Admin was successfully created.') }
          format.xml  { render :xml => @admin, :status => :created, :location => @admin }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /admins/1
    # PUT /admins/1.xml
    def update
      @admin = Admin.find(params[:id])

      respond_to do |format|
        # if @admin.update_attributes(params[:admin])
        to_update = params[:admin].clone
        to_update['password'] = (Digest::SHA2.new << to_update['password']).to_s
        if @admin.update_attributes(to_update)
          format.html { redirect_to(@admin, :notice => 'Admin was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
        end
      end
    end

Now, we need the password input fields on the admin controller's forms
to be true password inputs. Edit *app/views/admins/_form.html.erb* and
change this part:

    <div class="field">
      <%= f.label :password %><br />
      <%= f.text_field :password %>
    </div>

To look like this:

    <div class="field">
      <%= f.label :password %><br />
      <%= password_field(:admin, :password) %>
    </div>

One more problem with the admin scaffolding is that the hash of the
password gets loaded into the password field when you go to edit the
details of an admin. One way to get around this, is to set the password
field of the @admin object to an empty string in the *edit* action and
only update the password when something other than an empty string is
submitted. To do the first, we alter the *edit* action in the
*app/controllers/admins_controller.rb* file to look like this:

    # GET /admins/1/edit         
    def edit 
      @admin = Admin.find(params[:id])
      @admin.password = ''
    end

And to get the *update* action to only change the password when
something is entered into the password field, we should change the
*update* action to this:

    # PUT /admins/1
    # PUT /admins/1.xml
    def update
      @admin = Admin.find(params[:id])

      respond_to do |format|
        to_update = params[:admin].clone
        if to_update['password'] != ''
          to_update['password'] = to_update['pasword'].hash # set password to hashed password
        else
          to_update.delete('password') # remove password from update params
        end
        if @admin.update_attributes(to_update)
          format.html { redirect_to(@admin, :notice => 'Admin was successfully updated.') }
          format.xml  { head :ok }
        else
          @admin.password = '' # also set password empty on error
          format.html { render :action => "edit" }
          format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
        end
      end
    end

Don't Display Password Hash
---------------------------

To put the final touches on the admin controller, change the views to
not show the password hash either on the *show* or *index* listings.
Change this section in the *app/views/admins/show.html.erb*:

    <p> 
      <b>Password:</b>
      <%= @admin.password %>       
    </p>

To look like this:

    <p>
      <b>Password:</b>
      ******
    </p>

And change this line in *app/views/admins/index.html.erb*:

    <td><%= admin.password %></td>

To look like this:

    <td>******</td>

Now, go to [localhost:3000/admins](http://localhost:3000/admins) and
create an admin account to use. Also check in your changes to git.

Put Session Data into the Database
----------------------------------

The session is a wonderful thing. It is a place to store data for a
particular browser session. This is particularly handy for handling
storing if an admin is logged in or not. The session is a
[Hash](http://www.ruby-doc.org/core/classes/Hash.html), so it can store
any key / value pairs you'd like. By default, Rails uses cookies to
store session data which is very limited and not particularly secure.
The first thing to do is switch session storage to the database.

Edit the *config/initializers/session&#95;store.rb* to look like this:

    # Be sure to restart your server when you modify this file.

    # StoreApp::Application.config.session_store :cookie_store, :key => '_store_app_session'

    # Use the database for sessions instead of the cookie-based default,
    # which shouldn't be used to store highly confidential information
    # (create the session table with "rake db:sessions:create")
    StoreApp::Application.config.session_store :active_record_store

Then follow the advice in that file:

    $ rake db:sessions:create
    (in /home/steve/rails_stuff/store_app)
          invoke  active_record
          create    db/migrate/20101115041003_add_sessions_table.rb

Run the migration which adds the sessions table to your database:

    $ rake db:migrate
    (in /home/steve/rails_stuff/store_app)
    ==  AddSessionsTable: migrating ===============================================
    -- create_table(:sessions)
       -> 0.0018s
    -- add_index(:sessions, :session_id)
       -> 0.0006s
    -- add_index(:sessions, :updated_at)
       -> 0.0008s
    ==  AddSessionsTable: migrated (0.0033s) ======================================

You should restart your server if it is running in a different terminal.


Keeping the Admin Authentication in the Session
-----------------------------------------------

To handle logging and out of the session, let's create an AdminAuth
controller with *login* and *logout* actions:

    $ rails generate controller AdminAuth login logout
          create  app/controllers/admin_auth_controller.rb
           route  get "admin_auth/logout"
           route  get "admin_auth/login"
          invoke  erb
          create    app/views/admin_auth
          create    app/views/admin_auth/login.html.erb
          create    app/views/admin_auth/logout.html.erb
          invoke  test_unit
          create    test/functional/admin_auth_controller_test.rb
          invoke  helper
          create    app/helpers/admin_auth_helper.rb
          invoke    test_unit
          create      test/unit/helpers/admin_auth_helper_test.rb

Edit the login page to show a name and password field and any notices we
might want to give the user (*app/views/admin_auth/login.html.erb*):

    <% if flash[:notice] %>
      <p class="notice"><%= flash[:notice] %></p>
    <% end %>
    <%= form_tag do %>
      <%= label_tag(:name, "Name:") %>
      <%= text_field_tag(:name) %>
      <%= label_tag(:password, "Password:") %>
      <%= password_field_tag(:password) %>
      <%= submit_tag "Login" %>
    <% end %>

Now let's edit the login controller action to set the admin_id in the
session if someone enters a valid Admin name and password. While we're
at it, we can edit the logout controller to remove the admin_id
(*app/controllers/admin_auth_controller.rb*):

    class AdminAuthController < ApplicationController
      def login
        if params[:name]
          matches = Admin.where(:name => params[:name], 
                                :password => params[:password].hash)
          if matches.length > 0
            admin = matches[0]     
            session[:admin_id] = admin.id   
            flash[:notice] = "You have logged in as " + admin.name
          else
            flash[:notice] = "You failed to log in"
          end
        end
      end

      def logout
        session.delete(:admin_id)  
      end

    end 

By default, Rails will only recognize GET requests to the *login*
action, so to get it to respond to the POST add the following line to
*config/routes.rb*:

    post "admin_auth/login"








