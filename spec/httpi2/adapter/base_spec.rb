require "spec_helper"
require "httpi2/adapter/base"

describe HTTPI2::Adapter::Base do

  subject(:base) { HTTPI2::Adapter::Base.new(request) }
  let(:request)  { HTTPI2::Request.new }

  describe "#client" do
    it "returns the adapter's client instance" do
      expect { base.client }.
        to raise_error(HTTPI2::NotImplementedError, "Adapters need to implement a #client method")
    end
  end

  describe "#request" do
    it "executes arbitrary HTTP requests" do
      expect { base.request(:get) }.
        to raise_error(HTTPI2::NotImplementedError, "Adapters need to implement a #request method")
    end
  end

end
