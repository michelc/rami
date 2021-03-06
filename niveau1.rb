# encoding: UTF-8

class Niveau1

  attr_accessor :joueur       # Le joueur
  attr_accessor :trace
  attr_accessor :version

  def initialize joueur
    self.joueur = joueur
    self.version = 1
  end

  # Détermine quelle est la meilleure carte à défausser
  # - une au hasard
  # - évite le joker
  def meilleure_defausse les_tas, la_defausse
    self.joueur.cartes.sample
  end

  # Détermine quelle est la meilleure combinaison à poser
  # - une tierce franche au hasard
  # - sinon une combinaison au hasard
  def meilleure_combinaison carte_defausse = nil
    if joueur.tierce_franche?
      tierces = self.joueur.combinaisons.select { |c| c.tierce_franche? }
      sans_joker = tierces.reject { |c| c.avec_joker? }
      return sans_joker.sample if sans_joker.size > 0
      return tierces.sample
    end
    self.joueur.combinaisons.sample
  end

  # Détermine s'il vaut mieux prendre la défausse que piocher
  # - prend la défausse 1 fois sur 3
  def mieux_vaut_prendre? carte, les_tas, la_defausse
    false
  end

end
