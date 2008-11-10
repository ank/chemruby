require 'chem'

mol = Chem::OpenBabel::parse_smiles('CC(C)CCCC(C)C1CCC2C1(CCC3C2CC=C4C3(CCC(C4)O)C)C')
pat = Chem::OpenBabel::parse_smarts('Cc1ccc(C)cc1')

pat.match(mol)
ary = pat.get_umap_list

p ary

