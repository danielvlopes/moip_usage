class PaymentsController < ApplicationController

  def direct_charge
    response = Moip.authorize(:reason=>"Mensalidade",:id=>"62", :value=>1)
    redirect_to Moip.charge_url(response)
  end

  def manual_charge
    @response = Moip.authorize(:reason=>"Mensalidade",:id=>"60", :value=>1)
  end

end
