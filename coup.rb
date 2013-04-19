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
    suivant = 0
    self.each_with_index do | coup, index |
      unless coup.type_id.include? "ramasser"
        if index < suivant
          # La pose de cette carte a déjà été traitée
        elsif coup.type_id.include? "sur "
          # Traite la pose de plusieurs carte par le même joueur sur le même tas
          cartes = ""
          j = index
          while j < self.size
            break if coup.joueur_id != self[j].joueur_id
            break if coup.type_id != self[j].type_id
            carte = Carte.new(self[j].carte_id).to_s
            cartes << " #{carte}"
            j += 1
          end
          # Pour éviter de re-traiter les cartes déjà traitées
          suivant = j
          # Message pour pose des différentes cartes
          text = "MR"[coup.joueur_id]
          text << ": "
          text << "poser #{cartes}"
          messages << text
        else
          messages << coup.to_s
          suivant = 0
        end
      end
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
