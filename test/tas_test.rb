# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "minitest/spec"
require "minitest/autorun"
require "../tas"

# COMPLET AU 4/4/2013

describe "Tas", "Vérification initialisation" do

  it "La liste des cartes du tas est vide" do
    tas = Tas.new
    tas.cartes.must_be_instance_of Array
    tas.cartes.must_be_empty
  end

  it "Le tas vaut 0 points" do
    tas = Tas.new
    tas.points.must_equal 0
  end

  it "Le tas est lié à aucun joueur" do
    tas = Tas.new
    tas.nom_joueur.must_be_nil
  end

end


describe "Tas", "Vérification ajout carte" do

  it "Ajoute une carte à la liste des cartes" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(20)
    tas.cartes.size.must_equal 1
  end

  it "Ajoute la carte indiquée" do
    tas = Tas.new
    nouvelle = Carte.new 20
    tas.ajouter_une_carte nouvelle
    tas.cartes.include?(nouvelle).must_equal true
  end

  it "Ajoute la carte à la fin du tas" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(1)
    nouvelle = Carte.new 2
    tas.ajouter_une_carte nouvelle
    tas.cartes.last.must_equal nouvelle
  end

  it "Ajoute la carte au début du tas" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(1)
    tas.ajouter_une_carte Carte.new(2)
    tas.ajouter_une_carte Carte.new(52)
    nouvelle = Carte.new 0
    tas.ajouter_une_carte nouvelle
    tas.cartes.first.must_equal nouvelle
  end

end


describe "Tas", "Vérification combinaison" do

  it "Reconnait un simple tas" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(10)
    tas.ajouter_une_carte Carte.new(33)
    tas.combinaison.type.must_equal :tas
  end

  it "Reconnait une suite" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(1)
    tas.ajouter_une_carte Carte.new(2)
    tas.combinaison.type.must_equal :suite
  end

  it "Reconnait une série" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    tas.combinaison.type.must_equal :serie
  end

end


describe "Tas", "Vérification complete_le_tas? pour les suites" do

  it "Accepte la carte avant la suite" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(5)
    complete = tas.complete_le_tas? Carte.new(2)
    complete.must_equal true
  end

  it "Accepte la carte après la suite" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(5)
    complete = tas.complete_le_tas? Carte.new(6)
    complete.must_equal true
  end

  it "Accepte la carte avant le joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(52)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(5)
    complete = tas.complete_le_tas? Carte.new(2)
    complete.must_equal true
  end

  it "Accepte la carte après le joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(52)
    complete = tas.complete_le_tas? Carte.new(6)
    complete.must_equal true
  end

  it "Accepte un joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(5)
    complete = tas.complete_le_tas? Carte.new(52)
    complete.must_equal true
  end

  it "Refuse un joker s'il y en a déjà un" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(52)
    tas.ajouter_une_carte Carte.new(5)
    complete = tas.complete_le_tas? Carte.new(52)
    complete.must_equal false
  end

  it "Refuse les autres cartes" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(5)
    complete = tas.complete_le_tas? Carte.new(20)
    complete.must_equal false
  end

end


describe "Tas", "Vérification complete_le_tas? pour les séries" do

  it "Accepte la 4° carte pour un Carré" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    complete = tas.complete_le_tas? Carte.new(39)
    complete.must_equal true
  end

  it "Refuse un double comme 4° carte pour un Carré" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    complete = tas.complete_le_tas? Carte.new(26)
    complete.must_equal false
  end

  it "Refuse les autres cartes pour un Carré" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    complete = tas.complete_le_tas? Carte.new(20)
    complete.must_equal false
  end

  it "Accepte la 3° carte pour un Carré avec Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(52)
    complete = tas.complete_le_tas? Carte.new(26)
    complete.must_equal true
  end

  it "Accepte la 4° carte pour un Carré avec Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(52)
    complete = tas.complete_le_tas? Carte.new(39)
    complete.must_equal true
  end

  it "Refuse un double pour un Carré avec Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(52)
    complete = tas.complete_le_tas? Carte.new(13)
    complete.must_equal false
  end

  it "Accepte un joker pour un Carré sans Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    complete = tas.complete_le_tas? Carte.new(52)
    complete.must_equal true
  end

  it "Refuse un joker pour un Carré avec Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(52)
    complete = tas.complete_le_tas? Carte.new(52)
    complete.must_equal false
  end

  it "Refuse les autres cartes pour un Carré" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    complete = tas.complete_le_tas? Carte.new(20)
    complete.must_equal false
  end

end


describe "Tas", "Vérification remplace_le_joker? pour les suites" do

  it "Accepte si la première carte d'une tierce" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(52)
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    remplace = tas.remplace_le_joker? Carte.new(2)
    remplace.must_equal true
  end

  it "Accepte si une carte du milieu d'une tierce" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(52)
    tas.ajouter_une_carte Carte.new(5)
    remplace = tas.remplace_le_joker? Carte.new(4)
    remplace.must_equal true
  end

  it "Accepte si la dernière carte d'une tierce" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(5)
    remplace.must_equal true
  end

  it "Refuse si carte est un joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(52)
    remplace.must_equal false
  end

  it "Refuse carte qui va ailleurs qu'à la place du joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(2)
    remplace.must_equal false
  end

  it "Refuse si c'est une autre carte" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(20)
    remplace.must_equal false
  end

end


describe "Tas", "Vérification remplace_le_joker? pour les séries" do

  it "Accepte la 4° carte sur un Brelan + Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(39)
    remplace.must_equal true
  end

  it "Refuse un double comme 4° carte sur un Brelan + Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(0)
    remplace.must_equal false
  end

  it "Refuse un Joker sur un Brelan + Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(52)
    remplace.must_equal false
  end

  it "Refuse autre carte sur un Brelan + Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(20)
    remplace.must_equal false
  end

  it "Refuse la 3° carte sur une Paire + Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(26)
    remplace.must_equal false
  end

  it "Refuse la 4° carte sur une Paire + Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(39)
    remplace.must_equal false
  end

  it "Refuse un double sur une Paire + Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(0)
    remplace.must_equal false
  end

  it "Refuse un Joker sur une Paire + Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(52)
    remplace.must_equal false
  end

  it "Refuse autre carte sur une Paire + Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.remplace_le_joker? Carte.new(20)
    remplace.must_equal false
  end

end


describe "Tas", "Vérification echanger_le_joker pour les suites" do

  it "OK avec une carte qui remplace le Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(52)
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    remplace = tas.echanger_le_joker Carte.new(2)
    remplace.must_equal Carte.new(52)
    tas.combinaison.avec_joker?.must_equal false
  end

  it "KO avec une carte qui ne remplace pas le Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(3)
    tas.ajouter_une_carte Carte.new(4)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.echanger_le_joker Carte.new(20)
    remplace.must_be_nil
    tas.combinaison.avec_joker?.must_equal true
  end

end


describe "Tas", "Vérification echanger_le_joker pour les séries" do

  it "OK avec une carte qui remplace le Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.echanger_le_joker Carte.new(39)
    remplace.must_equal Carte.new(52)
    tas.combinaison.avec_joker?.must_equal false
  end

  it "KO avec une carte qui ne remplace pas le Joker" do
    tas = Tas.new
    tas.ajouter_une_carte Carte.new(0)
    tas.ajouter_une_carte Carte.new(13)
    tas.ajouter_une_carte Carte.new(26)
    tas.ajouter_une_carte Carte.new(52)
    remplace = tas.echanger_le_joker Carte.new(20)
    remplace.must_be_nil
    tas.combinaison.avec_joker?.must_equal true
  end

end
