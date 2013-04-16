# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "minitest/autorun"
require "../combinaison"

# COMPLET AU 4/4/2013

describe "Combinaison", "Vérification initialisation" do

  it "Défini la liste des cartes" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.cartes.must_equal suite
  end

  it "Défini le type de combinaison" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.type.must_equal :suite
  end

  it "Compte les points" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.points.wont_equal 0
  end

end


describe "Combinaison", "Vérification to_text pour les suites" do

  it "Renvoie 'Tierce' pour suite de 3 cartes" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.to_text.must_equal "Tierce"
  end

  it "Renvoie 'Cinquante' pour suite de 4 cartes" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    suite << Carte.new(4)
    combinaison = Combinaison.new :suite, suite
    combinaison.to_text.must_equal "Cinquante"
  end

  it "Renvoie 'Cent' pour suite de 5 cartes" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    suite << Carte.new(4)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.to_text.must_equal "Cent"
  end

  it "Renvoie 'Suite' pour suite de 6 cartes" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    suite << Carte.new(4)
    suite << Carte.new(5)
    suite << Carte.new(6)
    combinaison = Combinaison.new :suite, suite
    combinaison.to_text.must_equal "Suite"
  end

end


describe "Combinaison", "Vérification to_text pour les séries" do

  it "Renvoie 'Brelan' pour série de 3 cartes" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    combinaison = Combinaison.new :serie, serie
    combinaison.to_text.must_equal "Brelan"
  end

  it "Renvoie 'Carré' pour série de 4 cartes" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    serie << Carte.new(39)
    combinaison = Combinaison.new :serie, serie
    combinaison.to_text.must_equal "Carré"
  end

end


describe "Combinaison", "Vérification to_text pour les tas" do

  it "Renvoie 'Tas' pour les tas de cartes" do
    tas = []
    tas << Carte.new(1)
    tas << Carte.new(2)
    tas << Carte.new(3)
    combinaison = Combinaison.new :tas, tas
    combinaison.to_text.must_equal "Tas"
  end

end


describe "Combinaison", "Vérification to_s" do

  it "Renvoie [ AC 2P XK VT J* ]" do
    tas = []
    tas << Carte.new(0)
    tas << Carte.new(14)
    tas << Carte.new(35)
    tas << Carte.new(49)
    tas << Carte.new(52)
    combinaison = Combinaison.new :tas, tas
    combinaison.to_s.must_equal "[ AC 2P XK VT J* ]"
  end

end


describe "Combinaison", "Vérification valorisation des suites" do

  it "Renvoie 85 pour As, 2, 3 ... Roi" do
  suite = []
  13.times { |i| suite << Carte.new(i) }
  combinaison = Combinaison.new :suite, suite
    combinaison.points.must_equal 85
  end

  it "Renvoie 94 pour 2, 3 ... Roi, As" do
    suite = []
    13.times { |i| suite << Carte.new(i + 1) }
    combinaison = Combinaison.new :suite, suite
    combinaison.points.must_equal 94
  end

  it "Renvoie 85 pour Joker, 2, 3 ... Roi" do
    suite = []
    suite << Carte.new(52)
    12.times { |i| suite << Carte.new(i + 1) }
    combinaison = Combinaison.new :suite, suite
    combinaison.points.must_equal 85
  end

  it "Renvoie 94 pour 2, 3 ... Roi, Joker" do
    suite = []
    12.times { |i| suite << Carte.new(i + 1) }
    suite << Carte.new(52)
    combinaison = Combinaison.new :suite, suite
    combinaison.points.must_equal 94
  end

  it "Renvoie 9 pour 2, Joker, 4" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(52)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.points.must_equal 9
  end

end


