Getting Into Rails
------------------

Create rails project: store app.

    $ cd
    $ cd rails_stuff
    $ rails new store_app

Run bundle install

    $ cd store_app
    $ bundle install

Build default (empty) database:

    $ rake db:create

Set your Git username and email.

    $ git config --global user.name "Frank P. Jones"
    $ git config --global user.email "frankpjones@gmail.com"

Initialize local Git repository in project folder.

    $ git init .
    Initialize empty Git repository in /home/steve/rails_stuff/store_app/.git/

Add files to Git repository.

    $ git add .
    $ git commit -m "default rails setup"

Verify there is a Git repository and a single commit.

    $ git log
    commit df2d85be05b86746a6ae19254a7a9c942bf5a9e7
    Author: Frank P. Jones <frankpjones@gmail.com>
    Date:   Tue Sep 28 00:06:40 2010 -0700

        default rails setup

Another useful command is 'git status' which shows if there is anything
changed that may need to be committed.

    $ git status
    # On branch master
        nothing to commit (working directory clean)

Let's look at what we have:

    $ ls -l
    total 72
    drwxr-xr-x 7 steve steve 4096 2010-09-27 23:44 app
    drwxr-xr-x 5 steve steve 4096 2010-09-27 23:44 config
    -rw-r--r-- 1 steve steve  158 2010-09-27 23:44 config.ru
    drwxr-xr-x 2 steve steve 4096 2010-09-27 23:44 db
    drwxr-xr-x 2 steve steve 4096 2010-09-27 23:44 doc
    -rw-r--r-- 1 steve steve  665 2010-09-27 23:44 Gemfile
    -rw-r--r-- 1 steve steve 1634 2010-09-27 23:44 Gemfile.lock
    drwxr-xr-x 3 steve steve 4096 2010-09-27 23:44 lib
    drwxr-xr-x 2 steve steve 4096 2010-09-27 23:44 log
    drwxr-xr-x 5 steve steve 4096 2010-09-27 23:44 public
    -rw-r--r-- 1 steve steve  268 2010-09-27 23:44 Rakefile
    -rw-r--r-- 1 steve steve 9130 2010-09-27 23:44 README
    drwxr-xr-x 2 steve steve 4096 2010-09-27 23:44 script
    drwxr-xr-x 7 steve steve 4096 2010-09-27 23:44 test
    drwxr-xr-x 6 steve steve 4096 2010-09-27 23:44 tmp
    drwxr-xr-x 3 steve steve 4096 2010-09-27 23:44 vendor

One thing at a time. Let's look at the public folder:

    $ ls -l public
    total 36
    -rw-r--r-- 1 steve steve  728 2010-09-27 23:44 404.html
    -rw-r--r-- 1 steve steve  711 2010-09-27 23:44 422.html
    -rw-r--r-- 1 steve steve  728 2010-09-27 23:44 500.html
    -rw-r--r-- 1 steve steve    0 2010-09-27 23:44 favicon.ico
    drwxr-xr-x 2 steve steve 4096 2010-09-27 23:44 images
    -rw-r--r-- 1 steve steve 5780 2010-09-27 23:44 index.html
    drwxr-xr-x 2 steve steve 4096 2010-09-27 23:44 javascripts
    -rw-r--r-- 1 steve steve  204 2010-09-27 23:44 robots.txt
    drwxr-xr-x 2 steve steve 4096 2010-09-27 23:44 stylesheets

Right now, this is the entire web application. It's not much, just a
bunch of static files. It doesn't really accomplish anything. We can
look at it in action by running the server:

    $ rails server
    => Booting WEBrick
    => Rails 3.0.0 application starting in development on
    http://0.0.0.0:3000
    => Call with -d to detach
    => Ctrl-C to shutdown server
    [2010-09-28 00:21:14] INFO  WEBrick 1.3.1
    [2010-09-28 00:21:14] INFO  ruby 1.9.2 (2010-08-18) [x86_64-linux]
    [2010-09-28 00:21:14] INFO  WEBrick::HTTPServer#start: pid=7696
    port=3000

