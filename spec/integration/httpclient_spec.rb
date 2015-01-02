require "spec_helper"
require "integration/support/server"

describe HTTPI2::Adapter::HTTPClient do

  subject(:adapter) { :httpclient }

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

    it "it supports headers with multiple values" do
      request = HTTPI2::Request.new(@server.url + "cookies")

      response = HTTPI2.get(request, adapter)
      cookies = ["cookie1=chip1; path=/", "cookie2=chip2; path=/"]
      expect(response.headers["Set-Cookie"]).to eq(cookies)
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

    it "supports digest authentication" do
      request = HTTPI2::Request.new(@server.url + "digest-auth")
      request.auth.digest("admin", "secret")

      response = HTTPI2.get(request, adapter)
      expect(response.body).to eq("digest-auth")
    end

    it "supports chunked response" do
      request = HTTPI2::Request.new(@server.url)
      res = ""
      request.on_body do |body|
        res += body
      end
      response = HTTPI2.post(request, adapter)
      expect(res).to eq("post")
      expect(response.body).to eq("")
    end
  end

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

      it "raises when no certificate was set up" do
        expect { HTTPI2.post(@server.url, "", adapter) }.to raise_error(HTTPI2::SSLError)
      end

      it "works when set up properly" do
        request = HTTPI2::Request.new(@server.url)
        request.auth.ssl.ca_cert_file = IntegrationServer.ssl_ca_file

        response = HTTPI2.get(request, adapter)
        expect(response.body).to eq("get")
      end
    end
  end

end
