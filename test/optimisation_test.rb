# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "minitest/spec"
require "minitest/autorun"
require "../optimisation"

describe "Optimisation", "Vérification enlever_cartes_utilisees" do

  it "Enlève le bon nombre de cartes" do
    main = []
    main << Carte.new(0)
    main << Carte.new(1)
    main << Carte.new(2)
    main << Carte.new(33)
    optimisation = Optimisation.new
    analyse = Analyse.new main
    nouvelle = optimisation.enlever_cartes_utilisees(main, analyse.combinaisons[0])
    nouvelle.size.must_equal 1
  end

  it "Enlève uniquement les cartes utilisées" do
    main = []
    main << Carte.new(0)
    main << Carte.new(1)
    main << Carte.new(2)
    main << Carte.new(33)
    optimisation = Optimisation.new
    analyse = Analyse.new main
    nouvelle = optimisation.enlever_cartes_utilisees(main, analyse.combinaisons[0])
    analyse = Analyse.new nouvelle
    analyse.to_s.must_equal "[ 8K ]"
  end

  it "Enlève toutes les cartes utilisées" do
    main = []
    main << Carte.new(0)
    main << Carte.new(1)
    main << Carte.new(3)
    main << Carte.new(4)
    main << Carte.new(52)
    optimisation = Optimisation.new
    analyse = Analyse.new main
    nouvelle = optimisation.enlever_cartes_utilisees(main, analyse.combinaisons[0])
    analyse = Analyse.new nouvelle
    analyse.cartes.must_be_empty
  end

end


describe "Optimisation", "Vérification loop 1 tierce franche" do

  it "Ignore les séries" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("AP")
    main << Carte.new("AK")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main, true
    chemins.size.must_equal 0
  end

  it "Ignore les tierces avec Joker" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("2C")
    main << Carte.new("J*")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main, true
    chemins.size.must_equal 0
  end

  it "Accepte les tierces franches" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("2C")
    main << Carte.new("3C")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main, true
    chemins.size.must_equal 1
  end

end


describe "Optimisation", "Vérification loop 1 combinaison" do

  it "Compte est bon si 1 seule suite" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("2C")
    main << Carte.new("3C")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 1
    # La seule suite existante
    chemins[0].visuel.must_equal "[ AC 2C 3C ]"
    chemins[0].franche.must_equal true
    chemins[0].nb_points.must_equal 6
    chemins[0].nb_cartes.must_equal 3
  end

  it "Compte est bon si 1 seule série" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("AK")
    main << Carte.new("AP")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 1
    # La seule série existante
    chemins[0].visuel.must_equal "[ AC AP AK ]"
    chemins[0].franche.must_equal false
    chemins[0].nb_points.must_equal 30
    chemins[0].nb_cartes.must_equal 3
  end

  it "Compte est bon si 1 seule suite avec Joker" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("J*")
    main << Carte.new("3C")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 1
    # La seule suite existante
    chemins[0].visuel.must_equal "[ AC J* 3C ]"
    chemins[0].franche.must_equal false
    chemins[0].nb_points.must_equal 6
    chemins[0].nb_cartes.must_equal 3
  end

  it "Compte est bon si 1 seule série avec Joker" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("J*")
    main << Carte.new("AP")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 1
    # La seule suite existante
    chemins[0].visuel.must_equal "[ AC AP J* ]"
    chemins[0].franche.must_equal false
    chemins[0].nb_points.must_equal 30
    chemins[0].nb_cartes.must_equal 3
  end

end


