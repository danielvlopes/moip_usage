class Moip
  include HTTParty
  CONFIG = YAML.load_file(File.join(RAILS_ROOT, 'config', 'gateway.yml'))[RAILS_ENV]

  base_uri "#{CONFIG["uri"]}/ws/alpha"
  basic_auth CONFIG["token"], CONFIG["key"]

  class << self
    def authorize(attributes = {})
      xml = mount_request(attributes)
      response = post('/EnviarInstrucao/Unica', :body => xml)
      raise(StandardError, "Webservice can't be reached") if response.nil?
      response = response["ns1:EnviarInstrucaoUnicaResponse"]
      raise(StandardError, response["Resposta"]["Erro"]) if response["Resposta"]["Status"] == "Falha"
      response
    end

    def charge_url(token)
      "#{CONFIG["uri"]}/Instrucao.do?token=#{token}"
    end

  protected
    def mount_request(attributes)
      reason, id, value = attributes[:reason], attributes[:id], attributes[:value]
      xml = Builder::XmlMarkup.new.EnviarInstrucao do |e|
        e.InstrucaoUnica do |i|
          i.Razao reason
          i.IdProprio id
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