# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "minitest/autorun"
require "../joueur"

# MANQUE 3 TESTS POUR NIVEAU AU 4/4/2013

describe "Joueur", "Vérification constantes" do

  it "1 main de joueur compte 14 cartes" do
    Joueur::TAILLE_MAIN.must_equal 14
  end

end


describe "Joueur", "Vérification initialisation" do

  it "Défini le nom du joueur" do
    Joueur.new("Toto").nom.must_equal "Toto"
  end

  it "Crée une main vide" do
    joueur = Joueur.new("Toto")
    joueur.cartes.must_be_instance_of Array
    joueur.cartes.must_be_empty
  end

  it "Crée une liste vide des combinaisons" do
    joueur = Joueur.new("Toto")
    joueur.combinaisons.must_be_instance_of Array
    joueur.combinaisons.must_be_empty
  end

  it "Met à zéro le tour en cours" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour.must_equal 0
    joueur.a_pose_combien.must_equal 0
    joueur.a_atteint_51?.must_equal false
  end

end


describe "Joueur", "Vérification est-humain?" do

  it "Est un joueur humain par défaut" do
    joueur = Joueur.new("Toto")
    joueur.est_humain?.must_equal true
  end

  it "N'est pas un joueur humain si niveau est défini" do
    joueur = Joueur.new("Toto")
    joueur.niveau = ""
    joueur.est_humain?.must_equal false
  end

end


describe "Joueur", "Vérification ramassage" do

  it "Remplit la main du joueur" do
    joueur = Joueur.new("Toto")
    distribution = (0...5).map { |i| Carte.new i }
    joueur.ramasser_cartes distribution
    joueur.cartes.size.must_equal 5
  end

  it "Remplit la main du joueur avec les cartes triées" do
    joueur = Joueur.new("Toto")
    distribution = (0...5).map { |i| Carte.new i }
    distribution.shuffle!
    joueur.ramasser_cartes distribution
    joueur.cartes.must_equal distribution.sort
  end

  it "Remplit la main du joueur après l'avoir vidée" do
    joueur = Joueur.new("Toto")
    distribution1 = (0...10).map { |i| Carte.new i }
    joueur.ramasser_cartes distribution1
    distribution2 = (0...5).map { |i| Carte.new i }
    joueur.ramasser_cartes distribution2
    joueur.cartes.size.must_equal 5
  end

  it "Alimente la liste des combinaisons" do
    joueur = Joueur.new("Toto")
    distribution = (0..3).map { |i| Carte.new i }
    distribution << Carte.new(13)
    joueur.ramasser_cartes distribution
    joueur.combinaisons.size.must_equal 1
  end

  it "Met à zéro le tour en cours" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour = 10
    joueur.a_pose_combien = 100
    joueur.ramasser_cartes []
    joueur.compte_tour.must_equal 0
    joueur.a_pose_combien.must_equal 0
    joueur.a_atteint_51?.must_equal false
  end

end


describe "Joueur", "Vérification ajout carte" do

  it "Ajoute une carte à la main du joueur" do
    joueur = Joueur.new("Toto")
    distribution = (0...5).map { |i| Carte.new i }
    joueur.ramasser_cartes distribution
    joueur.ajouter_une_carte Carte.new(20)
    joueur.cartes.size.must_equal 6
  end

  it "Ajoute la carte indiquée" do
    joueur = Joueur.new("Toto")
    distribution = (0...5).map { |i| Carte.new i }
    joueur.ramasser_cartes distribution
    nouvelle = Carte.new 20
    joueur.ajouter_une_carte nouvelle
    joueur.cartes.include?(nouvelle).must_equal true
  end

  it "Actualise la liste des combinaisons à partir de 4 cartes" do
    joueur = Joueur.new("Toto")
    joueur.ajouter_une_carte Carte.new(0)
    joueur.combinaisons.must_be_empty
    joueur.ajouter_une_carte Carte.new(1)
    joueur.combinaisons.must_be_empty
    joueur.ajouter_une_carte Carte.new(2)
    joueur.combinaisons.must_be_empty
    joueur.ajouter_une_carte Carte.new(33)
    joueur.combinaisons.size.must_equal 1
  end

end


describe "Joueur", "Vérification retrait carte" do

  it "Supprime une carte à la main du joueur" do
    joueur = Joueur.new("Toto")
    distribution = (0...5).map { |i| Carte.new i }
    joueur.ramasser_cartes distribution
    joueur.enlever_une_carte distribution.sample
    joueur.cartes.size.must_equal 4
  end

  it "Supprime la carte indiquée" do
    joueur = Joueur.new("Toto")
    distribution = (0...5).map { |i| Carte.new i }
    joueur.ramasser_cartes distribution
    joueur.enlever_une_carte distribution.last
    joueur.cartes.include?(distribution.last).must_equal false
  end

  it "Actualise la liste des combinaisons" do
    joueur = Joueur.new("Toto")
    distribution = (0..2).map { |i| Carte.new i }
    distribution += (7..9).map { |i| Carte.new i }
    joueur.ramasser_cartes distribution
    joueur.combinaisons.size.must_equal 2
    joueur.enlever_une_carte distribution.last
    joueur.combinaisons.size.must_equal 1
  end

  it "Actualise la liste des combinaisons tant que au moins 3 cartes" do
    joueur = Joueur.new("Toto")
    distribution = (0..3).map { |i| Carte.new i }
    joueur.ramasser_cartes distribution
    joueur.combinaisons.size.must_equal 1
    joueur.enlever_une_carte distribution.last
    joueur.combinaisons.must_be_empty
  end

