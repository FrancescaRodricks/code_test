require 'net/http'

module LeadService
  SUCCESS_MESSAGE = "Thank you for using Make It Cheaper! We have received your request and one of our team will be in touch soon.".freeze
  BASE_API_URI = Rails.application.config.lead_api_base_uri

  def self.create(params)
    uri = URI("#{BASE_API_URI}/api/v1/create")
    req = Net::HTTP::Post.new(uri)

    req.set_form_data(params)

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    case res
    when Net::HTTPSuccess
      { success: SUCCESS_MESSAGE }
    else
      error = JSON.parse(res.body)
      if error.dig('errors')
        { errors: error['errors'] }
      elsif error.dig('message')
        { error: error['message'] }
      end
    end
  rescue SocketError => error
    { error: "#{error.message}" }
  end
end
