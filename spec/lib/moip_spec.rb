require "spec_helper"

describe Moip do

  let :valid_id do
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  let :params do
    {:reason => "Mensalidade",:id => valid_id, :value => 1, :domain => "foo.mysite.com"}
  end

  before :all do
    EphemeralResponse.activate
    @response = Moip.authorize(:reason => "Mensalidade",:id => valid_id, :value => 1, :domain => "foo.mysite.com")
  end

  after :all do
    EphemeralResponse.deactivate
  end

  describe "#authorize" do
    it "should have status Sucesso" do
      @response["Status"].should == "Sucesso"
    end

    it "should have a Token" do
      @response["Token"].should be_present
    end

    it "should have an ID" do
      @response["ID"].should be_present
    end

    context "error" do

      context "required informations" do
        it "should raise an error without any of the required info" do
          params.each do |key, value|
            lambda do
              Moip.authorize(params.replace({ key => nil }))
            end.should raise_error("Invalid data to do the request")
          end
        end
      end

      it "should raise a exception if status is not success" do
        invalid_request = File.open(File.join(Rails.root, "spec/fixtures/moip_error.xml")).read

        Moip.class_eval do
          self.stubs(:perform_request).returns(invalid_request)
        end

        lambda do
          Moip.authorize(params)
        end.should raise_error("Fail to authorize")
      end

      it "should raise a exception if response is nil" do
        Moip.class_eval do
          self.stubs(:perform_request).returns(nil)
        end

        lambda do
          Moip.authorize(params)
        end.should raise_error("Webservice can't be reached")
      end
    end

  end

  describe "when receive notification" do

    let :params do
      {"id_transacao" => "Pag706", "status_pagamento" => "4", "email_consumidor" => "joao@gmail.com", "valor" => "555", "forma_pagamento" => "73", "tipo_pagamento" => "BoletoBancario", "cod_moip" => "2331"}
    end

    it "should return a hash with params" do
      response = {:transaction_id => "Pag706", :amount => 5.55, :status => "completed", :code => "2331",:payment_type => "BoletoBancario", :email => "joao@gmail.com" }
      Moip.notification(params).should == response
    end

    it "should return valid status based on status code" do
      Moip::STATUS[1].should == "authorized"
      Moip::STATUS[2].should == "started"
      Moip::STATUS[3].should == "printed"
      Moip::STATUS[4].should == "completed"
      Moip::STATUS[5].should == "canceled"
      Moip::STATUS[6].should == "analysing"
    end
  end

  describe "when call charge url" do
    it "should return a valid url based on response token" do
      token = @response["Token"]
      Moip.charge_url(token).should == "https://desenvolvedor.moip.com.br/sandbox/Instrucao.do?token=#{token}"
    end
  end

  def request_content(id)
    Builder::XmlMarkup.new.EnviarInstrucao do |e|
      e.InstrucaoUnica do |i|
        i.Razao "Mensalidade"
        i.IdProprio id
        i.URLRetorno "http://foo.mysite.com/"
        i.URLNotificacao "http://foo.mysite.com/payment_return/"
        i.Valores {|v| v.Valor(1, :moeda => "BRL")}
        i.FormasPagamento { |p|
          p.FormaPagamento "BoletoBancario"
          p.FormaPagamento "CartaoCredito"
        }
      end
    end
  end

end