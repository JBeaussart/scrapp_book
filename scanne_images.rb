require 'rtesseract'
require 'pdftoimage'

# p "------ Call images to string -----"
# image = RTesseract.new("images/ANNUAIRE-DES-EXPOSANTS-1.jpeg")
# File.write("image_pixel.txt", image)

p "------ Call fonction -----"

images = PDFToImage.open('images/ANNUAIRE-DES-EXPOSANTS.pdf')

images.each do |img|
  img.save("jpg/page-#{img.page}.jpg")
  text = RTesseract.new("jpg/page-#{img.page}.jpg", lang: 'fra')
  File.write("log.csv", text.to_s, mode: "a")
end

p File.open("log.txt").read

