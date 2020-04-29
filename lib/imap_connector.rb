
module IMAPConnector
  class IMAPApi
    attr_accessor :errors, :service, :messages

    def initialize emailaccount
      require 'net/imap'
      require 'mail'
      require 'date'

      @emailaccount = emailaccount
      @errors = []
      @messages = []
      @service = get_service emailaccount
    end

    def replier_logger
      @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
    end

    def get_messages(limit: 500, unread: true)

      folders =  @service.list('', "*")

      inbox = folders.any? { |h| h.name.to_s.downcase == 'inbox' } ? folders.find { |h| h.name.to_s.downcase == 'inbox' }.name : 'INBOX'

      @service.examine(inbox)

      start_date = 1.year.ago.strftime("%d-%b-%Y") #change to 1.week.ago

      tags = ["SINCE", start_date]

      tags.unshift('UNSEEN') if unread

      @service.search(tags).each do |message_id|

        obj = {}

        if limit < 1
          break
        end

        email = @service.fetch(message_id, "RFC822")[0].attr["RFC822"]

        msg = Mail.read_from_string email

        date = DateTime.rfc3339(msg.date.to_s)
        formatted_date = date.strftime("%a, %b %d, %Y at %I:%M %p")

        thebody = msg.body.to_s

        from = msg[:from].display_names.first

        mid = msg.body.to_s[0, 30]
        body = msg.body.to_s.split(mid)
        thebody = ""

        puts "==========================================MSG"
        puts msg.content_type
        puts msg.main_type
        puts msg.sub_type
        puts msg.multipart?
        # puts msg.html_part
        puts msg.text_part
        # puts msg.body

        # body.each do |m|
        #   if m.include?("Content-Type: text/plain; charset=\"UTF-8\"")
        #     text = m.gsub("\n\n", "")
        #     text = text.gsub("\nContent-Type: text/plain; charset=\"UTF-8\"", "")
        #     thebody << text
        #     break
        #   end
        # end
        #
        # thebody = thebody.to_s.gsub("\r\n", " ")
        # thebody = thebody.truncate(80, separator: " ")
        #
        # date = DateTime.parse(msg.date.to_s)
        # formatted_date = date.strftime('%a, %b %d, %Y at %I:%M %p')
        # subject = msg.subject
        # from = from

        # body_html = (msg.html_part.body.to_s rescue "")
        # body_html = (msg.text_part.body.to_s rescue "") if body_html.strip.blank?
        # body_text = (msg.text_part.body.to_s rescue "").strip.blank? ? (msg.html_part.body.to_s rescue "") : (msg.text_part.body.to_s rescue "")
        # body_html = thebody.gsub("\n","<br>\n") if body_html.blank?
        # body_text = thebody if body_text.blank?
        # body = thebody

        # obj['date'] = date
        # obj['subject'] = subject
        # obj['from'] = from
        # obj['id'] = i.id
        # obj['thread_id'] = i.thread_id
        # obj['reply_to'] = reply_to
        # obj['body_size'] = payload.body.size rescue 0
        # obj['msgid'] = msgid.tr('<>', '')
        # obj['unread'] = (email.label_ids || []).include?("UNREAD")

        # @messages.push({date: formatted_date, subject:subject, body: thebody, from: from})

        limit -= 1

      end
    end

    def create_reply_draft

    end

    def read_messages

    end

    def is_thread_message!

    end

    private

      def get_service emailaccount
          ssl = emailaccount.imap_ssl ? {ssl_version: :TLSv1_2} : false
          port = emailaccount.imap_port ? emailaccount.imap_port : 993
          host = emailaccount.imap_host.to_s.empty? ? emailaccount.address.to_s.split("@").last : emailaccount.imap_host

          service = Net::IMAP.new(host, ssl: ssl, port: port )

          service.login(emailaccount.address, emailaccount.password)

          service
      end
  end
end


