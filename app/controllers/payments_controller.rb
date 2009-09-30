class PaymentsController < ApplicationController
  
  def charge
    response = Moip.authorize("2","Teste")
    redirect_to moip_url(response["Resposta"]["Token"])
  end

private

  def moip_url(token)
    "https://desenvolvedor.moip.com.br/sandbox/Instrucao.do?token=#{token}"
  end

end