require 'rtesseract'
require 'pdftoimage'
require_relative 'parse_csv'

# p "------ Call images to string -----"
# image = RTesseract.new("images/ANNUAIRE-DES-EXPOSANTS-1.jpeg")
# File.write("image_pixel.txt", image)

filepath = 'log.csv'

p "------ Pass PDF to JPG -----"

images = PDFToImage.open('images/ANNUAIRE-DES-EXPOSANTS.pdf')

images.each do |img|
  img.save("jpg/page-#{img.page}.jpg")
  text = RTesseract.new("jpg/page-#{img.page}.jpg", lang: 'fra')
  p "--------- Storing JPG to TEXT - #{img.page} / #{images.size} -------"
  File.open(filepath, "a") {|f| f.write text}
end

p "------ Forming Datas -----"

forming_datas

p "------ Parsing Datas -----"

parsing_datas(@draft_entreprises)

p "------ Storing Datas -----"

save_in_csv(@entreprises)

p "------ Finish ! -----"
