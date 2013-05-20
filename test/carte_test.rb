# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "minitest/autorun"
require "../carte"

# COMPLET AU 4/4/2013

describe "Carte", "Initialisation de la couleur" do

  it "Coeur pour les id de 0 à 12" do
    get_couleur((0..12)).must_equal [ :coeur ]
  end

  it "Pique pour les id de 13 à 25" do
    get_couleur((13..25)).must_equal [ :pique ]
  end

  it "Carreau pour les id de 26 à 38" do
    get_couleur((26..38)).must_equal [ :carreau ]
  end

  it "Trèfle pour les id de 39 à 51" do
    get_couleur((39..51)).must_equal [ :trefle ]
  end

  it "Nul pour le 1° joker" do
    Carte.new(52).couleur.must_be_nil
  end

  it "Nul pour le 2° joker" do
    Carte.new(53).couleur.must_be_nil
  end

  def get_couleur range
    couleurs = range.map { |i| Carte.new(i).couleur }
    couleurs.uniq
  end

end


describe "Carte", "Initialisation de la valeur" do

  it "Suite As, 2, ..., Roi pour les id de 0 à 12" do
    get_valeur((0..12)).size.must_equal 13
  end

  it "Suite As, 2, ..., Roi pour les id de 13 à 25" do
    get_valeur((13..25)).size.must_equal 13
  end

  it "Suite As, 2, ..., Roi pour les id de 26 à 38" do
    get_valeur((26..38)).size.must_equal 13
  end

  it "Suite As, 2, ..., Roi pour les id de 39 à 51" do
    get_valeur((39..51)).size.must_equal 13
  end

  it "J pour le 1° joker" do
    Carte.new(52).valeur.must_equal :J
  end

  it "J pour le 2° joker" do
    Carte.new(53).valeur.must_equal :J
  end

  def get_valeur range
    valeurs = range.map { |i| Carte.new(i).valeur }
    valeurs.uniq
  end

end


describe "Carte", "Initialisation de l'identifiant" do

  it "Conserve l'ID passé en paramètre" do
    actual_ids = (0..53).map { |i| Carte.new(i).carte_id }
    expected_ids = (0..53).to_a
    actual_ids.must_equal expected_ids
  end

end


describe "Carte", "Vérification du classement" do

  it "Renvoie -1 quand comparaison avec carte supérieure" do
    carte_a = Carte.new 10
    carte_b = Carte.new 20
    (carte_a <=> carte_b).must_equal -1
  end

  it "Renvoie 1 quand comparaison avec carte inférieure" do
    carte_a = Carte.new 10
    carte_b = Carte.new 20
    (carte_b <=> carte_a).must_equal 1
  end

  it "Renvoie 0 quand comparaison avec carte identique" do
    carte_a = Carte.new 15
    carte_b = Carte.new 15
    (carte_a <=> carte_b).must_equal 0
  end

end


describe "Carte", "Vérification de la comparaison" do

  it "Renvoie true quand comparaison avec soi-même" do
    carte = Carte.new 10
    (carte == carte).must_equal true
  end

  it "Renvoie true quand comparaison avec même carte_id" do
    carte_a = Carte.new 10
    carte_b = Carte.new 10
    (carte_a == carte_b).must_equal true
  end

  it "Renvoie false quand comparaison avec autre carte_id" do
    carte_a = Carte.new 10
    carte_b = Carte.new 20
    (carte_a == carte_b).must_equal false
  end

  it "Renvoie false quand comparaison avec objet autre que Carte" do
    carte = Carte.new 10
    (carte == true).must_equal false
  end

end


describe "Carte", "Vérification du est_joker?" do

  it "Renvoie true pour le 1° joker" do
    Carte.new(52).est_joker?.must_equal true
  end

  it "Renvoie true pour le 2° joker" do
    Carte.new(53).est_joker?.must_equal true
  end

  it "Renvoie false pour les autres cartes" do
    valeurs = (0..51).map { |i| Carte.new(i).est_joker? }
    valeurs.uniq.join.must_equal "false"
  end

end


describe "Carte", "Vérification du est_as?" do

  it "Renvoie true pour les As" do
    Carte.new("AC").est_as?.must_equal true
    Carte.new("AP").est_as?.must_equal true
    Carte.new("AK").est_as?.must_equal true
    Carte.new("AT").est_as?.must_equal true
  end

  it "Renvoie false pour d'autres cartes" do
    Carte.new(52).est_as?.must_equal false
    Carte.new(51).est_as?.must_equal false
    Carte.new(1).est_as?.must_equal false
  end

end


