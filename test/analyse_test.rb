# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "minitest/autorun"
require "../analyse"

# COMPLET AU 4/4/2013

describe "Analyse", "Vérification initialisation" do

  it "Défini une liste de cartes" do
    analyse = Analyse.new []
    analyse.cartes.must_be_instance_of Array
    analyse.cartes.must_be_empty
  end

  it "La liste de cartes contient les cartes définies" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(1)
    analyse = Analyse.new une_main
    analyse.cartes.must_equal une_main
  end

  it "La liste de cartes contient les cartes triées" do
    une_main = []
    une_main << Carte.new(1)
    une_main << Carte.new(0)
    analyse = Analyse.new une_main
    analyse.cartes.must_equal une_main.sort
  end

  it "La liste de cartes contient les cartes dédoublonnées" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(0)
    analyse = Analyse.new une_main
    analyse.cartes.size.must_equal 1
  end

end


describe "Analyse", "Vérification to_s" do

  it "Renvoie [ AC 2P XK VT J* ]" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(14)
    une_main << Carte.new(35)
    une_main << Carte.new(49)
    une_main << Carte.new(52)
    analyse = Analyse.new une_main
    analyse.to_s.must_equal "[ AC 2P XK VT J* ]"
  end

end


describe "Analyse", "Vérification suites" do

  it "Reconnait 2C 3C 4C comme tierce" do
    une_main = []
    une_main << Carte.new(1)
    une_main << Carte.new(2)
    une_main << Carte.new(3)
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 1
  end

  it "Reconnait 2C 3C 4C 6C comme tierce" do
    une_main = []
    une_main << Carte.new(1)
    une_main << Carte.new(2)
    une_main << Carte.new(3)
    une_main << Carte.new(5)
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 1
  end

  it "Reconnait 2C 4C 3C comme tierce" do
    une_main = []
    une_main << Carte.new(1)
    une_main << Carte.new(3)
    une_main << Carte.new(2)
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 1
  end

  it "Reconnait 2C 3C Joker comme tierce" do
    une_main = []
    une_main << Carte.new(1)
    une_main << Carte.new(2)
    une_main << Carte.new(52)
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 1
  end

  it "Reconnait 2C 4C Joker comme tierce" do
    une_main = []
    une_main << Carte.new(1)
    une_main << Carte.new(3)
    une_main << Carte.new(52)
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 1
  end

  it "Reconnait DC RC Joker comme tierce" do
    une_main = []
    une_main << Carte.new(11)
    une_main << Carte.new(12)
    une_main << Carte.new(52)
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 1
  end

  it "Ne traite pas 2C Joker Joker comme tierce" do
    une_main = []
    une_main << Carte.new(1)
    une_main << Carte.new(52)
    une_main << Carte.new(53)
    analyse = Analyse.new une_main
    analyse.combinaisons.must_be_empty
  end

  it "Reconnait AC DC RC comme tierce" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(11)
    une_main << Carte.new(12)
    analyse = Analyse.new une_main
    analyse.combinaisons[0].to_text.must_equal "Tierce"
  end

  it "Reconnait AC DC RC VC comme cinquante" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(11)
    une_main << Carte.new(12)
    une_main << Carte.new(10)
    analyse = Analyse.new une_main
    analyse.combinaisons[0].to_text.must_equal "Cinquante"
  end

  it "Reconnait XC AC DC RC VC comme cent" do
    une_main = []
    une_main << Carte.new(9)
    une_main << Carte.new(0)
    une_main << Carte.new(11)
    une_main << Carte.new(12)
    une_main << Carte.new(10)
    analyse = Analyse.new une_main
    analyse.combinaisons[0].to_text.must_equal "Cent"
  end

end


