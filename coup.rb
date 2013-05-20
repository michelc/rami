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
    cartes.each { |c| self << Coup.new(joueur_id, c.carte_id, "ramasse", "") }
  end

  # 1° coup possible
  # Joueur prend une carte dans la pioche
  def piocher joueur_id, carte_id
    self << Coup.new(joueur_id, carte_id, "pioche", "")
  end

  # 2° coup possible
  # Joueur prend une carte dans la défausse
  def prendre joueur_id, carte_id
    self << Coup.new(joueur_id, carte_id, "prend", "")
  end

  # 3° coup possible
  # Joueur pose une carte dans la défausse
  def defausser joueur_id, carte_id
    self << Coup.new(joueur_id, carte_id, "défausse", "")
  end

  # 4° coup possible
  # Joueur pose une carte sur un tas
  def poser joueur_id, carte_id, tas_id
    self << Coup.new(joueur_id, carte_id, "sur tas #{tas_id}", "")
  end

  # Annule le dernier coup joué
  def annuler
    self.pop
  end

  # Message d'information
  def alerter joueur_id, message
    self << Coup.new(joueur_id, 0, "", message)
  end

  # Information sur le score
  def marquer joueur_id, nb_points, total_points
    message = if nb_points == total_points
                "#{nb_points} points (tierce franche)"
              elsif total_points < 51
                "#{total_points} points"
              elsif total_points - nb_points < 51
                "#{total_points} points (51 atteint)"
              else
                nil
          end
    self << Coup.new(joueur_id, 0, "", message) if message
  end

  def to_messages
    messages = []
    tas = (0..11).map { |i| "" }
    avant = nil
    self.each_with_index do | coup, index |
      unless coup.type_id.include? "ramasse"
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
          carte = Carte.new(coup.carte_id).to_html
          tas_id = (coup.type_id.sub "sur tas ", "").to_i
          tas[tas_id] << " #{carte}"
          if derniere
            text = "MR"[coup.joueur_id]
            text << ": "
            text << "pose #{tas[tas_id].sub(carte, "[" + carte + "]")}"
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
  attr_accessor :message        # Message d'information

  def initialize joueur_id, carte_id, type_id, message
    self.joueur_id = joueur_id
    self.carte_id = carte_id
    self.type_id = type_id
    self.message = message
  end

  def to_s
    text = "MRD"[self.joueur_id]
    text << ": "
    if self.message == ""
      carte = Carte.new(self.carte_id).to_html
      if self.type_id.include? "sur "
        text << "pose #{carte} #{self.type_id}"
      else
        text << "#{self.type_id} #{carte}"
      end
    else
      text << self.message
    end
    text
  end

end
