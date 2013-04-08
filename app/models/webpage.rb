require 'nokogiri'

class Webpage
  def initialize(response)
    @url = URI.parse(response.url)
    @body = response.body
  end

  attr_reader :body, :url

  def alternate_url
    link = alternate_links.first
    link && link.attr('href')
  end


  # Alternate links:
  # <link
  #   rel="alternate" 
  #   type="application/rss+xml" 
  #   title="RSS"
  #   href="http://parislemon.com/rss"/>
  #
  # <link
  #   rel="alternate"
  #   type="application/atom+xml"
  #   href="/index.xml" />
  def alternate_links
    @alternate_links ||= begin
      html && html.css('link[rel=alternate]')
    end
  end

  def html
    @html ||= Nokogiri::HTML(body)
  end
end