describe "Analyse", "Vérification séries" do

  it "Reconnait AC AP AK comme brelan" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(13)
    une_main << Carte.new(26)
    analyse = Analyse.new une_main
    analyse.combinaisons[0].to_text.must_equal "Brelan"
  end

  it "Reconnait AC AP AK AK comme brelan" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(13)
    une_main << Carte.new(26)
    une_main << Carte.new(26)
    analyse = Analyse.new une_main
    analyse.combinaisons[0].to_text.must_equal "Brelan"
  end

  it "Reconnait AC AP AK AT comme carré" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(13)
    une_main << Carte.new(26)
    une_main << Carte.new(39)
    analyse = Analyse.new une_main
    analyse.combinaisons[0].to_text.must_equal "Carré"
  end

  it "Reconnait AC Joker AP comme brelan" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(52)
    une_main << Carte.new(13)
    analyse = Analyse.new une_main
    analyse.combinaisons[0].to_text.must_equal "Brelan"
  end

  it "Reconnait AC Joker AP AT comme brelan" do
    une_main = []
    une_main << Carte.new(0)
    une_main << Carte.new(52)
    une_main << Carte.new(13)
    une_main << Carte.new(39)
    analyse = Analyse.new une_main
    analyse.combinaisons[0].to_text.must_equal "Brelan"
  end

  it "Ne traite pas 2 jokers comme une paire" do
    une_main = []
    une_main << Carte.new(52)
    une_main << Carte.new(53)
    analyse = Analyse.new une_main
    analyse.combinaisons.must_be_empty
  end

  it "Ne traite pas 3 jokers comme un brelan" do
    une_main = []
    une_main << Carte.new(52)
    une_main << Carte.new(52)
    une_main << Carte.new(53)
    analyse = Analyse.new une_main
    analyse.combinaisons.must_be_empty
  end

end


describe "Analyse", "Multiples combinaisons" do

  it "Reconnait 2C 3C 4C 2P Joker comme 2 combinaisons" do
    une_main = []
    une_main << Carte.new(1)    # 2C
    une_main << Carte.new(2)    # 3C
    une_main << Carte.new(3)    # 4C
    une_main << Carte.new(14)   # 2P
    une_main << Carte.new(52)   # Joker
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 2
  end

  it "Reconnait 2C 3C 4C 2P Joker comme 1 tierce et 1 brelan" do
    une_main = []
    une_main << Carte.new(1)    # 2C
    une_main << Carte.new(2)    # 3C
    une_main << Carte.new(3)    # 4C
    une_main << Carte.new(14)   # 2P
    une_main << Carte.new(52)   # Joker
    analyse = Analyse.new une_main
    analyse.combinaisons[0].to_text.must_equal "Tierce"
    analyse.combinaisons[1].to_text.must_equal "Brelan"
  end

  it "Reconnait AC 3C 4C 6C 9C Joker comme 2 cinquantes" do
    une_main = []
    une_main << Carte.new(0)    # AC
    une_main << Carte.new(2)    # 3C
    une_main << Carte.new(3)    # 4C
    une_main << Carte.new(5)    # 6C
    une_main << Carte.new(8)    # 9C
    une_main << Carte.new(53)   # Joker
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 2
    analyse.combinaisons[0].to_text.must_equal "Cinquante"
    analyse.combinaisons[1].to_text.must_equal "Cinquante"
    analyse.combinaisons[0].to_s.must_equal "[ AC J* 3C 4C ]"
    analyse.combinaisons[1].to_s.must_equal "[ 3C 4C J* 6C ]"
  end

  it "Reconnait 5P 8P XP DP Joker comme 2 tierces" do
    une_main = []
    une_main << Carte.new(17)   # 5P
    une_main << Carte.new(20)   # 8P
    une_main << Carte.new(22)   # XP
    une_main << Carte.new(24)   # DP
    une_main << Carte.new(53)   # Joker
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 2
    analyse.combinaisons[0].to_text.must_equal "Tierce"
    analyse.combinaisons[1].to_text.must_equal "Tierce"
    analyse.combinaisons[0].to_s.must_equal "[ 8P J* XP ]"
    analyse.combinaisons[1].to_s.must_equal "[ XP J* DP ]"
  end

  it "Reconnait toutes les combinaisons d'une distribution" do
    une_main = []
    une_main << Carte.new(0)    # AC
    une_main << Carte.new(2)    # 3C
    une_main << Carte.new(3)    # 4C
    une_main << Carte.new(5)    # 6C
    une_main << Carte.new(8)    # 9C
    une_main << Carte.new(14)   # 2P
    une_main << Carte.new(21)   # 9P
    une_main << Carte.new(25)   # RP
    une_main << Carte.new(29)   # 4K
    une_main << Carte.new(31)   # 6K
    une_main << Carte.new(39)   # AT
    une_main << Carte.new(40)   # 2T
    une_main << Carte.new(44)   # 6T
    une_main << Carte.new(53)   # Joker
    analyse = Analyse.new une_main
    analyse.combinaisons.size.must_equal 9
    # 4 suites
    analyse.combinaisons[0].to_s.must_equal "[ AC J* 3C 4C ]"
    analyse.combinaisons[1].to_s.must_equal "[ 3C 4C J* 6C ]"
    analyse.combinaisons[2].to_s.must_equal "[ 4K J* 6K ]"
    analyse.combinaisons[3].to_s.must_equal "[ AT 2T J* ]"
    # 5 séries
    analyse.combinaisons[4].to_s.must_equal "[ AC AT J* ]"
    analyse.combinaisons[5].to_s.must_equal "[ 2P 2T J* ]"
    analyse.combinaisons[6].to_s.must_equal "[ 4C 4K J* ]"
    analyse.combinaisons[7].to_s.must_equal "[ 6C 6K 6T ]"
    analyse.combinaisons[8].to_s.must_equal "[ 9C 9P J* ]"
  end

