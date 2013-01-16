require 'open-uri'

Feed.find_each do |f|
  filename = f.title.parameterize
  file_path = "tmp/feeds/#{filename}.xml"
  next if File.exists?(file_path)

  url = URI.parse(f.feed_url)

  begin
    open(url) do |xml|
      case xml
      when File then system('cp', xml.path, file_path)
      when StringIO then File.write(file_path, xml.read)
      end

      puts "Fetched #{file_path}"
    end
  rescue => e
    puts "Could not fetch #{f.title}"
    puts "  #{f.feed_url}"
    puts "  #{e.message}"
  else
    # File.write(file_path, xml.read)
  end
end
