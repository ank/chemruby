# Gaussian98 parser

module Chem

  module G98

  class Lines
    def initialize lines_array
      @lines = lines_array
      @line_ptr = 0
    end
    def next_line
      @lines[@line_ptr + 1]
    end
    def proceed num = 1
      @line_ptr = @line_ptr + num
      raise if @line_ptr > @lines.length
    end
    def now
      @lines[@line_ptr]
    end
    def eof?
      @lines.length == @line_ptr
    end
  end

  class Link
    attr_accessor :next_link, :jump_link, :stop
    attr_reader :major_number, :minor_number, :parameters, :default_link, :goto
    def initialize major, minor, parameters, goto, gr
      @major_number = major
      @minor_number = minor
      @parameters = parameters
      @goto = goto
      @gaussian_result = gr
    end
    def default_link=(l)
      @default_link = l
      @next_link = l
    end
    def to_s
      sprintf("%2d%02d %2s ", @major_number, @minor_number, @goto.to_s) + parameter_to_s
    end
    def parameter_to_s
      s = ''
      @parameters.each do |key, value|
        s = s + key.to_s + '(' + value.to_s + ') '
      end
      return s
    end
    def process lines
      case (@major_number * 100 + @minor_number)
      when 101 # Initializes program and controls overlaying
        lines.proceed 3
        n_atoms = 0
        @gaussian_result.atoms = atoms = Hash.new
        if lines.next_line.split.length < 2 # Z-Matrix
          @gaussian_result.has_z_matrix_coordinate = true
          var = Hash.new
          atoms_tmp = Array.new
          while /^ \w+/ =~ lines.next_line
            lines.proceed
            atoms_tmp.push lines.now
            n_atoms = n_atoms + 1 if lines.now.split[0] != 'X'
          end
          lines.proceed
          if /Variables:/ =~ lines.now
            lines.proceed
            while /^  \w+/ =~ lines.now
              sp = lines.now.split
              var[sp[0]] = sp[1].to_f
              lines.proceed
            end
          end
          n = 1
          atoms_tmp.each do |atom_line|
            atom = G98Atom.new n_atoms, @gaussian_result
            atom_array = atom_line.split
            atom.element = atom_array[0]
            if atom_array.length >= 2
              if /\d/ !~ atom_array[2]
                length = var[atom_array[2]]
              else
                length = atom_array[2].to_f
              end
              atom.distance(atoms[atom_array[1].to_i], length)
            end
            if atom_array.length >= 4
              if /\d/ !~ atom_array[4]
                angle = var[atom_array[4]]
              else
                angle = atom_array[4].to_f
              end
              atom.angle(atoms[atom_array[3].to_i], angle)
            end
            if atom_array.length >= 7
              if /\d/ !~ atom_array[6]
                angle_a = var[atom_array[6]]
              else
                angle_a = atom_array[6].to_f
              end
              if /\d/ !~ atom_array[7]
                angle_b = var[atom_array[7]]
              else
                angle_b = atom_array[7].to_f
              end
              atom.dihedral(atoms[atom_array[5].to_i], angle_a, angle_b)
            end
            atoms[n] = atom
            n = n + 1
          end
        else # Cartessian Matrix
          @gaussian_result.has_cartessian_coordinate = true
          while /^ \w+/ =~ lines.next_line && / The following ModRedundant/ !~ lines.next_line
            lines.proceed
            atom_array = lines.now.split
            atom = G98Atom.new n_atoms + 1, @gaussian_result
            atom.element, atom.x, atom.y, atom.z = atom_array
            atoms[n_atoms + 1] = atom
            n_atoms = n_atoms + 1 if lines.now.split[0] != 'X'
          end
        end
        @gaussian_result.n_atoms = n_atoms
        @gaussian_result.atoms = atoms
        lines.proceed
        #      @stop = true
      when 103 # Berny optimization to minima and TS, STQN transition state searches
        @next_link = @jump_link if @jump_link
        lines.proceed 2
        while /GradGradGrad/ !~ lines.now
          if(/ Optimization completed./ =~ lines.now)
            #  	if(/ Predicted change in Energy=/ =~ lines.now && / Optimization completed./ =~ lines.next_line)
            @next_link = @default_link
          end
          lines.proceed
        end
        #        lines.proceed 2
        #        lines.proceed while / Predicted change in Energy=/ !~ lines.now
        #        puts lines.now
        #        is_loop = true if / Optimization completed./ =~ lines.now
        #  #        lines.proceed while /^ Predicted change in Energy=/ !~ lines.now
        #  #        lines.proceed
        #  #        is_loop = true if / Optimization completed./ =~ lines.now
        #        lines.proceed while /GradGradGrad/ !~ lines.now
        lines.proceed
      when 105 # MS optimization
      when 106 # Numerical differentiation of forces/dipoles to obtain polarizability/hyperpolarizability
      when 107 # Linear-synchronous-transit (LST) transition state search
      when 108 # Potential energy surface scan
      when 109 # Newton-Raphson optimization
      when 110 # Double numerical differentiation of energies to produce frequencies
      when 111 # Double num. diff. of energies to compute polarizabilities & hyperpolarizabilities
      when 113 # EF optimization using analytic gradients
      when 114 # EF numerical optimization (using only energies)
      when 115 # Follows reaction path using the intrinsic reaction coordinate (IRC)
      when 116 # Numerical self-consistent reaction field (SCRF)
      when 117 # Post-SCF SCRF
      when 118 # Trajectory calculations
      when 120 # Controls ONIOM calculations
      when 202 # Reorients coordinates, calculates symmetry, and checks variable
        # IOp(15) : Symmetry control.
        # 1: Unconditionally turn symmetry off. Note that Symm is still called, and will determine the
        #    framework group. However, the molecule is not oriented.
        while / Stoichiometry/ !~ lines.now && /Error/ !~ lines.now
          lines.proceed
        end
        if /Error/ =~ lines.now
          lines.proceed 6
          return
        end
        @gaussian_result.stoichiometry = lines.now.split[1]
        lines.proceed
        @gaussian_result.symmetricity = lines.now.split[2]
        if /KH/ !~ @gaussian_result.symmetricity
          unless @parameters.has_key?(15) && @parameters[15] == 1
            lines.proceed while /Standard orientation:/ !~ lines.now
            lines.proceed 5
            1.upto @gaussian_result.n_atoms do |num|
              o_array = lines.now.split
              @gaussian_result.atoms[o_array[0].to_i].x = o_array[3].to_f
              @gaussian_result.atoms[o_array[0].to_i].y = o_array[4].to_f
              @gaussian_result.atoms[o_array[0].to_i].z = o_array[5].to_f
              lines.proceed
            end
            lines.proceed
          end
          while(/^ Isotopes:/ !~ lines.now)
            lines.proceed
          end
          while /-$/ =~ lines.now || /,\D+-\d/ =~ lines.next_line
            lines.proceed
          end
          lines.proceed
        else
          lines.proceed 3
        end
      when 301 # Generate basis set information
        @gaussian_result.standard_basis = lines.now.split(':')[1].chop # Standard basis: VSTO-3G (5D, 7F)
        lines.proceed
        if / Basis set in the form of general basis input:/ =~ lines.now # with GFINPUT Keyword (24=10)
          while /^$/ !~ lines.next_line
            lines.proceed #  1 0
          end
          lines.proceed 2#^$
        end
        while / There are/ =~ lines.now
          lines.proceed
        end
        lines.proceed while /\d+ basis functions/ !~ lines.now
        @gaussian_result.n_orbitals = lines.now.split[0].to_i
        lines.proceed
        @gaussian_result.n_electron = lines.now.split[0].to_i
        lines.proceed
        @gaussian_result.nuclear_repulsion_energy = lines.now.split[3].to_f
        lines.proceed
      when 302 # Calculates overlap, kinetic, and potential integrals
        lines.proceed 3 # No discrimination between 302 and 303. More Gaussian results needed!
      when 303 # Calculates multipole integrals
        ;
      when 308 # Computes dipole velocity and RxD integrals
      when 309 # Computes ECP integrals
      when 310 # Computes spdf 2-electron integrals in a primitive fashion
      when 311 # Computes sp 2-electron integrals
      when 314 # Computes spdf 2-electron integrals
      when 316 # Prints 2-electron integrals
      when 319 # Computes 1-electron integrals for approximate spin orbital coupling
      when 401 # Forms the initial MO guess
        @gaussian_result.guess = lines.now.chop if @gaussian_result.guess == nil# Projected INDO Guess.
        lines.proceed
        if / Initial guess orbital symmetries:/ =~ lines.now
          lines.proceed 2
          while /\(A.\)/ =~ lines.now
            lines.proceed
          end
        end
      when 402 # Performs semi-empirical and molecular mechanics calculations
        while / Dipole moment=/ !~ lines.now
          lines.proceed
        end
        lines.now.split[4].to_f# Assertive Programming
        lines.proceed
      when 405 # Initializes an MCSCF calculation
      when 502 # Iteratively solves the SCF equations (conven. UHF & ROHF, all direct methods, SCRF)
        lines.proceed while / SCF Done:/ !~ lines.now
        @gaussian_result.energy = lines.now.split[4].to_f
        lines.proceed
        lines.now.split[5].to_f
        lines.proceed 2
        #      lines.proceed if / Axes restored/ =~ lines.now
        if / Annihilation of the first spin contaminant:/ =~ lines.now
          lines.proceed 2
        end
        if / Final SCRF E-Field is:/ =~ lines.now
          lines.proceed 15
        end
        if /---------/ =~ lines.now && /DeltaG/ =~ lines.next_line
          #      if /---------/ =~ lines.now
          while /DeltaG/ !~ lines.now
            lines.proceed
          end
          @gaussian_result.scrf_delta_g = lines.now.split[4].to_f
          lines.proceed 2
        end
        #        lines.proceed
      when 503 # Iteratively solves the SCF equations using direct minimization
      when 506 # Performs an ROHF or GVB-PP calculation
      when 508 # Quadratically convergent SCF program
      when 510 # MC-SCF
      when 601 # Population and related analyses (including multipole moments)
        #        puts 'l601 : '+ lines.now
        #        lines.proceed
        #        puts 'l601 : '+ lines.now
        #        lines.proceed
        #        puts 'l601 : '+ lines.now
        #        lines.proceed
        #        puts 'l601 : '+ lines.now
        #        lines.proceed 4
        lines.proceed 7
        if / Orbital Symmetries:/ =~ lines.now
          lines.proceed while / electronic state/ !~ lines.now
          lines.proceed
        end
        lines.proceed while / Alpha / =~ lines.now || / Beta / =~ lines.now
        if /     Molecular Orbital Coefficients/ =~ lines.now
          if(@parameters.has_key?(7))# Population = Full
            n = @gaussian_result.n_orbitals / 5.0
            n_orbital_col = n.ceil
          else
            n_orbital_col = 2
          end
          lines.proceed #     Molecular Orbital Coefficients
          last_occupy_or_virtual = ''
          1.upto(n_orbital_col) do |cycle|
            lines.proceed #                           1         2         3         4         5
            mo_array = lines.now.split
            0.upto( mo_array.length - 1 ) do |n_mo|
              /\((.+)\)/ =~ mo_array[n_mo] ; sym = $+
              /\)--(.)/ =~ mo_array[n_mo]
              occupy_or_virtual = ($+ != nil ? $+ : mo_array[n_mo])
              @gaussian_result.mo[(cycle - 1) * 5 + n_mo] =
                MolecularOrbital.new(((cycle - 1) * 5 + n_mo), sym, occupy_or_virtual)
              if last_occupy_or_virtual == 'O' && occupy_or_virtual == 'V'
                @gaussian_result.homo = @gaussian_result.mo[(cycle - 1) * 5 + n_mo - 1]
                @gaussian_result.lumo = @gaussian_result.mo[(cycle - 1) * 5 + n_mo]
              elsif(@gaussian_result.homo == nil && n_orbital_col == cycle && mo_array.length - 1 == n_mo)
                # No LUMO ! Example Br-
                @gaussian_result.homo = @gaussian_result.mo[(cycle - 1) * 5 + n_mo - 1]
                @gaussian_result.lumo = nil
              end
              last_occupy_or_virtual = occupy_or_virtual
            end
            lines.proceed
            ev_array = lines.now.split
            0.upto (ev_array.length - 3) do |n_ev|
              @gaussian_result.mo[(cycle - 1) * 5 + n_ev].eigen_value = ev_array[n_ev + 2].to_f
            end
            lines.proceed
            1.upto(@gaussian_result.n_orbitals) do | num |
              coef_array = [lines.now[0..3].strip, lines.now[5..8].strip, lines.now[9..10].strip,
                lines.now[11..21].strip]
              0.upto (mo_array.length - 1) do |n_mo|
                coef_array << lines.now[(21 + n_mo*10)..(31 + n_mo*10)]
              end
              plus = 0
              #  	    if /^[[:alpha:]]+/ =~ coef_array[2]
              if coef_array[1] != ''
                atom = @gaussian_result.atoms[coef_array[1].to_i]
              end
              1.upto( mo_array.length ) do |n_ao|
                atom.ao(coef_array[3]).push(coef_array[n_ao + 2].to_i)
                @gaussian_result.mo[(cycle - 1) * 5 + n_ao - 1].push([atom.index, coef_array[3]], coef_array[3 + n_ao].to_f)
                #  	      @gaussian_result.mo[(cycle - 1) * 5 + n_ao].push(coef_array[n_ao + plus + 2].to_f)
              end
              lines.proceed
            end
          end
          lines.proceed #      DENSITY MATRIX.
          density_time = @gaussian_result.n_orbitals
          while(density_time >0)
            lines.proceed #                           1         2         3         4         5
            lines.proceed density_time
            density_time = density_time - 5
          end
          lines.proceed #    Full Mulliken population analysis:
          mulliken_time = @gaussian_result.n_orbitals
          while(mulliken_time > 0)
            lines.proceed #                           1         2         3         4         5
            lines.proceed mulliken_time
            mulliken_time = mulliken_time - 5
          end
          lines.proceed #     Gross orbital populations:
          1.upto(@gaussian_result.n_orbitals) do |num|
            lines.proceed
          end
          lines.proceed #          Condensed to atoms (all electrons):
        end
        n = (@gaussian_result.n_atoms) / 6.0
        if /Condensed to / =~ lines.now
          lines.proceed
          if /              1/ =~ lines.now # BUG of Gaussian98 !?
            1.upto(n.ceil) do |num|
              @gaussian_result.exist_condensed_to_atom = true
              lines.proceed
              1.upto(@gaussian_result.n_atoms) do |nn|
                array = lines.now.split
                1.upto(array.length - 2) do |col|
                  @gaussian_result.atoms[array[0].to_i].density[(num - 1)* 6 + col] = array[col + 1].to_f
                end
                lines.proceed
              end
            end
          end
        end
        lines.proceed 2
        1.upto(@gaussian_result.n_atoms) do | num |
          @gaussian_result.atoms[lines.now.split[0].to_i].total_atomic_charge = lines.now.split[2].to_f
          lines.proceed
        end
        @gaussian_result.sum_of_mulliken_charge = lines.now.split[4].to_f
        lines.proceed
        lines.proceed # Atomic charges with hydrogens summed into heavy atoms:
        lines.proceed #              1
        1.upto(@gaussian_result.n_atoms) do |num|
          @gaussian_result.atoms[lines.now.split[0].to_i].heavy_charge = lines.now.split[2].to_f
          lines.proceed
        end
        lines.proceed
        if /Atomic-Atomic Spin Densities./ =~ lines.now
          lines.proceed
          n = @gaussian_result.n_atoms / 6.0
          1.upto n.ceil do |num|
            lines.proceed @gaussian_result.n_atoms
          end
          lines.proceed
          lines.proceed # Total atomic spin densities:
          lines.proceed #              1
          lines.proceed @gaussian_result.n_atoms
          lines.proceed
          if /Isotropic Fermi / =~ lines.now
            lines.proceed
            1.upto(@gaussian_result.n_atoms) do |num|
              lines.proceed
            end
          end
          lines.proceed
        end
        #        if(@parameters.has_key?(7) && (@parameters[7] == 3 || @parameters[7] == 2))
        if/ Electronic spatial extent/ =~ lines.now
          #      if(@parameters.has_key?(28))
          @gaussian_result.electronic_spatial_extent = lines.now.split[5].to_f
          lines.proceed 3
          @gaussian_result.dipole_moment_total = lines.now.split[7].to_f
          lines.proceed while / N-N=/ !~ lines.now
          lines.proceed
          if / Symmetry/ =~ lines.now
            lines.proceed while / Symmetry/ =~ lines.now
          end
        end
        if /Exact polarizability/ =~ lines.now
          lines.now.split[7].to_f #Assertive programming ;)
          lines.proceed while /Thermochemistry/ != lines.now
          lines.proceed while / TOTAL BOT/ !~ lines.now
          lines.proceed while / ROTATIONAL/ !~ lines.now
          lines.proceed
        end
        #      @stop = true
      when 602 # 1-electron properties (potential, field, and field gradient)
      when 604 # Evaluates MOs or density over a grid of points
        lines.proceed while / LenV=/ !~ lines.now
      when 607 # Performs NBO analyses
      when 608 # Non-iterative DFT energies
      when 609 # Atoms in Molecules properties
      when 701 # 1-electron integral first or second derivatives
        lines.proceed if /solvent charges in/ =~ lines.now
      when 702 # 2-electron integral first or second derivatives (sp)
        lines.proceed if /Density matrix is not symmetric/ =~ lines.now
      when 703 # 2-electron integral first or second derivatives (spdf)
      when 709 # Forms the ECP integral derivative contribution to gradients
      when 716 # Processes information for optimizations and frequencies
        # ***** Axes restored to original set *****
        lines.proceed if /Axes restored/ =~ lines.now
        if /Rotating electric field/ =~ lines.now
          lines.proceed while /Axes restored/ !~ lines.now
          lines.proceed
        end
        lines.proceed # -------------------------------------------------------------------
        lines.proceed # Center     Atomic                   Forces (Hartrees/Bohr)
        lines.proceed # Number     Number              X              Y              Z
        lines.proceed # -------------------------------------------------------------------
        1.upto(@gaussian_result.n_atoms) do |num|
          lines.now.split[4].to_f #Assertive Programming ;)
          lines.proceed
        end
        lines.proceed # -------------------------------------------------------------------
        lines.proceed # Cartesian Forces:  Max     2.919256220 RMS     1.058248881
      when 801 # Initializes transformation of 2-electron integrals
        lines.proceed 2
      when 802 # Performs integral transformation (N3 in-core)
      when 803 # Complete basis set (CBS) extrapolation
      when 804 # Integral transformation
        #        if /^$/ =~ lines.now
        #  	lines.proceed 3 # **** Warning!!: The largest alpha MO coefficient is  0.39613240D+02
        #        else
        #  	lines.proceed # Estimate disk for full transformation     8758468 words.
        #        end
        while !(/ANorm/ =~ lines.now && /^ E2=/ =~ lines.next_line)
          lines.proceed
        end
        lines.proceed 2
      when 811 # Transforms integral derivatives & computes their contributions to MP2 2nd derivatives
        lines.proceed # Form MO integral derivatives with frozen-active canonical formalism.
        lines.proceed # MDV=     6291456.
        lines.proceed # Discarding MO integrals.
        lines.proceed #             Reordered first order wavefunction length =       176418
        lines.proceed if /In DefCFB/ =~ lines.now
        lines.proceed if /Large arrays: / =~ lines.now
      when 901 # Anti-symmetrizes 2-electron integrals
      when 902 # Determines the stability of the Hartree-Fock wavefunction
      when 903 # Old in-core MP2
      when 905 # Complex MP2
      when 906 # Semi-direct MP2
        #      puts 'l906 : ' + lines.now
        #      lines.proceed 12
        lines.proceed while / E2 =/ !~ lines.now
        lines.proceed
      when 908 # OVGF (closed shell)
      when 909 # OVGF (open shell)
      when 913 # Calculates post-SCF energies and gradient terms
        while /^ QCISD\(T\)=/ !~ lines.now
          lines.proceed
        end
        lines.proceed 1
      when 914 # CI-Single, RPA and Zindo excited states; SCF stability
        lines.proceed while /       state/ !~ lines.now
        lines.proceed
        n_state = 0
        while / Ground to excited state/ !~ lines.now
          n_state = n_state + 1
          lines.proceed
        end
        while / Excitation energies and oscillator strengths:/ !~ lines.now
          lines.proceed
        end
        1.upto n_state do |num|
          lines.proceed while / Excited State / !~ lines.now
          lines.proceed
          lines.proceed while /\d+ ->/ =~ lines.now
        end
      when 915 # Computes fifth order quantities (for MP5, QCISD (TQ) and BD (TQ))
      when 918 # Reoptimizes the wavefunction
      when 1002 # Iteratively solves the CPHF equations; computes various properteis
        #      lines.proceed while /degrees of freedom in the / !~ lines.now
        #        lines.proceed # Petite list used in FoFDir.
        #        lines.proceed #MinBra= 0 MaxBra= 2 Meth= 1.
        #        lines.proceed #IRaf=       0 NMat=   1 IRICut=       1 DoRegI=T DoRafI=F ISym2E= 1 JSym2E=1.
        #        lines.proceed while /vectors were produced by pass/ =~ lines.now
        while /Inverted reduced A of dimension/ !~ lines.now
          lines.proceed
        end
        lines.proceed
        if / Calculating GIAO nuclear magnetic shielding tensors./ =~ lines.now
          1.upto @gaussian_result.n_atoms do |num|
            lines.proceed while /Eigenvalues:/ !~ lines.now
            lines.proceed
          end
        end
        #  	while /^$/ !~ lines.now
        #  	  lines.proceed
        #  	end
        #        end
        #        lines.proceed
      when 1003 # Iteratively solves the CP-MCSCF equations
      when 1014 # Computes analytic CI-Single second derivatives
      when 1101 # Computes 1-electron integral derivatives
      when 1102 # Computes dipole derivative integrals
      when 1110 # 2-electron integral derivative condition to F
        lines.proceed if /G2DrvN: will do/ =~ lines.now
        lines.proceed if /FoFDir used for/ =~ lines.now
      when 1111 # 2 PDM and post-SCF derivatives
      when 1112 # MP2 second derivatives
        lines.proceed if /R2 and R3 integrals will be/ =~ lines.now
        lines.proceed while / Incrementing Polarizabilities/ !~ lines.now
        lines.proceed 2
      when 9999 # Finalizes calculation and output
        while !lines.eof?
          if / Normal termination/ =~ lines.now
            #	  puts ' ****** Normal termination ****** '
          end
          lines.proceed
        end
	@stop = true
      else
        puts 'Not implemented Link Number!!'
        printf " major : %d   minor : %d\n", @major_number, @minor_number,to_s
      end
    rescue
      puts 'exception at ' + (@major_number * 100 + @minor_number).to_s
      raise
    end
  end

  class MolecularOrbital
    attr_accessor :eigen_value, :index
    def initialize index, sym, occupy_or_virtual
      @index = index
      @sym = sym
      @occupy_or_virtual = occupy_or_virtual
      @coefficient = Hash.new
    end
    def each_ao
      @coefficient.each do |key, ao|
        yield key, ao
      end
    end
    def push ao, coef
      @coefficient[ao] = coef
      #    puts index.to_s + ' : ' + @sym.to_s + ':' + ' : ' + @occupy_or_virtual + ':' + ao + ' : ' +coef.to_s + ' '
    end
    def to_s
      s = sprintf(" %3d %s %s", @index, @sym, @occupy_or_virtual)
      if @coefficient.length < 1
        puts '@coefficient == 0!'
      end
      @coefficient.each do |key, coef|
        s = s + sprintf(" %1.1f", coef)
      end
      s
    end
  end

  class AtomicOrbital
    def initialize type
      @type = type
      @coefficient = Array.new
    end
    def push coef
      @coefficient.push coef
    end
    def to_s
      s = sprintf("%5s ", @type)
      @coefficient.each do |coef|
        s = s + sprintf("%2.2f ", coef)
      end
      return s
    end
  end

  class G98Atom

    #include Atom

    attr_accessor :element, :density,
    :distance_atom, :distance_length, :angle_atom, :angle, :dihedral_angle_atom, :diheral_angle_a, :dihedral_angle_b,
    :x, :y, :z, :total_atomic_charge, :heavy_charge
    attr_reader :index
    VALENCY = {'C'=>4, 'N'=>3, 'H'=>1, 'F'=>1, 'CL'=>1, 'I'=>1, 'O'=>2, 'BR'=>1}
    VALENCY2 = {'C'=>2, 'H'=>-1, 'O'=>0, 'F'=>-1, 'CL'=>-1, 'BR'=>-1}
    WEIGHT = {'O'=>15.9999, 'BR'=>79.904, 'H'=>1.00794, 'C'=>12.001, 'F'=>18.9984032, 'CL'=>35.4527, 'N'=>14.00674}
    def initialize index, molecule
      @index = index
      @molecule = molecule
      @density = Hash.new
      @orbital = Hash.new
    end
    def get_distance atom
      Math.sqrt((@x - atom.x)*(@x - atom.x) + (@y - atom.y)*(@y - atom.y) + (@z - atom.z)*(@z - atom.z))
    end
    def neighbor? atom, length
      return (get_distance(atom) < length)
    end
    def element= el
      @element = el.upcase
    end
    def weight
      puts('@element : ' + @element + 'is not defined weight!!') if WEIGHT[@element] == nil
      return WEIGHT[@element]
    end
    def valency
      puts('@element : ' + @element + 'is not defined valency!!') if VALENCY[@element] == nil
      VALENCY[@element]
    end
    def valency2
      puts('@element : ' + @element + 'is not defined valency2!!') if VALENCY2[@element] == nil
      VALENCY2[@element]
    end
    def each_ao
      @orbital.each_value do |atomic_orbital|
        yield atomic_orbital
      end
    end
    def ao hash
      if @orbital[hash] == nil
        return @orbital[hash] = AtomicOrbital.new(hash)
      else
        return @orbital[hash]
      end
    end
    def distance atom, length
      @distance_atom = atom
      @distance_length = length
    end
    def angle atom, angle
      @angle_atom = atom
      @angle = angle
    end
    def dihedral atom, angle_a, angle_b
      @dihedral_atom = atom
      @dihedral_angle_a = angle_a
      @dihedral_angle_b = angle_b
    end
    def to_s
      if @molecule.has_cartessian_coordinate
        return to_cartessian_coodinate
      elsif @molecule.has_z_matrix
        return to_z_matrix
      end
    end
    def to_condensed_density
      s = sprintf("%2s  ", @element)
      1.upto @molecule.atoms.length do |num|
        s = s + sprintf("% f  ", @density[num].to_s)
      end
      return s
    end
    def to_cartessian_coodinate
      sprintf(" %2s  % f  % f  % f", @element, @x, @y, @z)
    end
    def to_mol
      sprintf("%10.4f%10.4f%10.4f %-2s  0  0  0  0  0", @x, @y, @z, @element)
    end
    def to_xyz
      sprintf("%2s% 8.3f% 8.3f% 8.3f\n", @element, @x, @y, @z)
    end
    def to_z_matrix
      s = sprintf("%d  %s ", @molecule.atoms.index(self), @element)
      if @distance_atom != nil
        s = s + sprintf("%2d  %f  ", @molecule.atoms.index(@distance_atom), @distance_length)
      end
      if @angle_atom != nil
        s = s + sprintf("%2d  %f  ", @molecule.atoms.index(@angle_atom), @angle)
      end
      if @dihedral_atom != nil
        s = s + sprintf("%2d  %f  %f", @molecule.atoms.index(@dihedral_atom), @dihedral_angle_a, @dihedral_angle_b)
      end
      return s
    end
  end

  class GaussianResult
    attr_accessor :guess, :standard_basis, :energy, :n_orbitals, :n_electron, :nuclear_repulsion_energy, :n_atoms,
    :sum_of_mulliken_charge, :electronic_spatial_extent, :scrf_delta_g, :dipole_moment_total, :atoms,
    :has_cartessian_coordinate, :has_z_matrix_coordinate, :exist_condensed_to_atom, :mo, :homo, :lumo,
    :stoichiometry, :symmetricity
    def initialize input, view=false
      @mo = Hash.new
      @has_cartessian_coordinate = false
      @has_z_matrix_coordinate = false
      @input = input
      read_link
      lines = Lines.new input.readlines
      link = @links[0].first
      puts_links if view
      while ! lines.eof?
        link.process lines
        break if link.stop
        link = link.next_link
      end
      #      link.process lines
    end
    def weight
      total_weight = 0
      @atoms.each do |key, atom|
        total_weight = total_weight + atom.weight
      end
      total_weight
    end
    def moment
      total_moment_x = 0
      total_moment_y = 0
      total_moment_z = 0
      @atoms.each do |key, atom|
        total_moment_x = total_moment_x + atom.weight * atom.x * atom.x
        total_moment_y = total_moment_y + atom.weight * atom.y * atom.y
        total_moment_z = total_moment_z + atom.weight * atom.z * atom.z
      end
      return total_moment_x * total_moment_y * total_moment_z
    end
    def entropy_trans temperature
      return 76.57 + 12.47 * Math.log10(weight) + 20.79 * Math.log10(temperature)
    end
    def entropy_rotate temperature, sigma
      return 877.37 + 8.3144 * (Math.log10(moment) + Math.log10(temperature) - Math.log10(sigma))
    end
    def entropy temperature
      return entropy_trans(temperature)
    end
    def valency
      total_valency = 0
      @atoms.each do |key, atom|
        total_valency = total_valency + atom.valency
      end
      total_valency
    end
    def valency2
      total_valency2 = 0
      @atoms.each do |key, atom|
        total_valency2 = total_valency2 + atom.valency2
      end
      total_valency2 / 2 + 1
    end
    def near one, distance
      @atoms.each do |key, another|
        puts '.'
        puts ((another.x - one.x) * (another.x - one.x) +
                (another.y - one.y) * (another.y - one.y) +
                (another.z + one.z) * (another.z - one.z)).to_s
        if ((another.x - one.x) * (another.x - one.x) +
              (another.y - one.y) * (another.y - one.y) +
              (another.z + one.z) * (another.z - one.z)) < distance * distance
          yield another
        end
      end
    end
    def to_xyz
      s = @atoms.length.to_s + "\n"
      s = s + "*\n"
      @atoms.each do |key, atom|
        s = s + sprintf("%2s% 8.3f% 8.3f% 8.3f\n", atom.element, atom.x, atom.y, atom.z)
      end
      s
    end
    def process_link_line line, last_link
      /\// =~ line
      major_no =  $`.to_i
      /\// =~ $'
      parameters = Hash.new
      minor_no = $'.chop.chop.split ','
      $`.split(',').each do |p|
        /=/ =~ p
        parameters[$`.to_i] = $'.to_i
      end
      goto = 0
      if /\((-?\d+)/ =~ minor_no.last
        minor_no[-1] = $`
        goto = $+.to_i
      end
      stop = false
      major_links = Array.new
      minor_no.each do |minor|
        link = Link.new(major_no, minor.to_i, parameters, goto, self)# if(major_no == 1 && minor == '1')
        major_links.push link
      end
      major_links
    end
    def read_link
      @links = Array.new
      while(/[*]{10}/ !~ @input.readline)
        ;
      end
      while(/[*]{10}/ !~ @input.readline)
        ;
      end
      while /[%]/ =~ @input.readline
        ;
      end
      @input.readline if / Will use up to/ =~ $_
      @input.readline# # RHF/6-31G(d) Pop=Full Test
      @input.readline# ----------------------------
      while(/(--+)|( Leave Link)/ !~ @input.readline)
        if /^$/ =~ $_
          @input.readline
          @input.readline
          @input.readline
          @input.readline
        end
        if(@links.last != nil)
          last = @links.last.last
        else
          last = nil
        end
        link =  process_link_line $_, last
        @links.push link
        #        puts link
      end
      last_link = nil
      @links.each do |link|
        link.each do |minor_link|
          if (last_link != nil)
            last_link.default_link = minor_link
            if minor_link.goto > 0
              minor_link.jump_link = @links[@links.index(link) + minor_link.goto + 1].first
            elsif minor_link.goto < 0
              minor_link.jump_link = @links[@links.index(link) + minor_link.goto].first
            end
          end
          last_link = minor_link
        end
      end
    end
    def include? major, minor, parameter
      @links.each do | link |
        link.each do |minor_link|
          if parameter
            if(minor_link.major_number == major &&
                 minor_link.minor_number == minor &&
                 minor_link.parameters.has_key?(parameter))
              return true
            end
          else
            if(minor_link.major_number == major && minor_link.minor_number == minor)
              return true
            end
          end
        end
      end
      false
    end
    def puts_links
      @links.each do | link |
        puts link
      end
    end
  end

  if __FILE__ == $0
    gr = GaussianResult.new(File.open(ARGV.shift), false)
    puts gr.entropy 256
    valency = 0
    puts 'entropy : ' + gr.entropy(276).to_s
    puts 'eigen_value : ' + gr.homo.eigen_value.to_s
    gr.atoms.keys.sort.each do |atom_num|
      #    puts gr.atoms[atom_num].to_condensed_density
      #      gr.atoms[atom_num].each_ao do |ao|
      #        puts ao
      #      end
    end
    puts '--------------- Print Out Molecular Orbitals---------------'
    #    gr.mo.keys.sort.each do |mo_key|
    #      puts gr.mo[mo_key].to_s
    #    end
    #    puts gr.homo
    #    puts gr.lumo
    #  printf "energy : %f\n", gr.energy
    #  puts gr.valency
    #  puts gr.valency2
    File.open("test.xyz", "w").puts gr.to_xyz
  end
  end # end of G98 module
end
