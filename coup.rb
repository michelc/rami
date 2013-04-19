# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))


# Classe Coups
# Représente la liste des coups joués

class Coups < Array

  def initialize
    super
  end

  # 1° coup possible
  # Un joueur prend une carte dans la pioche
  def piocher joueur_id, carte_id
    self << Coup.new(joueur_id, carte_id, "P")
  end

  # 2° coup possible
  # Un joueur prend une carte dans la défausse
  def repecher joueur_id, carte_id
    self << Coup.new(joueur_id, carte_id, "R")
  end

  # 3° coup possible
  # Un joueur pose une carte dans la défausse
  def defausser joueur_id, carte_id
    self << Coup.new(joueur_id, carte_id, "D")
  end

  # 4° coup possible
  # Un joueur pose une carte sur un tas
  def poser joueur_id, carte_id, tas_id
    self << Coup.new(joueur_id, carte_id, tas_id)
  end

  # Annule le dernier coup joué
  def annuler
    self.pop
  end

end


# Classe Coup
# Représente une coup joué

class Coup

  attr_accessor :joueur_id      # Identifiant du joueur qui joue
  attr_accessor :carte_id       # Identifiant de la carte jouée
  attr_accessor :type_id        # Identifie le type du coup joué

  def initialize joueur_id, carte_id, type_id
    self.joueur_id = joueur_id
    self.carte_id = carte_id
    self.type_id = type_id
  end

end