describe "Carte", "Vérification du to_text" do

  it "Renvoie 'Joker' pour le 1° joker" do
    Carte.new(52).to_text.must_equal "Joker"
  end

  it "Renvoie 'Joker' pour le 2° joker" do
    Carte.new(53).to_text.must_equal "Joker"
  end

  it "Renvoie 'As de Coeur' pour l'as de coeur'" do
    Carte.new(0).to_text.must_equal "As de Coeur"
  end

  it "Renvoie '2 de Coeur' pour le 2 de coeur'" do
    Carte.new(1).to_text.must_equal "2 de Coeur"
  end

  it "Renvoie '2 de Pique' pour le 2 de pique'" do
    Carte.new(14).to_text.must_equal "2 de Pique"
  end

  it "Renvoie '3 de Pique' pour le 3 de pique'" do
    Carte.new(15).to_text.must_equal "3 de Pique"
  end

  it "Renvoie '10 de Carreau' pour le 10 de carreau'" do
    Carte.new(35).to_text.must_equal "10 de Carreau"
  end

  it "Renvoie 'Valet de Carreau' pour le valet de carreau'" do
    Carte.new(36).to_text.must_equal "Valet de Carreau"
  end

  it "Renvoie 'Dame de Trefle' pour la dame de trèfle'" do
    Carte.new(50).to_text.must_equal "Dame de Trefle"
  end

  it "Renvoie 'Roi de Trefle' pour le roi de trèfle'" do
    Carte.new(51).to_text.must_equal "Roi de Trefle"
  end

end


describe "Carte", "Vérification du to_html" do

  it "Renvoie 'J*' pour le 1° joker" do
    Carte.new(52).to_s.must_equal "J*"
  end

  it "Renvoie 'J*' pour le 2° joker" do
    Carte.new(53).to_s.must_equal "J*"
  end

  it "Renvoie 'AC' pour l'as de coeur'" do
    Carte.new(0).to_s.must_equal "AC"
  end

  it "Renvoie '2C' pour le 2 de coeur'" do
    Carte.new(1).to_s.must_equal "2C"
  end

  it "Renvoie '2P' pour le 2 de pique'" do
    Carte.new(14).to_s.must_equal "2P"
  end

  it "Renvoie '3P' pour le 3 de pique'" do
    Carte.new(15).to_s.must_equal "3P"
  end

  it "Renvoie 'XK' pour le 10 de carreau'" do
    Carte.new(35).to_s.must_equal "XK"
  end

  it "Renvoie 'VK' pour le valet de carreau'" do
    Carte.new(36).to_s.must_equal "VK"
  end

  it "Renvoie 'DT' pour la dame de trèfle'" do
    Carte.new(50).to_s.must_equal "DT"
  end

  it "Renvoie 'RT' pour le roi de trèfle'" do
    Carte.new(51).to_s.must_equal "RT"
  end

end


describe "Carte", "Vérification du to_html" do

  it "Renvoie 'J*' pour le 1° joker" do
    Carte.new(52).to_html.must_equal "J*"
  end

  it "Renvoie 'J*' pour le 2° joker" do
    Carte.new(53).to_html.must_equal "J*"
  end

  it "Renvoie 'A♥' pour l'as de coeur'" do
    Carte.new(0).to_html.must_equal "A&hearts;"
  end

  it "Renvoie '2♥' pour le 2 de coeur'" do
    Carte.new(1).to_html.must_equal "2&hearts;"
  end

  it "Renvoie '2♠' pour le 2 de pique'" do
    Carte.new(14).to_html.must_equal "2&spades;"
  end

  it "Renvoie '3♠' pour le 3 de pique'" do
    Carte.new(15).to_html.must_equal "3&spades;"
  end

  it "Renvoie 'X♦' pour le 10 de carreau'" do
    Carte.new(35).to_html.must_equal "X&diams;"
  end

  it "Renvoie 'V♦' pour le valet de carreau'" do
    Carte.new(36).to_html.must_equal "V&diams;"
  end

  it "Renvoie 'D♣' pour la dame de trèfle'" do
    Carte.new(50).to_html.must_equal "D&clubs;"
  end

  it "Renvoie 'R♣' pour le roi de trèfle'" do
    Carte.new(51).to_html.must_equal "R&clubs;"
  end

end


describe "Carte", "Cartes avant / après" do

  it "Renvoie '2C' après 'AC'" do
    Carte.new(0).carte_apres.to_s.must_equal "2C"
  end

  it "Renvoie '3C' après '2C'" do
    Carte.new(1).carte_apres.to_s.must_equal "3C"
  end

  it "Renvoie 'AC' après 'RC'" do
    Carte.new(12).carte_apres.to_s.must_equal "AC"
  end

  it "Renvoie 'AC' avant '2C'" do
    Carte.new(1).carte_avant.to_s.must_equal "AC"
  end

  it "Renvoie '2C' avant '3C'" do
    Carte.new(2).carte_avant.to_s.must_equal "2C"
  end

  it "Renvoie nil avant 'AC'" do
    Carte.new(0).carte_avant.must_be_nil
  end

end
