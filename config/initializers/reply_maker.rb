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

include ActionView::Helpers::DateHelper

module ReplyMaker
  class Replier
    def replier_logger
      @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
    end
    def self.replier_logger
      @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
    end

    def self.start_checking(args = {})
      self.check_last_reply
      self.account_last_checked
      self.reset_drafts_daycount
      # This cronjob should technically loop forever. Just make sure it's still looping, and if it is, then go ahead and exit.
      return if already_running_fine? unless args[:force]
      return if too_many_of_myself_running? unless args[:force]
      # By doing the above, we can probably make sure that this runs faster than without it.
      # In the future, we may segment email accounts somehow, between multiple servers.
      loops = 0
      loops = 24 if args[:force]
      while not (resetting? || (loops > 25))
        self.check_accounts_using_imap
        self.check_accounts_using_google
        loops += 1 # End after 25 loops, in case of memory leak errors. A new process will be run later.
      end
    end

    def self.check_accounts_using_imap
      # now we need to detect all account that has been authenticated (authenticated = 1)
      accounts = Emailaccount.where('password IS NOT NULL AND password <> ""')
                     .where('authenticated = 1')
                     .where('email_provider IS NULL OR email_provider = "other"')
                     .where('error IS NULL OR error = ""')
                     .where('last_checked IS NULL OR last_checked < ?',2.minutes.ago.to_i)#.where('updated_at < ?',2.minutes.ago)

      if accounts
        for account in accounts

          #unless account.user.active
          #  return false
          #end
          # NEW:
          #return false unless account.setupcomplete

          begin
            ##next if (account.last_checked > (Time.now.to_i - (1*60))) unless account.last_checked.nil? #Check a max of every 1 minutes.
            self.touch_last_reply_time
            self.create_drafts_using_imap(account)
            replier_logger.info("IMAP - Success on account #{account.address}. #{$!.to_s}")
            puts "IMAP - Success on account #{account.address}. #{$!.to_s}"
            account.update_column(:last_checked,Time.now.to_i)

            data = {last_checked: "Last checked: Checked now."}
            EmailaccountChannel.broadcast_to(account, data)
          rescue
            replier_logger.info("IMAP - Failure on account #{account.address}. #{$!.to_s}")
            puts "IMAP - Failure on account #{account.address}. #{$!.to_s}"
            account.update_column(:error,$!.to_s)

            data = {last_checked: "#{$!.to_s}"}
            EmailaccountChannel.broadcast_to(account, data)
          end
        end

        sleep 1 if self.get_last_reply_time > (Time.now.to_i - (1*60)) # The loop must last at least a minute.
        self.touch_last_reply_time
      end
    end

    # Made this a separate function to make it easier to use from the command line when debugging.
    def self.accounts_to_check_using_google
       Emailaccount.where('google_access_token IS NOT NULL AND google_access_token <> ""')
        .where('authenticated = 1')
        .where('email_provider IS NOT NULL AND email_provider = "google"')
        .where('error IS NULL OR error = ""')
        .where('last_checked IS NULL OR last_checked < ?',2.minutes.ago.to_i)#.where('updated_at < ?',2.minutes.ago)
    end

    def self.check_accounts_using_google
      # accounts = Emailaccount.where('google_access_token IS NOT NULL AND google_access_token <> "" AND (error IS NULL OR error = "")').where('last_checked IS NULL OR last_checked < ?',2.minutes.ago.to_i)#.where('updated_at < ?',2.minutes.ago)
      accounts = accounts_to_check_using_google

      for account in accounts
        begin

          #unless account.user.active
          #  return false
          #end

          ##next if (account.last_checked > (Time.now.to_i - (1*60))) unless account.last_checked.nil? #Check a max of every 1 minutes.
          self.touch_last_reply_time
          self.create_drafts_using_google(account)

          replier_logger.info("Google - Success on account #{account.address}. #{$!.to_s}")
          puts "Google - Success on account #{account.address}. #{$!.to_s}"
          account.update_column(:last_checked,Time.now.to_i)

          data = {last_checked: "Last checked: Checked now."}
          EmailaccountChannel.broadcast_to(account, data)
        rescue
          replier_logger.info("Google - Failure on account #{account.address}. #{$!.to_s}")
          puts "Google - Failure on account #{account.address}. #{$!.to_s}"
          account.update_column(:error,$!.to_s)

          data = {last_checked: "#{$!.to_s}"}
          EmailaccountChannel.broadcast_to(account, data)
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

    def self.reset_account_error
      Emailaccount.where('error IS NOT NULL AND error <> ""').update_all(error: nil)
    end

    def self.already_running_fine?
      self.get_last_reply_time > (Time.now.to_i - (2*60))
    end

    def self.too_many_of_myself_running?
      # This will make sure there's not more than 4 of this process running.
      # This should not be necessary. It's a stopgap measure to prevent errors.

      processes = `ps aux | grep -i rails`.to_s
      process_size = processes.scan(/reply/).size

      process_checked = REDIS.get('processes_checked_at')

      unless process_checked.nil? and process_checked.to_i == 0
        if process_checked.to_i < (Time.now.to_i - (1*60*60*24)) #set to 0 if more than a day
          REDIS.set("processes_checked_at", 0)
        end
      end

      if process_size > 8

        if process_checked.nil? || process_checked.to_i == 0
          REDIS.set("processes_checked_at", Time.now.to_i)
          AdminMailer.with(process: process_size, subject: "Processes Running High").notification_email.deliver_now
        end

        return true
        # Consider sending an email to the admins.... but only once, not every 1 minute that this tries to run....
      else
        return false
      end
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
        Reply.where('drafts_created_today IS NOT NULL').update_all(drafts_created_today: nil)
      end
    end

    def self.create_drafts_using_imap(account)

      unless account.replies.count > 0
        return false #return if there's no replies created on the email account. fixed
      end

      begin

        require 'net/imap'
        require 'mail'
        require 'date'

        ssl = account.imap_ssl ? {ssl_version: :TLSv1_2} : false
        port = account.imap_port ? account.imap_port : 993
        host = account.imap_host.to_s.empty? ? account.address.to_s.split("@").last : account.imap_host

        imap = Net::IMAP.new(host, ssl: ssl, port: port )
        imap.login(account.address, account.password)

        folders =  imap.list('', "*")

        inbox = folders.any? { |h| h.name.to_s.downcase == 'inbox' } ? folders.find { |h| h.name.to_s.downcase == 'inbox' }.name : 'INBOX'
        drafts = folders.any? { |h| h.attr.include? :Drafts } ? folders.find { |h| h.attr.include? :Drafts }.name : 'DRAFTS'

        imap.select(inbox)

        start_date = 1.week.ago.strftime("%d-%b-%Y")

        messages_size = 0
        replies_size = 0

        imap.search(["UNSEEN", "SINCE", start_date]).each do |message_id|

          reply_used = false
          data = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
          msg = Mail.read_from_string data

          date = DateTime.rfc3339(msg.date.to_s)
          formatted_date = date.strftime("%a, %b %d, %Y at %I:%M %p")

          thebody = msg.body.to_s
          thebody_downcase = thebody.downcase
          next if account.subject_line_skip?(msg.subject)
          next if (msg.references && (msg.references.size > 1)) # Skip if this thread has more than one email! Secret sauce!

          auto = ""

          for reply in account.replies
            next unless reply.matches?(msg.subject, thebody_downcase)
            body = reply.body.to_s.gsub("\n","<br>\n")
            auto << body
            reply.increment!(:drafts_created_today)
            reply.increment!(:drafts_created_lifetime)
            replies_size += 1
            reply_used = true
          end

          if reply_used #only reply_used true can create draft.
            body_html = (msg.html_part.body.to_s rescue "")
            body_html = (msg.text_part.body.to_s rescue "") if body_html.strip.blank?
            body_text = (msg.text_part.body.to_s rescue "").strip.blank? ? (msg.html_part.body.to_s rescue "") : (msg.text_part.body.to_s rescue "")
            body_html = thebody.gsub("\n","<br>\n") if body_html.blank?
            body_text = thebody if body_text.blank?
            email_to = (msg.reply_to || msg.from)

            body_text2 = ""
            body_text.each_line do |tline|
              body_text2 << "> #{tline}"
            end

            reply_body = (account.template.nil? || account.template.to_s.strip == "")  ? auto : account.template.to_s.gsub("%%reply%%",auto)
            html_reply_body = reply_body.gsub("\n","<br>\n")

            mail = Mail.new do
              from    "#{account.address} <#{account.address}>"
              to      email_to
              subject "Re: #{msg.subject}"
              text_part do
                content_type 'text/plain; charset=UTF-8'
                # body account.template.gsub("%%reply%%",auto)+"\n\nIn reply to:\n\n"+(body_text)
                body reply_body+"\n\nOn #{formatted_date}, #{email_to} wrote:\n>\n#{body_text2}"
              end
              html_part do
                content_type 'text/html; charset=UTF-8'
                body html_reply_body+"<br><br>\n\nOn #{formatted_date}, #{email_to} wrote:<br>\n<br>\n#{body_html}"
              end
            end

            mail.header['In-Reply-To'] = msg["Message-ID"]#message_id
            mail.header['References'] = msg["Message-ID"]
            message = mail.to_s

            imap.append(drafts, message, [:Seen, :Draft], Time.now)

            account.increment!(:drafts_created_today)
            account.increment!(:drafts_created_lifetime)
          else
            account.increment!(:drafts_missing_replies_today) unless reply_used
            account.increment!(:drafts_missing_replies_lifetime) unless reply_used
          end

          messages_size += 1

        end

        if messages_size > 1
          self.update_admin_checked(account, emails: messages_size, replies: replies_size, type: 'success')
        else
          replier_logger.error("IMAP - Messages are empty.")
          self.update_admin_checked(account, message: "Messages on #{account.address} are empty", type: 'warning')
        end

      rescue Exception => e

        replier_logger.error e.message

        self.update_admin_checked(account, message: "Checking error on #{account.address}. #{e.message}", type: 'danger')

      end
    end

    # To be finished, or just rename test_google_draft once it works.
    def self.create_drafts_using_google account

      # We should stop checking this. It makes it so errors can appear at weird times; ie only after they've added replies.
      # The messages.each already does not run if there are no replies.
      #unless account.replies.count > 0
      #  return false
      #end

      include GoogleConnector
      api = GmailApi.new account

      begin

        require 'date'

        messages = api.get_messages

        ids = []

        if messages.empty?
          replier_logger.error("GOOGLE - Messages are empty.")
          self.update_admin_checked(account, message: "Messages on #{account.address} are empty", type: 'warning')

          return
        end

        replies_size = 0

        messages_size = messages.count

        messages.each do |msg|

          date = DateTime.parse(msg['date'])
          formatted_date = date.strftime('%a, %b %d, %Y at %I:%M %p')

          thebody = msg['body'].to_s
          thebody_downcase = thebody.downcase
          next if account.subject_line_skip?(msg['subject'])
          next if api.is_thread_message! msg['thread_id'] # Skip if this thread has more than one email! Secret sauce!

          reply_used = false

          auto = ""

          for reply in account.replies
            next unless reply.matches?(msg['subject'], thebody_downcase)
            body = reply.body.gsub("\n", "<br>\n")
            auto << body
            reply.increment!(:drafts_created_today)
            reply.increment!(:drafts_created_lifetime)
            replies_size += 1
            reply_used = true
          end

          if thebody_downcase.include?("testman100@fakedomain.com")
            reply = Reply.find(58)
            body = reply.body.gsub("\n", "<br>\n")
            auto << body
          end

          account_has_no_template = (account.template.nil? || account.template.to_s.strip == "")

          if (reply_used || (!account_has_no_template))
            body_html = (msg['body_html'].body.to_s rescue "")
            body_html = (msg['body_text'].body.to_s rescue "") if body_html.strip.blank?
            body_text = (msg['body_text'].to_s rescue "").strip.blank? ? (msg['body_html'].to_s rescue "") : (msg['body_text'].to_s rescue "")
            body_html = thebody.gsub("\n", "<br>\n") if body_html.blank?
            body_text = thebody if body_text.blank?

            #email_to = msg['from']
            #auto << msg.to_s
            email_to = msg['reply_to'].blank? ? msg['from'] : msg['reply_to']
            subject = "Re: #{msg['subject']}"
            from = "#{account.address}"

            body_text2 = ""
            body_text.each_line do |tline|
              body_text2 << "> #{tline}"
            end

            reply_body = account_has_no_template ? auto : account.template.to_s.gsub("%%reply%%", auto)
            html_reply_body = reply_body.gsub("\n", "<br>\n")


            text_part = reply_body + "\n\nOn #{msg['date']}, #{email_to} wrote:\n>\n#{body_text2}"

            email_to_html = CGI::escapeHTML(email_to)

            html_part = "<div dir=\"ltr\"><div dir=\"ltr\">#{html_reply_body.force_encoding('UTF-8')}</div><br><div class=\"gmail_quote\"><div dir=\"ltr\" class=\"gmail_attr\">On #{formatted_date} #{email_to_html} wrote:<br></div><blockquote class=\"gmail_quote\" style=\"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex\">#{body_html.force_encoding('UTF-8')}</blockquote></div></div>"


            api.create_reply_draft(msg['id'], thread_id: msg['thread_id'], from: from, to: email_to, subject: subject, multipart: msg['multipart'], body_text: text_part, body_html: html_part, msgid: msg['msgid'])
            ids.push(msg['id'])
          end

          if reply_used
            account.increment!(:drafts_created_today)
            account.increment!(:drafts_created_lifetime)
          else
            account.increment!(:drafts_missing_replies_today) unless reply_used
            account.increment!(:drafts_missing_replies_lifetime) unless reply_used
          end
        end

        self.update_admin_checked(account, emails: messages_size, replies: replies_size, type: 'success')

        UserChannel.broadcast_to(account.user, {message: "Succesfully checked #{messages.size} emails."})

        api.read_messages(ids)

      rescue Google::Apis::AuthorizationError => exception
        replier_logger.error exception.message
        exception.backtrace.each { |line| replier_logger.error line }

        begin
          api.refresh_api!
        rescue RefreshTokenFailureError => error
          replier_logger.error("GOOGLE: #{account.address} - Failed to refresh user token. #{error.to_s}")
          # return []
        end

        self.update_admin_checked(account, message: "Checking error on #{account.address}. #{exception.message}", type: 'danger')

        #retry # This could cause an infinite loop I think.
      rescue Exception => e
        replier_logger.error e.message

        self.update_admin_checked(account, message: "Checking error on #{account.address}. #{e.message}", type: 'danger')

        e.backtrace.each { |line| replier_logger.error line }
      end

    end

    def self.account_last_checked
      accounts = Emailaccount.where('authenticated = 1')
                     .where('email_provider IS NOT NULL')
                     .where("last_checked IS NOT NULL")
                     .where('error IS NULL OR error = ""')
                     # .where('last_checked IS NULL OR last_checked < ?',2.minutes.ago.to_i)

      accounts.each do |account|
        last_checked = account.last_checked.to_i ? time_ago_in_words(account.last_checked.to_i).humanize : ""
        data = {last_checked: "Last checked: #{last_checked} ago"}
        EmailaccountChannel.broadcast_to(account, data)
      end
    end

    def self.check_last_reply
      last_checked = time_ago_in_words(Time.at(REDIS.get("last_reply_checked_at").to_i)).humanize
      processes = `ps aux | grep -i rails`.to_s

      admins = User.where(admin: true)
      data = {
        last_checked: "#{last_checked} ago",
        rm_running: processes.scan(/reply/).size
      }
      admins.each do |admin|
        AdminChannel.broadcast_to(admin, data)
      end
    end

    def self.update_admin_checked(account, emails: 0, replies: 0, message: nil, type: 'info')

      admins = User.where(admin: true)
      admins.each do |admin|

      if message.nil?
        data = {
            checked_update: {
              message: "Checked #{account.address}. #{emails} emails. #{replies} replies.",
              type: type
            }
        }
      else
        data = {
            checked_update: {
                message: "#{message}",
                type: type
            }
        }
      end

      AdminChannel.broadcast_to(admin, data)

      end
    end
  end
end