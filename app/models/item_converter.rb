class ItemConverter < Struct.new(:item)
  def convert
    case item
    when RSS::Rss::Channel::Item then convert_rss(item)
    when RSS::Atom::Feed::Entry then convert_atom(item)
    when RSS::RDF::Item then convert_rdf(item)
    end
  end

  def convert_rss(item)
    Item.new do |i|
      i.url = convert_link(item.link)
      i.title = item.title
      # i.author = item.author
      # i.content = item.content
      i.published_at = Time.current
    end
  end

  def convert_atom(item)
    Item.new do |i|
      i.url = convert_link(item.link)
      i.title = item.title.content
      i.author = item.author.content
      i.content = item.content
      i.published_at = item.published
    end
  end

  def convert_rdf(item)
    Item.new do |i|
      i.url = convert_link(item.link)
      i.title = item.title
      # i.author = item.author
      # i.content = item.content
      i.published_at = Time.current
    end
  end

  def convert_link(link)
    link.respond_to?(:href) ? link.href : link.to_s
  end
end
