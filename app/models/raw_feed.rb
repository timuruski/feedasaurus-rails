require 'digest/md5'

class RawFeed < ActiveRecord::Base
  belongs_to :feed
  serialize :response_headers

  def self.from_response(response)
    new do |raw_feed|
      raw_feed.url = response.url
      raw_feed.status = response.status
      raw_feed.headers = response.headers

      raw_feed.etag = response.headers['Etag']
      raw_feed.last_modified = response.headers['Last-Modified']

      raw_feed.xml = response.body
    end
  end

  def xml
    @xml ||= read_xml
  end

  def xml=(new_xml)
    @xml = new_xml
  end

  def xml_path
    Digest::MD5.hexdigest(url)
  end

  def xml_exists?
    File.exists?(xml_path)
  end

  def read_xml
    xml_exists? ? File.read(xml_path) : ''
  end


  before_save :update_xml
  before_destroy :remove_xml

  def update_xml
    File.open(xml_path, 'w') do |f|
      f << String(xml)
    end
  end

  def remove_xml
    File.delete(xml_path) if xml_exists?
  end
end
