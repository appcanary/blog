articles ||= blog.articles[0..5]
tag ||= nil
title = strip_tags(config.casper[:blog][:name])
subtitle = strip_tags(config.casper[:blog][:description])

xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = config.casper[:blog][:url]
  xml.title tag.present? ? "#{title}: #{tag}" : title
  xml.subtitle tag.present? ? "Posts tagged with #{tag}" : subtitle
  xml.id URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.updated(articles.first.date.to_time.iso8601) if articles.present?

  articles.each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
      xml.id URI.join(site_url, article.url)
      xml.published article.date.to_time.iso8601
      xml.updated File.mtime(article.source_file).iso8601
      xml.author { xml.name blog_author(article).name }
      xml.content article.body, "type" => "html"
    end
  end
end
