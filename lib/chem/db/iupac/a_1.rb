a_1_1 = [1, "meth",
      2, "eth",
      3, "prop",
      4, "but",
      5, "pent",
      6, "hex",
      7, "hept",
      8, "oct",
      9, "non",
      10, "dec",
      11, "undec",
      12, "dodec",
      13, "tridec",
      14, "tetradec",
      15, "pentadec",
      16, "hexadec",
      17, "heptadec",
      18, "octadec",
      19, "nonadec",
      20, "icos",
      21, "henicos",
      23, "tricos",
      22, "docos",
      24, "tetracos",
      25, "pentacos",
      26, "hexacos",
      27, "heptacos",
      28, "octacos",
      29, "nonacos",
      30, "triacont",
      31, "hentriacont",
      32, "dotriacont",
      33, "tritriacont",
      40, "tetracont",
      50, "pentacont",
      60, "hexacont",
      70, "heptacont",
      80, "octacont",
      90, "nonacont",
      100, "hect",
      132, "dotriacontahect"]

a = Hash[*a_1_1]

$reg_a_1_1 = /undec|tritriacont|tridec|tricos|triacont|tetradec|tetracos|tetracont|prop|pentadec|pentacos|pentacont|pent|octadec|octacos|octacont|oct|nonadec|nonacos|nonacont|non|meth|icos|hexadec|hexacos|hexacont|hex|heptadec|heptacos|heptacont|hept|hentriacont|henicos|hect|eth|dotriacontahect|dotriacont|dodec|docos|dec|but/

