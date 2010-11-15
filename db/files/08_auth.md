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
          to_update['password'] = (Digest::SHA2.new << to_update['password']).to_s
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

To handle logging in and out of the session, let's create an AdminAuth
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
            :password => (Digest::SHA2.new << params['password']).to_s)
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

Now, you should be able to try out the login page at
[localhost:3000/admin_auth/login](http://localhost:3000/admin_auth/login).

Protect Admin Pages
-------------------

OK, so now you want to keep non-admins out of the admin pages. Let's
create a private method on the Application Controller
(*app/controllers/application_controller.rb*):

    class ApplicationController < ActionController::Base
      protect_from_forgery

      private

      def check_admin
        if session.has_key?(:admin_id)
          true
        else
          render :nothing => true
        end
      end
    end

We'll use this as a *before&#95;filter* on any controllers we only want
admins to have access to:

*app/controllers/admins_controller.rb*:

    class AdminsController < ApplicationController
      before_filter :check_admin

*app/controllers/products_controller.rb*:

    class ProductsController < ApplicationController
      before_filter :check_admin

*app/controllers/categories_controller.rb*:

    class CategoriesController < ApplicationController
      before_filter :check_admin

Now those pages will just render blank and do nothing unless the person
accessing them is logged in as an admin. We could also redirect directly
to the admin login page, but as an added measure of security, you don't
want to advertise the admin login page.

Last, but not least, you'll want to change the *logout* view
*app/views/admin_auth/logout.html.erb* to something informing the admin
that they are logged out.

You should get blank pages for the Products, Admins, and Categories
Controllers unless you are logged in as an admin. Now, the casual
visitor to your site will not have access to view and change the
contents of your site.

Changing Password From Console
------------------------------

Now, of course the Admins Controller is what you use to add and change
admin logins, so if you forget your password, you will not be able to
log in as an admin to change it. So you're stuck. Well, you can always
manipulate the database entries directly from the interactive console.
Rails allows you to fire up the Ruby interpreter in interactive mode
with all the access to the Rails systems you would have in normal code.
You can get there with this command:

    $ rails console

Now, once you are in the console, you can manipulate objects in the
database and save them.

    $ rails console
    Loading development environment (Rails 3.0.0)
    ruby-1.9.2-p0 > Admin.all
     => [#<Admin id: 2, name: "Steve", email: "myemail@email.com", password: "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca120...", created_at: "2010-11-15 01:13:42", updated_at: "2010-11-15 15:27:13">] 
    ruby-1.9.2-p0 > me = Admin.find(2)
     => #<Admin id: 2, name: "Steve", email: "myemail@email.com", password: "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca120...", created_at: "2010-11-15 01:13:42", updated_at: "2010-11-15 15:27:13"> 
    ruby-1.9.2-p0 > me.password = (Digest::SHA2.new << 'secretsauce').to_s
     => "544b9218c110325b61a91ad0cd60cd1bf9227ce789acb5b93b8debbd512684f4" 
    ruby-1.9.2-p0 > me.save
     => true 
    ruby-1.9.2-p0 > Admin.all
     => [#<Admin id: 2, name: "Steve", email: "myemail@email.com", password: "544b9218c110325b61a91ad0cd60cd1bf9227ce789acb5b93b8...", created_at: "2010-11-15 01:13:42", updated_at: "2010-11-15 16:00:12">] 
    ruby-1.9.2-p0 > 

After resetting my password in the console to 'secretsauce', I can now
log in to the admin with that password. You quit the interactive console
with Ctrl-D.

