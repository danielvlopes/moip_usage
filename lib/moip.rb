class Moip
  include HTTParty
  CONFIG = YAML.load_file(File.join(RAILS_ROOT, 'config', 'gateway.yml'))[RAILS_ENV]
  STATUS = {1=>"authorized", 2=>"started", 3=>"printed", 4=>"completed", 5=>"canceled", 6=>"analysing"}

  base_uri "#{CONFIG["uri"]}/ws/alpha"
  basic_auth CONFIG["token"], CONFIG["key"]

  class << self
    def authorize(attributes = {})
      xml = mount_request(attributes)
      response = post('/EnviarInstrucao/Unica', :body => xml)
      raise(StandardError, "Webservice can't be reached") if response.nil?
      response = response["ns1:EnviarInstrucaoUnicaResponse"]["Resposta"]
      raise(StandardError, response["Erro"]) if response["Status"] == "Falha"
      response
    end

    def charge_url(token)
      "#{CONFIG["uri"]}/Instrucao.do?token=#{token}"
    end
    
    def notification(params)
      notification = {}
      notification[:transaction_id] = params["id_transacao"]
      notification[:amount]         = sprintf("%.2f", params["valor"].to_f / 100).to_d
      notification[:status]         = STATUS[params["status_pagamento"].to_i]
      notification[:code]           = params["cod_moip"]
      notification[:payment_type]   = params["tipo_pagamento"]
      notification[:email]          = params["email_consumidor"]
      notification
    end
    
  protected
    def mount_request(attributes)
      reason, id, value = attributes[:reason], attributes[:id], attributes[:value]
      xml = Builder::XmlMarkup.new.EnviarInstrucao do |e|
        e.InstrucaoUnica do |i|
          i.Razao reason
          i.IdProprio id
          i.UrlRetorno "http://www.google.com/"
          i.Valores {|v| v.Valor(value, :moeda=>"BRL")}
          i.FormasPagamento { |p|
            p.FormaPagamento "BoletoBancario"
            p.FormaPagamento "CartaoCredito"
          }
        end
      end
    end

  end

end