and navigating to [localhost:3000](http://localhost:3000/) in a web
browser.

You can kill the server with Ctrl-C:

    ^C[2010-09-28 00:22:41] INFO  going to shutdown ...
    [2010-09-28 00:22:41] INFO  WEBrick::HTTPServer#start done.
    Exiting
    $ 

The page you see is mostly the index.html file and some of the images in
the public folder. It is possible to build as much static content in the
public folder that you want, but if that's all we wanted to do we
wouldn't need Ruby or Rails. So let's get rid of the index.html file.

    $ git rm public/index.html
    rm 'public/index.html'

Using 'git rm' to remove files is a handy way of removing files and
telling Git that you meant to remove them at the same time. Run 'git
status' to see the change waiting to be committed.

    $ git status
    # On branch master
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #       deleted:    public/index.html
    #

You can commit the changes now, or roll them back, or wait and make more
changes before committing. Let's commit the change, for practice.

    $ git commit -m "Removed default index.html"
    [master 2d0f61c] Removed default index.html
    1 files changed, 0 insertions(+), 239 deletions(-)
      delete mode 100644 public/index.html

If we fire up the server and try to load the page again, we'll get an
error:

  **Routing Error**

  * No route matches "/"

Now we see that rails will tell us when something has gone wrong. Right
now we haven't defined any routes for our Rails application, so it
doesn't know what to do. First we need to know a bit about how the web
works.

A Bit About How the Web Works
-----------------------------

When you go to a web page, say *http://www.google.com/* in your web
browser. Your browser uses DNS to find an IP address associated with the
server name (www.google.com) and sends a request that (simplified) looks
like this:

    GET / HTTP/1.1
    Host www.google.com

The "/" part is the last part on the web address

    http://  www.google.com  /  <--- This part

So if you went to *http://www.google.com/reader* the request would look
like this:

    GET /reader HTTP/1.1
    Host www.google.com

The "/" request path is the absolute minimal request, if you just type
in *http://www.google.com* without the trailing slash, the browser will
add it. Every request path starts with the forward slash.

The web server (in our case, our rails application) responds to the
request by sending back some information and a blob of (usually) HTML
which the browser uses to render the page. The response looks something
like this (simplified):

    HTTP/1.1 200 OK
    Date: Fri, 12 Dec 2009 12:00:00 GMT
    Content-Type: text/html

    <!DOCTYPE html>
    <html>
      <head>
        <title>Some page</title>
      </head>
      <body>
        <h2>Some page</h2>
        <p>Here is a paragraph.</p>
      </body>
    </html>

The top lines are the response headers, and the bottom part is the
response body text which will be used to render the page. The "200 OK"
part of the top header lets the browser know that there were no errors.
The "Content-Type" header tells the browser to interpret the body of the
response as HTML.

The basic job of a web server is to receive requests like the ones shown
above and respond with something like the response. The exact
specification for this interaction (HTTP) is defined in a standard. You
can see the draft of the 1999 version (HTTP 1.1) here:
[RFC2616](http://www.w3.org/Protocols/rfc2616/rfc2616.html)

For a gentler introduction try:
[HTTP Made Really Easy](http://www.jmarshall.com/easy/http/)

OK, now we should understand a bit about Rails.

Rails and MVC
-------------

MVC stands for Model View Controller. It's a way to separate different
parts of the code that do different things. The Controller is the part
of the code that accepts incoming requests and decides what to do. The
Model is the part of the code that takes care of interacting with the
database and may contain some business logic as well. The View is the
part of the code responsible for rendering HTML back to the browser that
sent the request.

The lifetime of a rails request looks something like this:

1. Request is routed to proper Controller action based on path
2. Controller requests data from Model
3. Controller passes some data to the View
4. The View renders output (usually HTML)

So the store app we've created gives an error: *No route matches "/"* it
just means that we haven't set it up to route the simplest request ("/")
to any controller actions.
