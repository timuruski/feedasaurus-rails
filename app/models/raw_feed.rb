require 'digest/md5'
require 'fileutils'

class RawFeed < ActiveRecord::Base
  belongs_to :feed
  serialize :response_headers

  attr_accessible :feed, :response

  def response=(response)
    self.url = response.url
    self.status = response.status

    headers = response.headers
    self.headers = headers
    self.etag = find_header(headers, 'etag')
    self.last_modified = find_header(headers, 'last-modified')

    self.xml = response.body
  end

  def xml
    @xml ||= read_xml
  end

  def xml=(new_xml)
    @xml = new_xml
  end

  def read_xml
    File.read(xml_path) if xml_exists?
  end

  def xml_exists?
    File.exists?(xml_path)
  end

  def xml_path
    digest = Digest::MD5.hexdigest(url)
    Rails.root.join('public', 'raw_feeds', "#{digest}.xml")
  end


  before_save :update_xml
  before_destroy :remove_xml

  def update_xml
    FileUtils.mkdir_p(xml_path.dirname)
    File.open(xml_path, 'w') do |f|
      f << String(xml)
    end
  end

  def remove_xml
    File.delete(xml_path) if xml_exists?
  end


  protected

  def find_header(headers, key)
    header = headers.detect { |k,_| k.downcase == key }
    header[1] unless header.nil?
  end
end
