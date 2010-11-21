Upload and Associate Images with Products
-----------------------------------------

In this section we'll add the capability to the admin interface to
upload and associated images with products. 

Create Folder for Images
------------------------

First of all, we have to decide where to put the images. We could create
a folder inside the public folder to store the images. Since Git will
not save empty folders, let's add a file in the folder so it can be
kept.

    $ mkdir public/images/products
    $ touch public/images/produtcts/.keep_folder

The *touch* command just creates an empty file.

Use Migration to Add Image Field to Products
--------------------------------------------

We want the product to have an image field which will be the file name
of it's product image. To add a field, we need to create a migration.

    $ rails generate migration AddImageToProduct image:string
          invoke  active_record
          create    db/migrate/20101121210950_add_image_to_product.rb


Add the field by running the migration:

    $ rake db:migrate
    (in /home/steve/rails_stuff/store_app)
    ==  AddImageToProduct: migrating ==============================================
    -- add_column(:products, :image, :string)
       -> 0.0212s
    ==  AddImageToProduct: migrated (0.0213s) =====================================

Add Image Upload to Product Form
--------------------------------

The way we'll handle adding the image to the product, is an optional
file upload on the product edit/create form. We'll have to edit the
form tag to accept multi-part encoding. The first line of
*app/views/products/_form.html.erb* should be changed from this:

    <%= form_for(@product) do |f| %>

to this:

    <%= form_for @product, :html => {:multipart => true} do |f| %>

There needs to be a file upload section on the form. Let's make it like
this:

    <div class="field">
      <%= label :image, 'Image' %><br />
      <%= file_field_tag 'image' %>
    </div>

Handling Image Upload in Controller
-----------------------------------

So now we'll have to deal with image uploads in the Products Controller
(*app/controllers/products_controller.rb*) in the *create* and *update*
actions. Uploads appear as *IO* objects which may be *read*. We can use
this object to write the images directly into the folder we created.
We can create a private method that will insert the image into the
params if it is uploaded. It should be created at the end of the class
as a private method.

      private

      def handle_image_upload(params)
        if params[:image]
          uploaded_io = params[:image]
          File.open(Rails.root.join('public', 'images','products',.
              uploaded_io.original_filename), 'wb') do |file|
            file.write(uploaded_io.read)
          end
          params[:product]['image'] = uploaded_io.original_filename
        end
      end

    end # end of Products Controller

Add a call to this method at the beginning of the *create* and *update*
actions:

    def create
      handle_image_upload(params)
      # ...

    def update
      handle_image_upload(params)
      # ...

Add Product Images to Views
---------------------------

The most likely place to add the product image would be the *cat* action
of the *public* controller. This is what you would add to show the
product image in the view (*app/views/public/cat.html.erb*):

    <%= image_tag "products/" + product.image %>

If you want to see the image in the products controller admin, you could
add the following to the *app/views/products/show.html.erb*:

    <p>
      <b>Image:</b>
      <%= image_tag "products/" + @product.image %>
    </p>


Adding jpg files to .gitignore
------------------------------

You probably don't want the file uploads to be added to the git
repository, so you can add this line to *.gitignore*, for example,
ignore all *jpg* files in the *public/images/products* folder:

    public/images/products/*.jpg


