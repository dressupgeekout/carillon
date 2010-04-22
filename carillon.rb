#
# Carillon CMS
# Christian Koch <ckoch002@student.ucr.edu>
#

require 'sinatra'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/carillon.sqlite3')

# Change these for your own application. The only requirements are that each
# table must have a primary_key named :id, a text column named :slug, and a text 
# column named :title. In order for the timestamps to work properly, you must
# have a column named :timestamp, typed timestamp.
DB.create_table?(:posts) do
  primary_key :id
  text        :slug
  text        :title
  text        :body
end
POSTS_TEXTAREAS = [:body]

DB.create_table?(:reviews) do
  primary_key :id
  text        :slug
  text        :title
  text        :rating
  text        :body
end
REVIEWS_TEXTAREAS = [:body]

helpers do

  # Assume the user not logged in. If that's true, then throw a 401.
  def auth
    session[:logged_in] ||= false
    complain unless session[:logged_in]
  end

  def complain
    halt 401, '<h1>401 NOT AUTHORIZED</h1>'
  end

  # Just a wrapper around #erb, so that I don't have to speficy the layout every
  # single time.
  def erb_admin(template)
    erb :"admin/#{template}", :layout => :'admin/layout'
  end

  class String
    # Transform a string into another string suitable for URLs.
    def to_slug
      self.gsub(/[^\w-]/, '').gsub(/\s/, '-')
    end

    # For the given table name, return the array which contains the names of the
    # columns within that table that should require a textarea (instead of just
    # an input field).
    # TODO: There's gotta be a better way of doing this. I don't wanna use eval.
    def equiv_textareas
      eval "#{self.to_s.upcase}_TEXTAREAS"
    end
  end
  
  module Sequel
    class Dataset

      # Given a Dataset, construct a hash that would be suitable for
      # Sequel::Dataset#update or #insert. This method provides some useful     
      # defaults, too.
      def generic_values(params)
        @hash = {}
        self.columns.each do |column|
          value = params[column.to_s]
          value = Time.now if column == :timestamp and value.empty?
          @hash.merge!(column => value)
        end
        @hash
      end

    end
  end

end

enable :sessions

##########

# Logging in
get '/admin/login' do
  erb_admin :login
end

post '/admin/login' do
  attempted_user = DB[:users].where(:username => params['username']).first
  if attempted_user and
     attempted_user[:username] == params['username'] and
     attempted_user[:password] == params['password'] then
    session[:logged_in] = true
    redirect '/admin'
  else
    complain
  end
end

# Logging out
get '/admin/logout' do
  session[:logged_in] = false
  redirect '/admin/login'
end

##########

# Admin front page
get '/admin' do
  if session[:logged_in]
    erb_admin :index
  else
    redirect '/admin/login'
  end
end

# Add a new user
get '/admin/users/new' do
  auth
  erb_admin :'users/new'
end

post '/admin/users/new' do
  auth
  if params['username'].any? and
     params['password_a'].any? and params['password_b'].any? and
     params['password_a'] == params['password_b'] then
    DB[:users].insert(
      :username => params['username'],
      :password => params['password_a']
    )
    redirect '/admin'
  else
    complain
  end
end

# Edit an existing user
get '/admin/users/edit/:id' do
  auth
  @user = DB[:users].where(:id => params[:id].to_i).first
  erb_admin :'users/edit'
end

post '/admin/users/edit/:id' do
  auth
  attempted_user = DB[:users].where(:id => params[:id].to_i).first

  if params['username'].any? and
     params['password_a'].any? and params['password_b'].any? and
     attempted_user[:password] == params['old_password'] and
     params['password_a'] == params['password_b'] then
    DB[:users].where(:id => params[:id].to_i).update(
      :username => params['username'],
      :password => params['password_a']
    )
    redirect '/admin'
  else
    complain
  end
end

# Delete a user
# TODO: implement this as DELETE
get '/admin/users/delete/:id' do
  auth
  DB[:users].where(:id => params[:id].to_i).delete
  redirect '/admin'
end

##########

# New addition to a collection
get '/admin/:collection/new' do
  auth
  @collection_name = params[:collection]
  @collection_columns = DB[@collection_name.to_sym].columns
  erb_admin :'collection/new'
end

post '/admin/:collection/new' do
  auth
  dataset = DB[params[:collection].to_sym]
  dataset.insert dataset.generic_values(params)
  redirect '/admin'
end

# Edit a record in a collection
get '/admin/:collection/edit/:id' do
  auth
  @collection_name = params[:collection]
  @collection_columns = DB[@collection_name.to_sym].columns
  @record = DB[params[:collection].to_sym].where(:id => params[:id].to_i).first
  erb_admin :'collection/edit'
end

post '/admin/:collection/edit/:id' do
  auth
  dataset = DB[params[:collection].to_sym].where(:id => params[:id].to_i)
  dataset.update dataset.generic_values(params)
  redirect '/admin'
end

# Delete a record in a collection
# TODO: implement this as DELETE
get '/admin/:collection/delete/:id' do
  auth
  DB[params[:collection].to_sym].where(:id => params[:id].to_i).delete
  redirect '/admin'
end

##########

# Front pages
get '/' do
  @posts = DB[:posts].all
  @reviews = DB[:reviews].all
  erb :index
end

get '/posts/:slug' do
  @post = DB[:posts].where(:slug => params[:slug]).first
  erb :post
end

get '/reviews/:slug' do
  @review = DB[:reviews].where(:slug => params[:slug]).first
  erb :review
end
