module RepliesHelper
  def preview_reply(reply)
    # logger.debug "===================11111==================="
    # logger.debug reply.emailaccount.template
    # logger.debug "===================22222==================="
    # reply_content =
    if !reply.emailaccount.template.nil?
      simple_format(reply.emailaccount.template.to_s.gsub("%%reply%%", "<div class='reply_body'>#{reply.body}</div>"))
    else
      reply.body
    end
  end
end
