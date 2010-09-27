class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:payment_return]

  def direct_charge
    response = Moip.authorize({
     :reason => "Mensalidade",
     :id => "Pag#{rand(1000)}",
     :value => 1,
     :domain => request.domain
    })

    redirect_to Moip.charge_url(response["Token"])
  end

  def manual_charge
    @response = Moip.authorize({
     :reason => "Mensalidade",
     :id => "Pag#{rand(1000)}",
     :value => 1,
     :domain => request.domain
    })
  end

  def payment_return
    notification = Moip.notification(params)
    logger.info { notification.to_yaml }
    render :text => "Status changed", :status => 200
  end

end