describe "Combinaison", "Vérification valorisation des séries" do

  it "Renvoie 6 pour Brelan de 2" do
    serie = []
    serie << Carte.new(1)
    serie << Carte.new(14)
    serie << Carte.new(27)
    combinaison = Combinaison.new :serie, serie
    combinaison.points.must_equal 6
  end

  it "Renvoie 8 pour Carré de 2" do
    serie = []
    serie << Carte.new(1)
    serie << Carte.new(14)
    serie << Carte.new(27)
    serie << Carte.new(40)
    combinaison = Combinaison.new :serie, serie
    combinaison.points.must_equal 8
  end

  it "Renvoie 30 pour Brelan d'As" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    combinaison = Combinaison.new :serie, serie
    combinaison.points.must_equal 30
  end

  it "Renvoie 40 pour Carré d'As" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    serie << Carte.new(39)
    combinaison = Combinaison.new :serie, serie
    combinaison.points.must_equal 40
  end

  it "Renvoie 6 pour Paire de 2 avec Joker" do
    serie = []
    serie << Carte.new(1)
    serie << Carte.new(14)
    serie << Carte.new(52)
    combinaison = Combinaison.new :serie, serie
    combinaison.points.must_equal 6
  end

end


describe "Combinaison", "Vérification avec_joker?" do

  it "Renvoie false pour Brelan As" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    combinaison = Combinaison.new :serie, serie
    combinaison.avec_joker?.must_equal false
  end

  it "Renvoie true pour Paire As + Joker" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(52)
    combinaison = Combinaison.new :serie, serie
    combinaison.avec_joker?.must_equal true
  end

  it "Renvoie false pour Tierce 2 3 4" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.avec_joker?.must_equal false
  end

  it "Renvoie true pour Tierce 2 Joker 4" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(52)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.avec_joker?.must_equal true
  end

end


describe "Combinaison", "Vérification tierce_franche?" do

  it "Renvoie false pour un tas de cartes" do
    tas = []
    tas << Carte.new(1)
    tas << Carte.new(2)
    tas << Carte.new(3)
    combinaison = Combinaison.new :tas, tas
    combinaison.tierce_franche?.must_equal false
  end

  it "Renvoie false pour une série" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    combinaison = Combinaison.new :serie, serie
    combinaison.tierce_franche?.must_equal false
  end

  it "Renvoie true pour Tierce 2 3 4" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.tierce_franche?.must_equal true
  end

  it "Renvoie false pour Tierce 2 Joker 4" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(52)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.tierce_franche?.must_equal false
  end

  it "Renvoie true pour Cinquante 2 3 4 5" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    suite << Carte.new(4)
    combinaison = Combinaison.new :suite, suite
    combinaison.tierce_franche?.must_equal true
  end

  it "Renvoie false pour Cinquante 2 Joker 4 5" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(52)
    suite << Carte.new(3)
    suite << Carte.new(4)
    combinaison = Combinaison.new :suite, suite
    combinaison.tierce_franche?.must_equal false
  end

  it "Renvoie true pour Cent 2 3 4 5 6" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    suite << Carte.new(4)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.tierce_franche?.must_equal true
  end

  it "Renvoie true pour Cent 2 Joker 4 5 6" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(52)
    suite << Carte.new(3)
    suite << Carte.new(4)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.tierce_franche?.must_equal true
  end

  it "Renvoie false pour Cent 2 3 Joker 5 6" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(52)
    suite << Carte.new(4)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.tierce_franche?.must_equal false
  end

  it "Renvoie true pour Cent 2 3 4 Joker 6" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    suite << Carte.new(52)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.tierce_franche?.must_equal true
  end

end


describe "Combinaison", "Vérification joker_facultatif?" do

  it "Renvoie true si la combinaison ne contient pas de joker" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    combinaison = Combinaison.new :serie, serie
    combinaison.joker_facultatif?.must_equal true
  end

  it "Renvoie true si la combinaison est une tierce franche" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(3)
    combinaison = Combinaison.new :suite, suite
    combinaison.joker_facultatif?.must_equal true
  end

  it "Renvoie false si combinaison de 2 cartes + Joker" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(52)
    combinaison = Combinaison.new :suite, suite
    combinaison.joker_facultatif?.must_equal false
  end

  it "Renvoie true si combinaison de plus de 2 cartes + Joker" do
    suite = []
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(52)
    suite << Carte.new(4)
    combinaison = Combinaison.new :suite, suite
    combinaison.joker_facultatif?.must_equal true
  end

end


