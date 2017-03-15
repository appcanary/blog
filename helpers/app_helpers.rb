module AppHelpers
  def tags?(article = current_article)
    article.tags.present?
  end

  def tags(article = current_article, separator = ', ')

    article.tags.map do |tag|
      link_to(tag, tag_path(tag))
    end.join(separator)
  end

  def post_author(article = current_article)
    author = article.metadata[:page][:author]
    author ||= "team"
    OpenStruct.new(config.authors[author])
  end

  def author_path(article)
    "/author/#{post_author(article).name.parameterize}.html"
  end

  def article_url(article)
    URI.join(config.site_url, article.url)
  end

  def podcast_path(article)
    URI.join(config.site_url, "mp3/#{article.data.filename}")
  end

  def podcast_file_size(ep)
    File.size("source/mp3/#{ep.data.filename}")
  end

  def guid(article)
    Digest::SHA256.hexdigest(File.open("source/mp3/#{article.data.filename}").read)
  end

  def format_date(date)
    date.strftime('%a, %d %b %Y %H:%M:%S GMT')
  end

end
