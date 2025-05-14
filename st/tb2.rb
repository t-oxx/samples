require 'net/http'
require 'uri'
require 'openssl'
require 'base64'
require 'time'

account_name = "your_storage_account"
account_key = "your_base64_encoded_key"
table_name = "your_table_name"

resource = "#{table_name}"
uri = URI("https://#{account_name}.table.core.windows.net/#{resource}")

method = "GET"

# 必須ヘッダー
timestamp = Time.now.utc.httpdate
canonicalized_resource = "/#{account_name}/#{resource}"

string_to_sign = "#{method}\n\n\n#{timestamp}\n#{canonicalized_resource}"

# HMAC-SHA256 署名の生成
decoded_key = Base64.strict_decode64(account_key)
signature = OpenSSL::HMAC.digest('sha256', decoded_key, string_to_sign)
encoded_signature = Base64.strict_encode64(signature)

# デバッグ用のコード
puts "String to Sign: #{string_to_sign}"
puts "Decoded Key: #{decoded_key}"
puts "Signature: #{signature}"
puts "Encoded Signature: #{encoded_signature}"
puts "Headers: #{headers}"

# リクエストヘッダー
headers = {
  "Authorization" => "SharedKeyLite #{account_name}:#{encoded_signature}",
  "x-ms-date" => timestamp,
  "x-ms-version" => "2019-02-02",
  "Accept" => "application/json;odata=nometadata"
}

# HTTP リクエストの送信
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Get.new(uri.request_uri, headers)

# レスポンスの取得
response = http.request(request)

# 結果の表示
puts "Status Code: #{response.code}"
puts "Response Body: #{response.body}"