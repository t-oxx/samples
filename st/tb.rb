require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'openssl'

# Azure Table Storage 設定
storage_account_name = 'your_storage_account'
table_name = 'your_table_name'
account_key = 'your_account_key'

# フィルタ設定（Timestamp が 2024-01-01 以降のデータを取得）
timestamp_filter = "Timestamp ge datetime'2024-01-01T00:00:00Z'"

# クエリパラメータをエンコード
query_params = URI.encode_www_form({ "$filter" => timestamp_filter })

# REST API のリクエスト URL
uri = URI("https://#{storage_account_name}.table.core.windows.net/#{table_name}()?#{query_params}")

# 認証情報の作成
timestamp = Time.now.utc.httpdate
string_to_sign = "GET\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nx-ms-date:#{timestamp}\nx-ms-version:2019-02-02\n/#{storage_account_name}/#{table_name}"
signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', Base64.decode64(account_key), string_to_sign))

# HTTPリクエスト作成
request = Net::HTTP::Get.new(uri)
request['x-ms-date'] = timestamp
request['x-ms-version'] = '2019-02-02'
request['Authorization'] = "SharedKey #{storage_account_name}:#{signature}"
request['Accept'] = 'application/json;odata=nometadata'

# HTTPリクエスト送信
begin
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = 10
  http.read_timeout = 30

  puts "[INFO] Sending request to Azure Storage Table..."
  response = http.request(request)

  # HTTP ステータスコードのチェック
  case response
  when Net::HTTPSuccess
    result = JSON.parse(response.body)
    puts "[INFO] Successfully retrieved data: #{result}"
  else
    puts "[ERROR] HTTP request failed with status #{response.code} - #{response.message}"
    puts "[ERROR] Response body: #{response.body}"
  end

rescue Net::OpenTimeout
  puts "[ERROR] Connection timed out while trying to reach Azure Table Storage."
rescue Net::ReadTimeout
  puts "[ERROR] Read timed out while waiting for response from Azure Table Storage."
rescue OpenSSL::SSL::SSLError => e
  puts "[ERROR] SSL error occurred: #{e.message}"
rescue SocketError => e
  puts "[ERROR] Network error (DNS resolution, connectivity issue): #{e.message}"
rescue StandardError => e
  puts "[ERROR] Unexpected error: #{e.message}"
  puts e.backtrace
end
