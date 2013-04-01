module ApplicationHelper

  # Format time nicely or write never.
  def format_time(datetime)
    if datetime
      formatted = datetime.strftime('%A, %e %B %Y, %H:%M %p')
      options = { :title => datetime.httpdate }
    else
      formatted = 'Never' if datetime.nil?
      options = {}
    end

    content_tag(:span, formatted, options)
  end
end
