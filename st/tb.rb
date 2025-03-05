require 'net/http'
require 'uri'
require 'json'
require 'base64'

# Azure Table Storageの設定
storage_account_name = 'your_storage_account_name'
table_name = 'your_table_name'
account_key = 'your_account_key'

# テーブルストレージのエンドポイント
uri = URI("https://#{storage_account_name}.table.core.windows.net/#{table_name}()")

# 認証情報の作成
timestamp = Time.now.utc.httpdate
signature_string = "GET\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nx-ms-date:#{timestamp}\nx-ms-version:2019-02-02"
signature = Base64.encode64(OpenSSL::HMAC.digest('sha256', account_key, signature_string)).strip

request = Net::HTTP::Get.new(uri)
request['x-ms-version'] = '2019-02-02'
request['x-ms-date'] = timestamp
request['Authorization'] = "SharedKey #{storage_account_name}:#{signature}"

# HTTPリクエスト送信
http = Net::HTTP.new(uri.host, uri.port)
response = http.request(request)

# レスポンスの処理
if response.code.to_i == 200
  puts "Tableデータ: #{response.body}"
else
  puts "Error: #{response.code} - #{response.message}"
end
