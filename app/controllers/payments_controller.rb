class PaymentsController < ApplicationController

  def direct_charge
    response = Moip.authorize(:reason=>"Teste",:id=>"15", :value=>1)
    redirect_to Moip.charge_url(response)
  end

  def manual_charge
    @response = Moip.authorize(:reason=>"Teste",:id=>"14", :value=>1)
  end

end