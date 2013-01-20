class ItemConverter < Struct.new(:item)
  def self.convert(item)
    converter_class = case item
    when RSS::Atom::Feed::Entry then AtomItemConverter
    when RSS::RDF::Item then RDFItemConverter
    when RSS::Rss::Channel::Item then RSSItemConverter
    end

    converter_class.new(item).convert
  end

  def convert_link(link)
    link.respond_to?(:href) ? link.href : link.to_s
  end

  def try_content
  end
end

class AtomItemConverter < ItemConverter
  def convert
    Item.new do |i|
      i.url = item.link.try(:href)
      i.title = item.title.try(:content)
      i.author = item.author.try(:name).try(:content)
      i.content = item.content.try(:content)
      i.published_at = item.published.try(:content)
    end
  end
end

class RSSItemConverter < ItemConverter
  def convert
    Item.new do |i|
      i.url = item.link
      i.title = item.title
      i.author = item.author
      i.content = item.description
      i.published_at = item.pubDate
    end
  end
end

class RDFItemConverter < ItemConverter
  def convert
    Item.new do |i|
      i.url = item.link
      i.title = item.title
      i.author = item.dc_creator
      i.content = item.description
      i.published_at = item.dc_date
    end
  end
end
