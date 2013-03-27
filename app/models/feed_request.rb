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
  before_save :save_body, if: :new_body?
  before_destroy :remove_body

  def new_body?
    body.present? && success?
  end

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

  def save_body
    FileUtils.mkdir_p(storage_dir)
    File.open(storage_path, 'w') do |f|
      f << String(body)
    end
  end

  def body_saved?
    File.exists?(storage_path)
  end

  def storage_path
    # Not sure whether to store one file per feed, or per successful
    # request
    digest = Digest::MD5.hexdigest(url)
    Rails.root.join('public', 'raw_feeds', "#{digest}.xml")
  end

  def storage_dir
    storage_path.dirname
  end

  def remove_body
    File.delete(storage_path) if body_saved?
  end


  protected


  def find_header(headers, key)
    header = headers.detect { |k,_| k.downcase == key }
    header[1] unless header.nil?
  end
end
