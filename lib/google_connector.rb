module GoogleConnector
  def read_messages(emailaccount)
    # begin
    client = Signet::OAuth2::Client.new(access_token: emailaccount.google_access_token)
    service = Google::Apis::GmailV1::GmailService.new

    service.authorization = client
    refresh_api!(emailaccount)

    list = service.list_user_messages('me', label_ids: ["UNREAD"])

    email_array = []

    if set = list.messages
      set.each do |i|
        obj = {}
        email = service.get_user_message('me', i.id)
        headers = email.payload.headers
        subject = headers.any? { |h| h.name == 'Subject' } ? headers.find { |h| h.name == 'Subject' }.value : ''

        obj['id'] = i.id
        obj['subject'] = subject

        email.payload.parts.each do |part|
          if part.body.data
            obj['message'] = part.body.data
            break
          end
        end

        email_array.push(obj)
      end
    end

    email_array.each do |i|
      create_drafts(i, emailaccount)
    end
  end

  def create_drafts(userid, emailaccount)
    client = Signet::OAuth2::Client.new(access_token: emailaccount.google_access_token)
    service = Google::Apis::GmailV1::GmailService.new

    service.authorization = client
    # refresh_api!(emailaccount)

    require 'rmail'
    message = RMail::Message.new
    message.header['To'] = 'marjonedev@gmail.com'
    message.header['From'] = 'marjone.owlreply@gmail.com'
    message.header['Subject'] = 'Test Draft'
    message.body = 'Test Body'

    service.create_user_draft(userid,
                              upload_source: StringIO.new(message.to_s),
                              content_type: 'message/rfc822')
    puts "====================================="
    puts message

  end

  def refresh_token(account)
    api_client_id = Rails.application.credentials.google_api_client_id
    api_client_secret = Rails.application.credentials.google_client_secret

    url = URI("https://accounts.google.com/o/oauth2/token")
    request = Net::HTTP.post_form url, { "refresh_token" => account.google_refresh_token,
                                         "client_id" => api_client_id,
                                         "client_secret" => api_client_secret,
                                         "grant_type" => 'refresh_token'}

    data = JSON.parse(request.body)

    expires_in = Time.now.to_i + data['expires_in']
    account.update(google_access_token: data['access_token'],
                   google_expires_in: expires_in)
  end

  def refresh_api!(account)
    refresh_token(account) if account.google_expires_in.to_i < Time.now.to_i
  end

  def revoke_access(account)

    refresh_api!(account)

    revoke = false
    token = nil

    if account.google_access_token?
      token = account.google_access_token
      revoke = true
    elsif account.google_refresh_token?
      token = account.google_refresh_token
      revoke = true
    end

    if revoke
      url = URI("https://accounts.google.com/o/oauth2/revoke")
      request = Net::HTTP.post_form url, { "token" => token }

      if request.code == 200
        account.update(google_access_token: nil,
                       google_expires_in: nil,
                       google_refresh_token: nil,
                       authenticated: false,
                       email_provider: nil)
        true
      else
        false
      end

    else

      false

    end

  end
end
