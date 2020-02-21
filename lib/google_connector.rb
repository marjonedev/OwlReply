module GoogleConnector

  class GmailApi

    def initialize emailaccount
      @emailaccount = emailaccount
      @service = get_service
    end

    def replier_logger
      @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
    end

    def get_messages

      begin
        refresh_api!
      rescue RefreshTokenFailureError => error
        replier_logger.error("GOOGLE: #{@emailaccount.address} - Failed to refresh user token. #{error.to_s}")
        return []
      end

      #if refresh
        #unless refresh.nil?
          #return false
        #end
      #end

      list = @service.list_user_messages('me', label_ids: ['UNREAD', 'INBOX'])

      email_array = []

      if set = list.messages
        set.each do |i|
          obj = {}
          email = @service.get_user_message('me', i.id)
          payload = email.payload
          headers = payload.headers
          subject = headers.any? { |h| h.name == 'Subject' } ? headers.find { |h| h.name == 'Subject' }.value : ''
          date = headers.any? { |h| h.name == 'Date' } ? headers.find { |h| h.name == 'Date' }.value : ''
          from = headers.any? { |h| h.name == 'From' } ? headers.find { |h| h.name == 'From' }.value.to_s : ''
          msgid = headers.any? { |h| h.name == 'Message-ID' } ? headers.find { |h| h.name == 'Message-ID' }.value.to_s : ''
          reply_to = headers.any? { |h| h.name == 'Reply-To' } ? headers.find { |h| h.name == 'Reply-To' }.value.to_s : ''

          obj['id'] = i.id
          obj['subject'] = subject
          obj['thread_id'] = i.thread_id
          obj['date'] = date
          obj['from'] = from
          obj['reply_to'] = reply_to
          obj['body'] = ""
          obj['body_html'] = nil
          obj['body_text'] = nil
          obj['body_size'] = payload.body.size rescue 0
          obj['msgid'] = msgid.tr('<>', '')

          # if body.nil? && payload.parts.any?
          #   body = payload.parts.map { |part| part.body.data }.join
          # end
          body = payload.body.data
          if body.nil? && payload.parts.any?
            obj['multipart'] = true
            payload.parts.each do |part|
              mime = part.mime_type
              if mime == "text/html"
                obj['body_html'] = part.body.data
                obj['body'] = part.body.data
              else
                obj['body_text'] = part.body.data
              end
            end
          else
            obj['multipart'] = false
            obj['body_text'] = body
            obj['body_html'] = body
            obj['body'] = body
          end


          email_array.push(obj)
        end
      end

      email_array

    end

    def create_reply_draft(id, thread_id: nil, to: nil, from: nil, subject: "", multipart: true, body_text: "",  body_html: "", msgid: nil)

      if thread_id.nil?
        thread_id = id
      end

      require 'mail'

      message = Mail.new do
        from    from
        to      to
        subject subject
        text_part do
          content_type 'text/plain; charset=UTF-8'
          body body_text
        end
        html_part do
          content_type 'text/html; charset=UTF-8'
          body body_html
        end
      end

      unless msgid.to_s.strip.empty?
        message.header['In-Reply-To'] = "<#{msgid}>"
        message.header['References'] = "<#{msgid}>"
      end

      puts message.to_s

      @service.create_user_draft(
          "me",
          Google::Apis::GmailV1::Draft.new(
              :message => Google::Apis::GmailV1::Message.new(
                  :raw => message.to_s,
                  :thread_id => thread_id,
                  :id => id,
              )
          )
      )

    end

    def read_messages email_ids
      if email_ids.any?
        @service.batch_modify_messages("me", {
            ids: email_ids,
            remove_label_ids: %w(UNREAD),
        }, options: {})
      end

    end

    def is_thread_message! thread_id
      thread = @service.get_user_thread("me", thread_id, format: 'minimal')
      thread.messages.count > 1
    end

    def refresh_this_token!

      url = URI("https://oauth2.googleapis.com/token")
      request = Net::HTTP.post_form url, { "refresh_token" => @emailaccount.google_refresh_token,
                                           "client_id" => api_client_id,
                                           "client_secret" => api_client_secret,
                                           "grant_type" => 'refresh_token'}

      data = JSON.parse(request.body)
      result = nil

      logger.debug "==============================================="
      logger.debug data
      puts data

      if data.key?("error")
        raise RefreshTokenFailureError.new(data['error_description'] ? data['error_description'] : data['error'])
        #result = {'error' => data['error_description'] ? data['error_description'] : data['error']}
        # empty_account(account)
      else
        expires_in = Time.now.to_i + data['expires_in']
        @emailaccount.update(google_access_token: data['access_token'],
                       google_expires_in: expires_in)
      end

      result

    end

    def refresh_api!
      if Time.now.to_i > @emailaccount.google_expires_in.to_i
        refresh_this_token!
      end
    end

    def revoke_access

      begin
        refresh_api!
      rescue RefreshTokenFailureError => error
        replier_logger.error("GOOGLE: #{@emailaccount.address} - Failed to refresh user token. #{error.to_s}")
        return false
      end


      revoke = false
      token = nil

      if @emailaccount.google_access_token?
        token = @emailaccount.google_access_token
        revoke = true
      elsif @emailaccount.google_refresh_token?
        token = @emailaccount.google_refresh_token
        revoke = true
      end


      if revoke
        url = URI("https://accounts.google.com/o/oauth2/revoke")
        request = Net::HTTP.post_form url, { "token" => token }

        if request.code.to_i == 200
          empty_account
          true
        else
          false
        end

      else

        false

      end

    end

    private

      Gmail = Google::Apis::GmailV1

      def get_service
        client = Signet::OAuth2::Client.new(access_token: @emailaccount.google_access_token)
        service = Gmail::GmailService.new

        service.authorization = client

        service
      end

      def api_client_id
        Rails.application.credentials.google_api_client_id
      end

      def api_client_secret
        Rails.application.credentials.google_client_secret
      end

      def empty_account
        @emailaccount.update(google_access_token: nil,
                             google_expires_in: nil,
                             google_refresh_token: nil,
                             authenticated: false,
                             email_provider: nil)
      end

  end

  class UnauthorizedError < StandardError
  end
  class RefreshTokenFailureError < StandardError
    def initialize(message = "Refresh token failure.")
      super(message)
    end
  end

end