describe "Optimisation", "Vérification loop avec 2 combinaisons" do

  it "Compte est bon si 2 suites indépendantes" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("2C")
    main << Carte.new("3C")
    main << Carte.new("AP")
    main << Carte.new("2P")
    main << Carte.new("3P")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 2
    # La 1° suite puis la 2°
    chemins[0].visuel.must_equal "[ AC 2C 3C ] [ AP 2P 3P ]"
    chemins[0].franche.must_equal true
    chemins[0].nb_points.must_equal 12
    chemins[0].nb_cartes.must_equal 6
    # La 2° suite puis la 1°
    chemins[1].visuel.must_equal "[ AP 2P 3P ] [ AC 2C 3C ]"
    chemins[1].franche.must_equal true
    chemins[1].nb_points.must_equal 12
    chemins[1].nb_cartes.must_equal 6
  end

  it "Compte est bon si 1 suite et 1 série indépendantes" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("2C")
    main << Carte.new("3C")
    main << Carte.new("7C")
    main << Carte.new("7P")
    main << Carte.new("7K")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 2
    # La suite puis la série
    chemins[0].visuel.must_equal "[ AC 2C 3C ] [ 7C 7P 7K ]"
    chemins[0].franche.must_equal true
    chemins[0].nb_points.must_equal 27
    chemins[0].nb_cartes.must_equal 6
    # La série puis la suite
    chemins[1].visuel.must_equal "[ 7C 7P 7K ] [ AC 2C 3C ]"
    chemins[1].franche.must_equal false
    chemins[1].nb_points.must_equal 27
    chemins[1].nb_cartes.must_equal 6
  end

  it "Compte est bon si 2 combinaisons dépendantes" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("2C")
    main << Carte.new("3C")
    main << Carte.new("AP")
    main << Carte.new("AK")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 2
    # La suite
    chemins[0].visuel.must_equal "[ AC 2C 3C ]"
    chemins[0].franche.must_equal true
    chemins[0].nb_points.must_equal 6
    chemins[0].nb_cartes.must_equal 3
    # La série
    chemins[1].visuel.must_equal "[ AC AP AK ]"
    chemins[1].franche.must_equal false
    chemins[1].nb_points.must_equal 30
    chemins[1].nb_cartes.must_equal 3
  end

  it "Compte est bon si 4 suites imbriquées - cas 1" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("J*")
    main << Carte.new("3C")
    main << Carte.new("4C")
    main << Carte.new("5C")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 6
    # La 1° suite
    chemins[0].visuel.must_equal "[ AC J* 3C 4C 5C ]"
    chemins[0].franche.must_equal false
    chemins[0].nb_points.must_equal 15
    chemins[0].nb_cartes.must_equal 5
    # La 2° suite
    chemins[1].visuel.must_equal "[ AC J* 3C 4C ]"
    chemins[1].franche.must_equal false
    chemins[1].nb_points.must_equal 10
    chemins[1].nb_cartes.must_equal 4
    # La 3° suite
    chemins[2].visuel.must_equal "[ 3C 4C 5C J* ]"
    chemins[2].franche.must_equal false
    chemins[2].nb_points.must_equal 18
    chemins[2].nb_cartes.must_equal 4
    # La 4° suite
    chemins[3].visuel.must_equal "[ AC J* 3C ]"
    chemins[3].franche.must_equal false
    chemins[3].nb_points.must_equal 6
    chemins[3].nb_cartes.must_equal 3
    # La 5° suite
    chemins[4].visuel.must_equal "[ 3C 4C 5C ]"
    chemins[4].franche.must_equal true
    chemins[4].nb_points.must_equal 12
    chemins[4].nb_cartes.must_equal 3
    # La 6° suite
    chemins[5].visuel.must_equal "[ 4C 5C J* ]"
    chemins[5].franche.must_equal false
    chemins[5].nb_points.must_equal 15
    chemins[5].nb_cartes.must_equal 3
  end

  it "Compte est bon si 2 suites imbriquées - cas 2" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("2C")
    main << Carte.new("3C")
    main << Carte.new("J*")
    main << Carte.new("5C")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 6
    # La 1° suite
    chemins[0].visuel.must_equal "[ AC 2C 3C J* 5C ]"
    chemins[0].franche.must_equal false
    chemins[0].nb_points.must_equal 15
    chemins[0].nb_cartes.must_equal 5
    # La 2° suite
    chemins[1].visuel.must_equal "[ AC 2C 3C J* ]"
    chemins[1].franche.must_equal false
    chemins[1].nb_points.must_equal 10
    chemins[1].nb_cartes.must_equal 4
    # La 3° suite
    chemins[2].visuel.must_equal "[ 2C 3C J* 5C ]"
    chemins[2].franche.must_equal false
    chemins[2].nb_points.must_equal 14
    chemins[2].nb_cartes.must_equal 4
    # La 4° suite
    chemins[3].visuel.must_equal "[ AC 2C 3C ]"
    chemins[3].franche.must_equal true
    chemins[3].nb_points.must_equal 6
    chemins[3].nb_cartes.must_equal 3
    # La 5° suite
    chemins[4].visuel.must_equal "[ 2C 3C J* ]"
    chemins[4].franche.must_equal false
    chemins[4].nb_points.must_equal 9
    chemins[4].nb_cartes.must_equal 3
    # La 6° suite
    chemins[5].visuel.must_equal "[ 3C J* 5C ]"
    chemins[5].franche.must_equal false
    chemins[5].nb_points.must_equal 12
    chemins[5].nb_cartes.must_equal 3
  end

