require 'digest/md5'
require 'fileutils'

class RawFeed

  def initialize(url, params = nil)
    @url = url
    @status = params.fetch(:status)
    @etag = params.fetch(:etag) { nil }
    @last_modified = params.fetch(:etag) { nil }
    @headers = params.fetch(:headers) { { } }

    @xml = nil
  end

  attr_reader :url, :status, :etag, :last_modified, :headers

  def parse_response(response)
    @url = response.url
    @status = response.status

    headers = response.headers
    @headers = headers
    @etag = find_header(headers, 'etag')
    @last_modified = find_header(headers, 'last-modified')

    @xml = response.body
  end

  def xml
    @xml ||= read_xml
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
