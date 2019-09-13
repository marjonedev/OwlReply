module ReplyMaker
  class Replier
    def self.check_accounts

      # This cronjob should technically loop forever. Just make sure it's still looping, and if it is, then go ahead and exit.
      # return if already_running_fine?
      # By doing the above, we can probably make sure that this runs faster than without it.
      # In the future, we may segment email accounts somehow, between multiple servers.

      accounts = Emailaccount.where('password IS NOT NULL AND password <> ""').where('updated_at < ?',5.minutes.ago)
      for account in accounts
        begin
          self.create_drafts(account)
          self.touch_last_reply_time
          puts "Success on account #{account.address}. #{$!.to_s}"
        rescue
          puts "Failure on account #{account.address}. #{$!.to_s}"
        end
      end
      self.touch_last_reply_time
      self.check_accounts
    end
    def self.already_running_fine?
      REDIS.some_get_method("last_reply_checked_at").to_i > (Time.now.to_i - (10*60))
    end
    def self.touch_last_reply_time

      # INSERT INTO REDIS
      # REDIS.some_method("last_reply_checked_at",Time.now.to_i)
    end
    def self.create_drafts(account)
      require 'net/imap'
      require 'mail'
      imap = Net::IMAP.new('imap.gmail.com', ssl: {ssl_version: :TLSv1_2}, port: 993 )
      imap.login(account.address, account.password)
      imap.select('INBOX')
      imap.search(['UNSEEN']).each do |message_id|
        reply_used = false
        data = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
        msg = Mail.read_from_string data
        thebody = msg.body.to_s.downcase
        next if account.subject_line_skip?(msg.subject)
        next if (msg.references && (msg.references.size > 1)) # Skip if this thread has more than one email! Secret sauce!

        auto = ""
        for reply in account.replies
          next unless reply.matches?(msg.subject, thebody)
          auto << reply.body
          reply.increment!(:drafts_created_today)
          reply.increment!(:drafts_created_lifetime)
          reply_used = true
        end

        body_html = (msg.html_part.body.to_s rescue "")
        body_html = (msg.text_part.body.to_s rescue "") if body_html.strip.blank?
        body_text = (msg.text_part.body.to_s rescue "").strip.blank? ? (msg.html_part.body.to_s rescue "") : (msg.text_part.body.to_s rescue "")
        body_html = thebody.gsub("\n","<br>\n") if body_html.blank?
        body_text = thebody if body_text.blank?
        email_to = (msg.reply_to || msg.from)

        mail = Mail.new do
          from    "#{h account.address} <#{account.address}>"
          to      email_to
          subject "Re: #{msg.subject}"
          text_part do
            body account.template.gsub("+REPLY+",auto)+"\n\nIn reply to:\n\n"+(body_text)
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body account.template_html.gsub("%%REPLY%%",auto)+"<br><br>\n\nOn #{msg.date}, #{msg.reply_to || msg.from} wrote:<br>\n<br>\n"+body_html
          end
        end
        mail.header['In-Reply-To'] = msg["Message-ID"]#message_id
        mail.header['References'] = msg["Message-ID"]
        message = mail.to_s
        imap.append("[Gmail]/Drafts", message, [:Seen], Time.now)

        account.increment!(:drafts_created_today)
        account.increment!(:drafts_created_lifetime)
        account.increment!(:drafts_missing_replies) unless reply_used
      end
    end

  end
end