end


describe "Optimisation", "Vérification loop avec 3 combinaisons" do

  it "Compte est bon si 2 indépendantes et une 3° dépendante" do
    main = []
    main << Carte.new("AC")
    main << Carte.new("2C")
    main << Carte.new("3C")
    main << Carte.new("AP")
    main << Carte.new("2P")
    main << Carte.new("3P")
    main << Carte.new("AK")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 3
    # La 1° suite puis la 2°
    chemins[0].visuel.must_equal "[ AC 2C 3C ] [ AP 2P 3P ]"
    chemins[0].franche.must_equal true
    chemins[0].nb_points.must_equal 12
    chemins[0].nb_cartes.must_equal 6
    # La 2° suite puis la 1°
    chemins[1].visuel.must_equal "[ AP 2P 3P ] [ AC 2C 3C ]"
    chemins[1].franche.must_equal true
    chemins[1].nb_points.must_equal 12
    chemins[1].nb_cartes.must_equal 6
    # La série toute seule
    chemins[2].visuel.must_equal "[ AC AP AK ]"
    chemins[2].franche.must_equal false
    chemins[2].nb_points.must_equal 30
    chemins[2].nb_cartes.must_equal 3
  end

  it "Compte est bon si 3 combinaisons dépendantes" do
    main = []
    main << Carte.new("5K")
    main << Carte.new("6C")
    main << Carte.new("6P")
    main << Carte.new("6K")
    main << Carte.new("7P")
    main << Carte.new("7K")
    main << Carte.new("7T")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 3
    # La suite toute seule
    chemins[0].visuel.must_equal "[ 5K 6K 7K ]"
    chemins[0].franche.must_equal true
    chemins[0].nb_points.must_equal 18
    chemins[0].nb_cartes.must_equal 3
    # La 1° série puis la 2°
    chemins[1].visuel.must_equal "[ 6C 6P 6K ] [ 7P 7K 7T ]"
    chemins[1].franche.must_equal false
    chemins[1].nb_points.must_equal 39
    chemins[1].nb_cartes.must_equal 6
    # La 2° série puis la 1°
    chemins[2].visuel.must_equal "[ 7P 7K 7T ] [ 6C 6P 6K ]"
    chemins[2].franche.must_equal false
    chemins[2].nb_points.must_equal 39
    chemins[2].nb_cartes.must_equal 6
  end

  it "Compte est bon si 3 combinaisons indépendantes" do
    main = []
    main << Carte.new("5K")
    main << Carte.new("6K")
    main << Carte.new("7K")
    main << Carte.new("6C")
    main << Carte.new("6P")
    main << Carte.new("6K")
    main << Carte.new("7P")
    main << Carte.new("7K")
    main << Carte.new("7T")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 6
    # La suite, la 1° série puis la 2°
    chemins[0].visuel.must_equal "[ 5K 6K 7K ] [ 6C 6P 6K ] [ 7P 7K 7T ]"
    chemins[0].franche.must_equal true
    chemins[0].nb_points.must_equal 57
    chemins[0].nb_cartes.must_equal 9
    # La suite, la 2° série puis la 1°
    chemins[1].visuel.must_equal "[ 5K 6K 7K ] [ 7P 7K 7T ] [ 6C 6P 6K ]"
    chemins[1].franche.must_equal true
    chemins[1].nb_points.must_equal 57
    chemins[1].nb_cartes.must_equal 9
    # La 1° série, la suite puis la 2° série
    chemins[2].visuel.must_equal "[ 6C 6P 6K ] [ 5K 6K 7K ] [ 7P 7K 7T ]"
    chemins[2].franche.must_equal false
    chemins[2].nb_points.must_equal 57
    chemins[2].nb_cartes.must_equal 9
    # La 1° série, la 2° puis la suite
    chemins[3].visuel.must_equal "[ 6C 6P 6K ] [ 7P 7K 7T ] [ 5K 6K 7K ]"
    chemins[3].franche.must_equal false
    chemins[3].nb_cartes.must_equal 9
    chemins[3].nb_points.must_equal 57
    # La 2° série, la suite puis la 1° série
    chemins[4].visuel.must_equal "[ 7P 7K 7T ] [ 5K 6K 7K ] [ 6C 6P 6K ]"
    chemins[4].franche.must_equal false
    chemins[4].nb_points.must_equal 57
    chemins[4].nb_cartes.must_equal 9
    # La 2° série, la 1° puis la suite
    chemins[5].visuel.must_equal "[ 7P 7K 7T ] [ 6C 6P 6K ] [ 5K 6K 7K ]"
    chemins[5].franche.must_equal false
    chemins[5].nb_points.must_equal 57
    chemins[5].nb_cartes.must_equal 9
  end

  it "Compte est bon si 4 combinaisons indépendantes avec 1 Joker dans la suite" do
    main = []
    main << Carte.new("5K")
    main << Carte.new("J*")
    main << Carte.new("7K")
    main << Carte.new("6C")
    main << Carte.new("6P")
    main << Carte.new("6K")
    main << Carte.new("7P")
    main << Carte.new("7K")
    main << Carte.new("7T")
    main << Carte.new("VT")
    optimisation = Optimisation.new
    chemins = optimisation.loop main
    chemins.size.must_equal 12
    # La 1° série puis la 2°
    chemins[0].visuel.must_equal "[ 6P 7P J* ] [ 5K 6K 7K ]"
    chemins[0].franche.must_equal false
    chemins[0].nb_points.must_equal 39
    chemins[0].nb_cartes.must_equal 6

    chemins[1].visuel.must_equal "[ 5K 6K 7K J* ] [ 7P 7K 7T ]"
    chemins[1].franche.must_equal false
    chemins[1].nb_points.must_equal 47
    chemins[1].nb_cartes.must_equal 7

    chemins[2].visuel.must_equal "[ 5K 6K 7K ] [ 6P 7P J* ]"
    chemins[2].franche.must_equal true
    chemins[2].nb_points.must_equal 39
    chemins[2].nb_cartes.must_equal 6

    chemins[3].visuel.must_equal "[ 5K 6K 7K ] [ 6C 6P J* ] [ 7P 7K 7T ]"
    chemins[3].franche.must_equal true
    chemins[3].nb_points.must_equal 57
    chemins[3].nb_cartes.must_equal 9

    chemins[4].visuel.must_equal "[ 5K 6K 7K ] [ 7P 7K 7T ] [ 6C 6P J* ]"
    chemins[4].franche.must_equal true
    chemins[4].nb_points.must_equal 57
    chemins[4].nb_cartes.must_equal 9

    chemins[5].visuel.must_equal "[ 6K 7K J* ] [ 7P 7K 7T ]"
    chemins[5].franche.must_equal false
    chemins[5].nb_points.must_equal 42
    chemins[5].nb_cartes.must_equal 6

    chemins[6].visuel.must_equal "[ 6C 6P 6K ] [ 5K J* 7K ] [ 7P 7K 7T ]"
    chemins[6].franche.must_equal false
    chemins[6].nb_points.must_equal 57
    chemins[6].nb_cartes.must_equal 9

    chemins[7].visuel.must_equal "[ 6C 6P 6K ] [ 7P 7K 7T ] [ 5K J* 7K ]"
    chemins[7].franche.must_equal false
    chemins[7].nb_points.must_equal 57
    chemins[7].nb_cartes.must_equal 9

    chemins[8].visuel.must_equal "[ 7P 7K 7T ] [ 5K 6K 7K J* ]"
    chemins[8].franche.must_equal false
    chemins[8].nb_points.must_equal 47
    chemins[8].nb_cartes.must_equal 7

    chemins[9].visuel.must_equal "[ 7P 7K 7T ] [ 5K 6K 7K ] [ 6C 6P J* ]"
    chemins[9].franche.must_equal false
    chemins[9].nb_points.must_equal 57
    chemins[9].nb_cartes.must_equal 9

    chemins[10].visuel.must_equal "[ 7P 7K 7T ] [ 6K 7K J* ]"
    chemins[10].franche.must_equal false
    chemins[10].nb_points.must_equal 42
    chemins[10].nb_cartes.must_equal 6

    chemins[11].visuel.must_equal "[ 7P 7K 7T ] [ 6C 6P 6K ] [ 5K J* 7K ]"
    chemins[11].franche.must_equal false
    chemins[11].nb_points.must_equal 57
    chemins[11].nb_cartes.must_equal 9

  end

end
