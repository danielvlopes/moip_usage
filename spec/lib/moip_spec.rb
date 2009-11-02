require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Moip do

  describe "when call authorize" do
    before :each do
      @id = valid_id
    end

    it "should mount a valid xml based in params" do
      Moip.stub!(:post).and_return(response_content(@id))
      Moip.should_receive(:mount_request).and_return(request_content(@id))
      Moip.authorize(:reason=>"Mensalidade",:id=>@id, :value=>1)
    end

    context "and get a response" do
      before :all do
        @response = Moip.authorize(:reason=>"Mensalidade",:id=>@id, :value=>1)
      end

      it "should have status Sucesso" do
        @response["Resposta"]["Status"].should == "Sucesso"
      end
      it "should have a Token" do
        @response["Resposta"]["Token"].should be_present
      end
      it "should have an ID" do
        @response["Resposta"]["ID"].should be_present
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

  def response_content(id)
    {"ns1:EnviarInstrucaoUnicaResponse"=>{"Resposta"=>{"ID"=>id,"Status"=>"Sucesso","Token" => "T2N0L0X8E0S71217U2H3W1T4F4S4G4K731D010V0S0V0S080M010E0Q082X2"}}}
  end

  def valid_id
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end

end
