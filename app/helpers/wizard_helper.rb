module WizardHelper

  def improved_message_body(message, less = true)
    body = message[:body]
    if less
      if body.length < 100
        return
      end
    end
    body = body.gsub('<br>',' ').gsub('<div>',"\n<div>")
    text = strip_tags(body)
    words = text.encode('UTF-8', :invalid => :replace, :replace => '?').split(/\s+/)
    return words
  end

end
