
module IMAPConnector
  class IMAPApi
    attr_accessor :errors, :service, :messages

    def initialize emailaccount
      require 'net/imap'
      require 'date'
      require 'mail'

      @emailaccount = emailaccount
      @errors = []
      @messages = []
      @service = get_service emailaccount

      @folders =  @service.list('', "*")
      @drafts = @folders.any? { |h| h.attr.include? :Drafts } ? @folders.find { |h| h.attr.include? :Drafts }.name : 'DRAFTS'
      @inbox = @folders.any? { |h| h.name.to_s.downcase == 'inbox' } ? @folders.find { |h| h.name.to_s.downcase == 'inbox' }.name : 'INBOX'

    end

    def replier_logger
      @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
    end

    def get_messages(limit: 500, unread: true)

      @service.examine(@inbox)

      start_date = 1.week.ago.strftime("%d-%b-%Y") #change to 1.week.ago

      tags = ["SINCE", start_date]

      tags.unshift('UNSEEN') if unread

      tags2 = ["SINCE", start_date]
      tags2.unshift('UNSEEN')
      unseen = @service.search(tags2).sort.reverse

      @service.search(tags).sort.reverse.each do |message_id|

        obj = {}

        if limit < 1
          break
        end

        email = @service.fetch(message_id, "RFC822")[0].attr["RFC822"]

        msg = Mail.read_from_string email

        date = msg.date
        formatted_date = date.strftime("%a, %b %d, %Y at %I:%M %p")

        # from = msg[:from].display_names.first
        from = msg[:from]
        subject = msg[:subject]
        reply_to = msg.reply_to.blank? ? msg[:from] : msg[:reply_to]
        reply_to_addr = msg.reply_to.blank? ? msg.from : msg.reply_to
        plain_part = msg.multipart? ? (msg.text_part ? msg.text_part.body.decoded : nil) : msg.body.decoded
        html_part = msg.html_part ? msg.html_part.body.decoded : nil
        body = if msg.multipart?
                 msg.text_part ? msg.text_part.body.decoded : msg.html_part.body.decoded
               else
                 msg.body.decoded
               end

        obj["is_thread"] = msg.in_reply_to.to_s.empty? ? false : true

        @messages.each do |ms|
          if ms['reference'].to_s.include?(msg.message_id)
            obj["is_thread"] = true
            break
          end
        end

        # obj['thread_id'] = i.thread_id
        obj['id'] = message_id
        obj['subject'] = subject
        obj['date'] = formatted_date
        obj['from'] = from
        obj['reply_to'] = reply_to
        obj['reply_to_addr'] = reply_to_addr
        obj['body'] = body
        obj['body_html'] = html_part
        obj['body_text'] = plain_part
        obj['unread'] = unseen.include?(message_id)
        obj['multipart'] = msg.multipart?
        obj['msgid'] = msg.message_id
        obj['reference'] = msg.references&.first

        @messages.push(obj)

        limit -= 1

      end

      return @messages
    end

    def create_reply_draft(id: nil, thread_id: nil, to: nil, from: nil, subject: "", body_text: "",  body_html: "", msgid: nil)

      require 'mail'

      mail = Mail.new do
        from    from
        to      to
        subject "Re: #{subject}"
        text_part do
          content_type 'text/plain; charset=UTF-8'
          # body account.template.gsub("%%reply%%",auto)+"\n\nIn reply to:\n\n"+(body_text)
          body body_text
        end
        html_part do
          content_type 'text/html; charset=UTF-8'
          body body_html
        end
      end

      unless msgid.to_s.strip.empty?
        mail.header['In-Reply-To'] = "<#{msgid}>" #message_id
        mail.header['References'] = "<#{msgid}>"
      end

      message = mail.to_s

      @service.append(@drafts, message, [:Draft], Time.now)
    end

    def read_messages ids
      if ids.any?
        @service.select(@inbox)
        @service.store(ids, "+FLAGS", [:Seen])
      end
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


