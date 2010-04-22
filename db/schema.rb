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
