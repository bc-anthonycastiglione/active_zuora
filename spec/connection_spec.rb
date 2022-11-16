require 'spec_helper'

WSDL = File.expand_path('../../wsdl/zuora.wsdl', __FILE__)

describe ActiveZuora::Connection do
  let(:dub) { double('resp').as_null_object }
  before do
    @connection = ActiveZuora::Connection.new
    allow(Savon).to receive(:client).with(wsdl: WSDL).and_return dub
  end

  context "custom header" do
    it "passes the regular header if not set" do
      expect(dub).to receive(:call).with(:amend, message: hash_including(header: { "SessionHeader" => {"session" => nil} }))
      @connection.request(:amend) {}
    end

    it "merges in a custom header if set" do
      @connection.custom_header = {'CallOptions' => {'useSingleTransaction' => true}}

      expect(dub).to receive(:call).with(:amend, message: hash_including(header: { "SessionHeader" => {"session" => nil}, 'CallOptions' => {'useSingleTransaction' => true} }))
      @connection.request(:amend) {}
    end
  end

  describe 'login' do
    context 'when a custom header is set' do
      it 'uses the custom header' do
        @connection.custom_header = { 'TestHeader' => 'Foo' }
        expect(dub).to receive(:call).with(:login, message: hash_including(header: { 'TestHeader' => 'Foo' })).and_return dub

        @connection.login
      end
    end

    context 'when a custom header is not set' do
      it 'does not use the custom header' do
        expect(dub).to receive(:call).with(:login, message: hash_including(header: nil)).and_return dub

        @connection.login
      end
    end
  end
end
