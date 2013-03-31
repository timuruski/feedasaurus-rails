class ItemBuilder < Struct.new(:item)
  UnsupportedItemType = Class.new(StandardError)

  def self.build(item)
    builder_class = case item
    when RSS::Atom::Feed::Entry then AtomItemBuilder
    when RSS::RDF::Item then RDFItemBuilder
    when RSS::Rss::Channel::Item then RSSItemBuilder
    else raise UnknownItemType
    end

    builder_class.new(item).build
  end

  def in_time_zone(time)
    time.try(:in_time_zone) || Time.current
  end

  # Specific converters
  class AtomItemBuilder < self
    def build
      Item.new do |i|
        i.url = item.link.try(:href)
        i.title = item.title.try(:content)
        i.author = item.author.try(:name).try(:content)
        i.content = item.content.try(:content)
        i.created_at = in_time_zone(item.published.try(:content))
      end
    end
  end

  class RSSItemBuilder < self
    def build
      Item.new do |i|
        i.url = item.link
        i.title = item.title
        i.author = item.author
        i.content = item.description
        i.created_at = in_time_zone(item.pubDate)
      end
    end
  end

  class RDFItemBuilder < self
    def build
      Item.new do |i|
        i.url = item.link
        i.title = item.title
        i.author = item.dc_creator
        i.content = item.description
        i.created_at = in_time_zone(item.dc_date)
      end
    end
  end

end

