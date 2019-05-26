module LeadsHelper
  def api_paccname
    Rails.application.config.lead_api_paccname
  end

  def api_pguid
    Rails.application.config.lead_api_pguid
  end

  def api_ppartner
    Rails.application.config.lead_api_ppartner
  end
end


