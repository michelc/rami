# encoding: UTF-8

VALEURS = %w(A 2 3 4 5 6 7 8 9 X V D R J).map { |o| o.to_sym }
COULEURS = %w(coeur pique carreau trefle).map { |c| c.to_sym }

# Classe Carte
# Représente une carte à jouer dans un jeu de carte
# (pas lié au jeu de Rami)

class Carte

  attr_accessor :carte_id   # Identifiant qui permet de définir la carte
                            # -  0 à 12 => c'est un coeur (0=As, 1=2, 2=3, ..., 9=10, 10=Valet, 11=Dame et 12=Roi)
                            # - 13 à 25 => c'est un pique (13=As ...)
                            # - 26 à 38 => c'est un carreau (26=As ...)
                            # - 39 à 51 => c'est un trèfle (39=As ...)
                            # - 52 à 53 => c'est un joker (52=1° joker, 53=2° joker)
  attr_accessor :couleur    # Couleur de la carte (:coeur, :pique, :carreau, :trefle)
  attr_accessor :valeur     # Valeur de la carte (As, 2, 3, ..., 10, Valet, Dame, Roi, Joker)
  attr_accessor :tooltip    # Information de débugage pour afficher le score de la carte

  def initialize(carte_id)

    if carte_id.is_a? String
      self.valeur = "A23456789XVDRJ".index carte_id[0]
      self.couleur = "CPKT*".index carte_id[1]
      if self.couleur == 4
        carte_id = 52
      else
        carte_id = (self.couleur * 13) + self.valeur
      end
    end

    self.carte_id = carte_id
    case carte_id
    when (0..51)
      self.valeur = VALEURS[carte_id % 13]
      self.couleur = COULEURS[carte_id / 13]
    else
      self.valeur = VALEURS[13]
      self.couleur = nil
    end
    self.tooltip = ""
  end

  # Opérateur <=> pour trier les cartes à l'affichage
  def <=> (other)
    self.carte_id <=> other.carte_id
  end

  # Opérateur == pour comparer les cartes selon carte_id
  def == (other)
    if other.instance_of? Carte
      self.carte_id == other.carte_id
    else
      false
    end
  end

  # Helper pour savoir si la carte est un joker
  def est_joker?
    self.couleur.nil?
  end

  # Représentation textuelle de la carte
  def to_text
    if est_joker?
      "Joker"
    else
      noms = %w(As 2 3 4 5 6 7 8 9 10 Valet Dame Roi)
      text = noms[self.carte_id % 13]
      text + " de #{self.couleur.to_s.capitalize}"
    end
  end

  # Représentation figurative de la carte
  def to_s
    if est_joker?
      "J*"
    else
      self.valeur.to_s + "CPKT".slice(self.carte_id / 13)
    end
  end

  # Représentation figurative de la carte
  # (pose problème incompatibilité encodage quand erreur avec Sinatra)
  def to_s2
    if est_joker?
      "J*"
    else
      self.valeur.to_s + "♥♠♦♣".slice(self.carte_id / 13)
    end
  end

  # Renvoie la carte précédante dans la couleur
  def carte_avant
    id_avant = self.carte_id - 1
    self.valeur == :A ? nil : Carte.new(id_avant)
  end

  # Renvoie la carte suivante dans la couleur
  def carte_apres
    id_apres = self.carte_id + 1
    id_apres -= 13 if self.valeur == :R   # As suit le Roi
    Carte.new(id_apres)
  end

end
