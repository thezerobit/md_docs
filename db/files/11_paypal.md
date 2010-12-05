Shopping Cart Payments through Paypal's Website Payments Standard
-----------------------------------------------------------------

The simplest way to allow payments on your store application is to
provide a button to allow visitors to pay for the contents of the
shopping cart through a payment gateway. Paypal makes it easy to do this
with their Website Payments Standard feature.

Set up Paypal Sandbox
---------------------

In order to be able to test your site against Paypal's service, they
provide a sandbox mode through which you can process payments using fake
accounts where no real money changes hands. This is for development and
testing, when you go live, you just have to change a couple things to
point everything at your normal account and Paypal's production payment
servers.

First, go to developer.paypal.com in your web browser and log in with
your paypal account or create a new one if you don't already have one.
You'll want to create a test seller account and a test buyer account.

Create Checkout Link and Page
-----------------------------

Add a link to a checkout page on the shopping cart page
(*app/views/public/cart.html.erb*):

    <%= link_to "Checkout", '/checkout' %>

Create a checkout route in *config/routes.rb*:

    match 'checkout' => 'public#checkout'

Create a checkout action in the *app/controllers/public_controller.rb*
file, that generates a link for Paypal purchase. Make sure you use the
email address for your fake sandbox seller account.

    def checkout
      paypal_params = {
        :business => 'fake_seller_account@whoopdiedoo.com',
        :cmd => '_cart',
        :upload => 1,
        :return => '/success',
      }
      @cart.each_with_index do |cart_item, index|
        real_index = index + 1
        product = Product.find(cart_item[:product_id])
        paypal_params.merge!({
          "amount_#{real_index}" => "%.2f" % (product.get_price / 100.0),
          "item_name_#{real_index}" => product.name,
          "item_number_#{real_index}" => product.id,
          "quantity_#{real_index}" => cart_item[:num],
        })
      end
      @paypal_link = "https://www.sandbox.paypal.com/cgi-bin/webscr?"
      @paypal_link += paypal_params.to_query
    end

Make a view file for the checkout action with a link to pay at the end.
This is very similar to the page from the last chapter. You'll want to
keep it separate so you can allow the customer to edit the cart contents
on the cart page while the checkout page will remain static.

    <p>Shopping Cart Checkout</p>
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
    <%= link_to "Pay With Paypal", @paypal_link %>

Create a Landing Page for Completed Transactions
------------------------------------------------

We told Paypal to return the customer to the "/success" page when they
are done. Create a route in *config/routes.rb*:

    match 'success' => 'public#success'

Create an action in the public controller to empty the contents of the
shopping cart. (*app/controllers/public_controller.rb*):

    def success
      session[:cart] = Array.new
    end

Create a view file for the success action
(*app/views/public/success.html.erb*):

    <p>Thank you for your purchase!</p>

Make Money
----------

That's it, your done. You'll want to test it out by making a purchase
with a test sandbox buyer account. To go live on the web for actual
purchases, change the email address to your actual paypal business
account email and change www.sandbox.paypal.com to www.paypal.com.
