require 'net/https'
require 'uri'

class Moip
  # include HTTParty
  CONFIG = YAML.load_file(File.join(RAILS_ROOT, 'config', 'gateway.yml'))[RAILS_ENV]
  STATUS = { 1 => "authorized", 2 => "started", 3 => "printed", 4 => "completed", 5 => "canceled", 6 => "analysing"}

  class << self
    def authorize(attributes = {})
      logger.info "Authorizing transaction with Gateway"
      
      xml = request_body(attributes)
      parse_content perform_request(xml)
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
    def request_body(args)
      raise "Invalid data to do the request" unless valid_request_for?(args)

      xml = Builder::XmlMarkup.new.EnviarInstrucao do |e|
        e.InstrucaoUnica do |i|
          i.Razao args[:reason]
          i.IdProprio args[:id]
          i.URLRetorno "http://#{args[:domain]}/"
          i.URLNotificacao "http://#{args[:domain]}/payment_return/"
          i.Valores {|v| v.Valor(args[:value], :moeda => "BRL")}
          i.FormasPagamento { |p|
            p.FormaPagamento "BoletoBancario"
            p.FormaPagamento "CartaoCredito"
          }
        end
      end
    end

    def perform_request(body)
      uri = URI.parse("#{CONFIG["uri"]}/ws/alpha/EnviarInstrucao/Unica")

      req = Net::HTTP::Post.new(uri.path)
      req.body = body
      req.basic_auth CONFIG["token"], CONFIG["key"]

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.request(req).body
    end

    def parse_content(raw_data)
      raise "Webservice can't be reached" if raw_data.nil?

      content = Hash.from_xml(raw_data)
      content = content["EnviarInstrucaoUnicaResponse"]["Resposta"]

      content["Status"] == "Sucesso" ? content : raise("Fail to authorize")
    end

    def valid_request_for?(args)
      args[:reason] && args[:id] && args[:value] && args[:domain]
    end

    def logger
      Rails.logger
    end

  end

end