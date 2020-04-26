module WizardHelper

  def improved_message_body(message)
    body = message[:body]
    if body.length < 100
      return
    end
    body = body.gsub('<br>',' ').gsub('<div>',"\n<div>")
    text = strip_tags(body)
    words = text.split(/\s+/)
    return words
  end

end
