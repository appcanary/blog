require 'ostruct'
require 'digest/md5'

module MiddlemanCasperHelpers
  def page_title
    title = ""
    if is_tag_page?
      title << current_resource.metadata[:locals]['tagname']
    elsif is_author_page?
      title << blog_author(current_resource.metadata[:locals][:current_article]).name
    elsif current_page.data.title
      title << current_page.data.title
    elsif is_blog_article?
      title << current_article.title
    end
    [title, blog_settings.name].reject(&:empty?).join(" - ")
  end

  def page_description
    if is_blog_article?
      body = strip_tags(current_article.body).gsub(/\s+/, ' ')
      truncate(body, length: 147)
    else
      blog_settings.description
    end
  end

  def page_class
    if is_blog_article? || current_page.data.layout == 'page'
      'post-template'
    elsif current_resource.metadata[:locals]['page_number'].to_i > 1
      'archive-template'
    else
      'post-template home-post-template'
    end
  end

  def summary(article)
    summary_length = article.blog_options[:summary_length]
    strip_tags(article.summary(summary_length, ''))
  end

  def read_next_summary(article, words)
    body = strip_tags(article.body)
    truncate_words(body, length: words, omission: '')
  end

  def blog_author(article = current_article)
    author = article.metadata[:page][:author]
    OpenStruct.new(config.casper[:authors][author])
  end

  def blog_settings
    OpenStruct.new(config.casper[:blog])
  end

  def navigation
    config.casper[:navigation]
  end

  def is_tag_page?
    current_resource.metadata[:locals]['page_type'] == 'tag'
  end

  def is_author_page?
    current_resource.metadata[:locals]['page_type'] == 'author'
  end

  def tags?(article = current_article)
    article.tags.present?
  end
  def tags(article = current_article, separator = ', ')
    capture_haml do
      article.tags.each do |tag|
        haml_tag(:a, tag, href: tag_path(tag))
        haml_concat(separator) unless article.tags.last == tag
      end
    end.gsub("\n", '')
  end

  def current_article_url
    URI.join(blog_settings.url, current_article.url)
  end

  def cover(page = current_page)
    if (src = page.data.cover).present?
      { style: "background-image: url(#{image_path(src)})" }
    else
      { class: 'no-cover' }
    end
  end
  def cover?(page = current_page)
    page.data.cover.present?
  end

  def thumbnail(page = current_page)
    if page.data.thumbnail.present?
      page.data.thumbnail
    else
      blog_settings.logo
    end
  end

  def gravatar(size = 68)
    # md5 = Digest::MD5.hexdigest(blog_author.gravatar_email.downcase)
    # "https://www.gravatar.com/avatar/#{md5}?size=#{size}"
    false
  end
  def gravatar?
    # blog_author.gravatar_email.present?
    false
  end

  def twitter_url
    "https://twitter.com/intent/tweet?text=#{current_article.title}" \
      "&amp;url=#{current_article_url}"
  end
  def facebook_url
    "https://www.facebook.com/sharer/sharer.php?u=#{current_article_url}"
  end
  def google_plus_url
    "https://plus.google.com/share?url=#{current_article_url}"
  end

  def feed_path
    if is_tag_page?
      "#{current_page.url.to_s}feed.xml"
    else
      "#{blog.options.prefix.to_s}/feed.xml"
    end
  end

  def home_path
    "#{blog.options.prefix.to_s}/"
  end

  def author_path(article)
    "#{blog.options.prefix.to_s}/author/#{blog_author(article).name.parameterize}.html"
  end

  def og_type
    if is_blog_article?
      'article'
    else
      'website'
    end
  end

  def og_title
    if current_page.data.title
      current_page.data.title
    elsif is_tag_page?
      current_resource.metadata[:locals]['tagname']
    elsif is_blog_article?
      current_article.title
    else
      nil
    end
  end
  alias :twitter_title :og_title
end
