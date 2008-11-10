
class String

  def is_valid_casrn?
    ary = self.split("-")
    return false if not ary.length == 3

    first_digits = ary[0].scan(/\d/)
    return false if not first_digits.length == ary[0].length

    second_digits = ary[1].scan(/\d/)
    return false if not second_digits.length == ary[1].length
    return false if not second_digits.length == 2

    return false if not ary[2].length == 1
    return false if /\d/.match(ary[2]).nil?
    third_digits = ary[2].to_i

    total = 0
    (second_digits.reverse + first_digits.reverse).each_with_index do |digit, idx|
      total += digit.to_i * (idx + 1)
    end
    return false if not (total % 10) == third_digits
    true
  end

end

