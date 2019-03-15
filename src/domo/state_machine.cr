# enum H2O
#   Ice
#   Water
#   Vapor
# end
# machine = Domo::StateMachine(H2O).new(H2O::Water)
# machine.add_valid(H2O::Ice, H2O::Water)
# machine.add_valid(H2O::Water, H2O::Ice)
# machine.add_valid(H2O::Water, H2O::Vapor)
# machine.add_valid(H2O::Vapor, H2O::Water)
# machine.next(H2O::Ice)
# machine.next(H2O::Vapor) # raises

class Domo::StateMachine(T)
  getter initial_state
  getter current_state

  @valid_changes = Hash(T, Set(T)).new

  def initialize(@initial_state : T)
    @current_state = @initial_state
  end

  def add_valid(from_state : T, to_state : T)
    puts "adding #{from_state} -> #{to_state}"
    valid_to = @valid_changes[from_state]? || Set(T).new
    valid_to << to_state
    @valid_changes[from_state] = valid_to
  end

  def next(next_state : T, error = "Invalid State Change: #{@current_state} -> #{next_state}")
    raise error unless @valid_changes[@current_state].includes?(next_state)
    @current_state = next_state
  end
end
