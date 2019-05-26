require 'rails_helper'

RSpec.describe LeadService, type: :module do
  let(:app_config) { Rails.application.config }
  let(:customer_info) {{
    name: 'John Doe',
    business_name: 'Test Inc.',
    telephone_number: '07678977833',
    email: 'john.doe@example.com'
  }}
  let(:default_params) {{
    pGUID: app_config.lead_api_pguid,
    pAccName: app_config.lead_api_paccname,
    pPartner: app_config.lead_api_ppartner,
    access_token: app_config.lead_api_access_token
  }}
  let(:params) { default_params.merge(customer_info) }

  subject { described_class.create(params) }

  context 'when it is a successful request' do
    it 'returns a response with success message' do
      VCR.use_cassette("successful_lead_create_response") do
        expect(subject[:success]).to eq(LeadService::SUCCESS_MESSAGE)
      end
    end
  end

  context 'when there is a tcp connection failure' do
    it 'returns a response with error message' do
      expect_any_instance_of(Net::HTTP).to receive(:request).and_raise(SocketError.new)
      expect(subject).to eq({ error: 'SocketError'} )
    end
  end

  context 'when the request is not authorized' do
    let(:default_params) {{
      pGUID: app_config.lead_api_pguid,
      pAccName: app_config.lead_api_paccname,
      pPartner: app_config.lead_api_ppartner,
      access_token: "test_access_token"
    }}

    it 'returns a response with error message' do
      VCR.use_cassette("failure_authorization_lead_create_response") do
        expect(subject[:error]).to eq("Unauthorised access_token")
      end
    end
  end

  context 'when the required attributes are not valid' do
    let(:customer_info) {{
      name: 'John',
      business_name: 'Test Inc.',
      telephone_number: '076777833a',
      email: 'john.doe.com'
    }}

    let(:errors) {
      ["Field 'name' wrong format, 'name' must be composed with 2 separated words (space between)","Field 'telephone_number' wrong format (must contain have valid phone number with 11 numbers. string max 13 chars)","Field 'email' wrong format"]
    }

    it 'returns a response with validation errors' do
      VCR.use_cassette("failure_validation_errors_lead_create_response") do
        expect(subject[:errors]).to eq(errors)
      end
    end
  end
end
