require 'digest/md5'
require 'fileutils'

# DEPRECATED
class RawFeed
  NOT_FOUND = 404

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

  def not_found?
    status == NOT_FOUND
  end

  def xml
    @xml ||= read_xml
  end

  def read_xml
    File.read(storage_path) if stored?
  end

  def stored?
    File.exists?(storage_path)
  end

  def storage_path
    digest = Digest::MD5.hexdigest(url)
    Rails.root.join('public', 'raw_feeds', "#{digest}.xml")
  end

  def storage_dir
    storage_path.dirname
  end


  protected

  def find_header(headers, key)
    header = headers.detect { |k,_| k.downcase == key }
    header[1] unless header.nil?
  end
end
