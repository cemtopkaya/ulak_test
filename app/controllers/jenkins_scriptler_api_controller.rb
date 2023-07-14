class JenkinsScriptlerApiController < ApplicationController
  def get_environments
    @headers = {
      # "Cookie" => cookie, # Cookie bilgisi
      "Content-Type" => "application/json", # İstenilen gövde türü
      "Authorization" => "Basic Y2VtLnRvcGtheWE6MTEwYjAzM2JmZjZhNGJlZDY0MWFiNzZmYTZmMzcwNDg5Ng==",
      "Cookie" => "JSESSIONID.e1d859f8=node0xhqg54lwzxgy4hd48ko5fms3478.node0",
    }

    arch = params[:ARCH]
    target_servers = UlakTest::Jenkins.get_environments_by_arch(arch)

    render json: { result: target_servers }, status: :ok
  end
end