describe "Combinaison", "Vérification remplacement joker" do

  it "Renvoie vide si suite sans joker" do
    suite = []
    suite << Carte.new(3)
    suite << Carte.new(4)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.remplacement.must_be_nil
  end

  it "Renvoie 6C pour 4C 5C Joker" do
    suite = []
    suite << Carte.new(3)
    suite << Carte.new(4)
    suite << Carte.new(52)
    combinaison = Combinaison.new :suite, suite
    combinaison.remplacement.wont_be_nil
    combinaison.remplacement.carte_id.must_equal Carte.new(5).carte_id
  end

  it "Renvoie 4C pour Joker 5C 6C" do
    suite = []
    suite << Carte.new(52)
    suite << Carte.new(4)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.remplacement.wont_be_nil
    combinaison.remplacement.carte_id.must_equal Carte.new(3).carte_id
  end

  it "Renvoie 5C pour 4C Joker 6C" do
    suite = []
    suite << Carte.new(3)
    suite << Carte.new(52)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.remplacement.wont_be_nil
    combinaison.remplacement.carte_id.must_equal Carte.new(4).carte_id
  end

  it "Renvoie vide si série sans joker" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    combinaison = Combinaison.new :serie, serie
    combinaison.remplacement.must_be_nil
  end

  it "Renvoie vide pour Paire AC AP + Joker" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(52)
    combinaison = Combinaison.new :serie, serie
    combinaison.remplacement.must_be_nil
  end

  it "Renvoie AT pour Brelan AC AP AK + Joker" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    serie << Carte.new(52)
    combinaison = Combinaison.new :serie, serie
    combinaison.remplacement.wont_be_nil
    combinaison.remplacement.carte_id.must_equal Carte.new(39).carte_id
  end

end


describe "Combinaison", "Vérification compléments" do

  it "Renvoie 3C et 7C si 4C 5C 6C" do
    suite = []
    suite << Carte.new(3)
    suite << Carte.new(4)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.complements.size.must_equal 2
    combinaison.complements[0].carte_id.must_equal Carte.new(2).carte_id
    combinaison.complements[1].carte_id.must_equal Carte.new(6).carte_id
  end

  it "Renvoie 3C et 7C si Joker 5C 6C" do
    suite = []
    suite << Carte.new(52)
    suite << Carte.new(4)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.complements.size.must_equal 2
    combinaison.complements[0].carte_id.must_equal Carte.new(2).carte_id
    combinaison.complements[1].carte_id.must_equal Carte.new(6).carte_id
  end

  it "Renvoie 3C et 7C si 4C Joker 6C" do
    suite = []
    suite << Carte.new(3)
    suite << Carte.new(52)
    suite << Carte.new(5)
    combinaison = Combinaison.new :suite, suite
    combinaison.complements.size.must_equal 2
    combinaison.complements[0].carte_id.must_equal Carte.new(2).carte_id
    combinaison.complements[1].carte_id.must_equal Carte.new(6).carte_id
  end

  it "Renvoie 3C et 7C si 4C 5C Joker" do
    suite = []
    suite << Carte.new(3)
    suite << Carte.new(4)
    suite << Carte.new(52)
    combinaison = Combinaison.new :suite, suite
    combinaison.complements.size.must_equal 2
    combinaison.complements[0].carte_id.must_equal Carte.new(2).carte_id
    combinaison.complements[1].carte_id.must_equal Carte.new(6).carte_id
  end

  it "Renvoie AT pour AC AP AK" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    combinaison = Combinaison.new :serie, serie
    combinaison.complements.size.must_equal 1
    combinaison.complements[0].carte_id.must_equal Carte.new(39).carte_id
  end

  it "Renvoie AK AT pour AC AP Joker" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(52)
    combinaison = Combinaison.new :serie, serie
    combinaison.complements.size.must_equal 2
    combinaison.complements[0].carte_id.must_equal Carte.new(26).carte_id
    combinaison.complements[1].carte_id.must_equal Carte.new(39).carte_id
  end

  it "Renvoie vide pour AC AP AK Joker" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    serie << Carte.new(52)
    combinaison = Combinaison.new :serie, serie
    combinaison.complements.size.must_equal 0
  end

end
