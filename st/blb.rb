require 'net/http'
require 'uri'
require 'json'

# Azure Blob Storageの設定
storage_account_name = 'your_storage_account_name'
container_name = 'your_container_name'
blob_name = 'your_blob_name'
account_key = 'your_account_key'

# 認証情報の作成
uri = URI("https://#{storage_account_name}.blob.core.windows.net/#{container_name}/#{blob_name}")
request = Net::HTTP::Get.new(uri)
request['x-ms-version'] = '2020-02-10'
request['Authorization'] = "SharedKey #{storage_account_name}:#{account_key}"

# HTTPリクエスト送信
http = Net::HTTP.new(uri.host, uri.port)
response = http.request(request)

# レスポンスの処理
if response.code.to_i == 200
  puts "Blob内容: #{response.body}"
else
  puts "Error: #{response.code} - #{response.message}"
end
