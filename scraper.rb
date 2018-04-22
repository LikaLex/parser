require 'nokogiri'
require 'csv'
require 'open-uri'
require 'pry'

ALL_INFORMATION = ARGV.first
END_CSV_FILE = ARGV.last

def parse_product(product_url)
  page = Nokogiri::HTML(open(product_url))
  image_src = page.css('#bigpic').last['src']
  product_name = page.css('h1').last.content.strip
  page.css('.attribute_labels_lists').map do |line|
    [
      "#{product_name} -- #{line.css('.attribute_name').last.content.strip}",
      line.css('.attribute_price').last.content.strip,
      image_src
    ]
  end
end

page = Nokogiri::HTML(open(ALL_INFORMATION))
product_urls = page.css('.product_img_link').map { |link| link['href'] }

product_lines = product_urls.inject([]) do |product_lines, product_url|
  product_lines + parse_product(product_url)
end

CSV.open("tmp/#{END_CSV_FILE}", 'wb') do |csv|
  csv << %w(Names Prices Images)
  product_lines.each do |line|
    csv << line
  end
end
