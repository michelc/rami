# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))


# Classe Coups
# Représente la liste des coups joués

class Coups < Array

  def initialize
    super
  end

  # Joueur ramasse les cartes distribuées
  def ramasser joueur_id, cartes
    cartes.each { |c| self << Coup.new(joueur_id, c.carte_id, "ramasser") }
  end

  # 1° coup possible
  # Joueur prend une carte dans la pioche
  def piocher joueur_id, carte_id
    self << Coup.new(joueur_id, carte_id, "piocher")
  end

  # 2° coup possible
  # Joueur prend une carte dans la défausse
  def repecher joueur_id, carte_id
    self << Coup.new(joueur_id, carte_id, "repecher")
  end

  # 3° coup possible
  # Joueur pose une carte dans la défausse
  def defausser joueur_id, carte_id
    self << Coup.new(joueur_id, carte_id, "défausser")
  end

  # 4° coup possible
  # Joueur pose une carte sur un tas
  def poser joueur_id, carte_id, tas_id
    self << Coup.new(joueur_id, carte_id, "sur #{tas_id}")
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

  def to_s
    carte = Carte.new(self.carte_id).to_s
    text = "MR"[self.joueur_id]
    text << ": "
    if self.type_id.include? "sur "
      text << "poser #{carte} #{self.type_id}"
    else
      text << "#{self.type_id} #{carte}"
    end
    text
  end

end
