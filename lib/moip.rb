class Moip
  RestClient.log = File.join(RAILS_ROOT, 'log', 'rest.log')
  MOIP = YAML.load_file(File.join(RAILS_ROOT, 'config', 'gateway.yml'))[RAILS_ENV]

  def self.authorize(value,razao)
    builder = Builder::XmlMarkup.new
    xml = builder.EnviarInstrucao do |e|
      e.InstrucaoUnica do |i|
        i.Razao razao
        i.Valores {|v| v.Valor(value, :moeda=>"BRL")}
        i.IdProprio rand(5000)
      end
    end

    moip = RestClient::Resource.new(MOIP["uri"], MOIP["token"], MOIP["key"])
    response = moip['EnviarInstrucao/Unica'].post xml, :content_type => 'text/xml'
    Crack::XML.parse(response)["ns1:EnviarInstrucaoUnicaResponse"]
  end
  
end
