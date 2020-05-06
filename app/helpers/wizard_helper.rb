module WizardHelper

  def improved_message_body(message)
    body = message[:body]
    if body.length < 100
      return
    end
    body = body.gsub('<br>',' ').gsub('<div>',"\n<div>")
    text = strip_tags(body)
    words = text.encode('UTF-8', :invalid => :replace).split(/\s+/)
    return words
  end

end
