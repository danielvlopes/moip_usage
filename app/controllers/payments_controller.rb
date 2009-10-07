class PaymentsController < ApplicationController

  def charge
    response = Moip.authorize(:reason=>"Teste",:id=>"12", :value=>1)
    redirect_to Moip.charge_url(response)
  end

end