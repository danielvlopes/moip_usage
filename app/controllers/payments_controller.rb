class PaymentsController < ApplicationController

  def direct_charge
    response = Moip.authorize(:reason=>"Mensalidade",:id=>"PagamentoComRedirect", :value=>1)
    redirect_to Moip.charge_url(response["Token"])
  end

  def manual_charge
    @response = Moip.authorize(:reason=>"Mensalidade",:id=>"PagamentoManual", :value=>1)
  end

end
