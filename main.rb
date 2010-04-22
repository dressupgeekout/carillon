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
