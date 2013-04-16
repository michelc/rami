# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "carte"

# Classe Paquet
# Représente un paquet de cartes à jouer
# (pas trop lié au jeu de Rami)

class Paquet
  NB_CARTES = 54

  attr_accessor :pioche   # Tableau des cartes à tirer par les joueurs (face cachée)
                          # = talon
  attr_accessor :defausse # tableau des cartes rejetées par les joueurs (face visible)
                          # = rebut ou écart

  def initialize nombre_de_jeux = 1
    # Rempli la pioche avec autant de jeux de cartes que demandés
    self.pioche = []
    nombre_de_jeux.times do
      self.pioche += (0..NB_CARTES-1).to_a.map { |id| Carte.new(id) }
    end
    # Mélange les cartes de la pioche
    self.pioche.shuffle!
    # Pile de défausse est vide puisque toutes les cartes sont à la pioche
    self.defausse = []
  end

  def distribuer_une_main nb_cartes
    # Distribue l'ensemble des cartes d'une main pour un joueur
    self.pioche.pop nb_cartes
  end

  def piocher_une_carte
    # Enlève et renvoie la carte située sur la pile de pioche
    self.pioche.pop
  end

  def defausser_une_carte carte
    # Ajoute une carte sur la pile de défausse
    self.defausse << carte
  end

  def prendre_la_defausse
    # Enlève et renvoie la carte située sur la pile de défausse
    self.defausse.pop
  end

  def carte_defausse
    # Indique quelle est la carte située sur la pile de défausse
    self.defausse.last
  end

end