end


describe "Analyse", "Reconnait une série" do

  it "Refuse série vide" do
    serie = []
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

  it "Refuse série de 1 carte" do
    serie = []
    serie << Carte.new(0)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

  it "Refuse série de 2 cartes" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

  it "Accepte série de 3 cartes" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal true
  end

  it "Accepte série de 4 cartes" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    serie << Carte.new(39)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal true
  end

  it "Refuse série de 5 cartes" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    serie << Carte.new(39)
    serie << Carte.new(52)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

  it "Refuse série de 6 cartes" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    serie << Carte.new(39)
    serie << Carte.new(52)
    serie << Carte.new(53)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

  it "Refuse une série disparate" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(14)
    serie << Carte.new(28)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

  it "Refuse une série de jokers" do
    serie = []
    serie << Carte.new(52)
    serie << Carte.new(53)
    serie << Carte.new(53)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

  it "Accepte une Paire + Joker" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(52)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal true
  end

  it "Accepte un Brelan + Joker" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    serie << Carte.new(52)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal true
  end

  it "Refuse une Paire + 2 Jokers" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(52)
    serie << Carte.new(53)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

  it "Refuse un Brelan avec doublon" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(13)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

  it "Refuse un Carré avec doublon" do
    serie = []
    serie << Carte.new(0)
    serie << Carte.new(13)
    serie << Carte.new(26)
    serie << Carte.new(26)
    analyse = Analyse.new []
    analyse.est_une_serie?(serie).must_equal false
  end

end


describe "Analyse", "Reconnait une suite" do

  it "Refuse suite vide" do
    suite = []
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal false
  end

  it "Refuse suite de 1 carte" do
    suite = []
    suite << Carte.new(0)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal false
  end

  it "Refuse suite de 2 cartes" do
    suite = []
    suite << Carte.new(0)
    suite << Carte.new(1)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal false
  end

  it "Accepte suite de 3 cartes" do
    suite = []
    suite << Carte.new(0)
    suite << Carte.new(1)
    suite << Carte.new(2)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal true
  end

  it "Accepte suite de 10 cartes" do
    suite = []
    10.times do |i|
      suite << Carte.new(i)
    end
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal true
  end

  it "Refuse une suite disparate" do
    suite = []
    suite << Carte.new(0)
    suite << Carte.new(14)
    suite << Carte.new(28)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal false
  end

  it "Refuse une suite de jokers" do
    suite = []
    suite << Carte.new(52)
    suite << Carte.new(53)
    suite << Carte.new(53)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal false
  end

  it "Accepte une suite avec Joker au début" do
    suite = []
    suite << Carte.new(52)
    suite << Carte.new(1)
    suite << Carte.new(2)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal true
  end

  it "Accepte une suite avec Joker au milieu" do
    suite = []
    suite << Carte.new(0)
    suite << Carte.new(52)
    suite << Carte.new(2)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal true
  end

  it "Accepte une suite avec Joker à la fin" do
    suite = []
    suite << Carte.new(0)
    suite << Carte.new(1)
    suite << Carte.new(52)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal true
  end

  it "Refuse suite avec un doublon" do
    suite = []
    suite << Carte.new(0)
    suite << Carte.new(1)
    suite << Carte.new(2)
    suite << Carte.new(2)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal false
  end

  it "Refuse suite avec cartes dispersées" do
    suite = []
    suite << Carte.new(0)
    suite << Carte.new(2)
    suite << Carte.new(4)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal false
  end

  it "Accepte suite Dame Roi As" do
    suite = []
    suite << Carte.new(11)
    suite << Carte.new(12)
    suite << Carte.new(0)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal true
  end

  it "Refuse suite Roi As 2" do
    suite = []
    suite << Carte.new(12)
    suite << Carte.new(0)
    suite << Carte.new(1)
    analyse = Analyse.new []
    analyse.est_une_suite?(suite).must_equal false
  end

end
