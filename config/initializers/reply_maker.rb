module ReplyMaker
  class Replier
    def self.start_checking
      self.reset_draft_created_today
      # This cronjob should technically loop forever. Just make sure it's still looping, and if it is, then go ahead and exit.
      return if already_running_fine?
      # By doing the above, we can probably make sure that this runs faster than without it.
      # In the future, we may segment email accounts somehow, between multiple servers.
      while not resetting?
        self.check_accounts
      end
    end
    def self.check_accounts
      accounts = Emailaccount.where('password IS NOT NULL AND password <> "" AND (error IS NULL OR error = "")').where('last_checked IS NULL OR last_checked < ?',2.minutes.ago.to_i)#.where('updated_at < ?',2.minutes.ago)
      for account in accounts
        begin
          ###next if (account.last_checked > (Time.now.to_i - (3*60))) unless account.last_checked.nil? #Check a max of every 3 minutes.
          self.touch_last_reply_time
          self.create_drafts(account)
          puts "Success on account #{account.address}. #{$!.to_s}"
          account.update_column(:last_checked,Time.now.to_i)
        rescue
          puts "Failure on account #{account.address}. #{$!.to_s}"
          account.update_column(:error,$!.to_s)
        end
      end
      sleep 1 if self.get_last_reply_time > (Time.now.to_i - (1*60)) # The loop must last at least a minute.
      self.touch_last_reply_time
    end
    def self.reset
      REDIS.set("replymaker_reset",1)
    end
    def self.resetting?
      if (REDIS.get("replymaker_reset").to_i == 1)
        REDIS.del("replymaker_reset")
        return true
      else
        return false
      end
    end
    def self.already_running_fine?
      self.get_last_reply_time > (Time.now.to_i - (2*60))
    end
    def self.touch_last_reply_time
      # INSERT INTO REDIS
      REDIS.set("last_reply_checked_at",Time.now.to_i)
    end
    def self.get_last_reply_time
      REDIS.get("last_reply_checked_at").to_i
    end
    def self.reset_draft_created_today
      if Time.now.beginning_of_day > Time.at(self.get_last_reply_time).beginning_of_day
        Emailaccount.where('drafts_created_today IS NOT NULL').update_all(drafts_created_today: nil)
      end
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
          body = reply.body.gsub("\n","<br>\n")
          auto << body
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
          from    "#{account.address} <#{account.address}>"
          to      email_to
          subject "Re: #{msg.subject}"
          text_part do
            body account.template.gsub("%%reply%%",auto)+"\n\nIn reply to:\n\n"+(body_text)
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body account.template_html.gsub("%%reply%%",auto)+"<br><br>\n\nOn #{msg.date}, #{msg.reply_to || msg.from} wrote:<br>\n<br>\n"+body_html
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