end


describe "Joueur", "Vérification incrementer_tour" do

  it "Augmente le compteur de tour" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour.must_equal 0
    joueur.incrementer_tour
    joueur.compte_tour.must_equal 1
  end

  it "Laisse à faux le drapeau 51 points si pas atteints" do
    joueur = Joueur.new("Toto")
    joueur.incrementer_tour
    joueur.a_atteint_51.must_equal false
    joueur.a_pose_combien = 33
    joueur.incrementer_tour
    joueur.a_atteint_51.must_equal false
  end

  it "Met à vrai le drapeau 51 points si déjà marqués" do
    joueur = Joueur.new("Toto")
    joueur.a_pose_combien = 51
    joueur.incrementer_tour
    joueur.a_atteint_51.must_equal true
  end

end


describe "Joueur", "Vérification a_pose_tierce?" do

  it "Non s'il n'a pas encore de points" do
    joueur = Joueur.new("Toto")
    joueur.a_pose_tierce?.must_equal false
  end

  it "Oui dès qu'il a des points" do
    joueur = Joueur.new("Toto")
    joueur.a_pose_combien = 1
    joueur.a_pose_tierce?.must_equal true
    joueur.a_pose_combien = 123456789
    joueur.a_pose_tierce?.must_equal true
  end

end


describe "Joueur", "Vérification a_pose_51?" do

  it "Non s'il n'a pas encore 51 points" do
    joueur = Joueur.new("Toto")
    joueur.a_pose_51?.must_equal false
    joueur.a_pose_combien = 50
    joueur.a_pose_51?.must_equal false
  end

  it "Oui dès qu'il a 51 points" do
    joueur = Joueur.new("Toto")
    joueur.a_pose_combien = 51
    joueur.a_pose_51?.must_equal true
  end

end


describe "Joueur", "Vérification a_atteint_51?" do

  it "Non s'il la propriété est fausse" do
    joueur = Joueur.new("Toto")
    joueur.a_atteint_51 = false
    joueur.a_atteint_51?.must_equal false
  end

  it "Oui s'il la propriété est vraie" do
    joueur = Joueur.new("Toto")
    joueur.a_atteint_51 = true
    joueur.a_atteint_51?.must_equal true
  end

end


describe "Joueur", "Vérification peut_prendre?" do

  it "Oui si c'est son 1° tour" do
    joueur = Joueur.new("Toto")
    joueur.peut_prendre?.must_equal true
  end

  it "Non s'il n'a qu'une carte dans sa main" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour = 1
    joueur.ajouter_une_carte Carte.new(0)
    joueur.peut_prendre?.must_equal false
  end

  it "Oui s'il a posé ses 51 points" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour = 1
    joueur.a_pose_combien = 51
    joueur.ajouter_une_carte Carte.new(0)
    joueur.ajouter_une_carte Carte.new(1)
    joueur.peut_prendre?.must_equal true
  end

  it "Oui s'il a une tierce franche en main" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour = 1
    joueur.ajouter_une_carte Carte.new(0)
    joueur.ajouter_une_carte Carte.new(1)
    joueur.ajouter_une_carte Carte.new(2)
    joueur.ajouter_une_carte Carte.new(33)
    joueur.peut_prendre?.must_equal true
  end

  it "Non s'il n'a pas encore sa tierce franche" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour = 1
    joueur.ajouter_une_carte Carte.new(0)
    joueur.ajouter_une_carte Carte.new(1)
    joueur.peut_prendre?.must_equal false
  end

end


describe "Joueur", "Vérification tierce_franche?" do

  it "Non s'il n'a pas de tierce franche dans sa main" do
    joueur = Joueur.new("Toto")
    joueur.tierce_franche?.must_equal false
  end

  it "Non s'il a déjà posé sa tierce franche" do
    joueur = Joueur.new("Toto")
    joueur.a_pose_combien = 1
    joueur.tierce_franche?.must_equal false
  end

  it "Oui s'il a une tierce franche en main" do
    joueur = Joueur.new("Toto")
    joueur.ramasser_cartes (0..3).map { |i| Carte.new i }
    joueur.tierce_franche?.must_equal true
  end

end


describe "Joueur", "Vérification peut_poser?" do

  it "Non si c'est le 1° tour" do
    joueur = Joueur.new("Toto")
    joueur.peut_poser?.must_equal false
  end

  it "Oui s'il a déjà posé sa tierce franche" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour = 1
    joueur.a_pose_combien = 1
    joueur.peut_poser?.must_equal true
  end

  it "Non s'il doit poser une tierce franche et qu'il n'en a pas" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour = 1
    joueur.peut_poser?.must_equal false
  end

  it "Oui s'il doit poser une tierce franche et qu'il en a une" do
    joueur = Joueur.new("Toto")
    joueur.compte_tour = 1
    joueur.ajouter_une_carte Carte.new(0)
    joueur.ajouter_une_carte Carte.new(1)
    joueur.ajouter_une_carte Carte.new(2)
    joueur.ajouter_une_carte Carte.new(33)
    joueur.peut_poser?.must_equal true
  end

end
