require "spec_helper"
require "integration/support/application"

describe HTTPI2::Adapter::NetHTTP do

  subject(:adapter) { :rack }

  context "http requests" do
    before :all do
      @app = 'app'
      @url = "http://#{@app}/"

      HTTPI2::Adapter::Rack.mount @app, IntegrationServer::Application
    end

    it "sends and receives HTTP headers" do
      request = HTTPI2::Request.new(@url + "x-header")
      request.headers["X-Header"] = "HTTPI2"

      response = HTTPI2.get(request, adapter)
      expect(response.body).to include("HTTPI2")
    end

    it "executes GET requests" do
      response = HTTPI2.get(@url, adapter)
      expect(response.body).to eq("get")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes POST requests" do
      response = HTTPI2.post(@url, "<some>xml</some>", adapter)
      expect(response.body).to eq("post")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes HEAD requests" do
      response = HTTPI2.head(@url, adapter)
      expect(response.code).to eq(200)
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes PUT requests" do
      response = HTTPI2.put(@url, "<some>xml</some>", adapter)
      expect(response.body).to eq("put")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes DELETE requests" do
      response = HTTPI2.delete(@url, adapter)
      expect(response.body).to eq("delete")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    describe "settings:" do

      let(:request) { HTTPI2::Request.new("http://#{@app}") }
      let(:client)  { HTTPI2::Adapter::Rack.new(request) }

      describe "proxy" do
        before do
          request.proxy = "http://proxy-host.com:443"
          request.proxy.user = "username"
          request.proxy.password = "password"
        end

        it "is not supported" do
          expect { client.request(:get) }.
            to raise_error(HTTPI2::NotSupportedError, "Rack adapter does not support proxying")
        end
      end

      describe "on_body" do
        before do
          request.on_body do
            # ola-la!
          end
        end

        it "is not supported" do
          expect { client.request(:get) }.
            to raise_error(HTTPI2::NotSupportedError, "Rack adapter does not support response streaming")
        end
      end

      describe "set_auth" do
        before do
          request.auth.basic "username", "password"
        end

        it "is not supported" do
          expect { client.request(:get) }.
            to raise_error(HTTPI2::NotSupportedError, "Rack adapter does not support HTTP auth")
        end
      end

      context "(for SSL client auth)" do
        before do
          request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
          request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
        end

        it "is not supported" do
          expect { client.request(:get) }.
            to raise_error(HTTPI2::NotSupportedError, "Rack adapter does not support SSL client auth")
        end
      end
    end

  end

end