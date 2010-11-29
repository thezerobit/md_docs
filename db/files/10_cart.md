Adding Price to Product
-----------------------

In order to create something of a Shopping Cart on your page, your
products will need a price. There are differing ways to store the price
of a product. Some people prefer to store the price as a floating point
number, which is to say a number with a fractional component. However,
since that is less the perfectly precise, depending on the calculations
involved, you can make your prices a bit more reliable by storing the
price as an integer value representing the hundredths of whichever
monetary unit you are using. If you are using US dollars, then you would
effectively be storing the price as a number of cents. It's a matter of
preference, but I prefer to store prices as integers representing cents,
so that's what I'll do with this example. 

We need to create an integer field on the product model. The way to do
this is with a migration:

    $ rails generate migration AddPriceToProduct price:integer
          invoke  active_record
          create    db/migrate/20101129040519_add_price_to_product.rb

Run the migration:

    $ rake db:migrate
    (in /home/steve/rails_stuff/store_app)
    ==  AddPriceToProduct: migrating
    ==============================================
    -- add_column(:products, :price, :integer)
       -> 0.0011s
       ==  AddPriceToProduct: migrated (0.0011s)
       =====================================

Add the price field to the product form
(*app/view/products/_form.html.erb*):

    <div class="field">
      <%= f.label :price %><br />
      <%= f.text_field :price %>
    </div>

You should use the admin interface to add prices to your products,
remembering that you are adding the price in cents, not dollars.

Add a method to the Product class to get the price, which will return 0
if price is not set yet (*app/models/product.rb*):

    class Product < ActiveRecord::Base
      belongs_to :category

      def get_image
        return image || 'default.jpg'   
      end

      def get_price
        return price || 0
      end
    end 

The price should be visible in the listings for the admin pages. These
lines should be added to the *app/view/products/index.html.erb* page:

With the other headers (th):

    <th>Price</th>

With the other row elements (td):

    <td>$<%= "%.2f" % (product.get_price / 100.0) %></td>

And to the *app/view/products/show.html.erb*:

    <p>
      <b>Price:</b>
      $<%= "%.2f" % (@product.get_price / 100.0) %>
    </p>


Adding a Shopping Cart to the Session
-------------------------------------

The *session* is a place to data unique to each user on your site that
is persistent between page loads. It is created when someone goes to
your page from a unique browser/computer and is managed with browser cookies
automatically.

It will be handy to have in the public controller, so let's add a method
that loads it in the public controller, creating it if it doesn't exist.
Right now, it will just be an Array. Here's what the
*app/controllers/public_controller.rb* looks like with the *load_cart* method:

    class PublicController < ApplicationController
      before_filter :load_categories, :load_cart
    
      def index
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
    
      def load_cart
        if not session.has_key? :cart
          session[:cart] = Array.new
        end
        @cart = session[:cart]
      end
    end

Now that we have the *@cart* available to us in the view, we can add
something to the public layout view that shows how many items we have in
our cart on each public page that links to our not-yet-created shopping
cart page. The line is this:

    <a href="/cart">Shopping Cart (<%= @cart.length %>)</a>

I put it at the end of the *category_nav* div in
*app/views/layouts/public.html.erb*:

    <div id="category_nav">
      <% @categories.each do |cat| %>
        <a href="/cat/<%= cat.id %>">
          <%= cat.name %>
        </a> .
      <% end %>
      <a href="/cart">Shopping Cart (<%= @cart.length %>)</a>
    </div>

Create Way for Customer to Add Items to Cart
--------------------------------------------

First let's create a little form consisting of a single button for each
product on the public category page (*app/views/public/cat.html.erb*)
add this inside the "li" tag (so it is unique to each product):

      <%= form_tag("/add_to_cart", :method => "post") do %>
        <%= label_tag(:num, "Number to add to cart:") %>
        <%= text_field_tag(:num, 1) %>
        <%= hidden_field_tag(:product_id, product.id) %>
        <%= submit_tag("Add To Cart") %>
      <% end %>

Add a route to the *config/routes.rb* allowing only post requests to the
"/add_to_cart" url:

  match 'add_to_cart' => 'public#add_to_cart', :via => :post

Add an *add_to_cart* action to public controller that adds the product
and number to the session array as a Hash
(*app/controllers/public_controller.rb*):

    def add_to_cart
      if params[:num] and params[:product_id]
        matching = Product.where(:id => params[:product_id])
        if matching.length > 0
          @cart.push({ :product_id => params[:product_id], :num => params[:num].to_i})
        end
      end
      redirect_to "/cart"
    end

That action needs no view since it automatically forwards the user to
the cart page which we haven't created yet.

Create "cart" Page in Public Controller
---------------------------------------

We've already added a link to the cart page from the public layout view.
First we need to create a route in *config/routes.rb*:

    match 'cart' => 'public#cart'

Now we need to create a *cart* action in the public controller
(*app/controllers/public_controller.rb*) before the private declaration.
It will be empty since we are already loading the *@cart* variable for
each page of the public controller automatically:

    def cart
    end

And of course a view file for the action
(*app/views/public/cart.html.erb*):

    <p>Shopping Cart</p>
    <table>
      <tr>
        <th>Product Name</th>
        <th>Quantity</th>
        <th>Price per unit</th>
        <th>Total Price</th>
      </tr>
        <% total_price = 0 %>
        <% @cart.each do |cart_item| %>
          <tr>
            <% product = Product.find(cart_item[:product_id]) %>
            <% total_price += product.get_price * cart_item[:num] %>
            <td><%= product.name %></td>
            <td><%= cart_item[:num] %></td>
            <td>$<%= "%.2f" % (product.get_price / 100.0) %></td>
            <td>$<%= "%.2f" % (cart_item[:num] * product.get_price / 100.0) %></td>
          </tr>
        <% end %>
        <tr>  
          <td></td>
          <td></td>
          <td><strong>Grand Total:</strong></td>
          <td>$<%= "%.2f" % (total_price / 100.0) %></td>
        </tr>
    </table>


An Exercise for the Reader
--------------------------

The code in this section creates a very simplistic Shopping Cart. It is
missing a number of key features which should be simple enough to add
given what we've covered so far.

 * Editing the quantities or removing items from the cart.
 * Detecting when a customer is adding an item already in the cart and
 updating the number instead of adding a new entry to the cart.

