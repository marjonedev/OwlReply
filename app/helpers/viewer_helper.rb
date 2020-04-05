module ViewerHelper

  def improved_message_body(message)
    body = message[:body]
    if body.length < 100
      return
    end
    text = strip_tags(body)
    words = text.split(/\s+/)
    return words[0..20].join(' ')
  end

end
