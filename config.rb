# coding: utf-8

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  blog.permalink = "{year}/{title}.html"
  # Matcher for blog source files
  blog.sources = "posts/{year}-{month}-{day}-{title}.html"
  blog.taglink = "tags/{tag}.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  # blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"
end

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

set :site_url, "https://blog.appcanary.com"

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true, footnotes: true, tables: true, with_toc_data: true

# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end

config[:authors] = {
    "phillmv" => {
      name: 'Phillip Mendonça-Vieira',
      bio: nil, # Optional
      location: nil, # Optional
      website: nil, # Optional
      gravatar_email: nil, # Optional
      twitter: "phillmv" # Optional
    },
    "mveytsman" => {
      name: "Max Veytsman",
      bio: nil,
      location: nil,
      website: nil,
      gravatar_email: nil,
      twitter: "mveytsman"
    },
    "team" => {
      name: "Team Appcanary",
      bio: nil,
      location: nil,
      website: nil,
      gravatar_email: nil,
      twitter: nil
    }
}


ready do
  config.authors.each do |k, author|
    proxy "/author/#{author[:name].parameterize}.html",
          '/author.html', ignore: true, :locals => { "page_type" => "author",
                                                     "articles" => sitemap.resources.select { |r| r.data.author == k }.sort_by { |r| r.data.date}.reverse,
                                                     :current_article => OpenStruct.new({:metadata => {:page => { :author => k }}}) }
  end
end



proxy "/rss", "/feed.xml"

redirect 'post/131974777156/hello-appcanary', to: '/2015/hello-appcanary.html'
redirect 'post/125101503771/hello-world', to: '/2015/hello-world.html'
redirect '2016/vikhal-morris.html', to: '/2016/tale-of-two-worms.html'

# Pretty URLs - https://middlemanapp.com/advanced/pretty_urls/
# activate :directory_indexes

# Middleman-Syntax - https://github.com/middleman/middleman-syntax
set :haml, { ugly: true }
activate :syntax, line_numbers: false

activate :sprockets
