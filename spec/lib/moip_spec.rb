require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Moip do

  describe "when call authorize" do
    it "should mount a valid xml based in params" do
      id = valid_id
      Moip.stub!(:post).and_return(response_content)
      Moip.should_receive(:mount_request).and_return(request_content(id))
      Moip.authorize(:reason=>"Mensalidade",:id=>id, :value=>1)
    end

    context "and get a response" do
      before :all do
        @response = Moip.authorize(:reason=>"Mensalidade",:id=>valid_id, :value=>1)
      end

      it "should have status Sucesso" do
        @response["Status"].should == "Sucesso"
      end
      it "should have a Token" do
        @response["Token"].should be_present
      end
      it "should have an ID" do
        @response["ID"].should be_present
      end
    end

    context "in error scenario" do
      it "should raise a exception if status is fail" do
        Moip.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>{"Resposta"=>{"Status"=>"Falha", "Erro"=>"Some error message"}})
        lambda { Moip.authorize(:reason=>"Mensalidade",:id=>"30", :value=>9) }.should raise_error(StandardError, "Some error message")
      end

      it "should raise a exception if response is nil" do
        Moip.stub!(:post).and_return(nil)
        lambda { Moip.authorize(:reason=>"Mensalidade",:id=>"30", :value=>9) }.should raise_error(StandardError, "Webservice can't be reached")
      end
    end
  end

  describe "when call charge url" do
    it "should return a valid url based on response token" do
      response = response_content
      Moip.charge_url(response["Token"]).should == "https://desenvolvedor.moip.com.br/sandbox/Instrucao.do?token=#{response["Token"]}"
    end
  end

  describe "when receive notification" do
    before(:each) do
      @params = {"id_transacao"=>"", "status_pagamento"=>"4", "email_consumidor"=>"joao@gmail.com", "valor"=>"555", "forma_pagamento"=>"73", "tipo_pagamento"=>"BoletoBancario", "cod_moip"=>"2331"}
    end

    it "should return a hash with params" do
      response = {:transaction_id=>"Pag706", :amount=>5.55, :status=>"completed", :code=>"2331",:payment_type=>"BoletoBancario", :email=>"joao@gmail.com" }
      Moip.notification(@params).should == response
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

  def request_content(id)
    xml = Builder::XmlMarkup.new.EnviarInstrucao do |e|
      e.InstrucaoUnica do |i|
        i.Razao "Month charge"
        i.IdProprio id
        i.Valores {|v| v.Valor(20, :moeda=>"BRL")}
        i.FormasPagamento { |p|
          p.FormaPagamento "BoletoBancario"
          p.FormaPagamento "CartaoCredito"
        }
      end
    end
  end

  def response_content
    {"ns1:EnviarInstrucaoUnicaResponse"=>{"Resposta"=>{"ID"=>Time.now.strftime("%y%m%d%H%M%S"),"Status"=>"Sucesso","Token" => "T2N0L0X8E0S71217U2H3W1T4F4S4G4K731D010V0S0V0S080M010E0Q082X2"}}}
  end

  def valid_id
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end

end
