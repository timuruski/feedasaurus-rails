require 'rss'
require 'fileutils'

def parse_feeds(pattern = 'tmp/feeds/*.xml')
  Dir[pattern]
    .map { |p|
      xml = File.read(p)
      begin
        RSS::Parser.parse(xml)
      rescue => e
        puts "#{p} - #{e.message}"
      end
    }
    .compact
    .flat_map { |f| f.items }
end
