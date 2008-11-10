
module Graph
  def morgan
    ec = {}  # extended connectivity
    tec = {} # trial extended connectivity

    @nodes.each{ |a| tec[a] = 1 }

    k = 0
    k2 = k + 1

    while k2 > k
      k = k2
      @nodes.each{ |a| ec[a] = tec[a] }

      @nodes.each do |a|
        tec[a] = adjacent_to(a).inject(0){|ret, (b, n)| ret + ec[n]}
      end
      k2 = @nodes.collect{|a| tec[a]}.uniq.length
    end

    #      calc morgan tree
    max = @nodes.max{|a, b| tec[a] <=> tec[b]}

    queue = [ max ]
    traversed = [ max ]

    while from = queue.shift
      adjacent_to(from).sort{|(b1, n), (b2, m)| tec[m] <=> tec[n]}.each do |bond, atom|
        unless traversed.include?(atom)
          queue.push(atom)
          traversed.push(atom)
        end
      end
    end
    [ec, tec, traversed]
  end
end
