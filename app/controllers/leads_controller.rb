module LeadsHelper
  def api_access_token
    Rails.application.config.lead_api_access_token
  end

  def api_params(params)
    params[:pGUID] = params.delete(:pguid)
    params[:pAccName] = params.delete(:paccname)
    params[:pPartner] = params.delete(:ppartner)
    params[:access_token] = api_access_token
    params
  end

  def validation_error_messages(response)
    response.each do |error|
      error.split(",").each do |err|
        error_msg_collection = err.split("'")
        @lead.errors.messages[error_msg_collection[1]] << error_msg_collection[-1].strip
      end
    end
  end
end

class LeadsController < ApplicationController
  def new
    @lead = Lead.new
  end

  def create
    @lead = Lead.new(lead_params)
    api_request_params = helpers.api_params lead_params.to_h
    response = LeadService.create api_request_params
    if response[:success]
      redirect_to root_url, { flash: response }
    elsif response[:errors]
      helpers.validation_error_messages(response[:errors])
      render :new
    else
      redirect_to root_url, { flash: response }
    end
  end

  private

  def lead_params
    params.require(:lead).permit(
      :paccname,
      :pguid,
      :ppartner,
      :name,
      :business_name,
      :email,
      :telephone_number
    )
  end
end
