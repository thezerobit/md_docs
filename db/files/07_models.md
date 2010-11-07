Rails Models
------------


A Rails model generally represents a data source and/or business logic.
We are going to take a little closer look at working with models that
use the database. We'll start by making a model to represent products to
be sold on our web app using the scaffold generating abilities of Rails.

    $ rails generate scaffold Product name:string description:string category:references

This is very similar to the scaffold we created earlier, except that
there is an additional field that refers to a category. This means that
each product has an associated category. There is a many-to-one
relationship. Many products may refer to the same category. Here is the
migration that was created:

    class CreateProducts < ActiveRecord::Migration
      def self.up                  
        create_table :products do |t|
          t.string :name           
          t.string :description    
          t.references :category_id

          t.timestamps             
        end                        
      end

      def self.down                
        drop_table :products
      end
    end

As before, we need to add the table to the database, so let's run the
migration:

    $ rake db:migrate
    (in /home/steve/rails_stuff/store_app)
    ==  CreateProducts: migrating =================================================
    -- create_table(:products)
      -> 0.0017s
    ==  CreateProducts: migrated (0.0018s) ========================================

Also, always check-in changes to git:

    $ git add .
    $ git commit -m "Added Product scaffolding"

The scaffolding is in place for us to create some products. You can do
that by going to
[localhost:3000/products](http://localhost:3000/products). However,
you'll find that creating a category doesn't quite work. Something to do
with the Category selection, which is just a text input box. What we'd
really like on the form at 
[localhost:3000/products/new](http://localhost:3000/products/new) is a
drop-down that will allow us to select the proper category for the
products we create. The form for editing or creating products is a
partial template used by both the *new* and *edit* pages. It is
*app/views/products/_form.html.erb*. The important part of this file is
here:

    <div class="field">
      <%= f.label :category %><br />
      <%= f.text_field :category %>
    </div>

What we need instead of a text field is a *select box*. Fortunately, Rails
comes with an large number of helpers, which are basically functions you
can use in the views to easily create common HTML widgets. The helper we
should use is *collection_select*. Change this part of the form to look
like this:

    <div class="field">
      <%= f.label :category_id %><br />
      <%= collection_select(:product, :category_id, Category.all, :id, :name) %>
    </div>

Notice how the field now refers to the *category_id* instead of the
category. The helper takes a number of parameters. You can learn more
about this helper and others
[here](http://guides.rubyonrails.org/form_helpers.html#select-boxes-for-dealing-with-models)
and
[here](http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-collection_select).

Assuming that you've already created some categories, you should be able
to use the products controller at
[localhost:3000/products](http://localhost:3000/products) to create some
products that are associated with categories.

In the product listing and display, the associated categories will be
listed with wierd looking names, like "#<Category:0x00000002697998>".
By default, Ruby will produce a string representation like this for most
classes. We can add a better one by editing the Category class
(*app/models/category.rb*) to have a *to_s* method like this:

    class Category < ActiveRecord::Base
      def to_s
        name
      end
    end

That basically tells Ruby to use the name field of the object as its
default string representation.

Displaying Associated Products on the public Category Pages
-----------------------------------------------------------

Our public category pages should have a listing of all products
associated with that category. This is easy enough to accomplish with
Rails. Right now, on a given Product object, we can get the *category*
attribute which will be the actual Category object from the database
that the product is associated with. This happens because of the
*:belongs_to* declaration in the Product class
(*app/models/product.rb*):

    class Product < ActiveRecord::Base
      belongs_to :category
    end

There is also a way to get a list of associated products from a
particular category object by adding a *:has_many* declaration to the
Category class (*app/models/category.rb*):

    class Category < ActiveRecord::Base
      has_many :products

      def to_s            
        name
      end                          
    end

We can now edit the public/cat view (*app/views/public/cat.html.erb*) to
list the names and descriptions of all the associated products:

    <div class="category_name">
      <%= @category.name %>
    </div>
    <div class="category_description">
      <%= @category.description %>
    </div>

    <ul>
      <% @category.products.each do |product| %>
        <li>
          <em><%= product.name %></em><br />
          <%= product.description %>
        </li>
      <% end %>
    </ul>

This code just generates a very plain unordered list of products. It's
up to you to add style. Don't forget to check in your changes to git.




