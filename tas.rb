# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "carte"
require "analyse"
require "combinaison"


# Classe Tas
# Représente un tas de cartes posées
# (totalement lié au jeu de Rami)

class Tas

  attr_accessor :tas_id       # Identifiant du tas
  attr_accessor :cartes       # Tableau des cartes qui composent le tas
  attr_accessor :points       # Nombre de points apportés par le tas
  attr_accessor :nom_joueur   # Nom du joueur qui a créé le tas

  def initialize tas_id = -1
    self.tas_id = tas_id
    clear
  end

  def clear
    self.cartes = []
    self.points = 0
    self.nom_joueur = nil
    @_combinaison = nil
  end

  # Affiche les cartes de la combinaison
  def to_s
    text = (self.cartes.map { |c| c.to_s }).join " "
    "[ #{text} ]"
  end

  def ajouter_une_carte carte
    # Mémorise si le tas contient actuellement une suite
    est_une_suite = self.combinaison.type == :suite
    # Ajoute la carte à la fin du tas
    self.cartes << carte
    # Vérifie éventuellement que la suite est toujours OK
    if est_une_suite
      # Si la suite n'est plus OK
      analyse = Analyse.new []
      unless analyse.est_une_suite? self.cartes
        # - Enlève la carte de la fin du tas
        self.cartes.pop
        # - Pour la placer au début du tas
        self.cartes.unshift carte
      end
    end
    @_combinaison = nil
  end

  def combinaison
    unless @_combinaison
      analyse = Analyse.new []
      if analyse.est_une_serie? self.cartes
        # Le tas constitue une série => autant la poser rangée
        self.cartes.sort!
        @_combinaison = Combinaison.new(:serie, self.cartes)
      elsif analyse.est_une_suite? self.cartes
        # Le tas constitue une suite tel quel => on la laisse telle quelle
        @_combinaison = Combinaison.new(:suite, self.cartes)
      else
        # On vérifie si toutes les cartes du tas constituent une combinaison
        analyse = Analyse.new self.cartes
        @_combinaison = analyse.combinaisons.find { |c| c.cartes.size == self.cartes.size }
        if @_combinaison
          # Le tas complet et re-trié constitue une combinaison
          # => on récupère le "bon" ordre des cartes pour la combinaison
          self.cartes = @_combinaison.cartes
        else
          # Le tas ne constitue pas une combinaison
          @_combinaison = Combinaison.new(:tas, self.cartes)
        end
      end
    end
    @_combinaison
  end

  # Indique si la carte examinée peut être ajoutée au tas
  def complete_le_tas? carte
    if carte.est_joker?
      if self.combinaison.avec_joker?
        # Joker refusé si le tas en contient déjà un
        false
      elsif self.combinaison.type == :suite
        # Joker accepté sur une suite qui n'en contient pas
        true
      else
        # Joker accepté sur une série de 3 cartes
        self.cartes.size == 3
      end
    else
      # Carte acceptée si correspond à une de celles qui complète le tas
      self.combinaison.complements.any? { |c| c == carte }
    end
  end

  # Indique si la carte examinée peut remplacer le joker dans le tas
  def remplace_le_joker? carte
    if carte.est_joker?
      # Joker ne peut pas remplacer un joker
      false
    elsif self.cartes.size < 3
      # Le joker n'est remplaçable qu'après avoir posé une combinaison complète
      false
    elsif self.combinaison.remplacement == nil
      # Le tas ne contient pas de joker remplaçable => on ne peut pas le remplacer
      false
    else
      # Le joker est remplaçable si la carte est celle que le joker remplace
      self.combinaison.remplacement == carte
    end
  end

  # Echange le joker du tas avec la carte
  def echanger_le_joker carte
    if remplace_le_joker? carte
      index = self.cartes.find_index { |c| c.est_joker? }
      joker = self.cartes[index]
      self.cartes.delete_at(index)
      self.cartes << carte
      @_combinaison = nil
      combinaison   # pour raffraichir l'ordre des cartes dans le tas
      joker
    else
      nil
    end
  end

end
