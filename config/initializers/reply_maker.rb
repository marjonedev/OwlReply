module ReplyMaker
  class Replier
    def self.start_checking
      self.reset_drafts_daycount
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
    def self.reset_drafts_daycount
      if Time.now.beginning_of_day > Time.at(self.get_last_reply_time).beginning_of_day
        Emailaccount.where('drafts_created_today IS NOT NULL').update_all(drafts_created_today: nil, drafts_missing_replies_today: nil)
      end
    end
    def self.create_drafts(account)
      if account.email_provider == 'google'
        self.create_draft_google(account)
      else
        self.create_draft_imap(account)
      end
    end

=begin
todo:
  1. authenticate email account first
  2. if not authenticated, reauthorize
  3. search message from inbox, unread
  4. get the subject and body and convert to lower case
  5. skip if matches the skipwords using account.subject_line_skip?
  6. skip if thread has more than 1 email
  7. scan the subject and body from every account.replies to match the reply keywords using reply.matches?
  8. get the body of the reply
  9. create new draft
=end

    def self.create_draft_google(account)
      if account.authenticated

        self.refresh_token(account)

        client = Signet::OAuth2::Client.new(access_token: account.google_access_token)
        gmail = Google::Apis::GmailV1::GmailService.new
        gmail.authorization = client

        # gmail.list_user_messages('me', labels: ['inbox'], max_results: 1000, q: 'is:unread')

        # ids =
        #     gmail.fetch_all(max: options[:limit], items: :messages) do |token|
        #       gmail.list_user_messages('me', max_results: [options[:limit], 500].min, q: query, page_token: token)
        #     end.map(&:id)

        # msg = Mail.new
        # msg.date = Time.now
        # msg.subject = options[:subject]
        # msg.body = Text.new(options[:message])
        # msg.from = {@_user.email => @_user.full_name}
        # msg.to   = {
        #     options[:to] => options[:to_name]
        # }
        # @email = @google_api_client.execute(
        #     api_method: @gmail.users.messages.to_h['gmail.users.messages.send'],
        #     body_object: {
        #         raw: Base64.urlsafe_encode64(msg.to_s)
        #     },
        #     parameters: {
        #         userId: 'me',
        #     }
        # )

      end
    end

    def self.create_draft_imap(account)
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
          next unless reply.matches?(msg.subject, thebody) #check if matches with keywords
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
        account.increment!(:drafts_missing_replies_today) unless reply_used
        account.increment!(:drafts_missing_replies_lifetime) unless reply_used
      end
    end

    def self.refresh_token(account)
      api_client_id = Rails.application.credentials.google_api_client_id
      api_client_secret = Rails.application.credentials.google_client_secret
      url = URI("https://accounts.google.com/o/oauth2/token")
      request = Net::HTTP.post_form(url,{ 'refresh_token' => account.google_refresh_token,
                                           'client_id'     => api_client_id,
                                           'client_secret' => api_client_secret,
                                           'grant_type'    => 'refresh_token'})
      data = JSON.parse(request.body)
      expires_in = Time.now.to_i + data['expires_in']
      account.update(google_access_token: data['access_token'],
             google_expires_in: expires_in,
             google_refresh_token: data['refresh_token'])
    end

    def refresh!(account)
      self.refresh_token if account.google_expires_in.to_i < Time.now.to_i
    end



  end
end