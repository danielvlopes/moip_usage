class Moip
  include HTTParty
  MOIP = YAML.load_file(File.join(RAILS_ROOT, 'config', 'gateway.yml'))[RAILS_ENV]

  base_uri MOIP["uri"]
  basic_auth MOIP["token"], MOIP["key"]

  def self.authorize(value,razao)
    builder = Builder::XmlMarkup.new
    xml = builder.EnviarInstrucao do |e|
      e.InstrucaoUnica do |i|
        i.Razao razao
        i.Valores {|v| v.Valor(value, :moeda=>"BRL")}
        i.IdProprio rand(5000)
      end
    end
    
    response = post('/EnviarInstrucao/Unica', :body => xml)
    response["ns1:EnviarInstrucaoUnicaResponse"]
  end

end
