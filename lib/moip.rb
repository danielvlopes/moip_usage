class Moip
  include HTTParty
  CONFIG      = YAML.load_file(File.join(RAILS_ROOT, 'config', 'gateway.yml'))[RAILS_ENV]

  base_uri CONFIG["uri"]
  basic_auth CONFIG["token"], CONFIG["key"]

  cattr_accessor :test_url
  self.test_url = 'https://desenvolvedor.moip.com.br/sandbox'

  cattr_accessor :production_url
  self.production_url = 'https://moip.com.br'

  def self.authorize(attributes = {})
    reason,id,value = attributes[:reason], attributes[:id], attributes[:value]

    xml = Builder::XmlMarkup.new.EnviarInstrucao do |e|
      e.InstrucaoUnica do |i|
        i.Razao reason
        i.IdProprio id
        i.Valores {|v| v.Valor(value, :moeda=>"BRL")}
        i.FormasPagamento do |p|
          p.FormaPagamento "BoletoBancario"
          p.FormaPagamento "CartaoCredito"
        end
      end
    end

    response = post('/EnviarInstrucao/Unica', :body => xml)["ns1:EnviarInstrucaoUnicaResponse"]
    response["Resposta"]["Status"] == "Falha" ? raise(StandardError, response["Resposta"]["Erro"]) : response
  end

  def self.charge_url(response)
    if [RAILS_ENV] != "production"
      "#{self.test_url}/Instrucao.do?token=#{response["Resposta"]["Token"]}"
    else
      "#{self.production_url}/Instrucao.do?token=#{response["Resposta"]["Token"]}"
    end
  end

end