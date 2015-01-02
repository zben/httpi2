require "spec_helper"
require "integration/support/server"

describe HTTPI2::Adapter::NetHTTPPersistent do

  subject(:adapter) { :net_http_persistent }

  context "http requests" do
    before :all do
      @server = IntegrationServer.run
    end

    after :all do
      @server.stop
    end

    it "sends and receives HTTP headers" do
      request = HTTPI2::Request.new(@server.url + "x-header")
      request.headers["X-Header"] = "HTTPI2"

      response = HTTPI2.get(request, adapter)
      expect(response.body).to include("HTTPI2")
    end

    it "executes GET requests" do
      response = HTTPI2.get(@server.url, adapter)
      expect(response.body).to eq("get")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes POST requests" do
      response = HTTPI2.post(@server.url, "<some>xml</some>", adapter)
      expect(response.body).to eq("post")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes HEAD requests" do
      response = HTTPI2.head(@server.url, adapter)
      expect(response.code).to eq(200)
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes PUT requests" do
      response = HTTPI2.put(@server.url, "<some>xml</some>", adapter)
      expect(response.body).to eq("put")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes DELETE requests" do
      response = HTTPI2.delete(@server.url, adapter)
      expect(response.body).to eq("delete")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "supports basic authentication" do
      request = HTTPI2::Request.new(@server.url + "basic-auth")
      request.auth.basic("admin", "secret")

      response = HTTPI2.get(request, adapter)
      expect(response.body).to eq("basic-auth")
    end

    it "does not support ntlm authentication" do
      request = HTTPI2::Request.new(@server.url + "ntlm-auth")
      request.auth.ntlm("tester", "vReqSoafRe5O")

      expect { HTTPI2.get(request, adapter) }.
        to raise_error(HTTPI2::NotSupportedError, /does not support NTLM authentication/)
    end
  end

  # it does not support digest auth

  if RUBY_PLATFORM =~ /java/
    pending "Puma Server complains: SSL not supported on JRuby"
  else
    context "https requests" do
      before :all do
        @server = IntegrationServer.run(:ssl => true)
      end
      after :all do
        @server.stop
      end

      # it does not raise when no certificate was set up
      it "works when set up properly" do
        request = HTTPI2::Request.new(@server.url)
        request.auth.ssl.ca_cert_file = IntegrationServer.ssl_ca_file

        response = HTTPI2.get(request, adapter)
        expect(response.body).to eq("get")
      end
    end
  end

end
