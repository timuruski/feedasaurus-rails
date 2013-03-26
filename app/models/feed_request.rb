class FeedRequest < ActiveRecord::Base
  def parse_response(response)
    self.url = response.url
    self.status = response.status

    headers = response.headers
    self.headers = headers
    self.etag = find_header(headers, 'etag')
    self.last_modified = find_header(headers, 'last-modified')

    self.body = response.body
  end

  attr_accessor :body

  default_scope order('created_at DESC')
  scope :successful, where(status: 200)

  def success?
    status == 200
  end

  def not_found?
    status == 404
  end

  def redirect?
    (300..399).cover?(status)
  end


  protected


  def find_header(headers, key)
    header = headers.detect { |k,_| k.downcase == key }
    header[1] unless header.nil?
  end
end
