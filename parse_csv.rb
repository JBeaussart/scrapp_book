require 'csv'
require "amazing_print"

IGNORED_EXPRESSIONS = ["ANNUAIRE DES EXPOSANTS // III",  "LIST OF EXHIBITORS WITH STAND NUMBER", "ANNUAIRE DES EXPOSANTS ///////////// 0/1",""," ","  ", "   "]

draft_entreprises = {}

def is_name?(data)
  data == data.upcase && data.scan(/\d/).empty? && data.size > 3
end

def is_valid?(data)
 if IGNORED_EXPRESSIONS.include?(data) || data.nil?
    false
  else
    true
 end
end

# Transformer la liste des données images en Hash
# "Nom de l'entreprise" => "string contenant les infos"

CSV.foreach("log.csv") do |line|
  data = line.first
  if is_valid?(line.first)
    if is_name?(data)
      draft_entreprises["#{data.strip}"] = data # generate compagny
    end
    # SI ce n'est pas un nom d'entreprise : Envoyer les infos dans la derniere compagny
    draft_entreprises[draft_entreprises.keys.last] << line.to_s
  end
end

# Spliter le string du hash en données
# ap draft_entreprises["PARTNER & CO SARL"].split("\"")
# [
#     [ 0] "PARTNER & CO SARL[",
#     [ 1] "PARTNER & CO SARL",
#     [ 2] "][",
#     [ 3] "ma",
#     [ 4] "][",
#     [ 5] "6 rue Alphonse Daudet",
#     [ 6] "][",
#     [ 7] "44350 GUÉRANDE",
#     [ 8] "][",
#     [ 9] "Tél 02 40 23 63 24",
#     [10] "][",
#     [11] "cl@partnerandco.fr",
#     [12] "][",
#     [13] "Www.partnerandco.fr",
#     [14] "]"
# ]

campagny_data_in_array = draft_entreprises["PARTNER & CO SARL"].split("\"")

entreprises = {}

# Pour le hash des entreprises en brouillon
draft_entreprises.each do |key, value|
  # key = "PARTNER & CO SARL"
  # value = "PARTNER & CO SARL[\"PARTNER & CO SARL\"][\"ma\"][\"6 rue Alphonse Daudet\"][\"44350 GUÉRANDE\"][\"Tél 02 40 23 63 24\"][\"cl@partnerandco.fr\"][\"Www.partnerandco.fr\"]"

  # Définir quel value = à quoi ?

  arr = value.split("\"")
  arr.each do |data|
    case
    when data == "][" || data == "]" || data == ""
    when data == data.upcase && data.scan(/\d/).empty?
      @name = data
    when data == data.upcase && data.scan(/\d/).any?
      @cp = data
    when data.empty?
    when data.scan(/^(Tél)/).any?
      @tel = data.gsub("Tél","").strip
    when data.scan(/(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))/).any?
      @email = data
    when data.scan(/(.com|.fr|.eu|.io|.org|.net|.de|.it)$/).any?
      @website = data.downcase
    when data.scan(/^(\d).*(rue|chemin|BD)/)
      @address = data
    end
    entreprises["#{key}"] = {
      name: @name,
      description: "Ma description",
      telephone: @tel,
      adresse: @address,
      cp_ville: @cp,
      email: @email,
      site_web: @website,
      verification: value
    }
  end
  # RESET des valeurs pour éviter de coller une valeur si elle est nil dans la prochaine ligne
  @name = @tel = @email = @website = @address = @cp = nil
end

ap entreprises
# ap entreprises.keys
# ap entreprises.class

# entreprises {
#   nom_de_entreprise {
#     adress:
#     tel:
#   }
# }

