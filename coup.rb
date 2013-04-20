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
    self << Coup.new(joueur_id, carte_id, "sur tas #{tas_id}")
  end

  # Annule le dernier coup joué
  def annuler
    self.pop
  end

  def to_messages
    messages = [ "Distribution des cartes "]
    tas = (0..11).map { |i| "" }
    avant = nil
    self.each_with_index do | coup, index |
      unless coup.type_id.include? "ramasser"
        if coup.type_id.include? "sur "
          # Est-ce que la carte posée est la dernière d'un ensemble de cartes
          # posées par le même joueur sur le même tas ?
          derniere = true
          if index < self.size - 1
            if coup.joueur_id == self[index + 1].joueur_id
              derniere = false if coup.type_id == self[index + 1].type_id
            end
          end
          # Message uniquement quand pose de la dernière carte de l'ensemble
          carte = Carte.new(coup.carte_id).to_s
          tas_id = (coup.type_id.sub "sur tas ", "").to_i
          tas[tas_id] << " #{carte}"
          if derniere
            text = "MR"[coup.joueur_id]
            text << ": "
            text << "poser #{tas[tas_id].sub(carte, "[" + carte + "]")}"
            messages << text
          end
        else
          messages << coup.to_s
        end
      end
      avant = coup
    end
    messages
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
