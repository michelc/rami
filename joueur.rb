# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "analyse"
require "carte"
require "combinaison"

# Classe Joueur
# Représente un joueur à jouer dans un jeu de carte
# (lié du jeu de Rami)

class Joueur
  TAILLE_MAIN = 14

  attr_accessor :joueur_id      # Identifiant du joueur
  attr_accessor :nom            # Nom du joueur
  attr_accessor :cartes         # Tableau des cartes dans la main du joueur
  attr_accessor :combinaisons   # Tableau des combinaisons possibles pour le joueur
  attr_accessor :compte_tour    # Numéro du dernier tour joué par le joueur
  attr_accessor :a_pose_combien # Nombre de points posés par le joueur
  attr_accessor :a_atteint_51   # Vrai si le joueur a posé 51 points lors des tours précédants

  attr_accessor :niveau         # Niveau de jeu du joueur

  def initialize nom_joueur, joueur_id = 0
    self.nom = nom_joueur
    self.joueur_id = joueur_id
    self.cartes = []
    self.combinaisons = []
    self.compte_tour = 0
    self.a_pose_combien = 0
    self.a_atteint_51 = false
  end

  def connait_les_regles?
    if self.niveau == nil
      true
    elsif self.niveau.version > 3
      true
    else
      false
    end
  end

  def ramasser_cartes cartes
    # Joueur ramasse les cartes qui lui ont été distribuées
    # (et il les trie pour que l'affichage soit plus simple)
    self.cartes = cartes.sort
    # Puis il analyse son jeu
    analyse = Analyse.new self.cartes
    self.combinaisons = analyse.combinaisons

    self.compte_tour = 0
    self.a_pose_combien = 0
    self.a_atteint_51 = false
  end

  def ajouter_une_carte carte
    # Joueur ajoute une carte dans sa main
    self.cartes << carte
    # Il re-trie son jeu
    self.cartes.sort!
    # Puis il ré-analyse son jeu (à condition d'avoir plus de 3 cartes)
    self.combinaisons = []
    if self.cartes.size > 3
      analyse = Analyse.new self.cartes
      self.combinaisons = analyse.combinaisons
    end
  end

  def enlever_une_carte carte
    # Joueur enlève une carte de sa main
    index = self.cartes.find_index { |c| c == carte }
    self.cartes.delete_at(index) if index
    # Et il ré-analyse son jeu (à condition d'avoir plus de 3 cartes)
    self.combinaisons = []
    if self.cartes.size > 3
      analyse = Analyse.new self.cartes
      self.combinaisons = analyse.combinaisons
    end
  end

  def incrementer_tour
    # Met à jour le compte-tour du joueur
    self.compte_tour += 1
    # Mémorise s'il a déjà marqué ses 51 points
    self.a_atteint_51 = self.a_pose_combien >= 51
  end

  # Détermine si le joueur a déjà posé sa tierce franche
  def a_pose_tierce?
    # Le joueur a posé sa tierce dès qu'il a des points
    # (car la tierce franche doit être posée en premier)
    self.a_pose_combien > 0
  end

  # Détermine si le joueur a déjà posé ses 51 points
  def a_pose_51?
    self.a_pose_combien >= 51
  end

  # Détermine si le joueur a marqué 51 points avant le tour en cours
  def a_atteint_51?
    self.a_atteint_51
  end

  # Détermine si le joueur peut prendre la carte de la défausse
  def peut_prendre?
    if self.compte_tour == 0
      # Le joueur peut prendre si c'est son 1° tour
      true
    elsif self.cartes.size == 1
      # Le joueur ne peut pas prendre quand il n'a plus qu'une carte
      false
    elsif self.a_pose_51?
      # Le joueur peut prendre une fois qu'il a posé ses 51 points
      true
    elsif self.tierce_franche?
      # Le joueur peut prendre s'il a déjà sa tierce franche en main
      true
    else
      false
    end
  end

  # Détermine si le joueur a sa premiere tierce franche dans sa main
  def tierce_franche?
    if a_pose_tierce?
      # Tierce franche déjà posée => on ne la cherche plus
      false
    else
      self.combinaisons.any? { |c| c.tierce_franche? }
    end
  end

  # Détermine si le joueur peut poser ses cartes
  def peut_poser?
    if self.compte_tour == 0
      # On ne peut pas poser dès le 1° tour
      false
    elsif a_pose_tierce? == true
      # Le joueur a posé sa tierce franche
      # (et par conséquent ses 51 points)
      # => Il peut poser
      true
    elsif tierce_franche? == false
      # Le joueur n'a pas encore posé sa tierce franche
      # Et il n'a pas de tierce franche
      # => Il ne peut pas poser
      false
    else
      # Le joueur n'a pas encore posé sa tierce franche
      # Et il a une tierce franche
      # Il faudrait s'assurer qu'il a bien 51 points à poser
      # MAIS EN ATTENDANT, IL PEUT POSER
      true
    end
  end

  # Détermine quelle est la phase du jeu pour le joueur
  def phase_du_jeu
    if self.a_pose_51?
      # Joueur a déjà posé ses cartes
      # => cherche à finir la partie (tout poser ou diminuer nb points en main)
      :finir_partie
    elsif self.a_pose_tierce?
      # Joueur a posé sa tierce franche (mais pas encore 51 points)
      # => doit poser d'autres combinaisons pour faire 51 points
      :faire_points
    else
      # Joueur n'a pas encore de tierce franche
      # => doit faire une tierce franche pour démarrer la partie
      :faire_tierce
    end
  end

  # Détermine quelle est la meilleure carte à défausser
  def meilleure_defausse les_tas, la_defausse
    self.niveau.meilleure_defausse les_tas, la_defausse
  end

  # Détermine quelle est la meilleure combinaison à poser
  def meilleure_combinaison carte_defausse = nil
    self.niveau.meilleure_combinaison carte_defausse
  end

  # Détermine s'il vaut mieux prendre la défausse que piocher
  def mieux_vaut_prendre? carte_defausse, les_tas, la_defausse
    self.niveau.mieux_vaut_prendre? carte_defausse, les_tas, la_defausse
  end

  def get_scores piocher, les_tas, la_defausse
    if piocher && self.peut_prendre?
      self.niveau.score_cartes(la_defausse.last, les_tas, la_defausse)
    else
      self.niveau.score_cartes(nil, les_tas, la_defausse)
    end
  end

end
