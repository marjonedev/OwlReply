module RepliesHelper
  def preview_reply(reply)
    logger.debug "======================================"
    logger.debug reply.emailaccount.template
    logger.debug "======================================"
    reply.emailaccount.template.gsub("%%reply%%", reply.body)
  end
end
