module ApplicationHelper
  def log_empty?(log)
    log.first =~ /no changes/
  end

  def bool_label(value)
    css_class = if value
                  'success'
                else
                  'danger'
                end

    content_tag(:span, value, class: "label label-#{css_class}")
  end

  def disable_text
    "<i class='fa fa-spinner fa-spin'></i> I\'m on it...".html_safe
  end
end
