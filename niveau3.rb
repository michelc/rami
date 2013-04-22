# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "joueur"

class Niveau3

  attr_accessor :joueur       # Le joueur
  attr_accessor :trace

  def initialize joueur
    self.joueur = joueur
  end

  # Détermine quelle est la meilleure carte à défausser
  # - une carte qui ne fait pas baisser le nombre de combinaisons possibles
  def meilleure_defausse les_tas
    # Calcule le score de chaque carte dans la main du joueur
    scores = score_cartes(nil, les_tas)
    # Détermine le score le plus bas
    minimum = scores.values.sort.first
    # Retrouve toutes les cartes concernées par le plus faible score
    defaussables = scores.select { | _k, v | v == minimum }.keys
    # Repose une des cartes faiblichonnes
    defaussables.sample
  end

  # Détermine quelle est la meilleure combinaison à poser
  # - celle qui contient le plus de cartes
  # - avec si possible pas de joker
  def meilleure_combinaison
    nb_cartes = 0
    avec_joker = nil
    meilleure = nil

    #
    if joueur.tierce_franche?
      tierces = self.joueur.combinaisons.select { |c| c.tierce_franche? }
      sans_joker = tierces.reject { |c| c.avec_joker? }
      return sans_joker.sample if sans_joker.size > 0
      return tierces.sample
    end

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
    # Non si le joueur n'a pas le droit de prendre la carte à la défausse
    self.trace = "interdit"
    return false if self.joueur.peut_prendre? == false

    # Calcule le score de chaque carte dans la main du joueur
    scores = score_cartes(carte, les_tas)
    # Si le score de la carte tirée est inférieur à 40
    # => La carte n'est pas directement posable
    self.trace = "score"
    return false if scores[carte] < 40

    # Si la carte est posable
    # Et que le joueur a déjà posé des 51 points
    # => Autant prendre la carte
    self.trace = "" if self.joueur.a_pose_51?
    return true if self.joueur.a_pose_51?

    # Sinon, il peut prendre à condition d'améliorer sa main
    # (ou pour l'instant son nombre de combinaisons)
    nb_possibilites = self.joueur.combinaisons.size
    nb_avec_joker = (self.joueur.combinaisons.map { |c| c.avec_joker? }).size
    main = self.joueur.cartes.clone
    main << carte
    analyse = Analyse.new main
    nb_possibilites < analyse.combinaisons.size
    if analyse.combinaisons.size > nb_possibilites
      self.trace = ""
      true
    else
      nb_avec_joker_apres = (analyse.combinaisons.map { |c| c.avec_joker? }).size
      if nb_avec_joker_apres < nb_avec_joker
        self.trace = ""
        true
      else
        self.trace = "pareil"
        false
      end
    end
  end

  def score_cartes autre_carte, les_tas
    # On analyse la main du joueur
    # pour compter l'intérêt de chaque carte dans sa main
    main = self.joueur.cartes

    # On complète la main avec la carte à examiner
    if autre_carte
      self.joueur.ajouter_une_carte autre_carte
    end
    main = self.joueur.cartes

    # Quelles sonts les combinaisons dans la main du joueur
    combinaisons = self.joueur.combinaisons

    # Si le joueur n'a pas de joker, on lui en ajoute un
    # ce qui permet de voir quelles sont les cartes qui
    # pourraient former une combinaison (un 6 et un 7 de
    # pique sont plus intéressants qu'un 8 de coeur tout
    # seul).
    a_un_joker = main.any? { |c| c.est_joker? }
    unless a_un_joker
      main_plus_joker = main + [ Carte.new(52) ]
      analyse = Analyse.new main_plus_joker
      combinaisons = analyse.combinaisons
    end

    # On recense toutes les cartes utilisées dans des combinaisons
    utiles = []
    combinaisons.each do |combi|
      utiles += combi.cartes
    end

    # On regarde si le joueur a toujours besoin d'une tierce franche
    a_besoin_tierce = self.joueur.a_pose_tierce? ? false : true

    # On compte le nombre de tierce franche du joueur
    nb_tierces_franches = combinaisons.count { |combi| combi.tierce_franche? }

    # On examine maintenant toutes les cartes du joueur
    scores = Hash.new 0
    main.each_with_index do |carte, i|

      #
      score = 0

      # Un joker est inestimable
      if carte.est_joker?
        score += 1_000_000
        scores[carte] = score
        next
      end

      # On regarde si la carte est en double
      nb_cartes = main.count { |c| c == carte }
      en_double = nb_cartes > 1

      # On passe en revue toutes les combinaisons où apparait la carte
      combinaisons.each do |combi|

        est_utilisee = combi.cartes.any? { |c| c == carte }
        next unless est_utilisee

        # Est-ce que la carte sert dans une tierce franche
        if combi.tierce_franche? && a_besoin_tierce
          # On valorise la carte en fonction du nb de tierce franche du joueur
          case nb_tierces_franches
          when 1
            # La carte fait partie de la seule tierce franche du joueur
            score += 100
          when 2
            # Le joueur a 2 tierce franche
            score += 75
          else
            score += 50
          end
          # Rien d'autre à faire
          next # ???
        end

        # Est-ce que la carte fait parti d'une combinaison où le joker
        # est facultatif ?
        if combi.joker_facultatif?
          # Oui => elle est donc pas mal intéressante
          score += 40
          next
        end

        # Lorsque le joker est indispensable,
        # on regarde s'il est facilement remplacable
        if combi.remplacement == nil
          # Le joker est remplaçable par 2 autres cartes
          # (cas Brelan = Paire + Joker => joker pas "remplaçable" immédiatement car il faut 2 cartes)
          # => la combinaison a de forte chance d'être réalisable
          # => la carte est raisonablement intéressante
          score += 20
        else
          # Le joker est remplaçable par 1 seule carte
          # => la combinaison a moins de chance d'être réalisable
          # => la carte est malgré tout intéressante
          score += 10
        end

      end

      # Si la carte ne vaut "rien" en elle même
      if score == 0
        # Mais que le joueur a déjà posé
        if self.joueur.a_pose_51?
          # On regarde si la carte n'est pas posable sur un tas

          les_tas.each_with_index do |un_tas|

            est_utilisee = un_tas.cartes.any? { |c| c == carte }
            next unless est_utilisee

            if un_tas.remplace_le_joker? carte
              # La pose de cette carte sur le tas permet de récupérer le joker
              score += 1000
            elsif un_tas.complete_le_tas? carte
              # La carte sera posable sur la tas
              score += 40
            end

          end

        end
      end

      # On mémorise le score de la carte
      scores[carte] = score

      if i < self.joueur.cartes.size
        self.joueur.cartes[i].tooltip = score
      end

    end

    if autre_carte
      self.joueur.enlever_une_carte autre_carte
    end
    # Renvoie les différents scores
    scores

  end

end
