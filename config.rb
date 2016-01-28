###
# middleman-casper configuration
###

config[:casper] = {
  blog: {
    url: 'http://blog.appcanary.com',
    name: 'Appcanary',
    description: '<a href="https://appcanary.com">Appcanary</a> makes sure you never run vulnerable software in your apps.',
    date_format: '%d %B %Y',
    navigation: false,
    logo: 'appcanary.png' # Optional
  },
  authors: {
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
  },
  navigation: {
    "Home" => "/",
    "Archive" => "archive.html",
    "Github" => "https://github.com/appcanary"
  }
}

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

# Proxy pages (https://middlemanapp.com/advanced/dynamic_pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

def get_tags(resource)
  if resource.data.tags.is_a? String
    resource.data.tags.split(',').map(&:strip)
  else
    resource.data.tags
  end
end

def group_lookup(resource, sum)
  results = Array(get_tags(resource)).map(&:to_s).map(&:to_sym)

  results.each do |k|
    sum[k] ||= []
    sum[k] << resource
  end
end

tags = resources
  .select { |resource| resource.data.tags }
  .each_with_object({}, &method(:group_lookup))

tags.each do |tag, articles|
  proxy "/tag/#{tag.downcase.to_s.parameterize}/feed.xml", '/feed.xml',
    locals: { tag: tag, articles: articles[0..5] }, layout: false
end

proxy "/rss", "/feed.xml"

config.casper[:authors].each do |k, author|
  proxy "/author/#{author[:name].parameterize}.html",
    '/author.html', ignore: true, :locals => { :current_article => OpenStruct.new({:metadata => {:page => { :author => k }}}) }
end

# General configuration
# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

###
# Helpers
###

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  blog.permalink = "{year}/{title}.html"
  # Matcher for blog source files
  blog.sources = "articles/{year}-{month}-{day}-{title}.html"
  blog.taglink = "tag/{tag}.html"
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
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

redirect 'post/131974777156/hello-appcanary', to: '/2015/hello-appcanary.html'
redirect 'post/125101503771/hello-world', to: '/2015/hello-world.html'

# Pretty URLs - https://middlemanapp.com/advanced/pretty_urls/
# activate :directory_indexes

# Middleman-Syntax - https://github.com/middleman/middleman-syntax
set :haml, { ugly: true }
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true, footnotes: true,
  link_attributes: { rel: 'nofollow' }, tables: true
activate :syntax, line_numbers: false

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :relative_links, true
# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Ignoring Files
  ignore 'javascripts/_*'
  ignore 'javascripts/vendor/*'
  ignore 'stylesheets/_*'
  ignore 'stylesheets/vendor/*'
end

