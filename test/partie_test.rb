# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "minitest/autorun"
require "../partie"


describe "Partie", "Vérification constantes" do

  it "1 partie se joue avec 2 jeux de cartes" do
    Partie::NB_JEUX.must_equal 2
  end

end


describe "Partie", "Vérification initialisation" do

  it "Crée un paquet de cartes" do
    partie = Partie.new "A", "B"
    partie.paquet.must_be_instance_of Paquet
  end

  it "Rempli la pioche avec 108 cartes" do
    partie = Partie.new "A", "B"
    partie.paquet.pioche.size.must_equal Paquet::NB_CARTES * Partie::NB_JEUX
  end

  it "Crée les 2 joueurs" do
    partie = Partie.new "A", "B"
    partie.joueurs.must_be_instance_of Array
    partie.joueurs.size.must_equal 2
    partie.joueurs[0].must_be_instance_of Joueur
    partie.joueurs[1].must_be_instance_of Joueur
  end

  it "Met à zéro le tour en cours" do
    partie = Partie.new "A", "B"
    partie.compte_tour.must_equal 0
  end

end


describe "Partie", "Vérification distribution" do

  it "Distribue 14 cartes à chaque joueur" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.joueurs[0].cartes.size.must_equal Joueur::TAILLE_MAIN
    partie.joueurs[1].cartes.size.must_equal Joueur::TAILLE_MAIN
  end

  it "Place une carte dans la défausse" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.paquet.defausse.size.must_equal 1
  end

  it "Laisse 79 cartes dans la pioche" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    nb_cartes = Paquet::NB_CARTES * Partie::NB_JEUX   # 2 paquets de cartes
    nb_cartes -= Joueur::TAILLE_MAIN * 2              # - 14 cartes par joueur
    nb_cartes -= 1                                    # - la carte de la défausse
    partie.paquet.pioche.size.must_equal nb_cartes
  end

  it "Démarre le premier tour du jeu" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.compte_tour.must_equal 1
    partie.carte_tiree.must_be_nil
  end

  it "Défini la carte sur la défausse" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.carte_defausse.wont_be_nil
    partie.carte_defausse.must_equal partie.paquet.carte_defausse
  end

end


describe "Partie", "Vérification prendre pioche" do

  it "Ajoute une carte à la main du joueur" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.prendre_dans_pioche 0
    partie.joueurs[0].cartes.size.must_equal Joueur::TAILLE_MAIN + 1
  end

  it "Enlève une carte de la pioche" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.prendre_dans_pioche 0
    nb_cartes = Paquet::NB_CARTES * Partie::NB_JEUX   # 2 paquets de cartes
    nb_cartes -= Joueur::TAILLE_MAIN * 2              # - 14 cartes par joueur
    nb_cartes -= 1                                    # - la carte de la défausse
    nb_cartes -= 1                                    # - la carte piochée
    partie.paquet.pioche.size.must_equal nb_cartes
  end

  it "Défini la carte en cours" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.carte_tiree.must_be_nil
    partie.prendre_dans_pioche 0
    partie.carte_tiree.wont_be_nil
  end

end


describe "Partie", "Vérification prendre défausse" do

  it "Ajoute une carte à la main du joueur" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.prendre_dans_defausse 0
    partie.joueurs[0].cartes.size.must_equal Joueur::TAILLE_MAIN + 1
  end

  it "Enlève une carte de la défausse" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.prendre_dans_defausse 0
    partie.paquet.defausse.size.must_equal 0
  end

  it "Ajoute la carte de la défausse dans la main du joueur" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    carte_defausse = partie.carte_defausse
    partie.prendre_dans_defausse 0
    partie.joueurs[0].cartes.include?(carte_defausse).must_equal true
  end

  it "Défini la carte en cours" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.carte_tiree.must_be_nil
    partie.prendre_dans_defausse 0
    partie.carte_tiree.wont_be_nil
  end

  it "La carte en cours est la carte de la défausse" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    carte_defausse = partie.carte_defausse
    partie.prendre_dans_defausse 0
    partie.carte_tiree.must_equal carte_defausse
  end

end


describe "Partie", "Vérification défausser" do

  it "Enlève une carte de la main du joueur" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.poser_dans_defausse 0, partie.joueurs[0].cartes.sample
    partie.joueurs[0].cartes.size.must_equal Joueur::TAILLE_MAIN - 1
  end

  it "Ajoute une carte dans la défausse" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.poser_dans_defausse 0, partie.joueurs[0].cartes.sample
    partie.paquet.defausse.size.must_equal 2
  end

  it "Enlève la carte défaussée de la main du joueur" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    carte_defausse = partie.joueurs[0].cartes.uniq { |c| c.carte_id }.sample
    partie.poser_dans_defausse 0, carte_defausse
    partie.joueurs[0].cartes.include?(carte_defausse).must_equal false
  end

  it "Ajoute la carte défaussée dans la défausse" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    carte_defausse = partie.joueurs[0].cartes.sample
    partie.poser_dans_defausse 0, carte_defausse
    partie.paquet.carte_defausse.must_equal carte_defausse
  end

  it "Mémorise la carte défaussée" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    carte_defausse = partie.joueurs[0].cartes.sample
    partie.poser_dans_defausse 0, carte_defausse
    partie.carte_defausse.must_equal carte_defausse
  end

  it "Il n'y a plus de carte en cours" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.prendre_dans_pioche 0
    partie.poser_dans_defausse 1, partie.joueurs[1].cartes.sample
    partie.carte_tiree.must_be_nil
  end

  it "Incrémente compte tour du joueur qui défausse" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.poser_dans_defausse 0, partie.joueurs[0].cartes.sample
    partie.joueurs[0].compte_tour.must_equal 1
    partie.joueurs[1].compte_tour.must_equal 0
  end

  it "Incrémente tour de jeu quand les 2 joueurs ont défaussé" do
    partie = Partie.new "A", "B"
    partie.distribuer_les_cartes
    partie.poser_dans_defausse 0, partie.joueurs[0].cartes.sample
    partie.compte_tour.must_equal 1
    partie.poser_dans_defausse 1, partie.joueurs[1].cartes.sample
    partie.compte_tour.must_equal 2
  end

end
