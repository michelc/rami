# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "joueur"

class Niveau2

  attr_accessor :joueur       # Le joueur

  def initialize joueur
    self.joueur = joueur
  end

  # Détermine quelle est la meilleure carte à défausser
  # - une carte qui ne fait pas baisser le nombre de combinaisons possibles
  def meilleure_defausse les_tas
    nb_possibilites = self.joueur.combinaisons.size
    defaussables = []
    self.joueur.cartes.each do |carte|
      unless carte.est_joker?
        main = self.joueur.cartes.map { |c| c }
        index = main.find_index{ |c| c.carte_id == carte.carte_id }
        main.delete_at(index)
        analyse = Analyse.new main
        defaussables << carte if nb_possibilites == analyse.combinaisons.size
      end
    end
    defaussables = self.joueur.cartes if defaussables.size == 0
    defaussables.sample
  end

  # Détermine quelle est la meilleure combinaison à poser
  # - celle qui contient le plus de cartes
  # - avec si possible pas de joker
  def meilleure_combinaison
    nb_cartes = 0
    avec_joker = nil
    meilleure = nil
    self.joueur.combinaisons.each do |combinaison|
      if nb_cartes < combinaison.cartes.size
        nb_cartes = combinaison.cartes.size
        meilleure = combinaison
        avec_joker = meilleure.avec_joker?
      elsif nb_cartes == combinaison.cartes.size
        if avec_joker
          nb_cartes = combinaison.cartes.size
          meilleure = combinaison
          avec_joker = meilleure.avec_joker?
        end
      end
    end
    meilleure
  end

  # Détermine s'il vaut mieux prendre la défausse que piocher
  # - si cela augmente le nombre de combinaisons
  # - sinon, si cela augmente le nombre de combinaisons sans joker (ie diminue le nb avec joker)
# TODO : sinon, si cela permet de poser dans les tas déjà posés
  def mieux_vaut_prendre? carte, les_tas
    nb_possibilites = self.joueur.combinaisons.size
    nb_avec_joker = (self.joueur.combinaisons.map { |c| c.avec_joker? }).size
    main = self.joueur.cartes.map { |c| c }
    main << carte
    analyse = Analyse.new main
    nb_possibilites < analyse.combinaisons.size
    if analyse.combinaisons.size > nb_possibilites
      true
    else
      nb_avec_joker_apres = (analyse.combinaisons.map { |c| c.avec_joker? }).size
      if nb_avec_joker_apres < nb_avec_joker
        true
      else
        false
      end
    end
  end

end
