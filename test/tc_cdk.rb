class CDKTest < Test::Unit::TestCase

  def test_load_cdk_save_ob
    mol  = Chem::CDK::parse_smiles("C1CCC=N1")
    mol2 = mol.cdk_generate_2D
    mol2.use_open_babel
    mol2.ob_save_as("temp/cdk2ob.mol", "mdl")
  end

  def t#est_random_generator
    mol1 = Chem::CDK::parse_smiles("C1CCC=N1").cdk_generate_2D_mol
    mol1.cdk_save_as("temp/original.png")
    mol2 = mol1.cdk_generate_randomly.cdk_generate
    mol2.cdk_save_as("temp/random.png")
  end

  def test_load_mdl
    mol = Chem::CDK::parse_mdl(File.open($data_dir + "troglitazone.mol").read)
#    mol.cdk_save_as("temp/troglitazone.png")
  end

  def test_load_cr_save_structure
    troglitazone = Chem.load($data_dir + "troglitazone.mol")
    mol = troglitazone.cdk_generate_2D
#    mol.cdk_save_as("temp/troglitazone.png")
  end

  def test_common_subgraphs
    troglitazone = Chem.load($data_dir + "troglitazone.mol")
    pioglitazone = Chem.load($data_dir + "pioglitazone.mol")
    
    troglitazone.cdk_mcs(pioglitazone).each_with_index do |mcs, i|
      hash = mcs.match(troglitazone)[0]
      hash.each do |from, to|
        to.visible   = true
        to.color   = [1, 0, 0]
      end
      troglitazone.save("temp/#{i}.pdf")
      troglitazone.nodes.each{|atom| atom.color = [0, 0, 0]}
      # RuntimeError: Fail: unknown method name `setMolecule'
#      mol = mcs.cdk_generate_2D # ??
#      mcs.cdk_save_as("temp/mcs-#{i}.png")
#      mcs.save("temp.pdf")
    end
  end

  def test_wiener
  end

  def get_sample
    Chem.load($data_dir + "troglitazone.mol")
  end

  def test_CPSA
    t = get_sample
    t.cdk_CPSA.all?{|n| assert(n.kind_of?(Numeric))}
  end

  def test_RotatableBondsCount
    t = get_sample
    p t.cdk_RotatableBondsCount
  end

  def test_load
#    Chem::CDK::load($data_dir + "troglitgazone")
  end

  def test_find_all_rings
    t = get_sample
#    p t.cdk_find_all_rings
  end

  def test_sssr
    t = get_sample
    require 'pp'
    t.cdk_sssr.each do |ring|
      p ring.length
    end
  end

  def test_all_rings
    t = get_sample
    require 'pp'
    t.cdk_find_all_rings.each do |ring|
      p ring.length
    end
  end

end
