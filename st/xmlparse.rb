require 'rexml/document'
require 'json'

xml_data = <<~XML
  <root>
    <item>
      <name>Apple</name>
      <price>100</price>
    </item>
    <item>
      <name>Banana</name>
      <price>50</price>
    </item>
  </root>
XML

# XMLをパース
doc = REXML::Document.new(xml_data)

# XMLノードを再帰的にHashに変換するメソッド
def xml_to_hash(element)
  hash = {}

  element.elements.each do |child|
    key = child.name
    value = child.has_elements? ? xml_to_hash(child) : child.text.strip

    if hash[key]
      hash[key] = [hash[key]] unless hash[key].is_a?(Array)
      hash[key] << value
    else
      hash[key] = value
    end
  end

  hash
end

result = xml_to_hash(doc.root)
puts JSON.pretty_generate(result)
