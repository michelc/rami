# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "minitest/autorun"
require "../paquet"

# COMPLET AU 4/4/2013

describe "Paquet", "Vérification constantes" do

  it "1 jeu de cartes compte 54 cartes" do
    Paquet::NB_CARTES.must_equal 54
  end

end


describe "Paquet", "Vérification initialisation" do

  it "Crée un paquet de 54 cartes par défaut" do
    Paquet.new.pioche.size.must_equal Paquet::NB_CARTES
  end

  it "3 jeux de cartes font un paquet de 162 cartes" do
    Paquet.new(3).pioche.size.must_equal Paquet::NB_CARTES * 3
  end

  it "Crée une pioche avec toutes les cartes" do
    Paquet.new.pioche.must_be_instance_of Array
    Paquet.new.pioche.size.must_equal Paquet::NB_CARTES
  end

  it "Crée une défausse vide" do
    Paquet.new.defausse.must_be_instance_of Array
    Paquet.new.defausse.must_be_empty
  end

  it "Mélange les cartes du paquet" do
    paquet = Paquet.new
    paquet.pioche.wont_equal paquet.pioche.sort
  end

end


describe "Paquet", "Vérification distribution" do

  it "Distribue le nb de cartes demandées" do
    paquet = Paquet.new
    main = paquet.distribuer_une_main 10
    main.size.must_equal 10
  end

  it "Diminue la pioche du nb de cartes distribuées" do
    paquet = Paquet.new
    main = paquet.distribuer_une_main 10
    paquet.pioche.size.must_equal Paquet::NB_CARTES - 10
  end

end


describe "Paquet", "Vérification piochage" do

  it "Renvoie une carte" do
    paquet = Paquet.new
    carte = paquet.piocher_une_carte
    carte.must_be_instance_of Carte
  end

  it "Diminue la pioche de une carte" do
    paquet = Paquet.new
    paquet.piocher_une_carte
    paquet.pioche.size.must_equal Paquet::NB_CARTES - 1
  end

end


describe "Paquet", "Vérification défaussage" do

  it "Augmente la défausse de une carte" do
    paquet = Paquet.new
    paquet.defausser_une_carte Carte.new(10)
    paquet.defausse.size.must_equal 1
  end

  it "Place la carte défaussé sur la pile de défausse" do
    paquet = Paquet.new
    paquet.defausser_une_carte Carte.new(10)
    carte = Carte.new(20)
    paquet.defausser_une_carte carte
    paquet.defausse.last.must_equal carte
  end

end


describe "Paquet", "Vérification prise à la défausse" do

  it "Renvoie une carte" do
    paquet = Paquet.new
    paquet.defausser_une_carte Carte.new(10)
    carte = paquet.prendre_la_defausse
    carte.must_be_instance_of Carte
  end

  it "Diminue la défausse de une carte" do
    paquet = Paquet.new
    paquet.defausser_une_carte Carte.new(10)
    paquet.prendre_la_defausse
    paquet.defausse.must_be_empty
  end

  it "Renvoie la carte du haut de la défausse" do
    paquet = Paquet.new
    premiere = Carte.new(10)
    deuxieme = Carte.new(20)
    derniere = Carte.new(30)
    paquet.defausser_une_carte premiere
    paquet.defausser_une_carte deuxieme
    paquet.defausser_une_carte derniere
    carte = paquet.prendre_la_defausse
    carte.must_equal derniere
  end

end


describe "Paquet", "Vérification contenu de la défausse" do

  it "Indique quelle est la carte sur la défausse" do
    paquet = Paquet.new
    premiere = Carte.new(10)
    deuxieme = Carte.new(20)
    derniere = Carte.new(30)
    paquet.defausser_une_carte premiere
    paquet.defausser_une_carte deuxieme
    paquet.defausser_une_carte derniere
    carte = paquet.carte_defausse
    carte.must_equal derniere
  end

  it "Laisse la carte sur sur la défausse" do
    paquet = Paquet.new
    premiere = Carte.new(10)
    deuxieme = Carte.new(20)
    derniere = Carte.new(30)
    paquet.defausser_une_carte premiere
    paquet.defausser_une_carte deuxieme
    paquet.defausser_une_carte derniere
    carte = paquet.carte_defausse
    paquet.defausse.last.must_equal derniere
  end

end
