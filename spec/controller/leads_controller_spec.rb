require "rails_helper"

RSpec.describe LeadsController, type: :controller do
  describe 'GET new' do
    subject { get :new }

    it 'renders the \'new\' template' do
      subject

      expect(response)
        .to render_template('new')
    end

    it 'has a 200 status code' do
      subject

      expect(response.status).to eq(200)
    end

    it 'creates an instance of Lead' do
      expect(Lead).to receive(:new) { @lead }

      subject
    end
  end

  describe 'POST create' do
    let(:params) {{ lead: customer_info.merge(config_lead_api_params) }}
    let(:app_config) { Rails.application.config }
    let(:config_lead_api_params) {{
      pguid: app_config.lead_api_pguid,
      paccname: app_config.lead_api_paccname,
      ppartner: app_config.lead_api_ppartner
    }}
    let(:api_request_params) { {
      pGUID: app_config.lead_api_pguid,
      pAccName: app_config.lead_api_paccname,
      pPartner: app_config.lead_api_ppartner,
      access_token: app_config.lead_api_access_token
    }}
    let(:customer_info) {{
      name: 'John Doe',
      business_name: 'Test Inc.',
      telephone_number: '07678977833',
      email: 'john.doe@example.com'
    }}

    subject { post :create , params: params }

    context 'with valid attributes' do

      let(:response_hash) {{
        success: LeadService::SUCCESS_MESSAGE
      }}

      it 'redirects to the root page' do
        expect(LeadService)
          .to receive(:create)
          .with(api_request_params.merge(customer_info)) { response_hash }
        expect(subject)
          .to redirect_to(root_url)
      end
    end

    context 'when the network is down' do
      let(:response_hash) {{
        error: "Failed to open TCP connection to mic-leads.dev-test.makeiteasy.com:80 (getaddrinfo: Temporary failure in name resolution)"
      }}

      it 'redirects to the root page' do
        expect(LeadService)
          .to receive(:create)
          .with(api_request_params.merge(customer_info)) { response_hash }
        expect(subject)
          .to redirect_to(root_url)
      end
    end

    context 'with invalid attributes' do
      let(:customer_info) {{
        name: 'J',
        business_name: '',
        telephone_number: '99',
        email: 'john.doe'
      }}
      let(:response_hash) {{
        errors: [
          "Field 'name' wrong format, 'name' must be composed with 2 separated words (space between)",
          "Field 'business_name' is blank",
          "Field 'telephone_number' wrong format (must contain have valid phone number with 11 numbers. string max 13 chars)",
          "Field 'email' wrong format"]
      }}

      it 'renders new template' do
        expect(LeadService)
          .to receive(:create)
          .with(api_request_params.merge(customer_info)) { response_hash }
        expect(subject)
          .to render_template("new")
      end
    end
  end
end

