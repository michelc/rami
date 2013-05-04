# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "carte"

# Classe Combinaison
# Représente une combinaison (suite ou série) de cartes
# (totalement lié au jeu de Rami)

class Combinaison

  attr_accessor :type           # Type de combinaison :suite (couleur) ou :serie (valeur)
  attr_accessor :cartes         # Tableau des cartes qui composent la combinaison
  attr_accessor :points         # Nombre de points apportés par la combinaison
  attr_accessor :remplacement   # Carte qui peut remplacer le joker
  attr_accessor :complements    # Cartes qui peuvent être ajoutées à la combinaison

  attr_accessor :tooltip        # Information de débugage pour afficher ce qui peut compléter le tas

  def initialize type, cartes
    self.type = type
    self.cartes = cartes.clone
    # L'ordre d'appel de ces 3 fonnctions est important
    self.remplacement = chercher_remplacement
    self.complements = chercher_complements
    self.points = compter_les_points
    self.tooltip = self.remplacement ? "Joker = #{self.remplacement.to_s} // " : ""
    self.tooltip += "[ "
    self.complements.each { |c| self.tooltip += c.to_s + " " }
    self.tooltip += "]"
  end

  # Affiche le nom de la combinaison
  def to_text
    if self.type == :tas
      "Tas"
    elsif self.type == :suite
      case cartes.size
      when 3
        "Tierce"
      when 4
        "Cinquante"
      when 5
        "Cent"
      else
        "Suite"
      end
    else
      case cartes.size
      when 3
        "Brelan"
      else
        "Carré"
      end
    end
  end

  # Affiche les cartes de la combinaison
  def to_s
    text = (self.cartes.map { |c| c.to_s }).join " "
    "[ #{text} ]"
  end

  def avec_joker?
    self.cartes.any? { |c| c.est_joker? }
  end

  def tierce_franche?
    if self.type == :tas
      # Combinaison est un tas sans rien de particulier
      # => ce n'est donc pas une tierce franche
      false
    elsif self.type == :serie
      # Combinaison constitue une série
      # => ce n'est donc pas une tierce franche
      false
    elsif avec_joker? == false
      # Combinaison est une suite sans joker
      # => elle contient donc une tierce franche
      true
    else
      # Combinaison est une suite avec joker
      j_pos = self.cartes.find_index { |c| c.est_joker? }
      if self.cartes.first(j_pos).size >= 3
        # Où le joker apparait après la 3° carte
        # => les 3 premières cartes forment une tierce franche
        true
      elsif self.cartes.slice(j_pos, 99).size > 3
        # Où il y a au moins 3 cartes après le joker
        # => les 3 dernières cartes forment une tierce franche
        true
      else
        # Où il y a moins de 3 cartes avant ou après le joker
        # => on ne peut pas former une tierce franche
        false
      end
    end
  end

  def joker_facultatif?
    if avec_joker? == false
      # La combinaison ne contient pas de joker
      # => le joker est forcément facultatif
      true
    elsif tierce_franche?
      # La combinaison constitue une tierce franche
      # (mais ça peut être un Cent : 2 Joker 4 5 6)
      # => le joker est forcément facultatif
      true
    elsif self.cartes.size == 3
      # La combinaison contient 3 cartes
      # (dont un joker)
      # => le joker est indispensable
      false
    elsif self.type == :serie
      # La combinaison est une série de plus de 3 cartes
      # (donc 3 cartes plus un Joker)
      # => le joker est facultatif
      true
    else
      # La combinaison est une suite de plus de 3 cartes
      # (mais ne contient pas une tierce franche)
      # => le joker est indispensable
      false
    end
  end

  # Recherche les cartes qui pourraient rendre le joker facultatif
  def possibilites
    if self.joker_facultatif?
      # Le Joker est facultatif
      # => On n'a pas besoin d'autres cartes pour que la combinaison soit complète
      []
    elsif self.type == :serie
      # Le Joker est indispensable dans une série (donc Paire + Joker)
      # => Il faut récupérer une des 2 cartes complémentaires pour espérer
      #    terminer la combinaison
      self.complements
    elsif self.cartes.first.est_as? || self.cartes.last.est_as?
      # Suite avec un As sur un des bords
      # => Le Joker est soit à l'autre bord, soit au milieu de la suite
      # => Il n'y a donc qu'une carte à récupérer pour terminer la combinaison,
      #    celle que le Joker remplace
      [ self.remplacement ]
    elsif self.cartes.first.est_joker?
      # Suite avec Joker en première carte
      # => Il y a 2 cartes à récupérer pour terminer la combinaison,
      #    celle que le joker remplace et celle qui suit la dernière carte
      [ self.remplacement, self.cartes.last.carte_apres ]
    elsif self.cartes.last.est_joker?
      # Suite avec Joker en dernière carte
      # => Il y a 2 cartes à récupérer pour terminer la combinaison,
      #    celle que le joker remplace et celle qui précède la première carte
      [ self.remplacement, self.cartes.first.carte_avant ]
    else
      # => Le Joker n'est pas au bord, il n'y a donc qu'une carte à récupérer
      #    pour terminer la combinaison, celle que le Joker remplace
      possibilites = [ self.remplacement ]
      if self.cartes[2].est_joker?
        # Et aussi celle qui précède la première carte
        # - [ 3 4 J 6 ] => _2_ 5
        # - [ 3 4 J 6 7 ] => _2_ 5 8
        possibilites << self.cartes.first.carte_avant
      end
      if self.cartes[self.cartes.size - 3].est_joker?
        # Et aussi celle qui suit la dernière carte
        # - [ 3 J 5 6 ] => 4 _7_
        # - [ 3 4 J 6 7 ] => 2 5 _8_
        possibilites << self.cartes.last.carte_apres
      end
      possibilites
    end
  end

  private

  # Compte le nombre de point que rapporte la combinaison
  def compter_les_points
    return 0 if self.type == :tas
    total_points = 0
    self.cartes.each_with_index do |carte, index|
      valeur = carte.valeur
      # Gestion valorisation du joker
      if carte.est_joker?
        if self.type == :serie
          # Joker est dans une série
          # => il a la même valeur que les autres cartes dans la série
          # (le joket est toujours à la fin de la série)
          valeur = self.cartes[0].valeur
        else
          # Joker est dans une suite
          # => il a la valeur de la carte qu'il remplace
          # (doit donc se faire après avoir trouvé la carte que le joker remplace)
          valeur = self.remplacement.valeur
        end
      end
      # Valorisation de la carte
      case valeur
      when :X, :V, :D, :R
        # Le 10 et les têtes valent 10 points
        total_points += 10
      when :A
        # L'As vaut 1 point par défaut
        total_points += 1
        # Ou :
        if self.type == :serie
          # 10 points (9 points de plus) dans une série
          total_points += 9
        elsif index > 0
          # 10 points (9 points de plus) dans une suite
          # (sauf si As, 2, 3 <=> l'As est en 1° position de la série)
          total_points += 9
        end
      else
        # Les autres cartes valent la valeur qu'elles représentent
        # Le 2 vaut 2, le 3 vaut 3, ... et le 9 vaut 9
        total_points += valeur.to_s.to_i
      end
    end
    # Renvoie le nombre de points
    total_points
  end

  # Renvoie les cartes absentes de la série pour qu'elle devienne un carré franc
  def cartes_absentes
    # Constitue le carré complet correspondant à la série
    valeur_as_i = self.cartes.sort.first.carte_id % 13
    carre_franc = (0..3).map { |i| Carte.new((i * 13) + valeur_as_i) }
    # Enlève les cartes déjà présentes dans la série
    self.cartes.each do |carte|
      carre_franc.reject! { |c| c == carte }
    end
    # Renvoie les cartes manquantes pour constituer un carré franc
    carre_franc
  end

  # Cherche les cartes qui peuvent compléter la combinaison
  # (doit se faire après avoir trouvé la carte que le joker remplace)
  def chercher_complements
    case self.type
    when :serie
      chercher_complements_serie
    when :suite
      chercher_complements_suite
    else
      []
    end
  end

  def chercher_complements_serie
    if self.remplacement
      # On a une série avec 1 joker remplaçable
      # => c'est forcément un Brelan + Joker
      # - Si le joueur joue cette carte, elle remplacera le joker
      # - Par conséquent, il n'existe aucune carte pour compléter la série
      []
    else
      # Paire + Joker => la série peut être complétée par 2 cartes
      # Brelan franc => la série peut être complétée par 1 carte
      # => renvoie les cartes qui manquent pour faire un carré franc
      cartes_absentes
    end
  end

  # Cherche les cartes qui peuvent compléter une suite
  def chercher_complements_suite
    suite = []
    # Trouve la première carte de la suite
    premiere_carte = self.cartes.first
    if premiere_carte.est_joker?
      premiere_carte = self.remplacement
    end
    # Détermine la carte qui peut aller avant la première carte
    unless premiere_carte.est_as?
      suite << premiere_carte.carte_avant
    end
    # Trouve la dernière carte de la suite
    derniere_carte = self.cartes.last
    if derniere_carte.est_joker?
      derniere_carte = self.remplacement
    end
    # Détermine la carte qui peut aller après la dernière carte
    unless derniere_carte.est_as?
      suite << derniere_carte.carte_apres
    end
    # Renvoie les cartes ajoutables
    suite
  end

  # Cherche la carte qui peut remplacer le Joker dans la combinaison
  def chercher_remplacement
    case self.type
    when :serie
      chercher_remplacement_serie
    when :suite
      chercher_remplacement_suite
    else
      nil
    end
  end

  # Cherche la carte qui peut remplacer le Joker dans une série
  def chercher_remplacement_serie
    if avec_joker? == false
      # Pas de Joker à remplacer
      nil
    elsif self.cartes.size < 4
      # Brelan = Paire + Joker => le joker n'est pas remplaçable
      nil
    else
      # Carré = Brelan + Joker
      # => il ne manque qu'une carte pour obtenir un carré franc
      # => on peut remplacer le joker
      # => renvoie la seule carte manquante du carré
      cartes_absentes.first
    end
  end

  # Cherche la carte qui peut remplacer le Joker dans une suite
  def chercher_remplacement_suite
    if avec_joker? == false
      # Pas de Joker à remplacer
      nil
    elsif self.cartes[0].valeur == :J
      # Le joker est en première position d'une suite
      # => Il remplace la carte qui précèderait normalement la 2° carte
      self.cartes[1].carte_avant
    else
      # Le Joker est en nième position d'une suite
      # => Il remplace la carte qui suivrait normalement la carte avant lui
      index = self.cartes.find_index { |c| c.est_joker? }
      self.cartes[index - 1].carte_apres
    end
  end

end
