module GoogleConnector

  class GmailApi

    def initialize emailaccount
      @emailaccount = emailaccount
      @service = get_service
    end

    def get_messages

      refresh = refresh_api!

      if refresh
        unless refresh.nil?
          return false
        end
      end

      list = @service.list_user_messages('me', label_ids: ['UNREAD', 'INBOX'])

      email_array = []

      if set = list.messages
        set.each do |i|
          obj = {}
          email = @service.get_user_message('me', i.id)
          headers = email.payload.headers
          subject = headers.any? { |h| h.name == 'Subject' } ? headers.find { |h| h.name == 'Subject' }.value : ''

          obj['id'] = i.id
          obj['subject'] = subject
          obj['thread_id'] = i.thread_id

          body = email.payload.body.data
          if body.nil? && email.payload.parts.any?
            body = email.payload.parts.map { |part| part.body.data }.join
          end

          obj['message'] = body

          # email.payload.parts.each do |part|
          #   if part.body.data
          #     obj['message'] = part.body.data
          #     break
          #   end
          # end

          email_array.push(obj)
        end
      end

      email_array

    end


    def create_reply_draft thread_id

      require 'rmail'
      message = RMail::Message.new
      message.header['To'] = 'marjonedev@gmail.com'
      # message.header['From'] = 'marjone@owlreply.com'
      message.header['Subject'] = 'Test Draft'
      message.body = 'Test Body'

      @service.create_user_draft(
          "me",
          Google::Apis::GmailV1::Draft.new(
              :message => Google::Apis::GmailV1::Message.new(
                  :raw => message.to_s,
                  :thread_id => thread_id
              )
          )
      )

      # puts "====================================="
      # puts message

    end

    def read_messages email_ids

      @service.batch_modify_messages("me", {
          ids: email_ids,
          remove_label_ids: %w(UNREAD),
      }, options: {})

    end

    def refresh_token

      url = URI("https://accounts.google.com/o/oauth2/token")
      request = Net::HTTP.post_form url, { "refresh_token" => @emailaccount.google_refresh_token,
                                           "client_id" => api_client_id,
                                           "client_secret" => api_client_secret,
                                           "grant_type" => 'refresh_token'}

      data = JSON.parse(request.body)
      result = nil

      if data.key?("error")
        result = {'error' => data['error_description'] ? data['error_description'] : data['error']}
        # empty_account(account)
      else
        expires_in = Time.now.to_i + data['expires_in']
        @emailaccount.update(google_access_token: data['access_token'],
                       google_expires_in: expires_in)
      end

      result

    end

    def refresh_api!
      if @emailaccount.google_expires_in.to_i > Time.now.to_i
        refresh_token
      else
        false
      end
    end

    def revoke_access

      refresh = refresh_api!

      if refresh && !refresh.nil?
        empty_account
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

end
